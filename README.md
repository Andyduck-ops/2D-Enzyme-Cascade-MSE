# 2D Enzyme Cascade Simulation

<!-- Language Switch -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange.svg)](https://www.mathworks.com/products/matlab.html)

- Theory: [2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)

A modular MATLAB framework for simulating a two-step enzyme cascade in 2D with mineral-surface-localized enzymes. It supports two modes (MSE vs bulk), heterogeneous diffusion, τ-leaping reactions, crowding inhibition, batch Monte Carlo, and reproducible outputs.

## Overview

- Two-step cascade: $\mathrm{S} \xrightarrow{\mathrm{GOx}} \mathrm{I} \xrightarrow{\mathrm{HRP}} \mathrm{P}$
- Modes:
  - MSE: enzymes localized to a ring film around a central particle
  - Bulk: enzymes uniformly distributed in the box
- Heterogeneous diffusion (film vs bulk), reflective boundaries, stochastic reactions per time step
- Batch runs with summary CSV and optional visualizations

## Background (why MSE vs bulk)
- Motivation
  - Mineral-surface enzyme (MSE) localization concentrates reacting species near a particle, enhancing encounter probability compared to bulk dispersion.
  - This study investigates how localization, diffusion contrast, enzyme numbers/split, and local crowding collectively influence yield and kinetics relative to a homogeneous bulk.
- 2D abstraction of an interfacial layer
  - We approximate a thin surface film as a ring $[r_p, r_p+f_t]$ around a central particle (enzymes fixed in MSE; free placement in bulk).
  - Defaults reflect a strong diffusion contrast (e.g., $D_{\mathrm{film}}=10$ vs $D_{\mathrm{bulk}}=1000\,\mathrm{nm}^2/\mathrm{s}$) and moderate film thickness ($f_t=5\,\mathrm{nm}$), see [default_config.m](modules/config/default_config.m).
- Reaction context
  - Two-step cascade $\mathrm{S} \xrightarrow{\mathrm{GOx}} \mathrm{I} \xrightarrow{\mathrm{HRP}} \mathrm{P}$; enzymes are split GOx/HRP (default 50/50 via `gox_hrp_split`).
  - Local crowding reduces effective $k_{\mathrm{cat}}$ via a bounded inhibition term; this penalizes dense patches and encodes steric/competition effects.
- Assumptions (scope)
  - Enzymes immobile; S/I/P diffuse; reflective boundaries; $\tau$‑leaping with fixed $\Delta t$; no adsorption/desorption; MSE ring strictly enforced for accepted events.
- Paper-facing outputs
  - Product advantage (MSE vs bulk), reaction-rate curves, spatial event maps, tracer paths; batch CSV for mean/variance reporting.
  - Visualization entrypoints: [plot_event_map.m](modules/viz/plot_event_map.m), [plot_tracers.m](modules/viz/plot_tracers.m), [plot_product_curve.m](modules/viz/plot_product_curve.m)

Key entrypoints:
- Runner: [main_2d_pipeline.m](main_2d_pipeline.m)
- Single simulation: [simulate_once()](modules/sim_core/simulate_once.m)  
- Batch Monte Carlo: [run_batches()](modules/batch/run_batches.m)   
- Default config: [default_config()](modules/config/default_config.m)

## Methods (paper-aligned summary)

- Geometry and species
  - 2D box of side length $L$; central particle of radius $r_p$; MSE ring $[r_p, r_p+f_t]$ (enzymes fixed in ring), bulk mode places enzymes uniformly in the box.
  - Diffusive species: substrate S, intermediate I, product P.

- One time step ($\Delta t$)
  1) Diffusion (BD): for each particle position $\mathbf{x}$
  
$$
\mathbf{x} \leftarrow \mathbf{x} + \sqrt{2\,D(\mathbf{x})\,\Delta t}\,\boldsymbol{\eta},\quad \boldsymbol{\eta} \sim \mathcal{N}(\mathbf{0}, \mathbf{I}_2)
$$

  2) Boundaries: reflect at box walls and at the particle boundary.
  3) Optional: tracer update if enabled.
  4) Reactions (per enzyme, per encounter):  
  
$$
P_{\mathrm{GOx}} = 1 - e^{-k_{\mathrm{cat,GOx}}\,\Delta t}\,(1 - \mathrm{inhibition}_{\mathrm{GOx}}),\quad
P_{\mathrm{HRP}} = 1 - e^{-k_{\mathrm{cat,HRP}}\,\Delta t}\,(1 - \mathrm{inhibition}_{\mathrm{HRP}})
$$

  with crowding inhibition
  
$$
\mathrm{inhibition} = I_{\max}\,\max\!\left(0,1 - \frac{n_{\mathrm{local}}}{n_{\mathrm{sat}}}\right).
$$

  In MSE mode, accepted reaction events must lie within the ring $[r_p, r_p+f_t]$.

