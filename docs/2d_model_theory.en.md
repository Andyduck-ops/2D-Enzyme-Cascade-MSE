# 2D Enzyme Cascade Simulation: Mathematical Theory and Simulation Methods Analysis

Language: [English](2d_model_theory.en.md) | [中文](2d_model_theory.md)

> This document systematically organizes the physical modeling, mathematical equations, stochastic/Monte Carlo mechanisms, statistical convergence, and code implementation mapping of the current 2D enzyme cascade simulation, facilitating reproduction, review, and extension.

- Main Control Entry and Batch Processing:
  - [2D/main_2d_pipeline.m](../main_2d_pipeline.m)
  - [2D/modules/batch/run_batches.m](../modules/batch/run_batches.m)
  - [2D/modules/seed_utils/get_batch_seeds.m](../modules/seed_utils/get_batch_seeds.m)
- Single Simulation and Core Physics:
  - [2D/modules/sim_core/simulate_once.m](../modules/sim_core/simulate_once.m)
  - [2D/modules/sim_core/init_positions.m](../modules/sim_core/init_positions.m)
  - [2D/modules/sim_core/diffusion_step.m](../modules/sim_core/diffusion_step.m)
  - [2D/modules/sim_core/boundary_reflection.m](../modules/sim_core/boundary_reflection.m)
  - [2D/modules/sim_core/reaction_step.m](../modules/sim_core/reaction_step.m)
  - [2D/modules/sim_core/precompute_inhibition.m](../modules/sim_core/precompute_inhibition.m)
  - [2D/modules/sim_core/record_data.m](../modules/sim_core/record_data.m)
- Visualization (Event Maps/Trajectories, etc.):
  - [2D/modules/viz/plot_event_map.m](../modules/viz/plot_event_map.m)
  - [2D/modules/viz/plot_tracers.m](../modules/viz/plot_tracers.m)

---

## 1. System Overview and Modeling Assumptions

- Geometry and Boundaries
  - 2D square box with side length $L$ (default $500\,\mathrm{nm}$), containing a central particle with radius $r_p$ (default $20\,\mathrm{nm}$) and a film region with thickness $f_t$ (default $5\,\mathrm{nm}$).
  - Boundary conditions: Box walls and particle surface are specular reflective (no absorption).
- Species and Processes
  - Substrate S undergoes random diffusion; GOx and HRP are fixed in the film region (MSE mode) or distributed in bulk (bulk mode).
  - Cascade reaction: S —(GOx)→ I —(HRP)→ P.
- Key Parameters (default values in configuration):
  - Diffusion coefficients: $D_{\text{bulk}} = 1000\,\mathrm{nm}^2/\mathrm{s}$, $D_{\text{film}} = 10\,\mathrm{nm}^2/\mathrm{s}$.
  - Rate constants: $k_{\mathrm{cat,GOx}} = 100\,\mathrm{s}^{-1}$, $k_{\mathrm{cat,HRP}} = 100\,\mathrm{s}^{-1}$.
  - Crowding inhibition: Range $R_{\text{inhibit}} = 10\,\mathrm{nm}$, saturation threshold $n_{\text{sat}} = 5$, maximum inhibition $I_{\max} = 0.8$.
- Configuration Entry
  - [2D/modules/config/default_config.m](../modules/config/default_config.m)
  - [2D/modules/config/interactive_config.m](../modules/config/interactive_config.m)

---

## 2. Continuum Model (PDE Perspective)

The reaction-diffusion equations in 2D space (qualitative display):

$$
\frac{\partial [\mathrm{S}]}{\partial t} = D \nabla^2[\mathrm{S}] - k_{\mathrm{GOx}}[\mathrm{S}][\mathrm{GOx}] \\
\frac{\partial [\mathrm{I}]}{\partial t} = D \nabla^2[\mathrm{I}] + k_{\mathrm{GOx}}[\mathrm{S}][\mathrm{GOx}] - k_{\mathrm{HRP}}[\mathrm{I}][\mathrm{HRP}] \\
\frac{\partial [\mathrm{P}]}{\partial t} = D \nabla^2[\mathrm{P}] + k_{\mathrm{HRP}}[\mathrm{I}][\mathrm{HRP}]
$$

