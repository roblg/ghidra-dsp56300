#!/usr/bin/env bash
# Regenerate data/languages/dsp56300.sinc from its templates.  CI runs this and
# fails if the committed file differs.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
L=data/languages
python3 tools/gen_sinc.py "$L/dsp56300.sinc.in" "$L/dsp56300_np.sinc.in" "$L/dsp56300_root.sinc.in" "$L/dsp56300.sinc"
