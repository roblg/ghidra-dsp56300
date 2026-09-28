# DSP56300 for Ghidra

A Ghidra processor extension for the Motorola/Freescale DSP56300 family of
24-bit digital signal processors (DSP56301/303/309/311/321/362/364/367/371/372/374,
the Symphony DSP5672x parts, ...).  It adds two languages and one analyzer:

| | |
|---|---|
| `DSP56300:LE:24:default` | address registers update linearly |
| `DSP56300:LE:24:modulo` | address register updates go through `agu_modulo(Rn, delta, Mn)` |
| **DSP56300 Loop End** analyzer | repairs loops whose last instruction is a two-word instruction |

## Install

1. Download the zip for your exact Ghidra version from
   [Releases](../../releases) (`ghidra_<version>_PUBLIC_<date>_DSP56300.zip`).
   Ghidra refuses extensions built for another version.
2. In Ghidra: **File > Install Extensions**, **+**, pick the zip, restart.
3. Import a binary with language `DSP56300:LE:24:default`.  Program words are
   read as three bytes, least significant first.

If your Ghidra version has no zip, build one (below).

## Build

Needs the target Ghidra release, JDK 21 and Python 3.

    GHIDRA_INSTALL_DIR=/path/to/ghidra_12.1.4_PUBLIC tools/build.sh
    # -> dist/ghidra_12.1.4_PUBLIC_<date>_DSP56300.zip

`tools/build.sh --install` then `tests/smoke.sh` runs the smoke tests in a
headless Ghidra; neither touches your own Ghidra settings (see `tools/env.sh`).
`DEBUG=1` shows the tools' full output.

## Model

* **Memory.** Three word-addressed spaces, `P` (program, the default space),
  `X` and `Y` (data), each `size=3 wordsize=3`: one address is one 24-bit word.
  Words are stored little-endian, three bytes per word, which is how DSP boot
  streams and most dumps lay them out.
* **Registers.** `x`/`y` = `x1:x0`/`y1:y0`; the 56-bit accumulators `a`/`b`
  (`a2:a1:a0`) are 7-byte registers with `a0`, `a1`, `a2` and `a10` aliased
  onto them.  Condition codes are separate one-byte registers (`C V Z N U E L S`);
  `sr` holds the mode bits.
* **Parallel moves.** An instruction's ALU operation and its one or two data
  moves read all of their sources before any destination is written, as the
  hardware does: `mac x0,y0,a x:(r0)+,x0` multiplies the *old* x0, and
  `mac x0,y0,a a,x:(r0)+` stores the *old* a.
* **Hardware loops.** `DO`/`DOR` attach context to the loop's last word; the
  root table adds the loop-back there, so the decompiler sees an ordinary loop.
  `LA`/`LC` are saved on the hardware system stack, modelled as the `SS` space
  addressed by the internal register `ssp` (the compiler spec's stack pointer),
  so nested loops restore correctly and the saves fold away.  `REP` repeats the
  following instruction the same way.
* **Data ALU.** Multiplies are fractional (`(s1*s2)<<1`).  The data limiter
  (moving an accumulator to a 24/48-bit destination) and rounding are the
  user ops `sat24`, `sat48` and `rnd56`.  Scaling modes are not modelled.
* **AGU.** The default language updates address registers linearly.  The
  `DSP56300:LE:24:modulo` variant routes every update through the user op
  `agu_modulo(Rn, delta, Mn)` for code that relies on modulo or reverse-carry
  addressing.

## Known limitations

* A loop whose last instruction is a two-word instruction starting at `LA-1`
  is not recognised as a loop bottom by SLEIGH alone (the context lands in the
  middle of that instruction).  The **DSP56300 Loop End** analyzer finds these
  loops, moves the loop-end context to `LA-1` and re-disassembles it.
* `BRKcc` branches to `LA+1` through a computed target.
* `DIV`, `NORM`, `NORMF`, `CLB` are user ops.

## Regenerating

`dsp56300.sinc` is generated.  Edit the templates and run `tools/regen.sh`
(CI fails if the committed file is stale).

The templates use the Family Manual's 24-character bit strings (`{...}`); the
generator turns them into field constraints.

## License

Apache License 2.0, as Ghidra.  See [NOTICE.md](NOTICE.md) for sources.
