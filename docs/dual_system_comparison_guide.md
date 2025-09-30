# Dual System Comparison Guide

## Overview

This guide explains how to use the dual-system comparison module to visualize and analyze product generation kinetics for **bulk** vs **MSE** enzyme distributions.

## Features

- ✅ **Dual-system batch simulations**: Runs both bulk and MSE configurations with identical seeds
- ✅ **Statistical visualization**: Displays mean±S.D. curves with shaded error bands
- ✅ **Advanced statistical plots**:
  - Monte Carlo convergence analysis
  - Batch distribution comparison (box plots + histograms)
  - Enhancement factor evolution over time
  - Batch timeseries heatmaps with anomaly detection
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
- **Question 5**: `y` for "Enable visualization" (to generate comparison plot)
- **Question 5b**: `y` for "Run dual-system comparison (bulk vs MSE)"

This will:
1. Prompt for interactive configuration
2. Generate random seeds for Monte Carlo sampling
3. Execute bulk and MSE simulations automatically
4. Create comparison plot with mean±S.D. visualization
5. Save results to `out/` directory

### Expected Output

- **Figures**:
  - `dual_comparison_enzymes_400.{png,pdf,fig}` - Mean±S.D. comparison plot
  - `stats_enzymes_400_*.{png,pdf,fig}` - Advanced statistical plots:
    - Batch distribution comparison (box plot + histogram)
    - Enhancement factor evolution with confidence intervals
    - Monte Carlo convergence analysis (Bulk & MSE)
    - Batch timeseries heatmaps with anomaly detection (Bulk & MSE)

- **Data**:
  - `batch_results_bulk.csv` - Bulk system batch statistics
  - `batch_results_mse.csv` - MSE system batch statistics
  - `batch_results.csv` - Default mode batch results (for compatibility)
  - `mc_summary_bulk.csv` - Bulk Monte Carlo confidence intervals
  - `mc_summary_mse.csv` - MSE Monte Carlo confidence intervals
  - `seeds.csv` - Seed records for reproducibility

## Configuration

### Enzyme Quantity

Enzyme count is configured during the interactive workflow. When prompted in `main_2d_pipeline`, specify the desired number of enzymes.

**Recommended values**:
- Low density: 10-20 enzymes
- Medium density: 40-60 enzymes
- High density: 90-100 enzymes

### Batch Count

Batch count is configured during the interactive workflow. When prompted in `main_2d_pipeline`, specify the desired number of batches.

**Guidelines**:
- Quick test: 5-10 batches
- Standard analysis: 20-50 batches
- Publication quality: 100+ batches

⚠️ **Note**: Larger batch counts improve statistical reliability but increase computation time.

### Simulation Time

Simulation time is configured during the interactive workflow. When prompted in `main_2d_pipeline`, specify the desired total time in seconds.

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

## Advanced Statistical Visualizations

### 1. Monte Carlo Convergence Analysis

**Purpose**: Assess the stability and reliability of statistical estimates

**Features**:
- Cumulative mean convergence curve
- Cumulative standard deviation evolution
- 95% confidence interval width reduction

**Interpretation**:
- Shows how many batches are needed for stable results
- Identifies the point where additional batches provide diminishing returns
- Final reference lines indicate converged values

**Usage**:
```matlab
fig = plot_mc_convergence(batch_table, config, 'Bulk');
```

### 2. Batch Distribution Comparison

**Purpose**: Compare statistical distributions between Bulk and MSE systems

**Features**:
- Box plots with individual data points (jittered scatter)
- Overlaid semi-transparent histograms
- Statistical significance testing (t-test p-value)
- Enhancement factor annotation

**Interpretation**:
- Box plot shows median, quartiles, and outliers
- Histogram overlay reveals distribution shape (skewness, modality)
- Scatter points show individual batch variability

**Usage**:
```matlab
fig = plot_batch_distribution(bulk_data, mse_data, config);
```

### 3. Enhancement Factor Evolution

**Purpose**: Visualize time-dependent enhancement dynamics (MSE/Bulk ratio)

**Features**:
- Mean enhancement factor trajectory with 95% confidence intervals
- Per-batch final enhancement factors (scatter)
- Reference line at EF=1 (no enhancement)
- Statistical annotation box (mean, std, max)

**Interpretation**:
- EF > 1: MSE system shows kinetic advantage
- EF < 1: Bulk system more efficient
- Time-dependent trends reveal transient vs steady-state effects
- Scatter shows batch-to-batch variability in enhancement

**Usage**:
```matlab
fig = plot_enhancement_factor(bulk_data, mse_data, config);
```

### 4. Batch Timeseries Heatmap

**Purpose**: Visualize product evolution across all batches as a 2D color map (NOT particle trajectories)

**Features**:
- 2D heatmap: time (x-axis) vs batch index (y-axis)
- Color intensity represents product count
- Overlaid mean trajectory reference line
- Anomalous batch markers (>2σ deviation)

**Interpretation**:
- Horizontal patterns indicate consistent behavior across batches
- Vertical stripes suggest time-dependent events
- Anomalous batches (red markers) highlight outliers
- Color scale reveals absolute product concentrations

**Usage**:
```matlab
fig = plot_batch_timeseries_heatmap(bulk_data, config, 'Bulk');
fig = plot_batch_timeseries_heatmap(mse_data, config, 'MSE');
```

## Module Files

### Core Functions

| File | Purpose |
|------|---------|
| `modules/viz/plot_dual_system_comparison.m` | Visualization function with mean±S.D. plotting |
| `modules/viz/plot_mc_convergence.m` | Monte Carlo convergence analysis plots |
| `modules/viz/plot_batch_distribution.m` | Distribution comparison (box + histogram) |
| `modules/viz/plot_enhancement_factor.m` | Enhancement factor evolution visualization |
| `modules/viz/plot_batch_timeseries_heatmap.m` | Batch timeseries heatmap with anomaly detection |
| `modules/batch/run_dual_system_comparison.m` | Batch execution for both systems |
| `main_2d_pipeline.m` | Main interactive workflow with dual-system integration |
| `modules/config/interactive_config.m` | Interactive configuration for dual-system mode |

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