Explanation:

- $\nabla^2 = \frac{\partial^2}{\partial x^2} + \frac{\partial^2}{\partial y^2}$.
- In MSE mode, $[\mathrm{GOx}]$ and $[\mathrm{HRP}]$ are effectively concentrated in the film annular region ($r \in [r_p, r_p+f_t]$), appearing as strongly non-uniform source terms.
- Nonlinearity and singular boundaries make analytical solutions difficult, so stochastic particle/Monte Carlo methods are used for numerical approximation.

---

## 3. Stochastic Particle Simulation (Monte Carlo BD + Event-Driven)

This model uses Brownian Dynamics for discrete diffusion, combined with fixed-step stochastic reaction determination (τ-leaping approximation).

### 3.1 Diffusion Discretization (Brownian Step)

- Theory:

$$
\Delta \mathbf{r} = \sqrt{2\,D\,\Delta t}\,\boldsymbol{\eta},\quad \boldsymbol{\eta} \sim \mathcal{N}(\mathbf{0}, \mathbf{I}_2)
$$

- Code correspondence: Gaussian displacement is superimposed on particle positions (D chosen based on bulk/film).
- File: [2D/modules/sim_core/diffusion_step.m](../modules/sim_core/diffusion_step.m)

### 3.2 Boundary and Film Region Constraints

- Box and particle surface specular reflection: Normal component is reversed.
- MSE mode: Reaction sites and feasible encounters are restricted to the film ring r ∈ [r_p, r_p + f_t].
- File: [2D/modules/sim_core/boundary_reflection.m](../modules/sim_core/boundary_reflection.m), film ring constraints in [2D/modules/sim_core/reaction_step.m](../modules/sim_core/reaction_step.m)

### 3.3 Reaction Probability and Event Sampling (Gillespie Style)

- Single-step reaction probability:

$$
p = 1 - e^{-k_{\mathrm{eff}}\,\Delta t},\qquad k_{\mathrm{eff}} = k_{\mathrm{cat}}\bigl(1 - \mathrm{inhibition}\bigr)
$$

- Determination: Sample $u \sim \mathcal{U}(0,1)$, if $u < p$, then a reaction event occurs ($\mathrm{S}\!\to\!\mathrm{I}$ or $\mathrm{I}\!\to\!\mathrm{P}$).
- Event coordinates: Sampled and recorded near the encounter pair (enzyme-substrate) for event heatmaps.
- File: [2D/modules/sim_core/reaction_step.m](../modules/sim_core/reaction_step.m)

### 3.4 Crowding Inhibition (Local Modulation)

- Count local crowding degree $n_{\text{local}}$ within neighbor radius ($R_{\text{inhibit}}$), forming inhibition weight:

$$
\mathrm{inhibition} = I_{\max}\,\max\!\left(0,\, 1 - \frac{n_{\text{local}}}{n_{\text{sat}}}\right).
$$

- File: [2D/modules/sim_core/precompute_inhibition.m](../modules/sim_core/precompute_inhibition.m)

### 3.5 Data Accumulation and Time Integration

- Rates: $r_{\mathrm{GOx}}(t) = n_{\mathrm{GOx,step}}/\Delta t$; similarly $r_{\mathrm{HRP}}(t)$.
- Product curve: $P(t) \approx \sum r_{\mathrm{HRP}}(t)\,\Delta t$.
- Snapshots/layering/trajectories are selectively recorded according to configuration.
- File: [2D/modules/sim_core/record_data.m](../modules/sim_core/record_data.m), summarized in [2D/modules/sim_core/simulate_once.m](../modules/sim_core/simulate_once.m)

---