- Recorded outputs (per run)
  - Final product count: products_final
  - Time axis $t=(1..N)\,\Delta t$; reaction rates $r_{\mathrm{GOx}}(t), r_{\mathrm{HRP}}(t)$; product curve $P(t) = \sum r_{\mathrm{HRP}}(t)\,\Delta t$
  - Optional: snapshots, tracer paths, spatial reaction event coordinates

- Config mapping to symbols
  - $L$ → simulation_params.box_size
  - $\Delta t$ → simulation_params.time_step
  - $r_p$ → geometry_params.particle_radius
  - $f_t$ → geometry_params.film_thickness
  - $D_{\mathrm{bulk}}, D_{\mathrm{film}}$ → particle_params.diff_coeff_bulk, diff_coeff_film
  - $k_{\mathrm{cat,GOx}}, k_{\mathrm{cat,HRP}}$ → particle_params.k_cat_GOx, k_cat_HRP
  - $I_{\max}, n_{\mathrm{sat}}, R_{\mathrm{inhibit}}$ → inhibition_params.I_max, n_sat, R_inhibit

- Monte Carlo and seeds
  - Use [run_batches.m](modules/batch/run_batches.m) with fixed seeds for determinism per $\Delta t$ and config; set `batch.seed_mode='fixed'` or provide seed list.
  - For statistical reporting, choose $M\ge 30$ batches; aggregated CSV is written via [write_report_csv.m](modules/io/write_report_csv.m)

## Algorithm

### Geometry and States
- Domain: 2D square of size $L \times L$
- Central particle: radius $r_p$
- Enzyme film: ring $[r_p, r_p+f_t]$ for MSE mode
- Species: substrate S, intermediate I, product P (diffusive particles); enzymes fixed

### Diffusion (Brownian step)
For each particle position $\mathbf{x} \in \mathbb{R}^2$:

$$
\mathbf{x} \leftarrow \mathbf{x} + \sqrt{2\,D(\mathbf{x})\,\Delta t}\,\boldsymbol{\eta},\quad \boldsymbol{\eta} \sim \mathcal{N}(\mathbf{0}, \mathbf{I}_2)
$$

$D(\mathbf{x})$ is piecewise:
- MSE mode: $D = D_{\mathrm{film}}$ inside the film ring; $D = D_{\mathrm{bulk}}$ elsewhere
- Bulk mode: $D = D_{\mathrm{bulk}}$ everywhere

Implementation: [diffusion_step()](modules/sim_core/diffusion_step.m)

### Boundaries
- Box reflection (mirror)
- Central particle reflection to a target radius > $r_p$ for stability  
Implementation: [boundary_reflection()](modules/sim_core/boundary_reflection.m)

### Reactions (τ-leaping per Δt)

Two independent channels per step:

$$
\mathrm{S} + \mathrm{GOx} \rightarrow \mathrm{I},\quad P_{\mathrm{GOx}} = 1 - e^{-k_{\mathrm{cat,GOx}}\,\Delta t}\,\bigl(1 - \mathrm{inhibition}_{\mathrm{GOx}}\bigr)
$$
$$
\mathrm{I} + \mathrm{HRP} \rightarrow \mathrm{P},\quad P_{\mathrm{HRP}} = 1 - e^{-k_{\mathrm{cat,HRP}}\,\Delta t}\,\bigl(1 - \mathrm{inhibition}_{\mathrm{HRP}}\bigr)
$$
Inhibition from local crowding (per enzyme):
  
  
$$
\mathrm{inhibition} = I_{\max}\,\max\!\left(0,\, 1 - \frac{n_{\mathrm{local}}}{n_{\mathrm{sat}}}\right)
$$
MSE mode additionally restricts events to film ring.  
Implementation: [reaction_step()](modules/sim_core/reaction_step.m)

### Recording
- Instantaneous reaction counts → reaction rates
- Product curve P(t) via integrating HRP rate
- Optional snapshots, tracer paths, and spatial reaction events  
  
Implementation: [record_data()](modules/sim_core/record_data.m)


### Orchestration
Time loop:
```matlab
for step = 1..N
  diffusion, boundary reflection, (optional) tracer update
  reactions (GOx then HRP), record
end
```
Implementation: [simulate_once()](modules/sim_core/simulate_once.m)


### Batch / Reproducibility
- Per-batch RNG setup and seed control
- Aggregation into table + CSV
Batch: [run_batches()](modules/batch/run_batches.m)  
RNG: [setup_rng()](modules/rng/setup_rng.m)  
Seeds: [get_batch_seeds()](modules/seed_utils/get_batch_seeds.m)

## Project Layout

