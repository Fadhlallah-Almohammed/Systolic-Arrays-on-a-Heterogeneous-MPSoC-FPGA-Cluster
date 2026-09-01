"""
Lab 5 — Mali-400 GEMM via Python + Headless EGL + GLES2 (ctypes)
==================================================================
Drives libEGL.so and libGLESv2.so directly from Python using ctypes.
No PyOpenGL required — works on any ARM Linux Mali rootfs.

Headless rendering uses GBM (Generic Buffer Manager) to obtain an EGL
platform display and a GBM-backed window surface.

"""

from __future__ import annotations
import os
import ctypes
import ctypes.util
import struct
import time
import numpy as np

# ---------------------------------------------------------------------------
# 1. Configuration
# ---------------------------------------------------------------------------
# N overridable via MATMUL_N=<n> — useful to bisect whether a crash is a
# shader-complexity/instruction-count ceiling (Mali-400/Utgard's fragment
# instruction memory is tiny; a fully-unrolled N=64 loop with 128 texture
# fetches may simply exceed it) without editing this file.
N     = int(os.environ.get("MATMUL_N", "64"))   # Matrix dimension
TILE  = 16      # Not used by GPU — kept for comparison with HLS core
SCALE = 200.0   # Value packing scale: stored_u8 = clamp(val * SCALE, 0, 255)
                # Matrices must have values in [0, 255/SCALE) = [0, 1.275)

# PASS/FAIL tolerance: the GPU result is packed into a single 8-bit output
# channel covering the range [0, N] (see FRAG_SRC), so its quantization step
# is N/255 — roughly 0.25 for N=64. Two output-LSBs of margin (rounding in
# both the encode and decode direction, plus input SCALE quantization noise)
# comfortably covers the single-pass algorithm's observed error (~0.4 max on
# N=64, seed 42, measured on real Mali-400 hardware).
VERIFY_TOL = max(0.05, 2.0 * N / 255.0)


def verify_tolerance(num_passes: int) -> float:
    """Tolerance for a result built from `num_passes` additive-blending draws.

    Each blend pass quantizes the running sum to the framebuffer's 8-bit
    channel before the next pass adds to it (unlike the single-pass
    algorithm, which keeps the full accumulation in shader-register
    precision and quantizes only once) — so multi-pass block/streaming
    results carry roughly one extra N/255 rounding step per additional pass,
    on top of the single-pass baseline. Measured on real hardware: 2 passes
    -> ~0.62 max error, 4 passes -> ~0.98 max error, both comfortably under
    this formula's bound.
    """
    return VERIFY_TOL + (num_passes - 1) * (N / 255.0)

# Algorithm #3 (block/tiled): K-dimension blocked into passes accumulated via
# additive blending, sampling the SAME full-resident A/B textures each pass —
# models a cache/BRAM-tiled reduction with no extra data movement.
BLOCK_SIZE  = min(32, N)
if N % BLOCK_SIZE:
    BLOCK_SIZE = N   # fall back to a single block for MATMUL_N overrides that don't divide 32

# Algorithm #5 (streaming/partitioned): K-dimension split into smaller tiles,
# each pass re-uploads only that tile's A-column-strip/B-row-strip as fresh
# textures before accumulating — models an AXI-Stream/DMA-fed pipeline where
# only tile_size*N elements of each operand are resident on-chip at once.
STREAM_TILE = min(16, N)
if N % STREAM_TILE:
    STREAM_TILE = N  # fall back to a single tile for MATMUL_N overrides that don't divide 16

# ---------------------------------------------------------------------------
# 2. Load shared libraries
# ---------------------------------------------------------------------------
def _load_lib(names):
    for name in names:
        try:
            return ctypes.CDLL(name, use_errno=True)
        except OSError:
            continue
    raise OSError(f"Could not load any of: {names}")

_libegl  = _load_lib(["libEGL.so.1", "libEGL.so",
                       "/usr/lib/aarch64-linux-gnu/libEGL.so.1"])
_libgles = _load_lib(["libGLESv2.so.2", "libGLESv2.so",
                       "/usr/lib/aarch64-linux-gnu/libGLESv2.so.2"])
_libgbm  = _load_lib(["libgbm.so.1", "libgbm.so",
                       "/usr/lib/aarch64-linux-gnu/libgbm.so.1"])

# EGL types
EGLDisplay = ctypes.c_void_p
EGLSurface = ctypes.c_void_p
EGLContext = ctypes.c_void_p
EGLConfig  = ctypes.c_void_p
EGLint     = ctypes.c_int32
EGLenum    = ctypes.c_uint32
EGLBoolean = ctypes.c_uint32

EGL_DEFAULT_DISPLAY = ctypes.c_void_p(0)
EGL_NO_DISPLAY      = ctypes.c_void_p(0)
EGL_NO_CONTEXT      = ctypes.c_void_p(0)
EGL_NO_SURFACE      = ctypes.c_void_p(0)

EGL_SURFACE_TYPE         = 0x3033
EGL_PBUFFER_BIT          = 0x0001
EGL_WINDOW_BIT           = 0x0004
EGL_RENDERABLE_TYPE      = 0x3040
EGL_OPENGL_ES2_BIT       = 0x0004
EGL_RED_SIZE             = 0x3024
EGL_GREEN_SIZE           = 0x3023
EGL_BLUE_SIZE            = 0x3022
EGL_ALPHA_SIZE           = 0x3021
EGL_NATIVE_VISUAL_ID     = 0x302E
EGL_NONE                 = 0x3038
EGL_WIDTH                = 0x3057
EGL_HEIGHT               = 0x3056
EGL_CONTEXT_CLIENT_VERSION = 0x3098
EGL_OPENGL_ES_API        = 0x30A0
EGL_PLATFORM_GBM_KHR     = 0x31D7

