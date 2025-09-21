# 2D Enzyme Cascade Simulation


<!-- Language Switch -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)


<!-- Project Badges -->
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](#)
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-purple.svg)](docs/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)


<!-- Core Links -->
- 📖 **Documentation**: [2D Theory (English)](docs/2d_model_theory.en.md) | [Theory（中文）](docs/2d_model_theory.md)
- 🎯 **Quick Start**: [Installation](#installation) | [Usage](#quick-start) | [Examples](#examples)
- ⚡ **Features**: [Key Features](#key-features) | [Algorithm](#algorithm) | [Visualization](#visualization)

## 🎯 Project Overview

A comprehensive, modular MATLAB framework for investigating **protocell emergence** through computational modeling of mineral-guided molecular enrichment processes. This framework simulates two-step enzyme cascade reactions in 2D space with mineral-surface-localized enzymes, addressing fundamental questions about how organized biological systems could have emerged from dilute **prebiotic chemistry** environments on early Earth. The computational platform implements advanced stochastic simulations including heterogeneous diffusion, $\tau$-leaping reactions, molecular crowding effects, batch Monte Carlo analysis, and fully reproducible scientific computations to quantify the **interfacial driving forces** critical for **compartmentalization** and **proto-metabolic flux** generation.

### Key Scientific Context

This research investigates **mineral-guided molecular enrichment as an interfacial driving force for protocell emergence** - a fundamental mechanism addressing how organized, compartmentalized biological systems could have originated from dilute prebiotic environments on early Earth. The study focuses on **Mineral-Surface Enzyme (MSE) localization effects**, where spatial co-adsorption of biomacromolecules near mineral interfaces creates concentration gradients that drive proto-metabolic flux, mimicking substrate channeling found in modern cellular systems.

The computational framework implements stochastic Brownian dynamics simulations of enzyme cascade reactions that model the critical transition from geochemical to biochemical complexity. This addresses a core challenge in origin-of-life research: how primitive metabolic networks could achieve sufficient molecular organization and concentration to sustain autocatalytic processes under the dilute conditions prevalent in prebiotic environments. By comparing mineral surface-mediated enrichment (MSE) versus bulk distribution scenarios, we quantitatively assess how interfacial processes could have resolved the "concentration problem" that has long puzzled researchers studying the emergence of life from non-living matter.

### Research Impact
- **Primary Goal**: Elucidate how mineral-guided molecular enrichment serves as a pathway from dilute prebiotic chemistry to organized protocell systems through quantitative computational modeling
- **Key Scientific Breakthrough**: Demonstrates that interfacial driving forces can achieve the molecular crowding and spatial organization necessary for proto-metabolic networks, bridging the gap between geochemistry and biochemistry
- **Origin-of-Life Implications**: Provides mechanistic insights into how early Earth mineral surfaces could have facilitated the emergence of compartmentalized reaction systems that preceded cellular life
- **Broader Applications**: Biocatalysis optimization, enzyme engineering for industrial processes, synthetic biology for artificial cell construction, and prebiotic chemistry research for astrobiology
- **Methodological Contribution**: Establishes a robust computational framework for studying interfacial biochemistry under early Earth conditions, advancing our understanding of life's origins

## Overview

**Protocell Emergence Modeling Framework**:
- **Enzyme cascade system**: S -(GOx)-> I -(HRP)-> P - mimics **substrate channeling** in primitive proto-metabolic networks
- **Comparative modes** representing stages of **prebiotic evolution**:
  - **MSE mode**: Enzymes localized to a ring film around a central mineral particle, modeling **mineral-guided molecular enrichment**
  - **Bulk mode**: Enzymes uniformly distributed throughout the domain, representing dilute **prebiotic chemistry** conditions
- **Interfacial physics**: Heterogeneous diffusion (film vs bulk regions), reflective boundaries, stochastic reaction kinetics modeling **early Earth conditions**
- **Statistical framework**: Batch runs with comprehensive statistical analysis, CSV exports, and visualization tools for quantifying **protocell emergence** pathways

## Background (why MSE vs bulk)

### Motivation
This computational framework addresses a fundamental question in origin-of-life research: how did organized, compartmentalized biological systems emerge from the dilute prebiotic environments of early Earth? We investigate **mineral-guided molecular enrichment** as a key interfacial driving force that could have facilitated **protocell emergence** by resolving the "concentration problem" - the challenge of achieving sufficient molecular crowding for sustained biochemical processes in primitive aqueous environments.

To quantitatively assess how mineral surface-mediated enrichment (MSE) serves as a pathway from geochemical to biochemical complexity, we employ stochastic Brownian dynamics simulations of a two-step enzymatic cascade reaction system that mimics **substrate channeling** found in modern metabolic networks. The computational model assumes a 500 nm cubic domain representing a prebiotic microenvironment where substrate molecules, intermediate products, and final products undergo free diffusion, while enzyme-like catalysts remain spatially constrained near mineral interfaces - modeling the critical transition that likely preceded cellular **compartmentalization**.

MSE localization creates concentration gradients that drive **proto-metabolic flux**, concentrating reacting species near mineral particles and dramatically enhancing encounter probabilities compared to bulk dispersion. This mechanism represents a plausible solution to how primitive reaction networks could have achieved the molecular organization necessary for autocatalytic processes under **early Earth conditions**, providing computational insights into the emergence of life from non-living matter.

### Scientific Framework
- **Molecular Diffusion**: Follows Brownian motion with position updates $\Delta r = \sqrt{2D \Delta t} \eta$, where $\eta$ represents Gaussian white noise
- **Heterogeneous Environment**: Diffusion coefficients are set to $D_{\text{bulk}} = 1000 \text{ nm}^2/\text{s}$ for bulk regions and $D_{\text{film}} = 10 \text{ nm}^2/\text{s}$ within the enzyme film layer
- **Spatial Confinement**: 2D abstraction approximates a thin surface film as a ring [r_p, r_p + f_t] around a central particle (enzymes fixed in MSE; free placement in bulk)

### Reaction System
- **Two-step cascade**: S -(GOx)-> I -(HRP)-> P with enzymes split GOx/HRP (default 50/50 via `gox_hrp_split`)
- **$\tau$-leaping kinetics**: Reaction probability follows $P = 1 - \exp(-k_{\text{cat}} \Delta t)$, where $k_{\text{cat}} = 100 \text{ s}^{-1}$ for both enzymes
- **Crowding effects**: Local enzyme density modulates effective catalytic rates according to $\text{inhibition\_factor} = 1 - I_{\text{max}} \times \min(n_{\text{local}}/n_{\text{sat}}, 1)$, with $I_{\text{max}} = 0.8$ and $n_{\text{sat}} = 5$

### Key Comparisons
The framework systematically compares two fundamental configurations representing distinct stages of **prebiotic evolution**:
- **MSE mode**: Enzymes concentrated within a 5 nm film around a central mineral particle (radius = 20 nm), modeling the **mineral-guided molecular enrichment** that drives spatially co-adsorbed biomacromolecule assemblies essential for **protocell emergence**
- **Bulk mode**: Uniform enzyme distribution throughout the simulation domain, representing dilute **prebiotic chemistry** environments lacking organizational driving forces
- **Evolutionary significance**: This comparison directly addresses how **interfacial driving forces** overcome the concentration problem in origin-of-life scenarios, quantifying the transition from geochemical to biochemical complexity
- **Flexible parameters**: Supports varying enzyme concentrations to model different system densities under diverse **early Earth conditions**, enabling systematic study of the pathway to organized protocell systems

## ⚡ Key Features

### 🧬 Advanced Simulation Capabilities for Protocell Emergence Studies
- **Proto-metabolic Network Modeling**: Two-step enzyme cascade S -(GOx)-> I -(HRP)-> P mimicking **substrate channeling** in primitive biochemical networks
- **Prebiotic Evolution Simulation Modes**:
  - **MSE Mode**: Enzymes localized to a ring film around a central mineral particle, modeling **mineral-guided molecular enrichment** and **protocell emergence** pathways
  - **Bulk Mode**: Enzymes uniformly distributed throughout the domain, representing dilute **prebiotic chemistry** environments
- **Interfacial Driving Forces**: Heterogeneous diffusion coefficients capturing **early Earth conditions** with different molecular mobility in film vs bulk regions
- **Prebiotic Reaction Kinetics**: $\tau$-leaping methodology with probabilistic reaction events modeling stochastic molecular encounters under primitive conditions
- **Molecular Crowding Physics**: Local density effects on catalytic efficiency, simulating **compartmentalization** effects critical for **proto-metabolic flux** generation

### 🔬 Scientific Rigor
- **Reproducible Results**: Deterministic simulations with fixed random seeds
- **Batch Monte Carlo**: Statistical analysis across multiple independent runs
- **Boundary Conditions**: Reflect particles at box walls and particle surface
- **Physical Validation**: Models based on established biophysical principles

### 📊 Comprehensive Analysis
- **Real-time Visualization**: Product curves, event maps, and tracer trajectories
- **Statistical Reporting**: CSV outputs with means, variances, and confidence intervals
- **Spatial Analysis**: Heat maps of reaction events and particle distributions
- **Performance Metrics**: Reaction rates, yields, and efficiency factors

Key entrypoints:
- Runner: [main_2d_pipeline.m](main_2d_pipeline.m)
- Single simulation: [simulate_once()](modules/sim_core/simulate_once.m)
- Batch Monte Carlo: [run_batches()](modules/batch/run_batches.m)
- Default config: [default_config()](modules/config/default_config.m)

## Methods (paper-aligned summary)

### Computational Geometry and Species
- **Domain**: 2D square box of side length L = 500 nm with reflective boundaries
- **Central particle**: Radius r_p = 20 nm with reflective surface
- **MSE configuration**: Enzymes localized to film ring [r_p, r_p + f_t] where f_t = 5 nm
- **Bulk configuration**: Enzymes uniformly distributed throughout the domain
- **Molecular species**: Substrate (S), Intermediate (I), and Product (P) undergo free diffusion; enzymes remain spatially fixed

### Diffusion (Brownian step)
For each particle position $x \in \mathbb{R}^2$:

$x \leftarrow x + \sqrt{2 D(x) \Delta t} \cdot \eta$, where $\eta \sim N(0, I_2)$

D(x) is piecewise:
- MSE mode: D = D_film inside the film ring; D = D_bulk elsewhere
- Bulk mode: D = D_bulk everywhere

### Boundaries
- Box reflection (mirror)
- Central particle reflection to a target radius > r_p for stability

### Reactions ($\tau$-leaping per $\Delta t$)

Two independent channels per step:

- S + GOx $\rightarrow$ I, $P_{\text{GOx}} = (1 - \exp(-k_{\text{cat,GOx}} \Delta t)) \times \text{inhibition\_factor}_{\text{GOx}}$
- I + HRP $\rightarrow$ P, $P_{\text{HRP}} = (1 - \exp(-k_{\text{cat,HRP}} \Delta t)) \times \text{inhibition\_factor}_{\text{HRP}}$

Inhibition from local crowding (per enzyme):

$\text{inhibition\_factor} = 1 - I_{\text{max}} \times \min(n_{\text{local}} / n_{\text{sat}}, 1)$

MSE mode additionally restricts events to film ring.

### Recording
- Instantaneous reaction counts -> reaction rates
- Product curve P(t) via integrating HRP rate
- Optional snapshots, tracer paths, and spatial reaction events

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

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Quick Reproduction](#-quick-reproduction)
- [Examples](#-examples)
- [Reproducibility](#-reproducibility)
- [Algorithm Details](#-algorithm)
- [Configuration](#-configuration)
- [Visualization](#-visualization)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)
- [Authors and Citation](#-authors-and-citation)

## 📦 Installation

### System Requirements
- **MATLAB Version**: R2019b or later
- **Required Toolboxes**:
  - Statistics and Machine Learning Toolbox (for `pdist2`)
  - Parallel Computing Toolbox (optional, for batch processing acceleration)
- **Operating System**: Windows, macOS, or Linux
- **Memory**: Minimum 4GB RAM, 8GB+ recommended for large simulations

### Quick Installation
```bash
# Clone the repository
git clone https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE.git
cd 2D-Enzyme-Cascade-Simulation

# Optional: Create output directory
mkdir -p out
```

### MATLAB Setup
1. Open MATLAB and navigate to the project root directory
2. The main pipeline automatically adds `modules/` to the MATLAB path
3. Verify installation by running:
```matlab
% At project root in MATLAB
main_2d_pipeline
```

## 🚀 Quick Start

### Interactive Mode (Recommended for Beginners)
```matlab
% At project root in MATLAB
main_2d_pipeline
% Follow the interactive prompts to configure and run simulations
```

### Programmatic Mode (Advanced Users)
```matlab
% Load default configuration
config = default_config();

% Set simulation parameters
config.simulation_params.simulation_mode = 'MSE';  % or 'bulk'
config.batch.batch_count = 10;
config.ui_controls.visualize_enabled = true;

% Run simulation
results = run_batches(config, (1001:1010)');

% View results
disp(['Final products: ', num2str(results.products_final)]);
```

### Basic Configuration Example
```matlab
% Minimal MSE simulation
config = default_config();
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 200;
config.ui_controls.visualize_enabled = true;

% Run single simulation
result = simulate_once(config, 1234);
fprintf('MSE mode produced %d products\n', result.products_final);
```

## 🔄 Quick Reproduction

### Using Reproducibility Seeds

For rapid reproduction of documented experimental results, use the seeds recorded in [`复现seed.txt`](复现seed.txt):

#### Method 1: Single Experiment Reproduction
```matlab
% Reproduce a specific documented experiment
config = default_config();

% Example: Reproduce MSE Enhancement Study
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 400;
config.particle_params.diff_coeff_film = 10;
config.simulation_params.total_time = 100.0;

% Use documented seed for exact reproduction
documented_seed = 1234;  % From 复现seed.txt
result = simulate_once(config, documented_seed);

fprintf('Reproduced result: %d products\n', result.products_final);
```

#### Method 2: Batch Reproduction with Seed Range
```matlab
% Reproduce batch experiments using consecutive seeds
config = default_config();
config.simulation_params.simulation_mode = 'MSE';
config.batch.batch_count = 30;

% Define seed range from documented experiment
base_seed = 1234;
seed_range = base_seed + (0:29);  % 30 consecutive seeds

% Run batch with specific seed sequence
batch_results = run_batches(config, seed_range);

% Compare with documented results
mean_products = mean(batch_results.products_final);
fprintf('Batch reproduction: %.1f ± %.1f products\n', ...
    mean_products, std(batch_results.products_final));
```

#### Method 3: Automated Seed Loading
```matlab
% Future enhancement: Load seeds directly from 复现seed.txt
% This functionality will be added as experiments are documented

function reproduce_experiment(experiment_name)
    % Load parameters from 复现seed.txt
    % Apply configuration automatically
    % Run reproduction and validate results
end
```

### Recording New Experiments

When you discover significant results, document them in [`复现seed.txt`](复现seed.txt):

```txt
[Your_Experiment_Name]
seed = 1234
simulation_mode = MSE
batch_count = 30
key_parameters = num_enzymes=200, diff_coeff_film=10, total_time=1.0
description = Brief description of your findings
results_summary = Key numerical results (e.g., mean±std)
date_recorded = 2025-09-21
researcher = YourName
```

## 💡 Examples

### Example 1: MSE vs Bulk Comparison
```matlab
% Comparative analysis
config = default_config();
config.batch.batch_count = 1;

% MSE mode
config.simulation_params.simulation_mode = 'MSE';
mse_result = simulate_once(config, 1234);

% Bulk mode
config.simulation_params.simulation_mode = 'bulk';
bulk_result = simulate_once(config, 1234);

% Calculate enhancement factor
enhancement = mse_result.products_final / max(bulk_result.products_final, 1);
fprintf('MSE enhancement factor: %.2fx\n', enhancement);
```

### Example 2: Enzyme Concentration Study
```matlab
% Test different enzyme concentrations
enzyme_counts = [50, 100, 200, 400, 800];
results = zeros(size(enzyme_counts));

config = default_config();
config.simulation_params.simulation_mode = 'MSE';

for i = 1:length(enzyme_counts)
    config.particle_params.num_enzymes = enzyme_counts(i);
    result = simulate_once(config, 1000 + i);
    results(i) = result.products_final;
    fprintf('Enzymes: %d, Products: %d\n', enzyme_counts(i), results(i));
end

% Plot results
plot(enzyme_counts, results, '-o');
xlabel('Number of Enzymes');
ylabel('Final Products');
title('Enzyme Concentration vs Product Yield');
grid on;
```

### Example 3: Batch Statistical Analysis
```matlab
% Multiple runs for statistical significance
config = default_config();
config.batch.batch_count = 30;  # Central Limit Theorem
config.simulation_params.simulation_mode = 'MSE';

% Run batch simulation
batch_results = run_batches(config);

% Calculate statistics
mean_products = mean(batch_results.products_final);
std_products = std(batch_results.products_final);
ci_lower = mean_products - 1.96 * std_products / sqrt(length(batch_results.products_final));
ci_upper = mean_products + 1.96 * std_products / sqrt(length(batch_results.products_final));

fprintf('Mean products: %.2f ± %.2f\n', mean_products, std_products);
fprintf('95%% CI: [%.2f, %.2f]\n', ci_lower, ci_upper);
```

### Example 4: Diffusion Parameter Study
```matlab
% Investigate diffusion coefficient effects
diff_coeff_film_values = [1, 5, 10, 20, 50];
results = zeros(size(diff_coeff_film_values));

config = default_config();
config.simulation_params.simulation_mode = 'MSE';

for i = 1:length(diff_coeff_film_values)
    config.particle_params.diff_coeff_film = diff_coeff_film_values(i);
    result = simulate_once(config, 2000 + i);
    results(i) = result.products_final;

    fprintf('D_film: %d, Products: %d\n', ...
        diff_coeff_film_values(i), results(i));
end
```

## 🔄 Reproducibility

### Research Reproducibility Framework

This project implements a comprehensive reproducibility framework essential for scientific research, enabling exact replication of experimental conditions and results. The framework supports systematic documentation of experimental seeds, conditions, and outcomes through the [复现seed.txt](复现seed.txt) file and automated seed management.

### Reproducibility Seeds File

The `复现seed.txt` file serves as a centralized repository for experimental conditions and random seeds, enabling researchers to:

- **Document experimental conditions** for key simulation runs
- **Share specific parameter combinations** that produce notable results
- **Reproduce exact simulation outcomes** across different systems and timepoints
- **Facilitate collaborative research** with standardized experimental records

### Using Reproducibility Seeds

#### 1. Recording Experimental Conditions
When you discover interesting results, record them in `复现seed.txt`:

```txt
[MSE_Enhancement_Study_Example]
seed = 1234
simulation_mode = MSE
batch_count = 30
key_parameters = num_enzymes=200, diff_coeff_film=10, total_time=1.0
description = Demonstrates significant MSE enhancement over bulk distribution
results_summary = MSE showed 3.2x enhancement in product yield (mean=150.3±12.7)
date_recorded = 2024-09-20
researcher = YourName
```

#### 2. Reproducing Documented Results
To reproduce a documented experiment:

```matlab
% Example: Reproduce the MSE Enhancement Study
config = default_config();

% Apply the documented parameters
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 200;
config.particle_params.diff_coeff_film = 10;
config.simulation_params.total_time = 1.0;
config.batch.batch_count = 30;

% Use the documented seed for exact reproduction
documented_seed = 1234;
results = run_batches(config, documented_seed);

% Verify reproduction
fprintf('Reproduced mean products: %.1f\n', mean(results.products_final));
```

#### 3. Batch Reproducibility with Seed Ranges
For systematic studies with multiple seeds:

```matlab
% Define seed range from documented experiment
base_seed = 1234;
seed_range = base_seed + (0:29);  % 30 consecutive seeds

% Run batch with specific seed sequence
config = default_config();
config.simulation_params.simulation_mode = 'MSE';
batch_results = run_batches(config, seed_range);
```

### Automated Seed Documentation

The framework automatically generates seed records during batch processing:

```matlab
% Automatic seed documentation in seeds.csv
config = default_config();
config.batch.batch_count = 50;
config.batch.seed_mode = 'fixed';  % Ensures reproducibility
config.batch.fixed_seed = 2000;

% Seeds are automatically recorded in out/seeds.csv
results = run_batches(config);
```

### Cross-Platform Reproducibility

The simulation framework ensures identical results across different platforms by:

- **Deterministic random number generation** using MATLAB's `rng()` function
- **Fixed-precision arithmetic** for all calculations
- **Consistent algorithm implementation** across all modules
- **Platform-independent file I/O** with standardized CSV formats

### Reproducibility Best Practices

1. **Always document significant findings** in `复现seed.txt`
2. **Use fixed seeds** for reproducible research (`config.batch.seed_mode = 'fixed'`)
3. **Record complete parameter sets** including all non-default values
4. **Include brief descriptions** of experimental goals and key findings
5. **Version control** your `复现seed.txt` file along with code changes
6. **Validate reproduction** by running documented experiments on different systems

### Statistical Reproducibility

For statistical studies requiring multiple independent runs:

```matlab
% Reproducible statistical analysis
config = default_config();
config.batch.batch_count = 100;

% MSE condition with documented seed
config.simulation_params.simulation_mode = 'MSE';
mse_results = run_batches(config, 3000 + (0:99));

% Bulk condition with offset seeds for independence
config.simulation_params.simulation_mode = 'bulk';
bulk_results = run_batches(config, 4000 + (0:99));

% Results are reproducible with same seed ranges
```

### Reproducibility Verification

Verify your experimental reproduction with built-in validation:

```matlab
% Load expected results from previous run
expected_mean = 150.3;
expected_std = 12.7;

% Run reproduction
reproduced_results = run_batches(config, documented_seed);
reproduced_mean = mean(reproduced_results.products_final);
reproduced_std = std(reproduced_results.products_final);

% Statistical validation
tolerance = 0.1;  % 10% tolerance for numerical precision
if abs(reproduced_mean - expected_mean) < tolerance
    fprintf('✓ Reproduction successful: %.1f vs %.1f (expected)\n', ...
        reproduced_mean, expected_mean);
else
    fprintf('✗ Reproduction failed: %.1f vs %.1f (expected)\n', ...
        reproduced_mean, expected_mean);
end
```

## ⚙️ Configuration

### Key Configuration Parameters

#### Simulation Parameters
```matlab
config.simulation_params.box_size = 500;          % nm
config.simulation_params.total_time = 100;        % s
config.simulation_params.time_step = 0.1;        % s
config.simulation_params.simulation_mode = 'MSE'; % 'MSE' or 'bulk'
```

#### Particle Parameters
```matlab
config.particle_params.num_enzymes = 400;
config.particle_params.num_substrate = 3000;
config.particle_params.diff_coeff_bulk = 1000;   % $\text{nm}^2/\text{s}$
config.particle_params.diff_coeff_film = 10;     % $\text{nm}^2/\text{s}$
config.particle_params.k_cat_GOx = 100;          % $\text{s}^{-1}$
config.particle_params.k_cat_HRP = 100;          % $\text{s}^{-1}$
```

#### Geometry Parameters
```matlab
config.geometry_params.particle_radius = 20;      % nm
config.geometry_params.film_thickness = 5;        % nm
```

#### Inhibition Parameters
```matlab
config.inhibition_params.R_inhibit = 10;          % nm
config.inhibition_params.n_sat = 5;
config.inhibition_params.I_max = 0.8;             % 0-1
```

#### Batch Processing
```matlab
config.batch.batch_count = 30;
config.batch.seed_mode = 'fixed';                  % 'fixed' or 'random'
config.batch.fixed_seed = 1234;
config.batch.use_parfor = false;                   % Parallel processing
```

### Configuration Templates

#### High-Throughput Screening
```matlab
config = default_config();
config.batch.batch_count = 100;
config.ui_controls.visualize_enabled = false;
config.simulation_params.total_time = 0.5;        % Faster screening
```

#### High-Resolution Analysis
```matlab
config = default_config();
config.simulation_params.time_step = 1e-6;        % Higher temporal resolution
config.ui_controls.visualize_enabled = true;
config.ui_controls.save_snapshots = true;
```

## 📊 Visualization

### Built-in Visualization Tools

#### 1. Product Curve Analysis
```matlab
% Plot product accumulation over time
config = default_config();
config.ui_controls.visualize_enabled = true;
result = simulate_once(config, 1234);

% Access plotting data
time_points = result.time_axis;
product_curve = result.product_curve;
reaction_rates_GOx = result.reaction_rates_GOx;
reaction_rates_HRP = result.reaction_rates_HRP;
```

#### 2. Spatial Event Maps
- **Purpose**: Visualize spatial distribution of reaction events
- **Features**: Heat map showing reaction hotspots
- **File**: `modules/viz/plot_event_map.m`

#### 3. Particle Trajectory Analysis
- **Purpose**: Track individual particle paths
- **Features**: Tracer visualization with diffusion patterns
- **File**: `modules/viz/plot_tracers.m`

### Custom Visualization Example
```matlab
% Create custom analysis plots
function plot_custom_analysis(results)
    figure('Position', [100, 100, 1200, 800]);

    % Product yield comparison
    subplot(2, 2, 1);
    plot_mse_vs_bulk(results);
    title('MSE vs Bulk Comparison');

    % Reaction rate analysis
    subplot(2, 2, 2);
    plot_reaction_rates(results);
    title('Reaction Rate Analysis');

    % Statistical distribution
    subplot(2, 2, 3);
    histogram(results.products_final);
    title('Product Distribution');
    xlabel('Final Products');
    ylabel('Frequency');

    % Enhancement Factor
    subplot(2, 2, 4);
    plot_enhancement_factor(results);
    title('Enhancement Factor Analysis');
end
```

## 📁 Project Structure

```
2D-Enzyme-Cascade-Simulation/
├── 📄 main_2d_pipeline.m              # Main entry point
├── 📄 README.md                       # English documentation
├── 📄 README.zh-CN.md                 # Chinese documentation
├── 📄 LICENSE                         # MIT license
├── 📄 CONTRIBUTING.md                 # Contribution guidelines
├── 📁 modules/                        # Core simulation modules
│   ├── 📁 config/                     # Configuration management
│   │   ├── 📄 default_config.m       # Default parameters
│   │   └── 📄 interactive_config.m   # Interactive setup
│   ├── 📁 sim_core/                  # Core simulation algorithms
│   │   ├── 📄 simulate_once.m        # Single simulation orchestrator
│   │   ├── 📄 init_positions.m       # Initial state setup
│   │   ├── 📄 diffusion_step.m       # Brownian dynamics
│   │   ├── 📄 boundary_reflection.m  # Boundary conditions
│   │   ├── 📄 reaction_step.m        # Reaction processing
│   │   ├── 📄 precompute_inhibition.m # Crowding effects
│   │   └── 📄 record_data.m          # Data recording
│   ├── 📁 batch/                     # Batch processing
│   │   └── 📄 run_batches.m          # Monte Carlo batches
│   ├── 📁 viz/                       # Visualization tools
│   │   ├── 📄 plot_product_curve.m   # Product kinetics
│   │   ├── 📄 plot_event_map.m       # Spatial events
│   │   └── 📄 plot_tracers.m         # Particle tracking
│   ├── 📁 io/                        # Input/output utilities
│   │   └── 📄 write_report_csv.m     # Data export
│   └── 📁 rng/                       # Random number management
│       └── 📄 setup_rng.m            # RNG setup
├── 📁 docs/                          # Documentation
│   ├── 📄 2d_model_theory.md         # English theory
│   └── 📄 2d_model_theory.en.md      # Chinese theory
├── 📁 out/                           # Output directory
│   ├── 📄 batch_results.csv          # Batch results
│   ├── 📄 mc_summary.csv            # Statistical summary
│   └── 📁 figures/                   # Generated plots
└── 📁 tests/                         # Test suite
    ├── 📄 test_basic_simulation.m   # Basic functionality
    ├── 📄 test_batch_processing.m   # Batch processing
    └── 📄 test_reproducibility.m    # Reproducibility tests
```

## 🤝 Contributing

We welcome contributions to improve this project! Please follow these guidelines:

### Development Workflow
1. **Fork the repository** on GitHub
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** with proper testing
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to the branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request** with a clear description

### Code Style Guidelines
- Follow MATLAB best practices and naming conventions
- Include comprehensive comments for complex algorithms
- Ensure all functions have proper help documentation
- Test thoroughly with different parameter combinations

### Reporting Issues
When reporting bugs or suggesting features, please include:
- **Issue type**: Bug report or feature request
- **MATLAB version** and operating system
- **Minimal reproduction example** for bugs
- **Expected vs actual behavior**
- **Error messages** (if applicable)

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### License Summary
- ✅ **Commercial use**: Allowed
- ✅ **Modification**: Allowed
- ✅ **Distribution**: Allowed
- ✅ **Private use**: Allowed
- ❌ **Liability**: No warranty provided
- ❌ **Trademark**: No trademark rights granted

## 👨‍🔬 Authors and Citation

### Authors
- **Rongfeng Zheng** (郑蓉锋) — Sichuan Agricultural University · Algorithm design, MATLAB pipeline implementation, comprehensive testing
- **Weifeng Chen** (陈为锋) — Sichuan Agricultural University · Algorithm co-design, module implementation, performance validation
- **Zhaosen Luo** (罗照森) — Sichuan Agricultural University · Regression testing, reproducibility verification, issue reporting

### Contact Information
- **GitHub Issues**: [Submit issues here](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **Email**: Please use GitHub Issues for general inquiries

### Citation
If you use this software in your research, please cite:

```bibtex
@software{enzyme_cascade_2d,
  title={2D Enzyme Cascade Simulation: A MATLAB Framework for Mineral-Surface Enzyme Localization Studies},
  author={Zheng, Rongfeng and Chen, Weifeng and Luo, Zhaosen},
  year={2024},
  publisher={GitHub},
  journal={GitHub repository},
  howpublished={\\url{https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE}},
  license={MIT}
}
```
**Code Availability**: Complete implementation details and source code are available in the accompanying GitHub repository: https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE

### Acknowledgments
- This work was supported by the research environment of Sichuan Agricultural University
- Special thanks to contributors and beta testers
- Built on the foundation of established biophysical modeling principles

---

<div align="center">

**🌟 If this project helps your research, please consider giving it a star! 🌟**

[🔝 Back to Top](#-2d-enzyme-cascade-simulation)


</div>
