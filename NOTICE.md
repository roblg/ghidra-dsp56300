# Sources and licensing

This extension is licensed under the Apache License, Version 2.0 (see
`LICENSE`), the licence of Ghidra itself.  It was written from public
documentation; no code from other disassemblers or emulators is included.

## Documentation

* *DSP56300 Family Manual* (Motorola/Freescale, DSP56300FM): instruction
  encodings (the 24-character bit strings in `data/languages/*.sinc.in`),
  instruction semantics, the AGU, the hardware stack and loop behaviour.
* The DSP5630x/5636x/5672x user manuals and data sheets for the family members'
  register and memory details.

No manual, or text extracted from one, is redistributed here.

## Cross-checks

The disassembler of the [dsp56300](https://github.com/dsp56300/dsp56300)
emulator project was used only as a test oracle, comparing its decodes with
this extension's; none of its code is included.
