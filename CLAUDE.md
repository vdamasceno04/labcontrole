# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this directory is

This is **not** a software project — it has no build system, tests, or source tree. It is a
study/coursework folder for **Laboratório de Controle Discreto** (Discrete/Digital Control Lab,
course code ELEC30 / EEC31) in Engenharia de Computação at **UTFPR**, professor Valéria Arruda.

Almost all content is in **Portuguese**. Work here means helping with control-systems theory,
reading the lecture material, and solving the assignments — not writing application code.

### Layout
- `Trabalho.pdf` — the **active team assignment** (see below). This is the main task.
- `pdfs aulas.pdf` (~15 MB) — all lecture notes bundled into one PDF.
- `Drive/ELEC30 - S71 (1-2026) Eng. Computação/`
  - `Notas de Aula/` — lecture notes `EEC31-AulaN[vn].pdf` and `Exercicios1/2.pdf`.
  - `ArquivosMatlab/` — Simulink demo models (`.slx`, binary): `RealEstado1/2` (state-space
    realization), `EfeitoZOH` (zero-order-hold effect), `Rlocus`/`RlocusEx1/2` (root locus),
    `aliasing`.
  - `ProvasResolvidas/` — solved past exams (`LabCD20xx-ProvaN.pdf`), useful as worked examples.
  - `ExemploTrabalhoFinal/` — example final-project submissions.
  - `Trabalho em equipe/` — example team submissions from other students.

## Reading the material

PDFs must be converted to text before Claude can read the prose (the Read tool renders pages
as images; for searching/quoting, extract text first):

```bash
pdftotext "Trabalho.pdf" - | less          # to stdout
pdftotext "pdfs aulas.pdf" /tmp/aulas.txt   # large file -> temp, then Read /tmp/aulas.txt
```

`.slx` files are binary Simulink models and cannot be read as text — describe them from their
filenames or ask the user to open them in MATLAB/Simulink.

## The active assignment (`Trabalho.pdf`)

Team work on an **armature-controlled DC motor** (input `Va(s)`, load disturbance `Td(s)`,
outputs speed `ω(s)` and position `θ(s)`). **Delivery: 02/07/2026.**

Tasks:
1. Closed-loop continuous TF (unity feedback, step input, `Td=0`); pick sampling period `T`
   giving ≥10 samples/cycle of the step response (≤4 decimal places); discretize; build the
   digital control scheme in Simulink (reference, A/D, D/A, digital controller).
2. Design **4 velocity controllers** `D(z)` meeting: overshoot ≤5%, settling time <2 s,
   steady-state error ≤1% — via (a) pole placement / root locus, (b) bilateral "w" transform
   (frequency response), (c) PID, (d) pole placement in state space.
3. Step responses for all designs (rise/settling/peak time, peak value) as `D(z)·G(z)` vs.
   `D(z)·G(s)` tables; analyze a unit-step load disturbance `Td`.
4. (Bonus) A **position** controller with minimal overshoot.

### Hard constraints (graded — do not violate)
- **`sisotool` and `pidtune` are forbidden.** Designs must be done by hand.
- Answers consisting only of MATLAB commands are **not accepted** — show full calculations.
- MATLAB/Simulink is allowed only as **support / verification**.

### This user's team parameters
Victor Damasceno Oliveira's team (with Luiz E. Passoni de Souza), from the EQUIPES table in
`Trabalho.pdf`:

| Ra (Ω) | La (H) | Km (N·m/A) | Kb (V·rad/s) | J (kg·m²) | b (N·m·s/rad) |
|--------|--------|------------|--------------|-----------|----------------|
| 2      | 1      | 0.05       | 0.05         | 0.05      | 0.5            |

## Working style here
- Default to **Portuguese** in responses unless asked otherwise.
- Treat this as a learning context: derive results step by step (Laplace/Z transforms, ZOH
  discretization, root locus, w-transform, state space) rather than just emitting answers.
