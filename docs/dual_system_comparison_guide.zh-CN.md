# 双体系对比使用指南

## 概述

本指南说明如何使用双体系对比模块来可视化和分析 **bulk** vs **MSE** 酶分布的产物生成动力学。

## 功能特性

- ✅ **双体系批量仿真**: 使用相同种子运行 bulk 和 MSE 配置
- ✅ **统计可视化**: 显示 mean±S.D. 曲线和阴影误差带
- ✅ **高级统计图表**:
  - 蒙特卡洛收敛分析
  - 批次结果分布对比（箱线图 + 直方图）
  - 增强因子随时间演化
  - 批次时间序列热力图与异常检测
- ✅ **可配置参数**: 轻松控制酶数量和批次数量
- ✅ **专业样式**: 与现有 `viz_style()` 主题保持一致
- ✅ **导出功能**: 保存图表(PNG, PDF, FIG)和 CSV 报告

## 快速开始

### 交互式工作流（推荐）

```matlab
% 运行主交互式管道
main_2d_pipeline
```

在配置过程中，选择:
- **问题 5**: 输入 `y` 启用 "Enable visualization" (生成对比图)
- **问题 5b**: 输入 `y` 选择 "Run dual-system comparison (bulk vs MSE)"

这将会:
1. 提示交互式配置
2. 生成蒙特卡洛采样的随机种子
3. 自动执行 bulk 和 MSE 仿真
4. 创建 mean±S.D. 可视化对比图
5. 保存结果到 `out/` 目录

### 预期输出

- **图表**:
  - `dual_comparison_enzymes_400.{png,pdf,fig}` - Mean±S.D. 对比图
  - `stats_enzymes_400_*.{png,pdf,fig}` - 高级统计图表：
    - 批次分布对比（箱线图 + 直方图）
    - 增强因子演化（含置信区间）
    - 蒙特卡洛收敛分析（Bulk 和 MSE）
    - 批次时间序列热力图与异常检测（Bulk 和 MSE）

- **数据**:
  - `batch_results_bulk.csv` - Bulk 系统批次统计
  - `batch_results_mse.csv` - MSE 系统批次统计
  - `batch_results.csv` - 默认模式批次结果（兼容性）
  - `mc_summary_bulk.csv` - Bulk 蒙特卡洛置信区间
  - `mc_summary_mse.csv` - MSE 蒙特卡洛置信区间
  - `seeds.csv` - 用于可重现性的种子记录

## 配置说明

### 酶数量

酶数量在交互式工作流中配置。在 `main_2d_pipeline` 提示时，指定所需的酶数量。

**推荐值**:
- 低密度: 10-20 个酶
- 中密度: 40-60 个酶
- 高密度: 90-100 个酶

### 批次数量

批次数量在交互式工作流中配置。在 `main_2d_pipeline` 提示时，指定所需的批次数量。

**指导原则**:
- 快速测试: 5-10 批次
- 标准分析: 20-50 批次
- 出版质量: 100+ 批次

⚠️ **注意**: 更大的批次数量会提高统计可靠性,但会增加计算时间。

### 仿真时间

仿真时间在交互式工作流中配置。在 `main_2d_pipeline` 提示时，指定所需的总时间（秒）。

## 高级用法

### 编程 API

对于自定义工作流,直接使用模块函数:

```matlab
% 1. 设置
config = default_config();
config.particle_params.num_enzymes = 500;
config.batch.batch_count = 30;

% 2. 生成种子
[seeds, ~] = get_batch_seeds(config);

% 3. 运行对比
[bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

% 4. 可视化
fig = plot_dual_system_comparison(bulk_data, mse_data, config);

% 5. 自定义图表(可选)
ax = gca;
title(ax, '自定义标题: 我的分析');
xlabel(ax, '时间 (秒)');
```

### 数据结构

对比函数返回结构化数据:

```matlab
bulk_data (或 mse_data) = 包含以下字段的结构体:
    time_axis: [n_steps × 1] double     % 时间点 (s)
    product_curves: [n_steps × n_batches] double  % 产物数量矩阵
    enzyme_count: 标量 double           % 使用的酶数量
    batch_table: table                  % 完整批次统计
```

### 提取统计数据

```matlab
% 最终时间点的均值和标准差
bulk_final_mean = mean(bulk_data.product_curves(end, :));
bulk_final_std = std(bulk_data.product_curves(end, :), 0);

% 增强因子
enhancement = mean(mse_data.product_curves(end, :)) / bulk_final_mean;
fprintf('MSE 增强: %.2fx\n', enhancement);

% 时间序列分析
time_idx = 50;  % t=50s 的索引(取决于 time_step)
bulk_at_50s = mean(bulk_data.product_curves(time_idx, :));
mse_at_50s = mean(mse_data.product_curves(time_idx, :));
```

## 高级统计可视化

### 1. 蒙特卡洛收敛分析

**目的**: 评估统计估计的稳定性和可靠性

**特性**:
- 累积均值收敛曲线
- 累积标准差演化
- 95% 置信区间宽度缩减

**解读**:
- 显示需要多少批次才能得到稳定结果
- 识别额外批次带来边际收益递减的临界点
- 最终参考线指示收敛值