```
2D/
├─ main_2d_pipeline.m                  # top-level pipeline
├─ modules/
│  ├─ config/
│  │  ├─ default_config.m              # defaults  
│  │  └─ interactive_config.m          # interactive overrides
│  ├─ sim_core/
│  │  ├─ simulate_once.m               # single-run orchestrator
│  │  ├─ init_positions.m              # initial state
│  │  ├─ diffusion_step.m              # BD step
│  │  ├─ boundary_reflection.m         # reflections
│  │  ├─ reaction_step.m               # τ-leaping reactions
│  │  └─ record_data.m                 # accumulation
│  ├─ batch/
│  │  └─ run_batches.m                 # batch runner
│  ├─ viz/
│  │  ├─ plot_product_curve.m
│  │  ├─ plot_event_map.m
│  │  └─ plot_tracers.m
│  └─ io/
│     └─ write_report_csv.m
└─ docs/
   └─ 2d_model_theory.md               # extended notes
```

Direct links:  
- Pipeline: [main_2d_pipeline.m](main_2d_pipeline.m)  
- Theory: [2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)

## Installation

Requirements:
- MATLAB R2019b+  
- Statistics and Machine Learning Toolbox (for `pdist2`)  
- Parallel Computing Toolbox (optional for batches)

Clone and open in MATLAB:
```bash
git clone https://github.com/your-org/2D-Enzyme-Cascade-Simulation.git
cd 2D-Enzyme-Cascade-Simulation
```

MATLAB path setup is handled in [main_2d_pipeline.m](main_2d_pipeline.m) by adding `modules/`.

## Quick Start

Interactive run:
```matlab
% at project root in MATLAB
main_2d_pipeline
```

Non-interactive snippet:
```matlab
config = default_config();                        % default_config()
config.simulation_params.simulation_mode = 'MSE';
config.batch.batch_count = 5;
config.ui_controls.visualize_enabled = true;
T = run_batches(config, (1001:1005)');            % run_batches()
```

Outputs:  
- `out/batch_results.csv` via [write_report_csv()](modules/io/write_report_csv.m)
- Optional figures if `visualize_enabled = true` (product curve, event map, tracers)


## Examples

Compare MSE vs bulk modes:
```matlab
config = default_config();
config.batch.batch_count = 1;

config.simulation_params.simulation_mode = 'MSE';
r1 = simulate_once(config, 1234);                 % [simulate_once()](modules/sim_core/simulate_once.m)

config.simulation_params.simulation_mode = 'bulk';
r2 = simulate_once(config, 1234);

fprintf('Final products | MSE=%d, bulk=%d, factor=%.2fx\n', ...
  r1.products_final, r2.products_final, r1.products_final / max(r2.products_final,1));
```

High vs low enzyme counts:

```matlab
config = default_config();
for ne = [100, 400]
  config.particle_params.num_enzymes = ne;
  rr = simulate_once(config, 1000 + ne);
  fprintf('num_enzymes=%d  products_final=%d\n', ne, rr.products_final);
end
```

## Visualization

- Toggle: set `config.ui_controls.visualize_enabled = true;`
- Plots:
  - Product curve: [modules/viz/plot_product_curve.m](modules/viz/plot_product_curve.m)
  - Event map: [modules/viz/plot_event_map.m](modules/viz/plot_event_map.m)
  - Tracers: [modules/viz/plot_tracers.m](modules/viz/plot_tracers.m)
- Minimal example:
```matlab
config = default_config();
config.ui_controls.visualize_enabled = true;
res = simulate_once(config, 2025);
```

## Configuration Keys (selected)

From [default_config()](modules/config/default_config.m):
- `simulation_params.box_size` (nm), `total_time` (s), `time_step` (s), `simulation_mode` ('MSE'|'bulk')
- `particle_params.num_enzymes`, `num_substrate`, `diff_coeff_bulk` (nm²/s), `diff_coeff_film` (nm²/s), `k_cat_GOx`, `k_cat_HRP`
- `geometry_params.particle_radius` (nm), `film_thickness` (nm)
- `inhibition_params.R_inhibit` (nm), `n_sat`, `I_max` (0..1)
- `batch.batch_count`, `seed_mode`, `fixed_seed`, `use_gpu`, `use_parfor`
- `ui_controls.visualize_enabled`, `io.outdir`

## Reproducibility

- Seeds recorded per batch; RNG can be fixed via `batch.seed_mode = 'fixed'` and `batch.fixed_seed`
- Batch summary CSV plus optional `mc_summary.csv` at the end of [main_2d_pipeline.m](main_2d_pipeline.m)  
- Deterministic $\tau$-leaping per step size $\Delta t$

## License and Credits

- License: MIT (see [LICENSE](LICENSE))  
- Authors: Rongfeng Zheng , Weifeng Chen — Sichuan Agricultural University
- Contact: please open a GitHub Issue or add your email entry here
