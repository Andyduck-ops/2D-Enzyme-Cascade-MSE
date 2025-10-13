# Bug Fix Summary

## 修复的问题 (2025-10-13)

### 1. ✅ 反应“冷却期”被放大与遍历偏置导致精度失真
**问题描述：**
- 忙碌/周转时间以“整步”计数，`dt`稍大时会被夸大（例如真实0.01s被量化为0.1s），总体速率偏低；
- 固定酶遍历顺序引入“先手抢占”偏置；
- 线性近似概率`k·dt`在大`dt`下可溢出到>1。

**修复方案：**
- 改为“连续时间计时器”，定时器按秒递减（每步减`dt`），避免整步放大；
- 每步随机化酶遍历顺序（`randperm`）以消除顺序偏置；
- 线性近似模式增加[0,1]安全钳制；
- 新增`config_sanity_checks()`对`k_max·dt`与扩散步长σ给出警告；
- 新增`auto_adjust_dt()`自动将`dt`回退减半直至满足精度门槛（并记录日志）。

**影响文件：**
- `modules/utils/timer_busy_update.m`（连续时间计时器）
- `modules/sim_core/reaction_step.m`（随机遍历、概率钳制）
- `modules/utils/config_sanity_checks.m`（精度体检）
- `modules/utils/auto_adjust_dt.m`、`main_2d_pipeline.m`（自动dt与日志）

---

### 2. ✅ 单次计算热点未优化、GPU开关仅影响RNG（易误导）
**问题描述：**
- 每步两次`pdist2`全距阵搜索是主耗时；
- 交互里的GPU开关仅影响RNG（`gpurng`），不影响计算，造成“开了GPU也不快”的体验。

**修复方案：**
- 抽象邻域搜索后端：`pdist2` / `rangesearch`（KD-tree）/ GPU 矩阵乘法；
- 新增计算开关：`config.compute.neighbor_backend`、`config.compute.use_gpu`；
- 交互中将`batch.use_gpu`联动映射至`compute.use_gpu`（保持用户简单心智）。

**影响文件：**
- `modules/sim_core/neighbor_search.m`（新）
- `modules/sim_core/reaction_step.m`（接入可插拔后端）
- `modules/config/default_config.m`（新增compute配置）
- `modules/config/interactive_config.m`（GPU交互联动与摘要打印）

---

### 3. ✅ 可视化不优雅（主题适配、箱线图贴边与标注重叠）
**问题描述：**
- 参考线与注释框固定黑白色，暗色主题下突兀；
- 箱线图上下贴边，离群点/箱须“挤在边界”；
- 类目多时刻度/标注重叠；事件点过密不通透。

**修复方案：**
- 主题自适应：参考线/注释框使用前景/背景色；
- 全局`axis padded`减少剪切；事件点半透明；
- 箱线图自动上下预留：边距=min(200, max(1, 0.05·跨度))；
- 根据分组数动态`xlim`并旋转刻度（20°）减少重叠；
- 统一图例字号使用配置。

**影响文件：**
- `modules/viz/viz_style.m`（tight→padded）
- `modules/viz/plot_enhancement_factor.m`（主题自适应参考线与注释）
- `modules/viz/plot_event_map.m`（MarkerFaceAlpha、图例字号）
- `modules/viz/plot_reaction_rate_analysis.m`（图例字号统一）
- `modules/viz/plot_batch_distribution.m`（箱线图y轴预留、刻度旋转、动态xlim）
- `modules/config/default_config.m`（箱线图边距配置项）

---

### 4. ✅ 可复现记录增强（dt自适应日志与元数据）
**问题描述：**
- 自动调整`dt`后需要完整记录过程以保证复现。

**修复方案：**
- 在`out/.../data/`写入`dt_history.txt`记录初始/最终dt与历史序列；
- 在`run_metadata.json`新增：`auto_dt_enabled`、`dt_initial`、`dt_final`、`dt_history`、`kdt_final`、`sigma_final`与目标阈值等。

**影响文件：**
- `main_2d_pipeline.m`（写入日志）
- `modules/io/write_metadata.m`（新增元数据字段）

---

### 5. 🧹 清理冗余
**内容：** 移除不再需要的 `复现seed.txt`。

---

## 测试建议（本次变更）
- dt 收敛：逐步减半`dt`，产物曲线变化<5% 判为可接受；
- 邻域后端一致性：同一seed下`pdist2`/`rangesearch`/GPU统计一致（波动范围内）；
- 箱线图：样本带离群点/极值时不再贴边；多组类目刻度不重叠。

## 版本信息
- 修复日期：2025-10-13
- 修复版本：v1.2.0
- 修复人员：Kiro AI Assistant

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