# GBM constants
GBM_FORMAT_XRGB8888  = ord('X') | ord('R') << 8 | ord('2') << 16 | ord('4') << 24
GBM_BO_USE_RENDERING = 1 << 2

# Pointer-returning functions default to a 32-bit `int` restype in ctypes,
# which truncates real 64-bit handles on aarch64 — must be declared explicitly.
_libegl.eglGetDisplay.restype             = ctypes.c_void_p
_libegl.eglCreateContext.restype          = ctypes.c_void_p
_libegl.eglCreatePbufferSurface.restype   = ctypes.c_void_p
_libegl.eglCreateWindowSurface.restype    = ctypes.c_void_p
_libgbm.gbm_create_device.restype          = ctypes.c_void_p
_libgbm.gbm_create_device.argtypes         = [ctypes.c_int]
_libgbm.gbm_surface_create.restype         = ctypes.c_void_p
_libgbm.gbm_surface_create.argtypes        = [ctypes.c_void_p, ctypes.c_uint32,
                                               ctypes.c_uint32, ctypes.c_uint32,
                                               ctypes.c_uint32]
try:
    _libegl.eglGetPlatformDisplayEXT.restype   = ctypes.c_void_p
    _libegl.eglGetPlatformDisplayEXT.argtypes  = [ctypes.c_int, ctypes.c_void_p,
                                                   ctypes.POINTER(ctypes.c_int)]
except AttributeError:
    pass
_libgles.glGetString.restype = ctypes.c_void_p

# Explicit signatures for every GLESv2 entry point this script calls. On the
# aarch64/lima Mesa stack, calling these with ctypes' default argument-type
# guessing (bare Python ints/pointers, no argtypes) corrupts the stack for
# functions with pointer-out parameters and reliably SIGSEGVs — every call
# needs its real C prototype declared, matching the defensive approach
# already used by mali_cpu_benchmark.py's load_graphics_libs().
_c_uint_p = ctypes.POINTER(ctypes.c_uint)
_c_int_p  = ctypes.POINTER(ctypes.c_int)

_libgles.glGetString.argtypes               = [ctypes.c_uint]
_libgles.glCreateShader.argtypes            = [ctypes.c_uint]
_libgles.glCreateShader.restype             = ctypes.c_uint
_libgles.glShaderSource.argtypes            = [ctypes.c_uint, ctypes.c_int,
                                                ctypes.POINTER(ctypes.c_char_p), _c_int_p]
_libgles.glCompileShader.argtypes           = [ctypes.c_uint]
_libgles.glGetShaderiv.argtypes             = [ctypes.c_uint, ctypes.c_uint, _c_int_p]
_libgles.glGetShaderInfoLog.argtypes        = [ctypes.c_uint, ctypes.c_int, _c_int_p, ctypes.c_char_p]
_libgles.glCreateProgram.argtypes           = []
_libgles.glCreateProgram.restype            = ctypes.c_uint
_libgles.glAttachShader.argtypes            = [ctypes.c_uint, ctypes.c_uint]
_libgles.glLinkProgram.argtypes             = [ctypes.c_uint]
_libgles.glGetProgramiv.argtypes            = [ctypes.c_uint, ctypes.c_uint, _c_int_p]
_libgles.glGetProgramInfoLog.argtypes       = [ctypes.c_uint, ctypes.c_int, _c_int_p, ctypes.c_char_p]
_libgles.glDeleteShader.argtypes            = [ctypes.c_uint]
_libgles.glDeleteProgram.argtypes           = [ctypes.c_uint]
_libgles.glUseProgram.argtypes              = [ctypes.c_uint]
_libgles.glGenTextures.argtypes             = [ctypes.c_int, _c_uint_p]
_libgles.glDeleteTextures.argtypes          = [ctypes.c_int, _c_uint_p]
_libgles.glBindTexture.argtypes             = [ctypes.c_uint, ctypes.c_uint]
_libgles.glTexParameteri.argtypes           = [ctypes.c_uint, ctypes.c_uint, ctypes.c_int]
_libgles.glTexImage2D.argtypes              = [ctypes.c_uint, ctypes.c_int, ctypes.c_int,
                                                ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                                ctypes.c_uint, ctypes.c_uint, ctypes.c_void_p]
_libgles.glGetUniformLocation.argtypes      = [ctypes.c_uint, ctypes.c_char_p]
_libgles.glGetUniformLocation.restype       = ctypes.c_int
_libgles.glGetAttribLocation.argtypes       = [ctypes.c_uint, ctypes.c_char_p]
_libgles.glGetAttribLocation.restype        = ctypes.c_int
_libgles.glBindFramebuffer.argtypes         = [ctypes.c_uint, ctypes.c_uint]
_libgles.glViewport.argtypes                = [ctypes.c_int, ctypes.c_int,
                                                ctypes.c_int, ctypes.c_int]
_libgles.glActiveTexture.argtypes           = [ctypes.c_uint]
_libgles.glUniform1i.argtypes               = [ctypes.c_int, ctypes.c_int]
_libgles.glUniform1f.argtypes               = [ctypes.c_int, ctypes.c_float]
_libgles.glEnableVertexAttribArray.argtypes = [ctypes.c_uint]
_libgles.glVertexAttribPointer.argtypes     = [ctypes.c_uint, ctypes.c_int, ctypes.c_uint,
                                                ctypes.c_ubyte, ctypes.c_int, ctypes.c_void_p]
