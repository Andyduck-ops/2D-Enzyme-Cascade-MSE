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
- 📖 **Documentation**: [2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)
- 🎯 **Quick Start**: [Installation](#installation) | [Usage](#quick-start) | [Examples](#examples)
- ⚡ **Features**: [Key Features](#key-features) | [Algorithm](#algorithm) | [Visualization](#visualization)

## 🎯 Project Overview

A comprehensive, modular MATLAB framework for simulating two-step enzyme cascade reactions in 2D space with mineral-surface-localized enzymes. This framework implements advanced stochastic simulations including heterogeneous diffusion, τ-leaping reactions, crowding inhibition, batch Monte Carlo analysis, and fully reproducible scientific computations.

### Key Scientific Context

This research focuses on **Mineral-Surface Enzyme (MSE) localization effects** - a critical phenomenon where enzyme confinement near mineral surfaces dramatically enhances reaction efficiency through spatial organization and localized high-concentration environments.

### Research Impact
- **Primary Goal**: Quantify how MSE localization compares to bulk dispersion in terms of reaction efficiency
- **Key Insight**: Localized enzyme systems can achieve significantly higher product yields due to increased encounter probabilities
- **Applications**: Biocatalysis, enzyme engineering, synthetic biology, and industrial process optimization

## ⚡ Key Features

### 🧬 Advanced Simulation Capabilities
- **Two-Step Enzyme Cascade**: $\\mathrm{S} \\xrightarrow{\\mathrm{GOx}} \\mathrm{I} \\xrightarrow{\\mathrm{HRP}} \\mathrm{P}$
- **Dual Simulation Modes**:
  - **MSE Mode**: Enzymes localized to a ring film around a central particle
  - **Bulk Mode**: Enzymes uniformly distributed in the simulation box
- **Heterogeneous Diffusion**: Different diffusion coefficients for film vs bulk regions
- **Stochastic Reactions**: τ-leaping methodology with probabilistic reaction events
- **Crowding Inhibition**: Local density effects on catalytic efficiency

### 🔬 Scientific Rigor
- **Reproducible Results**: Deterministic simulations with fixed random seeds
- **Batch Monte Carlo**: Statistical analysis across multiple independent runs
- **Boundary Conditions**: Reflective boundaries at box walls and particle surface
- **Physical Validation**: Models based on established biophysical principles

### 📊 Comprehensive Analysis
- **Real-time Visualization**: Product curves, event maps, and tracer trajectories
- **Statistical Reporting**: CSV outputs with means, variances, and confidence intervals
- **Spatial Analysis**: Heat maps of reaction events and particle distributions
- **Performance Metrics**: Reaction rates, yields, and efficiency factors

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Examples](#-examples)
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
git clone https://github.com/your-org/2D-Enzyme-Cascade-Simulation.git
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

## 🔬 Algorithm Details

### Simulation Architecture

The simulation employs a multi-scale approach combining:

#### 1. **Geometric Model**
- **Domain**: 2D square box of size $L \\times L$
- **Central Particle**: Radius $r_p$ with reflective boundaries
- **Enzyme Film**: Ring region $[r_p, r_p + f_t]$ for MSE mode
- **Species**: Substrate (S), Intermediate (I), Product (P)

#### 2. **Diffusion Process**
Brownian dynamics with spatially-dependent diffusion coefficients:
```math
\mathbf{x} \leftarrow \mathbf{x} + \sqrt{2\,D(\mathbf{x})\,\Delta t}\,\boldsymbol{\eta},\quad \boldsymbol{\eta} \sim \mathcal{N}(\mathbf{0}, \mathbf{I}_2)
```

Where $D(\mathbf{x})$ is piecewise-defined:
- MSE mode: $D_{\text{film}}$ inside ring, $D_{\text{bulk}}$ elsewhere
- Bulk mode: $D_{\text{bulk}}$ everywhere

#### 3. **Reaction Kinetics**
τ-leaping method with probabilistic reaction events:
```math
P_{\mathrm{GOx}} = 1 - e^{-k_{\mathrm{cat,GOx}}\,\Delta t}\,(1 - \mathrm{inhibition}_{\mathrm{GOx}})
```
```math
P_{\mathrm{HRP}} = 1 - e^{-k_{\mathrm{cat,HRP}}\,\Delta t}\,(1 - \mathrm{inhibition}_{\mathrm{HRP}})
```

#### 4. **Crowding Inhibition**
Local density effects on catalytic efficiency:
```math
\mathrm{inhibition} = I_{\max}\,\max\!\left(0,\, 1 - \frac{n_{\mathrm{local}}}{n_{\mathrm{sat}}}\right)
```

### Core Modules

| Module | Description | Location |
|--------|-------------|----------|
| `simulate_once` | Single simulation orchestrator | `modules/sim_core/` |
| `diffusion_step` | Brownian dynamics implementation | `modules/sim_core/` |
| `reaction_step` | τ-leaping reaction processing | `modules/sim_core/` |
| `boundary_reflection` | Boundary condition handling | `modules/sim_core/` |
| `run_batches` | Monte Carlo batch processing | `modules/batch/` |

## ⚙️ Configuration

### Key Configuration Parameters

#### Simulation Parameters
```matlab
config.simulation_params.box_size = 500;          % nm
config.simulation_params.total_time = 1.0;        % s
config.simulation_params.time_step = 1e-5;       % s
config.simulation_params.simulation_mode = 'MSE'; % 'MSE' or 'bulk'
```

#### Particle Parameters
```matlab
config.particle_params.num_enzymes = 200;
config.particle_params.num_substrate = 1000;
config.particle_params.diff_coeff_bulk = 1000;   % nm²/s
config.particle_params.diff_coeff_film = 10;     % nm²/s
config.particle_params.k_cat_GOx = 100;          % s⁻¹
config.particle_params.k_cat_HRP = 100;          % s⁻¹
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

    % Enhancement factor
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

### Lead Authors
- **Rongfeng Zheng** (郑荣峰) - Sichuan Agricultural University
- **Weifeng Chen** (陈伟峰) - Sichuan Agricultural University

### Contact Information
- **GitHub Issues**: [Submit issues here](https://github.com/your-org/2D-Enzyme-Cascade-Simulation/issues)
- **Email**: Please use GitHub Issues for general inquiries

### Citation
If you use this software in your research, please cite:

```bibtex
@software{enzyme_cascade_2d,
  title={2D Enzyme Cascade Simulation: A MATLAB Framework for Mineral-Surface Enzyme Localization Studies},
  author={Zheng, Rongfeng and Chen, Weifeng},
  year={2024},
  publisher={GitHub},
  journal={GitHub repository},
  howpublished={\\url{https://github.com/your-org/2D-Enzyme-Cascade-Simulation}},
  license={MIT}
}
```

### Acknowledgments
- This work was supported by [Grant Information if applicable]
- Special thanks to contributors and beta testers
- Built on the foundation of established biophysical modeling principles

---

<div align="center">

**🌟 If this project helps your research, please consider giving it a star! 🌟**

[🔝 Back to Top](#-2d-enzyme-cascade-simulation)

</div>