## 4. Batch Monte Carlo Statistics and Convergence

- Single batch output: Final product count `products_final`, plus trajectories/events, etc.
- Multi-batch statistics: Run $M$ times with independent seeds, estimate expectation and variance:

$$
\hat{\mu} = \frac{1}{M}\sum_{m=1}^M P_m,\qquad \mathrm{Var}(\hat{\mu}) = \frac{\sigma^2}{M}.
$$

- Recommendations:
  - Validation/parameter tuning phase: M≈5–10;
  - Reporting/interval estimation: M≥30, and output mean ± confidence interval.
- File: [2D/modules/batch/run_batches.m](../modules/batch/run_batches.m), seed strategy in [2D/modules/seed_utils/get_batch_seeds.m](../modules/seed_utils/get_batch_seeds.m)

---

## 5. Code Implementation Flowchart (Logical Overview)

```mermaid
graph TD;
    A[Init/Config];
    B[Seeds];
    C[Batch loop];
    D[Setup RNG];
    E[Simulate once];
    E1[Init & inhibition precomp];
    E2[Time loop 1..N];
    E3[Diffusion];
    E4[Reflection & MSE];
    E5[Reactions];
    E6[Record];
    F[Summarize products_final];
    G[Aggregate & write CSV];
    H[Visualization optional];

    A --> B;
    B --> C;
    C --> D;
    D --> E;
    E --> E1;
    E1 --> E2;
    E2 --> E3;
    E3 --> E4;
    E4 --> E5;
    E5 --> E6;
    E6 --> F;
    F --> G;
    G --> H;
```

- Entry: [2D/main_2d_pipeline.m](../main_2d_pipeline.m)
- Single simulation: [2D/modules/sim_core/simulate_once.m](../modules/sim_core/simulate_once.m)

---

## 6. Code Mapping Quick Reference

- Main Control and IO
  - [2D/main_2d_pipeline.m](../main_2d_pipeline.m): Unified workflow, visualization, and reporting
  - [2D/modules/batch/run_batches.m](../modules/batch/run_batches.m): Batch loop and result aggregation
  - [2D/modules/seed_utils/get_batch_seeds.m](../modules/seed_utils/get_batch_seeds.m): Seed strategy
- Physics Core
  - [2D/modules/sim_core/simulate_once.m](../modules/sim_core/simulate_once.m): Single simulation facade
  - [2D/modules/sim_core/init_positions.m](../modules/sim_core/init_positions.m): Initial positions
  - [2D/modules/sim_core/diffusion_step.m](../modules/sim_core/diffusion_step.m): Brownian diffusion
  - [2D/modules/sim_core/boundary_reflection.m](../modules/sim_core/boundary_reflection.m): Boundary/particle reflection
  - [2D/modules/sim_core/reaction_step.m](../modules/sim_core/reaction_step.m): Reaction events and film ring constraints
  - [2D/modules/sim_core/precompute_inhibition.m](../modules/sim_core/precompute_inhibition.m): Crowding inhibition
  - [2D/modules/sim_core/record_data.m](../modules/sim_core/record_data.m): Rate/curve accumulation
- Visualization
  - [2D/modules/viz/plot_event_map.m](../modules/viz/plot_event_map.m): Spatial event maps
  - [2D/modules/viz/plot_tracers.m](../modules/viz/plot_tracers.m): Particle trajectories
  - Other plot_* files in `modules/viz/`

---

## 7. Terminology and Reference

- Brownian Dynamics: Discrete Wiener process simulation of diffusion through $\Delta r = \sqrt{2D\Delta t}\cdot\eta$.
- Gillespie/τ-leaping: Fixed-step event probability approximation using $p=1-\exp(-k\Delta t)$.
- Smoluchowski Encounter Theory: Encounter rates for diffusion-controlled reactions, expressed differently in 2D/3D.

To export this theory document as PDF, you can use export plugins in VSCode after rendering, or copy to document tools for formatting conversion.