_libgles.glDrawArrays.argtypes              = [ctypes.c_uint, ctypes.c_int, ctypes.c_int]
_libgles.glReadPixels.argtypes              = [ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                                ctypes.c_uint, ctypes.c_uint, ctypes.c_void_p]
_libgles.glFinish.argtypes                  = []
_libgles.glGetError.argtypes                = []
_libgles.glGetError.restype                 = ctypes.c_uint
_libgles.glClearColor.argtypes              = [ctypes.c_float, ctypes.c_float,
                                                ctypes.c_float, ctypes.c_float]
_libgles.glClear.argtypes                   = [ctypes.c_uint]
_libgles.glEnable.argtypes                  = [ctypes.c_uint]
_libgles.glDisable.argtypes                 = [ctypes.c_uint]
_libgles.glBlendFunc.argtypes               = [ctypes.c_uint, ctypes.c_uint]

GL_VERTEX_SHADER         = 0x8B31
GL_FRAGMENT_SHADER       = 0x8B30
GL_COMPILE_STATUS        = 0x8B81
GL_LINK_STATUS           = 0x8B82
GL_TEXTURE_2D            = 0x0DE1
GL_TEXTURE0              = 0x84C0
GL_TEXTURE1              = 0x84C1
GL_LUMINANCE             = 0x1909
GL_UNSIGNED_BYTE         = 0x1401
GL_TEXTURE_MIN_FILTER    = 0x2801
GL_TEXTURE_MAG_FILTER    = 0x2800
GL_NEAREST               = 0x2600
GL_TEXTURE_WRAP_S        = 0x2802
GL_TEXTURE_WRAP_T        = 0x2803
GL_CLAMP_TO_EDGE         = 0x812F
GL_FRAMEBUFFER           = 0x8D40
GL_RGBA                  = 0x1908
GL_FLOAT                 = 0x1406
GL_TRIANGLE_STRIP        = 0x0005
GL_NO_ERROR              = 0
GL_BLEND                 = 0x0BE2
GL_ONE                   = 1
GL_COLOR_BUFFER_BIT      = 0x00004000


# ---------------------------------------------------------------------------
# 3. GLSL shader sources (embedded — no file I/O needed on board)
# ---------------------------------------------------------------------------
VERT_SRC = b"""
attribute vec2 a_pos;
varying   vec2 v_uv;
void main() {
    v_uv        = a_pos * 0.5 + 0.5;
    gl_Position = vec4(a_pos, 0.0, 1.0);
}
"""

# NOTE ON LOOP BOUNDS: Mali-400 (Utgard) / lima cannot compile a fragment
# shader `for` loop whose trip count depends on a uniform (a runtime value) —
# it needs a literal/compile-time constant so the loop can be fully unrolled.
# A uniform-bound loop compiles and links fine, but crashes the driver with a
# SIGSEGV the first time it's actually executed via glDrawArrays(). So N,
# BLOCK_SIZE and STREAM_TILE (all fixed Python-side constants) are baked
# directly into the GLSL source below via f-strings — exactly how
# mali_cpu_benchmark.py bakes `max_iter` into its Mandelbrot shader. Only
# values that do NOT affect the loop trip count (u_k_start, an addend used
# inside the loop body) remain real uniforms.
assert N % BLOCK_SIZE == 0,  "BLOCK_SIZE must evenly divide N (loop bound is baked at compile time)"
assert N % STREAM_TILE == 0, "STREAM_TILE must evenly divide N (loop bound is baked at compile time)"

# SCALE FACTORS: a texel stores round(mat_val*SCALE) as a byte, so
# texture2D(...).r (normalized to [0,1] by the GPU) equals mat_val*SCALE/255.
# u_scale = 255/SCALE recovers the true mat_val when multiplied against that
# texel — NOT SCALE/255 (that earlier version multiplied every texel by
# SCALE/255 on top of the SCALE/255 the GPU already applies when normalizing,
# squaring the shrink factor; measured empirically: it made every fragment's
# pre-clamp value average ~12x too large, saturating every pixel to 1.0).
# With mat_val correctly recovered, acc = sum(a*b) IS the true dot-product
# accumulator, bounded above by N (since every mat_val < 255/SCALE ≈ 1.275,
# actually generated in [0,1) — see main()). Dividing by N before storing
# in gl_FragColor.r, and multiplying back by N on readback (read_gpu_result),
# is therefore a mathematically safe, non-saturating pack/unpack — no more
# fragile than the byte quantization already applied to the inputs.
FRAG_SRC = f"""
precision mediump float;
varying   vec2      v_uv;
uniform   sampler2D u_A;
uniform   sampler2D u_B;
uniform   float     u_scale;   /* 255/SCALE — recovers mat_val from a texel */

void main() {{
    float row   = floor(v_uv.y * {N}.0);
    float col   = floor(v_uv.x * {N}.0);
    float invN  = 1.0 / {N}.0;
    float acc   = 0.0;
    for (int k = 0; k < {N}; k++) {{
        float kf = float(k);
        float a = texture2D(u_A, vec2((kf+0.5)*invN, (row+0.5)*invN)).r * u_scale;
        float b = texture2D(u_B, vec2((col+0.5)*invN, (kf+0.5)*invN)).r * u_scale;
        acc += a * b;
    }}
    /* pack: acc is bounded above by N, so acc/N never exceeds 1.0 */
    gl_FragColor = vec4(acc / {N}.0, 0.0, 0.0, 1.0);
}}
""".encode()

