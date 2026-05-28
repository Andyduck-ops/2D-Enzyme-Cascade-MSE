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

### 🛡️ Checkpoint Protection (NEW ✨)
- **Automatic Batch-Level Checkpoints**: Multi-batch runs (batch_count > 1) automatically save progress after each batch
- **Seamless Recovery**: Resume interrupted simulations from the last completed batch
- **Zero Configuration**: No user setup required - protection is automatic
- **Real-Time CSV Saving**: Results saved immediately to `batch_results.csv` for instant recovery
- **Time-Series Data**: Complete product evolution curves saved for all multi-batch runs
- **Minimal Overhead**: < 0.1% performance impact
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
  - Structured subdirectories: `data/` and `figures/`
- **Historical Data Import**: Load and compare results from previous simulation runs
  - Interactive run selection interface
  - Support for both single-mode and dual-mode historical data
  - Automatic metadata extraction and validation
- **Multi-Dataset Comparison**: Visualize and compare multiple historical runs simultaneously
  - Publication-quality comparison plots with mean±S.D. curves
  - Shaded error bands for statistical visualization
  - Interactive legend with click-to-toggle visibility
  - Automatic color and line style cycling for clarity
- **Output-Based Reproducibility**: Reproduce runs from the timestamped folder under `out/`
  - Use the folder name to identify the historical run
  - Read complete parameters from `data/run_metadata.json`
  - Load batch seeds from `data/seeds.csv` when reproducing Monte Carlo runs
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

### Accuracy & Acceleration (Key Settings)
- Continuous busy timers: cool-downs are tracked in seconds (no step-rounding), improving high-rate accuracy.
- Neighbor search backends (single-run acceleration):
  ```matlab
  % Compute options
  config.compute.neighbor_backend = 'auto';    % 'auto' | 'pdist2' | 'rangesearch' | 'kdtree' | 'celllist' | 'gpu'
  config.compute.use_gpu = 'off';              % 'off'  | 'on'     | 'auto'
  ```
- Time-step sanity: prefer `k_max * dt <= 0.05` and `sqrt(2*D_bulk*dt) << min(reaction radii, film thickness)`. Warnings are printed by `config_sanity_checks()`.

## 🚀 Performance Optimization (NEW ✨)

The framework implements **algorithmic optimizations achieving 10-30× speedup** while maintaining <1% accuracy deviation:

### Phase 1 (P0): Foundation - **10-15× speedup**

#### 1. KD-Tree Neighbor Search with Caching
- **Problem**: Original O(NA·NB) distance computation every step
- **Solution**: Pre-build `KDTreeSearcher` for static enzymes, use O(NA·log NB) queries
- **Performance**: 3-8× speedup on neighbor search (3000×100 scale)
- **Usage**: Automatic when `neighbor_backend='rangesearch'` or `'auto'`

#### 2. ROI Pre-Filtering (MSE Mode)
- **Problem**: Search all particles, but only ~1% near film annulus
- **Solution**: Pre-filter to reaction zone: `pr - r_react ≤ r_center ≤ film_r + r_react`
- **Performance**: 2-5× additional speedup (60-90% candidate reduction)
- **Accuracy**: <0.5% deviation (exact filtering, no approximation)

#### 3. Batch Parallel Processing
- **Problem**: Serial batch execution doesn't utilize multi-core CPUs
- **Solution**: `parfor` with independent RNG seeds per worker
- **Performance**: 5-7× speedup on 8-core systems
- **Usage**: Automatic when `batch.use_parfor=true` (default)

### Configuration Example

```matlab
% Optimized batch configuration
config = default_config();
config.compute.neighbor_backend = 'rangesearch';  % KD-tree + caching
config.batch.use_parfor = true;                   % Parallel execution
config.ui_controls.visualize_enabled = false;     % Disable viz for speed

% Run benchmark
benchmark_p0  % Test P0 optimizations
```

### Performance Benchmarks

**Test System**: Intel i7-8700 (6 cores), 16GB RAM, MATLAB R2023a  
**Configuration**: 400 enzymes, 3000 substrates, 100s simulation

| Configuration | Time (s) | Speedup | Accuracy |
|--------------|----------|---------|----------|
| Baseline (pdist2) | 120.5 | 1.0× | Reference |
| P0 (rangesearch + ROI) | 10.2 | 11.8× | 0.3% MSE |
| P0 + Batch Parallel (8 cores) | 1.8 | 66.9× | 0.3% MSE |
| P1 (celllist) | 7.5 | 16.1× | 0.8% MSE |

### Advanced Backends (P1)

#### Grid-Based Cell List
- **Algorithm**: Spatial hashing, check only 9 neighboring cells
- **Performance**: 20-50% faster than KD-tree (dense systems)
- **Usage**: `config.compute.neighbor_backend = 'celllist'`

### Documentation

- **Detailed Guide**: [Performance Optimization Guide](docs/performance_optimization_guide.md)
- **Benchmark Script**: `benchmark_p0.m`
- **Spec Documents**: `.kiro/specs/performance-optimization-20x/`

### Troubleshooting

