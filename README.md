# 2D Enzyme Cascade Simulation


<!-- Language Switch -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)


<!-- Project Badges -->
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b%2B%20(tested%202023)-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](#)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](#installation)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-A%2B-brightgreen.svg)](#)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-success.svg)](#)
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-purple.svg)](docs/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/Andyduck-ops/2D-Enzyme-Cascade-MSE?style=social)](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/stargazers)


<!-- Core Links -->
- 📖 **Documentation**: [2D Theory (English)](docs/2d_model_theory.en.md) | [Theory（中文）](docs/2d_model_theory.md)
- 🎯 **Quick Start**: [Installation](#installation) | [Usage](#quick-start) | [Examples](#examples)
- ⚡ **Features**: [Key Features](#key-features) | [Algorithm](#algorithm) | [Visualization](#visualization)

## 🎯 Project Overview

A comprehensive, modular MATLAB framework for comparing **Mineral-Surface Enzyme (MSE) localization** versus **bulk distribution** in two-step enzyme cascade reactions. This framework quantifies the **spatial proximity advantages** of co-localized enzymes through reduced intermediate diffusion distances, while accounting for the dual mechanism at high enzyme densities: **bulk systems' superior first-step reaction flux** and **MSE crowding inhibition**. The computational platform implements advanced stochastic simulations including heterogeneous diffusion, $\tau$ -leaping reactions, and fully reproducible scientific computations to systematically evaluate **concentration-dependent kinetic trade-offs** in enzyme spatial organization.

### Key Scientific Context

This research investigates **spatial proximity effects in enzyme cascade reactions** as a key mechanism for understanding organized biochemical systems. The study focuses on **Mineral-Surface Enzyme (MSE) localization effects**, where co-localization of cascade enzymes **reduces diffusion distances for intermediate products**, creating kinetic advantages through enhanced substrate channeling. This spatial advantage is **concentration-dependent**: highly effective at **low enzyme densities** where proximity benefits dominate, but reversed at **high enzyme densities** where bulk systems gain **superior first-step reaction flux** due to increased enzyme-substrate contact opportunities, while MSE systems simultaneously suffer from **crowding inhibition**, creating a dual mechanism that favors bulk distribution.

The computational framework implements stochastic Brownian dynamics simulations of enzyme cascade reactions that model the critical transition from geochemical to biochemical complexity. This addresses a core challenge in origin-of-life research: how primitive metabolic networks could achieve sufficient molecular organization and concentration to sustain autocatalytic processes under the dilute conditions prevalent in prebiotic environments. By comparing mineral surface-mediated spatial organization (MSE) versus bulk distribution scenarios, we quantitatively assess how interfacial processes could have optimized reaction efficiency through spatial proximity effects, particularly relevant for understanding biochemical organization in primitive systems.

### Research Impact
- **Primary Goal**: Elucidate how mineral-guided spatial organization serves as a pathway from dilute prebiotic chemistry to organized protocell systems through quantitative computational modeling of concentration-dependent kinetic advantages
- **Key Scientific Breakthrough**: Reveals the concentration-dependent nature of MSE advantages - demonstrating optimal kinetic enhancement at low enzyme densities through reduced intermediate diffusion paths, while identifying a dual mechanism at high densities: bulk systems gain superior first-step reaction flux while MSE systems suffer crowding inhibition, creating a crossover favoring bulk distribution
- **Origin-of-Life Implications**: Provides mechanistic insights into how early Earth mineral surfaces could have facilitated the emergence of compartmentalized reaction systems that preceded cellular life
- **Broader Applications**: Biocatalysis optimization, enzyme engineering for industrial processes, synthetic biology for artificial cell construction, and prebiotic chemistry research for astrobiology
- **Methodological Contribution**: Establishes a robust computational framework for studying interfacial biochemistry under early Earth conditions, advancing our understanding of life's origins

## Overview

**Protocell Emergence Modeling Framework**:
- **Enzyme cascade system**: S -(GOx)-> I -(HRP)-> P - mimics **substrate channeling** in primitive proto-metabolic networks
- **Comparative modes** representing stages of **prebiotic evolution**:
  - **MSE mode**: Enzymes localized to a ring film around a central mineral particle, modeling **mineral-surface spatial organization**
  - **Bulk mode**: Enzymes uniformly distributed throughout the domain, representing dilute **prebiotic chemistry** conditions
- **Interfacial physics**: Heterogeneous diffusion (film vs bulk regions), reflective boundaries, stochastic reaction kinetics modeling **early Earth conditions**
- **Statistical framework**: Batch runs with comprehensive statistical analysis, CSV exports, and visualization tools for quantifying **protocell emergence** pathways

## Background (why MSE vs bulk)

### Motivation
This computational framework addresses a fundamental question in origin-of-life research: how did organized, compartmentalized biological systems emerge from the dilute prebiotic environments of early Earth? We investigate **mineral-guided spatial organization** as a key interfacial driving force that could have facilitated **protocell emergence** by optimizing reaction efficiency through reduced intermediate diffusion distances, particularly effective at low enzyme concentrations.

To quantitatively assess how mineral surface-mediated spatial organization (MSE) serves as a pathway from geochemical to biochemical complexity, we employ stochastic Brownian dynamics simulations of a two-step enzymatic cascade reaction system that mimics **substrate channeling** found in modern metabolic networks. The computational model assumes a 500 nm cubic domain representing a prebiotic microenvironment where substrate molecules, intermediate products, and final products undergo free diffusion, while enzyme-like catalysts remain spatially constrained near mineral interfaces - modeling the critical transition that likely preceded cellular **compartmentalization**.

MSE localization provides kinetic advantages by **reducing intermediate diffusion distances** between cascade steps, creating an **optimal enzyme concentration regime** where spatial proximity benefits dominate. At **low enzyme densities**, MSE shows significant enhancement due to shortened diffusion paths for intermediate products. However, at **high enzyme densities**, a dual mechanism reverses this advantage: bulk systems gain **superior first-step reaction flux** through increased enzyme-substrate contact opportunities, while MSE systems simultaneously suffer **crowding inhibition**, making uniform distribution more effective. This **concentration-dependent crossover** reveals the importance of spatial organization in biochemical systems and provides insights into optimal enzyme arrangement strategies.

### Scientific Framework
- **Molecular Diffusion**: Follows Brownian motion with position updates $\Delta r = \sqrt{2D \Delta t} \eta$, where $\eta$ represents Gaussian white noise
- **Heterogeneous Environment**: Diffusion coefficients are set to $D_{\text{bulk}} = 1000 \text{ nm}^2/\text{s}$ for bulk regions and $D_{\text{film}} = 10 \text{ nm}^2/\text{s}$ within the enzyme film layer
- **Spatial Confinement**: 2D abstraction approximates a thin surface film as a ring [r_p, r_p + f_t] around a central particle (enzymes fixed in MSE; free placement in bulk)

### Reaction System
- **Two-step cascade**: S -(GOx)-> I -(HRP)-> P with enzymes split GOx/HRP (default 50/50 via `gox_hrp_split`)
- **$\tau$ -leaping kinetics**: Reaction probability follows $P = 1 - \exp(-k_{\text{cat}} \Delta t)$, where $k_{\text{cat}} = 100 \text{ s}^{-1}$ for both enzymes
- **Crowding effects**: Local enzyme density modulates effective catalytic rates according to $\text{inhibition factor} = 1 - I_{\text{max}} \times \min(n_{\text{local}}/n_{\text{sat}}, 1)$, with $I_{\text{max}} = 0.8$ and $n_{\text{sat}} = 5$

### Key Comparisons
The framework systematically compares two fundamental configurations representing distinct stages of **prebiotic evolution**:
- **MSE mode**: Enzymes concentrated within a 5 nm film around a central mineral particle (radius = 20 nm), modeling **mineral-surface localization** that reduces intermediate diffusion distances but introduces crowding effects at high enzyme densities
- **Bulk mode**: Uniform enzyme distribution throughout the simulation domain, representing dilute **prebiotic chemistry** environments with longer diffusion paths but superior first-step reaction flux at high enzyme densities
- **Concentration-dependent dynamics**: This comparison reveals the **optimal enzyme density regime** where MSE provides maximum kinetic advantage - typically at low concentrations where spatial proximity outweighs the dual disadvantages of reduced first-step flux and crowding inhibition
- **Flexible parameters**: Supports systematic exploration of enzyme concentration effects, enabling identification of the **crossover point** where bulk distribution becomes more efficient than surface localization

## ⚡ Key Features

### 🧬 Advanced Simulation Capabilities for Protocell Emergence Studies
- **Proto-metabolic Network Modeling**: Two-step enzyme cascade S -(GOx)-> I -(HRP)-> P mimicking **substrate channeling** in primitive biochemical networks
- **Prebiotic Evolution Simulation Modes**:
  - **MSE Mode**: Enzymes localized to a ring film around a central mineral particle, modeling **mineral-surface spatial organization** and **protocell emergence** pathways
  - **Bulk Mode**: Enzymes uniformly distributed throughout the domain, representing dilute **prebiotic chemistry** environments
- **Interfacial Driving Forces**: Heterogeneous diffusion coefficients capturing **early Earth conditions** with different molecular mobility in film vs bulk regions
- **Prebiotic Reaction Kinetics**: $\tau$ -leaping methodology with probabilistic reaction events modeling stochastic molecular encounters under primitive conditions
- **Molecular Crowding Physics**: Local density effects on catalytic efficiency, simulating **compartmentalization** effects critical for **proto-metabolic flux** generation

### 🔬 Scientific Rigor
- **Reproducible Results**: Deterministic simulations with fixed random seeds
- **Batch Monte Carlo**: Statistical analysis across multiple independent runs
- **Boundary Conditions**: Reflect particles at box walls and particle surface
- **Physical Validation**: Models based on established biophysical principles

### ⚡ High-Performance Computing (NEW ✨)
- **Auto CPU Core Detection**: Automatically detects and utilizes available CPU cores for optimal performance
- **Intelligent Parallel Processing**: Smart worker allocation (CPU cores - 1) to maintain system responsiveness
- **Flexible Worker Configuration**: Choose between auto mode or manually specify worker count
- **Parallel Pool Management**: Automatic parallel pool creation and optimization
- **Performance Scaling**: Near-linear speedup for large batch simulations (6-7x faster on 8-core systems)
- **See**: [Parallel Computing Guide](docs/parallel_computing_guide.md) for detailed configuration and performance tips

### 📊 Comprehensive Analysis
- **Real-time Visualization**: Product curves, event maps, and tracer trajectories
- **Dual-System Comparison** (NEW ✨): Automated bulk vs MSE comparison with mean±S.D. visualization, configurable enzyme quantities, and professional error band plotting ([docs/dual_system_comparison_guide.md](docs/dual_system_comparison_guide.md))
- **Statistical Reporting**: Automatic CSV exports including batch results (`batch_results.csv`), seed records (`seeds.csv`), and statistical summaries (`mc_summary.csv`) with means, variances, and confidence intervals
- **Spatial Analysis**: Heat maps of reaction events and particle distributions
- **Performance Metrics**: Reaction rates, yields, and efficiency factors

### 📂 Data Management & Comparison (NEW ✨)
- **Timestamped Output Structure**: Organized directory hierarchy with automatic timestamping for easy data management
  - `out/single/` and `out/batch/` directories with timestamped subdirectories
  - Automatic `latest` shortcuts/symlinks to most recent runs
  - Structured subdirectories: `data/`, `figures/`, `single_viz/`
- **Historical Data Import**: Load and compare results from previous simulation runs
  - Interactive run selection interface
  - Support for both single-mode and dual-mode historical data
  - Automatic metadata extraction and validation
- **Multi-Dataset Comparison**: Visualize and compare multiple historical runs simultaneously
  - Publication-quality comparison plots with mean±S.D. curves
  - Shaded error bands for statistical visualization
  - Interactive legend with click-to-toggle visibility
  - Automatic color and line style cycling for clarity
- **Seed Import & Reproducibility**: Import seeds from historical runs for exact reproduction
  - Load seeds from any previous batch run
  - Automatic handling of seed count mismatches
  - Full traceability with source information in metadata
- **Comprehensive Metadata**: JSON-formatted run metadata for complete traceability
  - Configuration parameters, seed information, output file manifest
  - System information and runtime statistics
  - Automatic generation and storage with each run

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

### Reactions ($\tau$ -leaping per $\Delta t$)

Two independent channels per step:

- S + GOx $\rightarrow$ I, $P_{\text{GOx}} = (1 - \exp(-k_{\text{cat,GOx}} \Delta t)) \times \text{inhibition factor}_{\text{GOx}}$
- I + HRP $\rightarrow$ P, $P_{\text{HRP}} = (1 - \exp(-k_{\text{cat,HRP}} \Delta t)) \times \text{inhibition factor}_{\text{HRP}}$

Inhibition from local crowding (per enzyme):

$\text{inhibition factor} = 1 - I_{\text{max}} \times \min(n_{\text{local}} / n_{\text{sat}}, 1)$

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
- **MATLAB Version**: R2019b or later (tested with MATLAB 2023)
- **Required Toolboxes**:
  - Statistics and Machine Learning Toolbox (for `pdist2`)
  - Parallel Computing Toolbox (optional, for batch processing acceleration)
- **Operating System**: Windows, macOS, or Linux
- **Memory**: Minimum 4GB RAM, 8GB+ recommended for large simulations
- **GPU**: NVIDIA GPU recommended for accelerated computation (optional)

### Quick Installation
```bash
# Clone the repository
git clone https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE.git
cd 2D-Enzyme-Cascade-Simulation

# Note: Output directory will be auto-created when running simulations
# Optional: Pre-create output directory
mkdir -p out
```

### MATLAB Setup
1. Open MATLAB and navigate to the project root directory
2. The main pipeline automatically adds `modules/` to the MATLAB path
3. **GPU Setup (Optional)**: If you have an NVIDIA GPU, ensure CUDA is installed and GPU computing is enabled in MATLAB for optimal performance
4. Verify installation by running:
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
% NEW: Choose between running new simulations or importing historical data
```

**New Features in Interactive Mode:**
1. **Run Mode Selection**: Choose between running new simulations or importing historical data for comparison
2. **Historical Data Import**: Select and compare multiple previous runs with interactive visualization
3. **Seed Import**: Load seeds from previous runs for exact reproduction
4. **Timestamped Outputs**: All results automatically organized in timestamped directories

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

### Data Management & Historical Comparison (NEW ✨)

#### Browse Historical Runs
```matlab
% View all historical runs
browse_history_cli()

% View only batch runs
browse_history_cli('batch')

% View only single runs
browse_history_cli('single')
```

#### Import and Compare Historical Data
```matlab
% Interactive mode - select runs to compare
main_2d_pipeline
% Choose option [2] Import historical data for comparison
% Select multiple runs from the list
% Comparison plot will be generated automatically
```

#### Load Seeds from Previous Run
```matlab
% Interactive mode
main_2d_pipeline
% Choose option [1] Run new simulation
% When asked for seed mode, select 'from_file'
% Select a previous batch run to load seeds from
```

#### Output Directory Structure
```
out/
├── single/                          # Single-run simulations
│   ├── 20251010_143022_mse_enz400_sub3000_seed1234/
│   │   ├── data/
│   │   │   ├── run_metadata.json   # Complete run information
│   │   │   └── batch_results.csv   # Results data
│   │   └── figures/                # Generated plots
│   └── latest.lnk                  # Shortcut to most recent run
├── batch/                           # Batch simulations
│   ├── 20251010_143530_dual_enz400_sub3000_n10/
│   │   ├── data/
│   │   │   ├── run_metadata.json
│   │   │   ├── seeds.csv
│   │   │   ├── batch_results_bulk.csv
│   │   │   ├── batch_results_mse.csv
│   │   │   ├── timeseries_products_bulk.csv
│   │   │   └── timeseries_products_mse.csv
│   │   ├── figures/                # Statistical plots
│   │   └── single_viz/             # Single-run visualization
│   └── latest.lnk
└── comparisons/                     # Multi-dataset comparisons
    └── comparison_20251010_150000_n3.png
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

### Example 1.5: Dual-System Comparison with Statistical Visualization (NEW ✨)
```matlab
% NEW FEATURE: Integrated dual-system comparison with mean±S.D. visualization
% Runs both bulk and MSE simulations with Monte Carlo sampling via interactive workflow

% Interactive workflow (RECOMMENDED)
main_2d_pipeline
% Then select:
%   5b) Run dual-system comparison (bulk vs MSE) [y/n]: y
%   5)  Enable visualization [y/n]: y

% Programmatic usage - custom configuration
config = default_config();
config.particle_params.num_enzymes = 500;  % Configurable enzyme count
config.batch.batch_count = 30;             % Monte Carlo samples
config.batch.seed_mode = 'incremental';
config.batch.seed_base = 6000;
config.ui_controls.dual_system_comparison = true;  % Enable comparison mode
config.ui_controls.visualize_enabled = true;       % Enable visualization

% Generate seeds and run comparison
[seeds, ~] = get_batch_seeds(config);
[bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

% Visualize with mean±S.D. error bands
fig = plot_dual_system_comparison(bulk_data, mse_data, config);

% Extract statistics
fprintf('Bulk:  %.1f ± %.1f products\n', ...
    mean(bulk_data.product_curves(end,:)), std(bulk_data.product_curves(end,:), 0));
fprintf('MSE:   %.1f ± %.1f products\n', ...
    mean(mse_data.product_curves(end,:)), std(mse_data.product_curves(end,:), 0));
fprintf('Enhancement: %.2fx\n', ...
    mean(mse_data.product_curves(end,:)) / mean(bulk_data.product_curves(end,:)));

% For detailed usage, see: docs/dual_system_comparison_guide.md
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

#### 4. Snapshot Animation (NEW ✨)
- **Purpose**: Generate MP4 video from simulation snapshots
- **Features**:
  - Zero additional simulation cost (<5% rendering overhead)
  - MPEG-4/H.264 encoding, default 10fps, quality 95
  - 1920x1080 HD output with time labels and progress indicators
  - Memory-efficient frame-by-frame rendering
- **File**: `modules/viz/animate_snapshots.m`
- **Usage**:
  ```matlab
  config = default_config();
  config.ui_controls.visualize_enabled = true;
  config.ui_controls.enable_animation = true;  % Enable animation
  results = simulate_once(config, 12345);
  % Animation automatically saved to out/animation_seed_12345.mp4
  ```
- **Note**: Only available for single-run visualization (not batch runs)

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
├── 📁 out/                           # Output directory (auto-created)
│   ├── 📄 batch_results.csv          # Batch results
│   ├── 📄 seeds.csv                  # Batch seed records
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
- **Rongfeng Zheng** — Sichuan Agricultural University · Core algorithm design, MATLAB pipeline implementation, batch processing and modular code development, comprehensive testing
- **Weifeng Chen** — Sichuan Agricultural University · Algorithm co-design and construction, performance and functional validation, comprehensive testing
- **Zhaosen Luo** — Sichuan Agricultural University · Regression and reproducibility testing, issue reporting and result verification

### Contact Information
- **GitHub Issues**: [Submit issues here](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **Email**: Please use GitHub Issues for general inquiries

### Citation
If you use this software in your research, please cite:

```bibtex
@software{enzyme_cascade_2d,
  title={2D Enzyme Cascade Simulation: A MATLAB Framework for Mineral-Surface Enzyme Localization Studies},
  author={Zheng, Rongfeng and Chen, Weifeng and Luo, Zhaosen},
  year={2025},
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