# Algorithm #3 — Block/tiled: same full A/B textures as FRAG_SRC, but only
# accumulates over a [u_k_start, u_k_start+BLOCK_SIZE) slice of K per draw
# call. Multiple passes with additive blending (GL_ONE, GL_ONE) reconstruct
# the full sum — the GPU analogue of block_matmul()'s "kk" blocking loop.
# u_k_start is a real uniform (pure data, doesn't affect the loop trip count).
FRAG_SRC_BLOCK = f"""
precision mediump float;
varying   vec2      v_uv;
uniform   sampler2D u_A;
uniform   sampler2D u_B;
uniform   float     u_scale;
uniform   float     u_k_start;

void main() {{
    float row  = floor(v_uv.y * {N}.0);
    float col  = floor(v_uv.x * {N}.0);
    float invN = 1.0 / {N}.0;
    float acc  = 0.0;
    for (int k = 0; k < {BLOCK_SIZE}; k++) {{
        float kk = u_k_start + float(k);
        float a = texture2D(u_A, vec2((kk+0.5)*invN, (row+0.5)*invN)).r * u_scale;
        float b = texture2D(u_B, vec2((col+0.5)*invN, (kk+0.5)*invN)).r * u_scale;
        acc += a * b;
    }}
    gl_FragColor = vec4(acc / {N}.0, 0.0, 0.0, 1.0);
}}
""".encode()

# Algorithm #5 — Streaming/partitioned: u_Astrip/u_Bstrip hold ONLY the
# current K-tile (re-uploaded from the host each pass, see run_streaming_gemm),
# never the full matrix — the GPU analogue of streaming_matmul()'s tile_size
# ping-pong buffers / DMA-fed dataflow. Strips are always STREAM_TILE wide
# (N % STREAM_TILE == 0 is asserted above), so the loop trip count is baked.
FRAG_SRC_STREAM = f"""
precision mediump float;
varying   vec2      v_uv;
uniform   sampler2D u_Astrip;   /* width = {STREAM_TILE}, height = {N} */
uniform   sampler2D u_Bstrip;   /* width = {N}, height = {STREAM_TILE} */
uniform   float     u_scale;

void main() {{
    float row  = floor(v_uv.y * {N}.0);
    float col  = floor(v_uv.x * {N}.0);
    float invN = 1.0 / {N}.0;
    float invK = 1.0 / {STREAM_TILE}.0;
    float acc  = 0.0;
    for (int k = 0; k < {STREAM_TILE}; k++) {{
        float kf = float(k);
        float a = texture2D(u_Astrip, vec2((kf+0.5)*invK, (row+0.5)*invN)).r * u_scale;
        float b = texture2D(u_Bstrip, vec2((col+0.5)*invN, (kf+0.5)*invK)).r * u_scale;
        acc += a * b;
    }}
    gl_FragColor = vec4(acc / {N}.0, 0.0, 0.0, 1.0);
}}
""".encode()


# ---------------------------------------------------------------------------
# 4. EGL helpers
# ---------------------------------------------------------------------------

def _check_egl(val, msg="EGL error"):
    if not val:
        err = _libegl.eglGetError()
        raise RuntimeError(f"{msg}: EGL error code 0x{err:04X}")
    return val


def check_device_node_permissions():
    """Reports which graphics device nodes exist and are read/write accessible."""
    devices = ["/dev/dri/card0", "/dev/dri/renderD128", "/dev/mali", "/dev/mali0"]
    available, inaccessible = [], []
    for dev in devices:
        if os.path.exists(dev):
            (available if os.access(dev, os.R_OK | os.W_OK) else inaccessible).append(dev)
    return available, inaccessible


def get_gbm_display():
    """Open a DRM device node and wrap it in a GBM device + EGL platform display.

    Returns (display, gbm_dev, fd). Raises RuntimeError if no device node /
    GBM device / EGL display could be obtained.
    """
    fd = -1
    for dev_path in (b"/dev/dri/card0", b"/dev/dri/renderD128", b"/dev/mali", b"/dev/mali0"):
        try:
            fd = os.open(dev_path, os.O_RDWR)
            break
        except OSError:
            continue
    if fd == -1:
        raise RuntimeError("No accessible DRM/Mali device node "
                            "(/dev/dri/card0, renderD128, /dev/mali*)")

    gbm_dev = _libgbm.gbm_create_device(fd)
    if not gbm_dev:
        os.close(fd)
        raise RuntimeError("gbm_create_device() failed")

    disp = None
    if hasattr(_libegl, "eglGetPlatformDisplayEXT"):
        disp = _libegl.eglGetPlatformDisplayEXT(EGL_PLATFORM_GBM_KHR, gbm_dev, None)
    if not disp:
        disp = _libegl.eglGetDisplay(gbm_dev)
    if not disp:
        os.close(fd)
        raise RuntimeError("Could not obtain an EGL display for the GBM device")

    return disp, gbm_dev, fd