**用法**:
```matlab
fig = plot_mc_convergence(batch_table, config, 'Bulk');
```

### 2. 批次分布对比

**目的**: 比较 Bulk 和 MSE 系统的统计分布差异

**特性**:
- 箱线图配合单个数据点（抖动散点图）
- 叠加半透明直方图
- 统计显著性检验（t 检验 p 值）
- 增强因子标注

**解读**:
- 箱线图显示中位数、四分位数和异常值
- 直方图叠加揭示分布形态（偏度、峰度）
- 散点显示单个批次的变异性

**用法**:
```matlab
fig = plot_batch_distribution(bulk_data, mse_data, config);
```

### 3. 增强因子演化

**目的**: 可视化时间依赖的增强动力学（MSE/Bulk 比值）

**特性**:
- 平均增强因子轨迹配 95% 置信区间
- 各批次终态增强因子（散点）
- EF=1 参考线（无增强）
- 统计标注框（均值、标准差、最大值）

**解读**:
- EF > 1：MSE 系统显示动力学优势
- EF < 1：Bulk 系统更高效
- 时间依赖趋势揭示瞬态 vs 稳态效应
- 散点显示批次间增强的变异性

**用法**:
```matlab
fig = plot_enhancement_factor(bulk_data, mse_data, config);
```

### 4. 批次时间序列热力图

**目的**: 将所有批次的产物演化可视化为 2D 颜色图（不是粒子轨迹图）

**特性**:
- 2D 热力图：时间（x 轴）vs 批次索引（y 轴）
- 颜色强度代表产物数量
- 叠加平均轨迹参考线
- 异常批次标记（>2σ 偏差）

**解读**:
- 水平模式表示批次间一致行为
- 垂直条纹暗示时间依赖事件
- 异常批次（红色标记）突出离群值
- 颜色刻度揭示绝对产物浓度

**用法**:
```matlab
fig = plot_batch_timeseries_heatmap(bulk_data, config, 'Bulk');
fig = plot_batch_timeseries_heatmap(mse_data, config, 'MSE');
```

## 模块文件

### 核心函数

| 文件 | 用途 |
|------|------|
| `modules/viz/plot_dual_system_comparison.m` | 带 mean±S.D. 绘图的可视化函数 |
| `modules/viz/plot_mc_convergence.m` | 蒙特卡洛收敛分析图 |
| `modules/viz/plot_batch_distribution.m` | 分布对比（箱线图 + 直方图）|
| `modules/viz/plot_enhancement_factor.m` | 增强因子演化可视化 |
| `modules/viz/plot_batch_timeseries_heatmap.m` | 批次时间序列热力图与异常检测 |
| `modules/batch/run_dual_system_comparison.m` | 两种系统的批量执行 |
| `main_2d_pipeline.m` | 集成双体系的主交互式工作流 |
| `modules/config/interactive_config.m` | 双体系模式的交互式配置 |

### 依赖关系

- `modules/viz/viz_style.m` - 统一可视化样式
- `modules/config/default_config.m` - 配置管理
- `modules/batch/run_batches.m` - 批处理框架
- `modules/sim_core/simulate_once.m` - 核心仿真引擎
- `modules/utils/getfield_or.m` - 安全字段提取工具

## 结果解读

### 阅读图表

- **蓝色曲线**: Bulk 系统均值轨迹
- **红色曲线**: MSE 系统均值轨迹
- **阴影区域**: ±1 标准差置信带
- **图例**: 显示最终 mean±S.D. 值,便于快速比较

### 关键指标

1. **最终产物数量**: t=total_time 时的均值
2. **标准差**: 蒙特卡洛样本间的变异性
3. **增强因子**: MSE_mean / Bulk_mean
   - \>1: MSE 显示动力学优势
   - <1: Bulk 系统更高效

### 物理解释

- **低酶密度**: MSE 通常显示增强,因为中间产物扩散距离减少
- **高酶密度**: Bulk 可能表现更好,原因:
  - 第一步反应通量增加
  - MSE 拥挤抑制效应

## 故障排查

### 常见问题

**问题**: 仿真期间出现 "No product_curve" 警告
```
解决方案: 增加 data_recording_interval 或检查 simulate_once() 输出
```

**问题**: 图表未保存
```
解决方案: 确保 config.io.outdir 存在且有写入权限
```

**问题**: 内存不足错误
```
解决方案: 减少 batch_count 或 total_time 以降低数据大小
```

### 性能提示

- 使用 `parfor` 进行批处理并行化(需要 Parallel Computing Toolbox)
- 减少 `data_recording_interval` 以降低内存占用
- 考虑 GPU 加速处理大量酶(修改 `config.batch.use_gpu`)

## 引用

如果您在研究中使用此双体系对比模块,请引用:

```
@software{2D_Enzyme_Cascade_Dual_Comparison,
  title={2D 酶级联仿真双体系对比模块},
  year={2025},
  url={https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE}
}
```

## 支持

如有问题、反馈或功能请求:
- **GitHub Issues**: [在此提交](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **文档**: 参见主 [README.zh-CN.md](../README.zh-CN.md) 了解项目概览

---

**最后更新**: 2025-09-30
**模块版本**: v1.0