**Statistics Toolbox not available?**  
→ System auto-falls back to `'gpu'` or `'pdist2'`

**Parallel pool fails?**  
→ System auto-falls back to serial execution

**Results differ from baseline?**  
→ Check MSE < 1% (P0) or < 2% (P1) is acceptable

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Performance Optimization](#-performance-optimization-new-)
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
│   │   └── figures/                # Statistical plots
│   └── latest.lnk
└── comparisons/                     # Multi-dataset comparisons
    └── comparison_20251010_150000_n3.png
```

## 🔄 Quick Reproduction

### Reproduce from `out/` Run Directories

This project reproduces historical runs from the timestamped directories under `out/`, not from a manually maintained seed text file. The directory name is a compact index for finding a run; the complete parameter record and output manifest are stored in `data/run_metadata.json`, and Monte Carlo batch seeds are stored in `data/seeds.csv`.

Typical run directory names include the main indexing fields:

```text
out/single/20251017_154320_mse_enz100_sub9000_seed1234/
out/batch/20251016_110157_dual_enz20_sub9000_n200/
```

Use the timestamp, mode, enzyme count, substrate count, seed, or batch count in the folder name to locate the target run. For exact reproduction, use `data/run_metadata.json` as the source of truth.

#### Method 1: Browse Historical Runs

```matlab
% List historical runs from out/single and out/batch
browse_history_cli()

% Or only list batch runs
browse_history_cli('batch')
```

You can also inspect the files directly:

```text
out/batch/20251016_110157_dual_enz20_sub9000_n200/data/run_metadata.json
out/batch/20251016_110157_dual_enz20_sub9000_n200/data/seeds.csv
```

#### Method 2: Reproduce a Single Run from Metadata

```matlab
% Example: restore the configuration from the parameters field
% in data/run_metadata.json
config = default_config();

config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 100;
config.particle_params.num_substrate = 9000;
config.simulation_params.total_time = 50;
config.simulation_params.time_step = 0.0005;
config.particle_params.diff_coeff_bulk = 1000;
config.particle_params.diff_coeff_film = 10;
config.particle_params.k_cat_GOx = 100;
config.particle_params.k_cat_HRP = 100;

% Seed comes from the directory name or seed_info.fixed_seed
% in run_metadata.json
result = simulate_once(config, 1234);
fprintf('Reproduced result: %d products\n', result.products_final);
```

If adaptive dt was enabled, also apply the `dt_final`, `dt_history`, and dt target fields recorded in `run_metadata.json`. The snippet above shows only the core fields; do not rely on it as a complete metadata parser.

#### Method 3: Reproduce a Batch Run from `seeds.csv`

```matlab
config = default_config();

% Restore parameters from the target run_metadata.json
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 20;
config.particle_params.num_substrate = 9000;
config.batch.batch_count = 200;

% Load the original Monte Carlo seeds from the selected run directory
seed_table = readtable('out/batch/20251016_110157_dual_enz20_sub9000_n200/data/seeds.csv');
seeds = seed_table.seed;

batch_results = run_batches(config, seeds);
fprintf('Batch reproduction: %.1f ± %.1f products\n', ...
    mean(batch_results.products_final), std(batch_results.products_final));
```

In the interactive workflow, you can also choose `from_file` as the seed mode. The program will let you select a historical batch run, load its `seeds.csv`, and record the seed source in the new run metadata.

### Recording New Experiments

Every run automatically creates a timestamped output directory. Keep or share that directory to preserve the information needed for reproduction:

- `data/run_metadata.json`: run type, mode, key parameters, adaptive-dt information, seed information, output-file manifest, system information, and runtime
- `data/seeds.csv`: one seed per Monte Carlo batch
- `data/batch_results*.csv`: final statistical results
- `data/timeseries_products*.csv`: product time series
- `figures/`: generated plots from the run

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

### Output-Based Research Reproducibility

The project records reproducibility information with each simulation output. A timestamped run directory is the durable record of an experiment:

```text
out/<single|batch>/<timestamp>_<mode|dual>_enz<N>_sub<M>_<seed|nBatches>/
```

The folder name is useful for browsing and selecting a run, while the complete reproducibility payload lives in `data/`:

- `run_metadata.json`: parameter snapshot, simulation mode, adaptive-dt fields, seed mode/source, output-file manifest, runtime, and system information
- `seeds.csv`: exact Monte Carlo seed sequence for batch runs
- `batch_results*.csv`: final product counts and summary tables
- `timeseries_products*.csv`: product curves used by the comparison figures

### Reproducing a Historical Run

1. Identify the target folder from its name or with `browse_history_cli()`.
2. Open `data/run_metadata.json` and restore the fields under `parameters`.
3. For a single run, use `seed_info.fixed_seed` or the `seed<value>` suffix in the directory name.
4. For a batch run, read `data/seeds.csv` and pass the seed vector to `run_batches(config, seeds)`.
5. Compare the new `batch_results*.csv` and `timeseries_products*.csv` with the historical files.

```matlab
% Example: reproduce a batch run after restoring parameters
% from data/run_metadata.json.
config = default_config();
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 20;
config.particle_params.num_substrate = 9000;
config.batch.batch_count = 200;

seed_table = readtable('out/batch/20251016_110157_dual_enz20_sub9000_n200/data/seeds.csv');
seeds = seed_table.seed;

results = run_batches(config, seeds);
fprintf('Reproduced mean products: %.1f\n', mean(results.products_final));
```

### Automated Metadata and Seed Documentation

The framework automatically writes metadata and seed records during each run. No separate manual seed registry is required:

```matlab
config = default_config();
config.batch.batch_count = 50;
config.batch.seed_mode = 'fixed';
config.batch.fixed_seed = 2000;

results = run_batches(config);
% Reproducibility files are written under the timestamped out/.../data/ directory.
```

### Cross-Platform Reproducibility

The simulation framework ensures identical results across different platforms by:

- **Deterministic random number generation** using MATLAB's `rng()` function
- **Fixed-precision arithmetic** for all calculations
- **Consistent algorithm implementation** across all modules
- **Platform-independent file I/O** with standardized CSV formats

### Reproducibility Best Practices

1. **Keep the full timestamped run directory** for any result used in analysis or publications
2. **Use `run_metadata.json` as the source of truth** for parameters, not the abbreviated folder name
3. **Use `seeds.csv` for batch reproduction** instead of reconstructing seed ranges manually
4. **Record external analysis notes separately** if needed, but do not duplicate parameters by hand
5. **Version control code changes** together with the output directory or archived metadata used for a result
6. **Validate reproduction** by comparing regenerated CSV outputs against the historical files

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

Verify reproduction by comparing regenerated outputs with the historical CSV files from the selected `out/` directory:

```matlab
historical = readtable('out/batch/20251016_110157_dual_enz20_sub9000_n200/data/batch_results_mse.csv');
reproduced_mean = mean(results.products_final);
historical_mean = mean(historical.products_final);

tolerance = 1e-9;
if abs(reproduced_mean - historical_mean) <= tolerance
    fprintf('Reproduction successful: %.6f vs %.6f\n', ...
        reproduced_mean, historical_mean);
else
    fprintf('Reproduction differs: %.6f vs %.6f\n', ...
        reproduced_mean, historical_mean);
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
2D-Enzyme-Cascade-MSE/
├── main_2d_pipeline.m              # Entry point
├── run_simulation.m                # Helper script
├── README.md / README.zh-CN.md     # Documentation (EN/ZH)
├── LICENSE / CONTRIBUTING.md / AUTHORS.md / BUGFIX_SUMMARY.md
├── docs/                           # Theory & guides
│   ├── 2d_model_theory.en.md       # English theory
│   └── 2d_model_theory.md          # Chinese theory
├── modules/
│   ├── config/
│   │   ├── default_config.m        # Defaults (auto-dt, compute options)
│   │   └── interactive_config.m    # Interactive setup (GPU mapping)
│   ├── sim_core/
│   │   ├── simulate_once.m         # Orchestrator
│   │   ├── init_positions.m        # Initialization
│   │   ├── diffusion_step.m        # Brownian motion
│   │   ├── boundary_reflection.m   # Reflective boundaries
│   │   ├── reaction_step.m         # Reactions (continuous timers, neighbor)
│   │   ├── precompute_inhibition.m # Crowding inhibition
│   │   ├── record_data.m           # Rates & curves
│   │   └── neighbor_search.m       # pdist2 / rangesearch / GPU
│   ├── batch/
│   │   ├── run_batches.m           # Batch Monte Carlo
│   │   └── auto_configure_parallel.m # parfor pool management (auto workers)
│   ├── viz/
│   │   ├── viz_style.m                 # Unified styling (theme-aware)
│   │   ├── plot_product_curve.m        # Product kinetics over time
│   │   ├── plot_event_map.m            # Spatial reaction event map
│   │   ├── plot_tracers.m              # Particle trajectory visualization
│   │   ├── plot_reaction_rate_analysis.m # Rate diagnostics + exponential fit
│   │   ├── plot_dual_system_comparison.m # Bulk vs MSE mean±SD curves
│   │   ├── plot_batch_distribution.m   # Box plot + overlaid histograms
│   │   └── plot_batch_timeseries_heatmap.m # Batch timeseries heatmap
│   ├── rng/
│   │   └── setup_rng.m                 # Seed CPU/GPU RNG deterministically
│   ├── seed_utils/
│   │   └── get_batch_seeds.m           # Generate seed list by mode
│   ├── data_import/
│   │   ├── select_runs_interactive.m   # Pick prior runs interactively
│   │   ├── load_seeds_from_file.m      # Load seeds from history file
│   │   └── browse_history.m            # CLI history browser
│   ├── io/
│   │   ├── output_manager.m        # root-level out/
│   │   ├── write_report_csv.m / save_timeseries.m / save_figures.m
│   │   └── write_metadata.m        # run_metadata.json (+dt auto info)
│   └── utils/
│       ├── timer_busy_update.m
│       ├── auto_adjust_dt.m / config_sanity_checks.m
│       └── getfield_or.m
└── out/                            # Created at runtime (root-level)
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