def egl_init() -> tuple:
    """Initialise a headless EGL context backed by a GBM window surface.

    Returns (display, surface, context, gbm_dev, gbm_surface, fd).
    Pbuffer surfaces are not used: this Mesa+lima stack only exposes EGL
    configs with EGL_WINDOW_BIT, so a real (never-displayed) GBM surface
    is created instead — same approach as mali_cpu_benchmark.py.
    """
    available, inaccessible = check_device_node_permissions()
    if inaccessible:
        print(f"  [WARNING] Device node(s) found but not writeable: {inaccessible}")
        print("            Try running with sudo or check group membership (e.g. 'render').")
    if not available and not inaccessible:
        print("  [WARNING] No /dev/dri/* or /dev/mali* nodes found.")

    disp, gbm_dev, fd = get_gbm_display()

    # From here on, any failure must release disp/gbm_dev/fd (and whatever
    # partial EGL state got created) before propagating — otherwise a failed
    # attempt leaks the DRM fd / GBM device and degrades every subsequent
    # run against the same node (observed: a leaked fd made later
    # eglInitialize() calls fail outright until the process exited).
    surf = None
    ctx = None
    gbm_surface = None
    egl_initialized = False
    try:
        major, minor = EGLint(0), EGLint(0)
        _check_egl(_libegl.eglInitialize(disp, ctypes.byref(major), ctypes.byref(minor)),
                   "eglInitialize")
        egl_initialized = True
        print(f"EGL {major.value}.{minor.value} — Mali-400 (headless GBM)")

        cfg_attrs = (EGLint * 13)(
            EGL_RED_SIZE,   8, EGL_GREEN_SIZE, 8,
            EGL_BLUE_SIZE,  8, EGL_ALPHA_SIZE, 8,
            EGL_SURFACE_TYPE,    EGL_WINDOW_BIT,
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_NONE,
        )
        config    = EGLConfig()
        num_cfgs  = EGLint(0)
        _check_egl(_libegl.eglChooseConfig(disp, cfg_attrs,
                                           ctypes.byref(config), 1,
                                           ctypes.byref(num_cfgs)),
                   "eglChooseConfig")
        if num_cfgs.value == 0:
            raise RuntimeError("eglChooseConfig returned no matching WINDOW configs")

        _check_egl(_libegl.eglBindAPI(EGL_OPENGL_ES_API), "eglBindAPI")

        visual_id = EGLint(0)
        _libegl.eglGetConfigAttrib(disp, config, EGL_NATIVE_VISUAL_ID, ctypes.byref(visual_id))
        gbm_surface = _libgbm.gbm_surface_create(gbm_dev, N, N,
                                                  visual_id.value or GBM_FORMAT_XRGB8888,
                                                  GBM_BO_USE_RENDERING)
        _check_egl(gbm_surface, "gbm_surface_create")

        surf = _libegl.eglCreateWindowSurface(disp, config, gbm_surface, None)
        _check_egl(surf, "eglCreateWindowSurface")

        ctx_attrs = (EGLint * 3)(EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE)
        ctx = _libegl.eglCreateContext(disp, config, EGL_NO_CONTEXT, ctx_attrs)
        _check_egl(ctx, "eglCreateContext")

        _check_egl(_libegl.eglMakeCurrent(disp, surf, surf, ctx), "eglMakeCurrent")
    except Exception:
        _egl_release(disp, surf, ctx, gbm_dev, gbm_surface, fd, egl_initialized)
        raise

    return disp, surf, ctx, gbm_dev, gbm_surface, fd


def _egl_release(disp, surf, ctx, gbm_dev, gbm_surface, fd, egl_initialized=True):
    """Best-effort teardown of whatever subset of EGL/GBM state was created."""
    if disp and surf and ctx:
        _libegl.eglMakeCurrent(disp, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)
    if disp and ctx:
        _libegl.eglDestroyContext(disp, ctx)
    if disp and surf:
        _libegl.eglDestroySurface(disp, surf)
    if disp and egl_initialized:
        _libegl.eglTerminate(disp)
    if gbm_surface:
        _libgbm.gbm_surface_destroy(gbm_surface)
    if gbm_dev:
        _libgbm.gbm_device_destroy(gbm_dev)
    if fd != -1:
        try:
            os.close(fd)
        except OSError:
            pass


def egl_teardown(disp, surf, ctx, gbm_dev, gbm_surface, fd):
    _egl_release(disp, surf, ctx, gbm_dev, gbm_surface, fd)


# ---------------------------------------------------------------------------
# 5. GLES2 helpers
# ---------------------------------------------------------------------------

# Set MATMUL_DEBUG=1 to print every GLESv2 call immediately before it runs
# (flushed) — since a native SIGSEGV kills the process with no Python
# traceback, the last line printed is the call that crashed.
DEBUG_GL = os.environ.get("MATMUL_DEBUG") == "1"


def _gl(fn_name: str):
    """Return a ctypes function pointer from libGLESv2."""
    fn = getattr(_libgles, fn_name)
    if not DEBUG_GL:
        return fn

    def _traced(*args):
        print(f"  [GL] {fn_name}{args}", flush=True)
        return fn(*args)
    return _traced


def check_gl():
    err = _gl("glGetError")()
    if err != GL_NO_ERROR:
        raise RuntimeError(f"GL error 0x{err:04X}")


def compile_shader(shader_type: int, src: bytes) -> int:
    sh = _gl("glCreateShader")(shader_type)
    src_ptr   = ctypes.c_char_p(src)
    src_len   = ctypes.c_int(len(src))
    _gl("glShaderSource")(sh, 1,
                          ctypes.byref(src_ptr),
                          ctypes.byref(src_len))
    _gl("glCompileShader")(sh)
    status = ctypes.c_int(0)
    _gl("glGetShaderiv")(sh, GL_COMPILE_STATUS, ctypes.byref(status))
    if not status.value:
        buf = ctypes.create_string_buffer(1024)
        _gl("glGetShaderInfoLog")(sh, 1024, None, buf)
        raise RuntimeError(f"Shader compile error:\n{buf.value.decode()}")
    return sh


