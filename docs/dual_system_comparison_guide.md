# Dual System Comparison Guide

## Overview

This guide explains how to use the dual-system comparison module to visualize and analyze product generation kinetics for **bulk** vs **MSE** enzyme distributions.

## Features

- ✅ **Dual-system batch simulations**: Runs both bulk and MSE configurations with identical seeds
- ✅ **Statistical visualization**: Displays mean±S.D. curves with shaded error bands
- ✅ **Configurable parameters**: Easy control of enzyme quantity and batch count
- ✅ **Professional styling**: Consistent with existing `viz_style()` themes
- ✅ **Export capabilities**: Saves figures (PNG, PDF, FIG) and CSV reports

## Quick Start

### Interactive Workflow (Recommended)

```matlab
% Run the main interactive pipeline
main_2d_pipeline
```

During configuration, select:
- **Question 5b**: `y` for "Run dual-system comparison (bulk vs MSE)"
- **Question 5**: `y` for "Enable visualization" (to generate comparison plot)

This will:
1. Prompt for interactive configuration
2. Generate random seeds for Monte Carlo sampling
3. Execute bulk and MSE simulations automatically
4. Create comparison plot with mean±S.D. visualization
5. Save results to `out/` directory

### Standalone Demo (Deprecated)

```matlab
% Legacy standalone demo (not recommended)
demo_dual_system_comparison
```

⚠️ **Note**: The standalone demo script is deprecated. Use the interactive workflow via `main_2d_pipeline` for integrated experience.

### Expected Output

- **Figures**:
  - `dual_comparison_enzymes_400.png` - High-resolution comparison plot
  - `dual_comparison_enzymes_400.pdf` - Publication-ready vector graphics
  - `dual_comparison_enzymes_400.fig` - Editable MATLAB figure

- **Data**:
  - `bulk_batch_results.csv` - Bulk system statistics
  - `mse_batch_results.csv` - MSE system statistics
  - `seeds.csv` - Seed records for reproducibility

## Configuration

### Enzyme Quantity

Modify enzyme count in the demo script or configuration:

```matlab
% In demo_dual_system_comparison.m (line ~45)
config.particle_params.num_enzymes = 400;  % Default: 400
```

**Recommended values**:
- Low density: 100-200 enzymes
- Medium density: 300-500 enzymes
- High density: 600-1000 enzymes

### Batch Count

Control Monte Carlo sample size:

```matlab
% In demo_dual_system_comparison.m (line ~48)
config.batch.batch_count = 20;  % Default: 20
```

**Guidelines**:
- Quick test: 5-10 batches
- Standard analysis: 20-50 batches
- Publication quality: 100+ batches

⚠️ **Note**: Larger batch counts improve statistical reliability but increase computation time.

### Simulation Time

Adjust total simulation time:

```matlab
% In demo_dual_system_comparison.m (line ~51)
config.simulation_params.total_time = 100;  % seconds
```

## Advanced Usage

### Programmatic API

For custom workflows, use the module functions directly:

```matlab
% 1. Setup
config = default_config();
config.particle_params.num_enzymes = 500;
config.batch.batch_count = 30;

% 2. Generate seeds
[seeds, ~] = get_batch_seeds(config);

% 3. Run comparison
[bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

% 4. Visualize
fig = plot_dual_system_comparison(bulk_data, mse_data, config);

% 5. Customize plot (optional)
ax = gca;
title(ax, 'Custom Title: My Analysis');
xlabel(ax, 'Time (seconds)');
```

### Data Structure

The comparison functions return structured data:

```matlab
bulk_data (or mse_data) = struct with fields:
    time_axis: [n_steps × 1] double     % Time points (s)
    product_curves: [n_steps × n_batches] double  % Product counts matrix
    enzyme_count: scalar double         % Number of enzymes used
    batch_table: table                  % Full batch statistics
```

### Extracting Statistics

```matlab
% Mean and standard deviation at final time point
bulk_final_mean = mean(bulk_data.product_curves(end, :));
bulk_final_std = std(bulk_data.product_curves(end, :), 0);

% Enhancement factor
enhancement = mean(mse_data.product_curves(end, :)) / bulk_final_mean;
fprintf('MSE enhancement: %.2fx\n', enhancement);

% Time-series analysis
time_idx = 50;  % Index for t=50s (depends on time_step)
bulk_at_50s = mean(bulk_data.product_curves(time_idx, :));
mse_at_50s = mean(mse_data.product_curves(time_idx, :));
```

## Module Files

### Core Functions

| File | Purpose |
|------|---------|
| `modules/viz/plot_dual_system_comparison.m` | Visualization function with mean±S.D. plotting |
| `modules/batch/run_dual_system_comparison.m` | Batch execution for both systems |
| `demo_dual_system_comparison.m` | Demonstration script with default settings |
| `test_dual_system_syntax.m` | Syntax validation and unit tests |

### Dependencies

- `modules/viz/viz_style.m` - Unified visualization styling
- `modules/config/default_config.m` - Configuration management
- `modules/batch/run_batches.m` - Batch processing framework
- `modules/sim_core/simulate_once.m` - Core simulation engine
- `modules/utils/getfield_or.m` - Safe field extraction utility

## Interpretation

### Reading the Plot

- **Blue curve**: Bulk system mean trajectory
- **Red curve**: MSE system mean trajectory
- **Shaded regions**: ±1 standard deviation confidence bands
- **Legend**: Shows final mean±S.D. values for quick comparison

### Key Metrics

1. **Final Product Count**: Mean value at t=total_time
2. **Standard Deviation**: Variability across Monte Carlo samples
3. **Enhancement Factor**: MSE_mean / Bulk_mean
   - \>1: MSE shows kinetic advantage
   - <1: Bulk system more efficient

### Physical Interpretation

- **Low enzyme density**: MSE typically shows enhancement due to reduced intermediate diffusion distances
- **High enzyme density**: Bulk may outperform due to:
  - Increased first-step reaction flux
  - MSE crowding inhibition effects

## Troubleshooting

### Common Issues

**Problem**: "No product_curve" warnings during simulation
```
Solution: Increase data_recording_interval or check simulate_once() output
```

**Problem**: Figures not saving
```
Solution: Ensure config.io.outdir exists and has write permissions
```

**Problem**: Out of memory errors
```
Solution: Reduce batch_count or total_time to decrease data size
```

### Performance Tips

- Use `parfor` for batch parallelization (requires Parallel Computing Toolbox)
- Reduce `data_recording_interval` to decrease memory footprint
- Consider GPU acceleration for large enzyme counts (modify `config.batch.use_gpu`)

## Citation

If you use this dual-system comparison module in your research, please cite:

```
@software{2D_Enzyme_Cascade_Dual_Comparison,
  title={Dual-System Comparison Module for 2D Enzyme Cascade Simulation},
  year={2025},
  url={https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE}
}
```

## Support

For questions, issues, or feature requests:
- **GitHub Issues**: [Submit here](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **Documentation**: See main [README.md](../README.md) for project overview

---

**Last Updated**: 2025-09-30
**Module Version**: v1.0