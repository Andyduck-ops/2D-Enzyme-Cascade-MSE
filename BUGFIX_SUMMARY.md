# Bug Fix Summary

## 修复的问题 (2025-10-10)

### 1. ❌ 批次运行不应该有 single_viz 文件夹
**问题描述：** 批次运行时会创建 `single_viz/` 文件夹，但这个文件夹应该只用于单次运行的可视化。

**修复方案：**
- 移除 `output_manager.m` 中创建 `single_viz` 目录的逻辑
- 修改 `main_2d_pipeline.m`，只在 `batch_count == 1` 时运行单次可视化
- 批次运行只生成统计图表，不生成单次运行的快照

**影响文件：**
- `modules/io/output_manager.m`
- `main_2d_pipeline.m`

---

### 2. ❌ 图片没有正确保存到输出文件夹
**问题描述：** 所有图片应该保存到 `figures/` 目录，但有些保存到了错误的位置。

**修复方案：**
- 统一所有 `save_figures()` 调用使用 `config.io.figures_dir`
- 移除使用 `viz_outdir` 变量的逻辑
- 确保动画视频也保存到 `figures/` 目录

**影响文件：**
- `main_2d_pipeline.m`

---

### 3. ❌ 批次运行不应该包含单次运行的快照
**问题描述：** 批次运行时会生成单次运行的快照图（如 snapshot、tracer 等），这些应该只在单次运行时生成。

**修复方案：**
- 添加条件判断：只在 `batch_count == 1` 时运行单次可视化
- 批次运行（`batch_count > 1`）只生成统计图表：
  - Dual system comparison
  - Batch distribution
  - Enhancement factor
  - MC convergence
  - Batch timeseries heatmap

**影响文件：**
- `main_2d_pipeline.m`

---

### 4. ⚠️ MP4 视频无法播放
**可能原因：**
- 编码器问题
- 帧率设置问题
- 视频质量设置问题

**建议检查：**
1. 确认 MATLAB 版本支持 MPEG-4 编码
2. 尝试使用其他视频播放器（VLC、Windows Media Player）
3. 检查 `animate_snapshots.m` 中的编码设置

**当前设置：**
```matlab
v = VideoWriter(video_path, 'MPEG-4');
v.FrameRate = 10;  % 默认 10 fps
v.Quality = 95;    % 高质量
```

---

## 修复后的目录结构

### 单次运行 (batch_count = 1)
```
out/single/20251010_143022_mse_enz400_sub3000_seed1234/
├── data/
│   ├── run_metadata.json
│   ├── seeds.csv
│   └── batch_results.csv
└── figures/
    ├── viz_seed_1234_01_ProductCurve.png
    ├── viz_seed_1234_02_ReactionRate.png
    ├── viz_seed_1234_03_Snapshot_t0.png
    ├── viz_seed_1234_04_EventMap.png
    ├── viz_seed_1234_05_Tracers.png
    └── animation_seed_1234.mp4  (如果启用)
```

### 批次运行 (batch_count > 1)
```
out/batch/20251010_143530_mse_enz400_sub3000_n10/
├── data/
│   ├── run_metadata.json
│   ├── seeds.csv
│   └── batch_results.csv
└── figures/
    └── (只有统计图表，没有单次运行的快照)
```

### Dual 模式批次运行
```
out/batch/20251010_143530_dual_enz400_sub3000_n10/
├── data/
│   ├── run_metadata.json
│   ├── seeds.csv
│   ├── batch_results_bulk.csv
│   ├── batch_results_mse.csv
│   ├── timeseries_products_bulk.csv
│   └── timeseries_products_mse.csv
└── figures/
    ├── dual_comparison_enzymes_400.png
    ├── stats_enzymes_400_01_BatchDistribution.png
    ├── stats_enzymes_400_02_EnhancementFactor.png
    ├── stats_enzymes_400_03_MCConvergence_Bulk.png
    ├── stats_enzymes_400_04_MCConvergence_MSE.png
    ├── stats_enzymes_400_05_Heatmap_Bulk.png
    └── stats_enzymes_400_06_Heatmap_MSE.png
```

---

## 测试建议

### 测试 1：单次运行
```matlab
main_2d_pipeline
% 选择：
% - Batch count = 1
% - Visualization = y
% - Animation = y (可选)
% - Figure save = y

% 预期结果：
% - 在 out/single/ 下创建时间戳目录
% - figures/ 包含所有可视化图片
% - 如果启用动画，包含 .mp4 文件
% - 没有 single_viz/ 文件夹
```

### 测试 2：批次运行（非 Dual）
```matlab
main_2d_pipeline
% 选择：
% - Batch count = 10
% - Visualization = n  (批次运行不需要单次可视化)
% - Figure save = y

% 预期结果：
% - 在 out/batch/ 下创建时间戳目录
% - figures/ 为空（因为没有启用可视化）
% - 没有 single_viz/ 文件夹
% - 没有单次运行的快照图
```

### 测试 3：Dual 模式批次运行
```matlab
main_2d_pipeline
% 选择：
% - Batch count = 10
% - Dual comparison = y
% - Visualization = n
% - Figure save = y

% 预期结果：
% - 在 out/batch/ 下创建时间戳目录
% - figures/ 包含统计图表（dual comparison, distributions, etc.）
% - 没有 single_viz/ 文件夹
% - 没有单次运行的快照图
```

---

## 注意事项

1. **批次运行的可视化**：批次运行应该关注统计结果，不需要单次运行的详细可视化
2. **单次运行的可视化**：只有 `batch_count = 1` 时才生成详细的快照、轨迹等图
3. **图片保存位置**：所有图片统一保存到 `figures/` 目录
4. **MP4 播放问题**：如果无法播放，尝试使用 VLC 播放器或检查 MATLAB 版本

---

## 版本信息

- 修复日期：2025-10-10
- 修复版本：v1.1.0
- 修复人员：Kiro AI Assistant
