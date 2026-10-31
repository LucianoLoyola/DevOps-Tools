#!/usr/bin/env bash
# Exporta cada <section class="slide"> de un carrusel dev.luchops a PNG 1080x1350
# y, opcionalmente, todos los slides a un único PDF (formato de carrusel de LinkedIn).
#
# Uso:
#   bash export-slides.sh <carrusel.html> <carpeta-salida> [nombre.pdf]
#
# Ejemplos:
#   bash export-slides.sh branding/tema/instagram.html branding/tema/export/instagram
#   bash export-slides.sh branding/tema/linkedin-carousel.html branding/tema/export/linkedin carrusel-linkedin.pdf
set -euo pipefail

HTML="$1"; OUT="$2"; PDF="${3:-}"
[ -f "$HTML" ] || { echo "No existe $HTML" >&2; exit 1; }
mkdir -p "$OUT"

# Navegador headless: Chrome o Edge (Windows / macOS / Linux)
CHROME=""
for c in \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "$(command -v google-chrome 2>/dev/null || true)" \
  "$(command -v chromium 2>/dev/null || true)"; do
  [ -n "$c" ] && [ -x "$c" ] && { CHROME="$c"; break; }
done
[ -n "$CHROME" ] || { echo "No encontré Chrome/Edge para renderizar" >&2; exit 1; }

# Rutas en formato del navegador (Windows necesita C:/...)
if command -v cygpath >/dev/null 2>&1; then
  url() { echo "file:///$(cygpath -m "$1")"; }
  native() { cygpath -w "$1"; }
else
  url() { echo "file://$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; }
  native() { echo "$1"; }
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
OUT_ABS="$(cd "$OUT" && pwd)"

HEAD='<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=1080">'
FIX='<style>html,body{margin:0;padding:0}.intro,.hint{display:none!important}.wrap{padding:0!important;max-width:none!important}.strip{display:block!important;overflow:visible!important;padding:0!important}.slide{width:1080px!important;max-width:none!important;flex:none!important;border:0!important;border-radius:0!important}</style>'

N=$(grep -c '<section class="slide' "$HTML")
rm -f "$OUT_ABS"/slide-*.png

for i in $(seq 1 "$N"); do
  n=$(printf %02d "$i")
  { echo "$HEAD"; cat "$HTML"; echo "$FIX<style>.slide{display:none!important}.slide:nth-child($i){display:flex!important}</style></head><body></body></html>"; } > "$TMP/s$i.html"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --window-size=1080,1350 --virtual-time-budget=6000 \
    --screenshot="$(native "$OUT_ABS/slide-$n.png")" "$(url "$TMP/s$i.html")" >/dev/null 2>&1
done

if [ -n "$PDF" ]; then
  { echo "$HEAD"; cat "$HTML"; echo "$FIX<style>@page{size:1080px 1350px;margin:0}.slide{break-after:page;height:1350px}</style></head><body></body></html>"; } > "$TMP/all.html"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=6000 \
    --print-to-pdf="$(native "$OUT_ABS/$PDF")" "$(url "$TMP/all.html")" >/dev/null 2>&1
fi

echo "Exportados $N slides en $OUT_ABS${PDF:+ (+ $PDF)}"
