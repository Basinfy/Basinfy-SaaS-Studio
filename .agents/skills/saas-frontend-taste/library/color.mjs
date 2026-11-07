/* ------------------------------------------------------------------ colour (OKLab) */

const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const toLin = v => (v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4));
const toGam = v => (v <= 0.0031308 ? v * 12.92 : 1.055 * Math.pow(v, 1 / 2.4) - 0.055);

function hexToRgb(hex) {
  let h = String(hex).trim().replace(/^#/, '');
  if (h.length === 3 || h.length === 4) h = h.split('').map(c => c + c).join('');
  const n = parseInt(h.slice(0, 6), 16);
  if (!Number.isFinite(n)) throw new Error(`color: not a hex colour: ${hex}`);
  return [((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255];
}
function rgbToHex(c) {
  return '#' + c.slice(0, 3).map(v => Math.round(clamp(v, 0, 1) * 255).toString(16).padStart(2, '0')).join('');
}
function toRgb(c) {
  if (Array.isArray(c) || ArrayBuffer.isView(c)) return [c[0], c[1], c[2]];
  return hexToRgb(c);
}
function rgbToLab(rgb) {
  const [r, g, b] = rgb.map(toLin);
  const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  return [
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  ];
}
function labToLinear([L, a, b]) {
  const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
  const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
  const s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3;
  return [
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
}
const inGamut = lin => lin.every(v => v >= -1e-4 && v <= 1 + 1e-4);
function labToRgb(lab) {
  let lin = labToLinear(lab);
  if (!inGamut(lin)) {
    const [L, a, b] = [clamp(lab[0], 0, 1), lab[1], lab[2]];
    let lo = 0, hi = 1;
    for (let i = 0; i < 18; i++) {
      const k = (lo + hi) / 2;
      if (inGamut(labToLinear([L, a * k, b * k]))) lo = k; else hi = k;
    }
    lin = labToLinear([L, a * lo, b * lo]);
  }
  return lin.map(v => toGam(clamp(v, 0, 1)));
}
const lab = c => rgbToLab(toRgb(c));
const fromLab = L => rgbToHex(labToRgb(L));
function lch(c) {
  const [L, a, b] = lab(c);
  return [L, Math.hypot(a, b), ((Math.atan2(b, a) * 180) / Math.PI + 360) % 360];
}
function fromLch([L, C, h]) {
  const r = (h * Math.PI) / 180;
  return fromLab([L, C * Math.cos(r), C * Math.sin(r)]);
}
function relLum(c) {
  const [r, g, b] = toRgb(c).map(toLin);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export const color = {
  rgb: toRgb,
  hex: c => rgbToHex(toRgb(c)),
  lab,
  fromLab,
  lch,
  fromLch,
  mix(a, b, t = 0.5) {
    const A = lab(a), B = lab(b);
    return fromLab(A.map((v, i) => v + (B[i] - v) * t));
  },
  lighten(c, d = 0.08) {
    const [L, a, b] = lab(c);
    return fromLab([clamp(L + d, 0, 1), a, b]);
  },
  darken(c, d = 0.08) { return color.lighten(c, -d); },
  saturate(c, k = 1.2) {
    const [L, C, h] = lch(c);
    return fromLch([L, C * k, h]);
  },
  adjust(c, { l = 0, c: ck = 1, h = 0 } = {}) {
    const [L, C, H] = lch(c);
    return fromLch([clamp(L + l, 0, 1), C * ck, (H + h + 360) % 360]);
  },
  withLightness(c, L) {
    const [, C, h] = lch(c);
    return fromLch([clamp(L, 0, 1), C, h]);
  },
  luminance: relLum,
  contrast(a, b) {
    const x = relLum(a), y = relLum(b);
    return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05);
  },
  isDark: c => lab(c)[0] < 0.6,
  chroma: c => lch(c)[1],
  hueDistance(a, b) {
    const A = lch(a), B = lch(b);
    if (A[1] < 0.03 || B[1] < 0.03) return 0;
    const d = Math.abs(A[2] - B[2]) % 360;
    return d > 180 ? 360 - d : d;
  },
  readable(bg, ...candidates) {
    return candidates.reduce((best, c) => (color.contrast(bg, c) > color.contrast(bg, best) ? c : best));
  },
  vec3: c => toRgb(c),
  labVec: c => lab(c),
};

export default color;