def build_program(frag_src: bytes = FRAG_SRC) -> int:
    vs   = compile_shader(GL_VERTEX_SHADER,   VERT_SRC)
    fs   = compile_shader(GL_FRAGMENT_SHADER, frag_src)
    prog = _gl("glCreateProgram")()
    _gl("glAttachShader")(prog, vs)
    _gl("glAttachShader")(prog, fs)
    _gl("glLinkProgram")(prog)
    status = ctypes.c_int(0)
    _gl("glGetProgramiv")(prog, GL_LINK_STATUS, ctypes.byref(status))
    if not status.value:
        buf = ctypes.create_string_buffer(1024)
        _gl("glGetProgramInfoLog")(prog, 1024, None, buf)
        raise RuntimeError(f"Link error:\n{buf.value.decode()}")
    _gl("glDeleteShader")(vs)
    _gl("glDeleteShader")(fs)
    return prog


def upload_matrix_texture(mat: np.ndarray, tex_id: int | None = None) -> int:
    """Pack float matrix → uint8 GL_LUMINANCE texture via SCALE.

    If `tex_id` is given, re-specifies that existing texture's image data
    (used to re-upload a small K-tile strip each pass in run_streaming_gemm)
    instead of allocating a new one.
    """
    rows, cols = mat.shape
    pixels = np.clip(mat * SCALE, 0, 255).astype(np.uint8)
    pixels = np.ascontiguousarray(pixels)

    if tex_id is None:
        tex = ctypes.c_uint(0)
        _gl("glGenTextures")(1, ctypes.byref(tex))
        tex_id = tex.value
        _gl("glBindTexture")(GL_TEXTURE_2D, tex_id)
        for param, val in [
            (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
            (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
            (GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE),
            (GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE),
        ]:
            _gl("glTexParameteri")(GL_TEXTURE_2D, param, val)
    else:
        _gl("glBindTexture")(GL_TEXTURE_2D, tex_id)

    _gl("glTexImage2D")(GL_TEXTURE_2D, 0, GL_LUMINANCE,
                        cols, rows, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,
                        pixels.ctypes.data_as(ctypes.c_void_p))
    check_gl()
    return tex_id


def uniform_loc(prog: int, name: bytes) -> int:
    return _gl("glGetUniformLocation")(prog, ctypes.c_char_p(name))


def attrib_loc(prog: int, name: bytes) -> int:
    return _gl("glGetAttribLocation")(prog, ctypes.c_char_p(name))


def read_gpu_result() -> np.ndarray:
    """Read back the bound framebuffer's result channel and decode it to float32."""
    pixels = np.zeros((N, N, 4), dtype=np.uint8)
    _gl("glReadPixels")(0, 0, N, N, GL_RGBA, GL_UNSIGNED_BYTE,
                        pixels.ctypes.data_as(ctypes.c_void_p))
    check_gl()
    # No vertical flip: glReadPixels' row 0 is the window's bottom scanline,
    # which is also v_uv.y=0 / row=0 in the shader (a_pos.y=-1 -> v_uv.y=0),
    # i.e. the same row 0 that upload_matrix_texture() stored A's row 0 at.
    # Flipping here (as an earlier version did) compares row i against
    # A's row (N-1-i) instead of row i, which is wrong for a data texture
    # that's never actually displayed as an image.
    # gl_FragColor.r stored acc/N (see FRAG_SRC*: acc is bounded above by N)
    return pixels[:, :, 0].astype(np.float32) / 255.0 * float(N)


# ---------------------------------------------------------------------------
# 6. GEMM algorithm variants — Block/tiled (#3) and Streaming/partitioned (#5)
#    See Docs/Labs/Lab5_Matrix_Multiplication/src_python/algorithms.py for the
#    CPU reference implementations these mirror.
# ---------------------------------------------------------------------------

def run_block_gemm(texA: int, texB: int, block_size: int = BLOCK_SIZE):
    """Algorithm #3 (block/tiled): K-blocked passes over the SAME full-resident
    A/B textures, summed via additive blending (block_matmul()'s "kk" loop).

    Returns (C_gpu, elapsed_ms, num_passes).
    """
    assert N % block_size == 0, "block_size must evenly divide N (FRAG_SRC_BLOCK's loop bound is baked at compile time)"
    prog = build_program(FRAG_SRC_BLOCK)
    _gl("glUseProgram")(prog)

    _gl("glActiveTexture")(GL_TEXTURE0)
    _gl("glBindTexture")(GL_TEXTURE_2D, texA)
    _gl("glUniform1i")(uniform_loc(prog, b"u_A"), 0)
    _gl("glActiveTexture")(GL_TEXTURE1)
    _gl("glBindTexture")(GL_TEXTURE_2D, texB)
    _gl("glUniform1i")(uniform_loc(prog, b"u_B"), 1)
    _gl("glUniform1f")(uniform_loc(prog, b"u_scale"), ctypes.c_float(255.0 / SCALE))
    loc_k_start = uniform_loc(prog, b"u_k_start")

    _gl("glClearColor")(ctypes.c_float(0.0), ctypes.c_float(0.0),
                        ctypes.c_float(0.0), ctypes.c_float(0.0))
    _gl("glClear")(GL_COLOR_BUFFER_BIT)
    _gl("glEnable")(GL_BLEND)
    _gl("glBlendFunc")(GL_ONE, GL_ONE)

    t0, num_passes, k = time.perf_counter(), 0, 0
    while k < N:
        _gl("glUniform1f")(loc_k_start, ctypes.c_float(float(k)))
        _gl("glDrawArrays")(GL_TRIANGLE_STRIP, 0, 4)
        k += block_size
        num_passes += 1
    _gl("glFinish")()
    elapsed_ms = (time.perf_counter() - t0) * 1e3

    _gl("glDisable")(GL_BLEND)
    C_gpu = read_gpu_result()
    _gl("glDeleteProgram")(prog)
    return C_gpu, elapsed_ms, num_passes


def run_streaming_gemm(A: np.ndarray, B: np.ndarray, tile_size: int = STREAM_TILE):
    """Algorithm #5 (streaming/partitioned): re-uploads only the current
    K-tile's A-strip/B-strip each pass — never the full matrix — mirroring
    streaming_matmul()'s tile_size-bounded on-chip footprint. Accumulates via
    additive blending like run_block_gemm(), but pays a per-pass upload cost.

    Returns (C_gpu, elapsed_ms, num_passes).
    """
    assert N % tile_size == 0, "tile_size must evenly divide N (FRAG_SRC_STREAM's loop bound is baked at compile time)"
    prog = build_program(FRAG_SRC_STREAM)
    _gl("glUseProgram")(prog)

    strip_a_tex = upload_matrix_texture(np.ascontiguousarray(A[:, 0:tile_size]))
    strip_b_tex = upload_matrix_texture(np.ascontiguousarray(B[0:tile_size, :]))

    _gl("glUniform1f")(uniform_loc(prog, b"u_scale"), ctypes.c_float(255.0 / SCALE))
    _gl("glUniform1i")(uniform_loc(prog, b"u_Astrip"), 0)
    _gl("glUniform1i")(uniform_loc(prog, b"u_Bstrip"), 1)

    _gl("glClearColor")(ctypes.c_float(0.0), ctypes.c_float(0.0),
                        ctypes.c_float(0.0), ctypes.c_float(0.0))
    _gl("glClear")(GL_COLOR_BUFFER_BIT)
    _gl("glEnable")(GL_BLEND)
    _gl("glBlendFunc")(GL_ONE, GL_ONE)

    t0, num_passes, k = time.perf_counter(), 0, 0
    while k < N:
        _gl("glActiveTexture")(GL_TEXTURE0)
        upload_matrix_texture(np.ascontiguousarray(A[:, k:k+tile_size]), tex_id=strip_a_tex)
        _gl("glActiveTexture")(GL_TEXTURE1)
        upload_matrix_texture(np.ascontiguousarray(B[k:k+tile_size, :]), tex_id=strip_b_tex)
        _gl("glDrawArrays")(GL_TRIANGLE_STRIP, 0, 4)
        k += tile_size
        num_passes += 1
    _gl("glFinish")()
    elapsed_ms = (time.perf_counter() - t0) * 1e3

    _gl("glDisable")(GL_BLEND)
    C_gpu = read_gpu_result()
    _gl("glDeleteTextures")(1, ctypes.byref(ctypes.c_uint(strip_a_tex)))
    _gl("glDeleteTextures")(1, ctypes.byref(ctypes.c_uint(strip_b_tex)))
    _gl("glDeleteProgram")(prog)
    return C_gpu, elapsed_ms, num_passes


# ---------------------------------------------------------------------------
# 7. Main
# ---------------------------------------------------------------------------

def main():
    # ---- Test matrices (values in [0, 1/SCALE range]) ----
    rng = np.random.default_rng(42)
    A = rng.random((N, N)).astype(np.float32) * (200.0 / SCALE)
    B = rng.random((N, N)).astype(np.float32) * (200.0 / SCALE)
    C_ref = A @ B

    # ---- EGL init ----
    disp, surf, ctx, gbm_dev, gbm_surface, fd = egl_init()

    renderer = ctypes.cast(_gl("glGetString")(0x1F01), ctypes.c_char_p).value
    version  = ctypes.cast(_gl("glGetString")(0x1F02), ctypes.c_char_p).value
    print(f"GL renderer : {renderer.decode()}")
    print(f"GL version  : {version.decode()}")

    # ---- Build program ----
    prog = build_program()
    _gl("glUseProgram")(prog)

    # ---- Upload textures ----
    texA = upload_matrix_texture(A)
    texB = upload_matrix_texture(B)

    # ---- Render target: the default framebuffer (id 0), backed by the GBM
    # window surface created in egl_init() — NOT a user-created FBO. This
    # Mesa+lima stack's render-to-user-FBO/renderbuffer path appears broken
    # (crashes the driver at the first glDrawArrays regardless of shader
    # size, from N=4 up through N=64); rendering straight into the surface
    # that already backs the EGL context, like mali_cpu_benchmark.py does,
    # avoids that path entirely.
    _gl("glBindFramebuffer")(GL_FRAMEBUFFER, 0)
    _gl("glViewport")(0, 0, N, N)

    # ---- Bind textures to samplers ----
    _gl("glActiveTexture")(GL_TEXTURE0)
    _gl("glBindTexture")(GL_TEXTURE_2D, texA)
    _gl("glUniform1i")(uniform_loc(prog, b"u_A"), 0)

    _gl("glActiveTexture")(GL_TEXTURE1)
    _gl("glBindTexture")(GL_TEXTURE_2D, texB)
    _gl("glUniform1i")(uniform_loc(prog, b"u_B"), 1)

    _gl("glUniform1f")(uniform_loc(prog, b"u_scale"), ctypes.c_float(255.0 / SCALE))

    # ---- Full-screen quad, as a client-side vertex array (NOT a VBO) ----
    # This Mesa+lima/Mali-400 stack's VBO code path (glGenBuffers/glBindBuffer/
    # glBufferData + an offset-based glVertexAttribPointer) crashes the driver
    # at the first glDrawArrays, regardless of shader content or FBO usage —
    # confirmed by bisecting both away. mali_cpu_benchmark.py never uses a VBO
    # either; it passes a raw ctypes array pointer straight to
    # glVertexAttribPointer, which is valid in GLES2 and avoids that path.
    # `quad` must stay alive for as long as any of these programs still draw.
    quad = (ctypes.c_float * 8)(-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0)
    pos_loc = attrib_loc(prog, b"a_pos")
    _gl("glVertexAttribPointer")(pos_loc, 2, GL_FLOAT, 0, 0,
                                 ctypes.cast(quad, ctypes.c_void_p))
    _gl("glEnableVertexAttribArray")(pos_loc)

    # ---- Render (GPU runs GEMM, algorithm #1: standard/single-pass) ----
    t0 = time.perf_counter()
    _gl("glDrawArrays")(GL_TRIANGLE_STRIP, 0, 4)
    _gl("glFinish")()                   # block until GPU done
    elapsed_standard = (time.perf_counter() - t0) * 1e3
    print(f"\nGPU GEMM (standard):   {elapsed_standard:.2f} ms  (N={N})")

    C_gpu = read_gpu_result()

    # ---- Verify ----
    max_err = float(np.max(np.abs(C_gpu - C_ref)))
    bad     = int(np.sum(np.abs(C_gpu - C_ref) > VERIFY_TOL))
    status_str = "PASS" if bad == 0 else f"FAIL ({bad} elements)"
    print(f"Max error vs NumPy: {max_err:.5f}  → {status_str}")

    # Print 4×4 corner
    print("\nC[0:4][0:4]  GPU vs NumPy:")
    for i in range(4):
        row = "  ".join(
            f"GPU={C_gpu[i,j]:.4f} NP={C_ref[i,j]:.4f}"
            for j in range(4)
        )
        print(f"  {row}")

    # ---- Algorithm #3: Block/tiled ----
    C_block, elapsed_block, passes_block = run_block_gemm(texA, texB)
    err_block = float(np.max(np.abs(C_block - C_ref)))
    status_block = "PASS" if err_block <= verify_tolerance(passes_block) else "FAIL"

    # ---- Algorithm #5: Streaming/partitioned ----
    C_stream, elapsed_stream, passes_stream = run_streaming_gemm(A, B)
    err_stream = float(np.max(np.abs(C_stream - C_ref)))
    status_stream = "PASS" if err_stream <= verify_tolerance(passes_stream) else "FAIL"

    # ---- Timing comparison ----
    t0 = time.perf_counter()
    _ = A @ B
    t1 = time.perf_counter()
    numpy_ms = (t1 - t0) * 1e3

    print("\n" + "=" * 78)
    print(f"{'Mali GPU — algorithm comparison (N=' + str(N) + ')':^78}")
    print("=" * 78)
    print(f"| {'Algorithm':<30} | {'Time (ms)':>10} | {'Passes':>7} | {'Max err':>8} | {'':>6} |")
    print("|" + "-"*32 + "|" + "-"*12 + "|" + "-"*9 + "|" + "-"*10 + "|" + "-"*8 + "|")
    print(f"| {'#1 Standard (single-pass)':<30} | {elapsed_standard:>10.2f} | {1:>7} | {max_err:>8.5f} | {status_str:>6} |")
    print(f"| {'#3 Block/tiled (block=' + str(BLOCK_SIZE) + ')':<30} | {elapsed_block:>10.2f} | {passes_block:>7} | {err_block:>8.5f} | {status_block:>6} |")
    print(f"| {'#5 Streaming (tile=' + str(STREAM_TILE) + ')':<30} | {elapsed_stream:>10.2f} | {passes_stream:>7} | {err_stream:>8.5f} | {status_stream:>6} |")
    print(f"| {'NumPy GEMM (CPU reference)':<30} | {numpy_ms:>10.2f} | {'—':>7} | {'0.0':>8} | {'—':>6} |")
    print("=" * 78)

    results = {
        "N": str(N),
        "Standard": {
            "time": elapsed_standard,
            "passes": 1,
            "max_err": max_err,
            "status": status_str
        },
        "block": {
            "n_block": BLOCK_SIZE,
            "time": elapsed_block,
            "passes": passes_block,
            "max_err": err_block,
            "status": status_block
        },
        "streaming": {
            "n_tile": STREAM_TILE,
            "time": elapsed_stream,
            "passes": passes_stream,
            "max_err": err_stream,
            "status": status_stream
        },
        "NumPy GEMM (CPU reference)": {
            "time": numpy_ms
        }
    }

    # ---- Cleanup ----
    _gl("glDeleteTextures")(1, ctypes.byref(ctypes.c_uint(texA)))
    _gl("glDeleteTextures")(1, ctypes.byref(ctypes.c_uint(texB)))
    _gl("glDeleteProgram")(prog)
    egl_teardown(disp, surf, ctx, gbm_dev, gbm_surface, fd)

    return results


if __name__ == "__main__":
    main()
