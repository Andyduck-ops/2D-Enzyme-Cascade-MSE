# 2D 酶级联模拟


<!-- 语言切换 -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)


<!-- 项目徽章 -->
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b%2B%20(已测试%202023)-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](#)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](#-安装指南)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-A%2B-brightgreen.svg)](#)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-success.svg)](#)
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-purple.svg)](docs/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/Andyduck-ops/2D-Enzyme-Cascade-MSE?style=social)](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/stargazers)


<!-- 核心链接 -->
- 📖 **文档资料**: [2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)
- 🎯 **快速入门**: [安装指南](#-安装指南) | [使用方法](#-快速入门) | [示例代码](#-示例代码)
- ⚡ **功能特性**: [核心功能](#-核心功能) | [算法原理](#-算法说明) | [可视化](#-visualization)

## 🎯 项目概览

一个全面、模块化的MATLAB框架，用于比较矿物表面局域化酶（MSE）与体相分散模式的两步级联反应效率。该框架通过**缩短中间产物扩散距离**来量化共定位酶的空间邻近优势，同时考虑高酶密度下**bulk体系第一步反应通量优势**与**MSE拥挤抑制**的双重机制。实现了先进的随机模拟，包括异质扩散、 $\tau$ -跳跃反应和完全可复现的科学计算。

### 核心科学背景

本研究专注于**矿物表面酶（MSE）局域化的空间邻近效应**——通过共定位级联酶来**缩短中间产物扩散距离**，从而提高反应效率。关键发现是这种优势具有**浓度依赖性**：在**低酶密度**时，空间邻近性带来显著动力学增强；但在**高酶密度**时，bulk体系因**第一步反应接触通量大幅增加**而获得初始反应优势，同时MSE体系受**拥挤抑制**进一步削弱，使bulk分散模式更为高效。该计算框架通过随机布朗动力学模拟定量评估这种浓度依赖的双重机制权衡。

### 研究影响
- **主要目标**: 通过系统计算研究，揭示MSE局域化的**浓度依赖性优势**——在低酶密度时通过缩短扩散距离提供显著增强，在高密度时因bulk体系第一步反应通量优势与MSE拥挤抑制的双重作用而逆转
- **核心洞察**: 识别**最优酶浓度区间**，其中空间邻近性的优势超过bulk体系第一步反应通量优势与MSE拥挤抑制的双重劣势，为理解原始生命系统的组织原理提供定量基础
- **应用领域**: 生物催化、酶工程、合成生物学、工业过程优化，以及理解前生命反应系统

## 概览

- 两步级联：S -(GOx)-> I -(HRP)-> P
- 模式：
  - MSE：酶局域于中心颗粒周围的薄膜环区
  - Bulk：酶在盒域内均匀分布
- 功能：异质扩散（薄膜/体相）、镜面反射边界、逐步随机反应、批处理统计、可选可视化
- 入口与核心：
  - 主流程：[main_2d_pipeline.m](main_2d_pipeline.m)
  - 单次模拟：[simulate_once()](modules/sim_core/simulate_once.m)
  - 批处理MC：[run_batches()](modules/batch/run_batches.m)
  - 默认配置：[default_config()](modules/config/default_config.m)

## 背景（为何比较 MSE 与 bulk）

- 科学动机：矿物表面酶（MSE）局域化的主要优势在于**缩短中间产物的扩散距离**，提高级联反应中酶间的底物传递效率。这种空间优势在**低酶浓度**时尤为显著，但在**高酶浓度**时会被双重机制逆转：bulk体系获得**第一步反应接触通量优势**，同时MSE体系受**拥挤抑制**削弱，使bulk分散模式更为高效。
- 2D 抽象：用环区 $[r_p, r_p + f_t]$ 近似中心颗粒周围的表面薄膜，酶在 MSE 模式固定于环区，bulk 模式则在盒域均匀分布。默认参数体现强扩散对比（如 $D_{\text{film}} = 10$ 与 $D_{\text{bulk}} = 1000 \text{ nm}^2/\text{s}$ ）与适中的膜厚（ $f_t = 5 \text{ nm}$ ），见 [modules/config/default_config.m](modules/config/default_config.m)。
- 反应语境：两步级联 S -(GOx) $\rightarrow$ I -(HRP) $\rightarrow$ P；酶数量按比例 `gox_hrp_split`（默认 50/50）划分 GOx 与 HRP。
- 模型假设（范围）：酶不移动；S/I/P 扩散；盒域与颗粒边界为镜面反射；固定步长 $\tau$ ‑跳跃；无吸附/解吸；MSE 下仅接受薄膜环区内的反应事件。
- 面向论文的输出：MSE vs bulk 的产物优势、反应速率曲线、空间事件图、示踪轨迹；批量 CSV 用于均值/方差等统计汇总。可视化入口： [modules/viz/plot_event_map.m](modules/viz/plot_event_map.m)、[modules/viz/plot_tracers.m](modules/viz/plot_tracers.m)、[modules/viz/plot_product_curve.m](modules/viz/plot_product_curve.m)。

## ⚡ 核心功能

### 🧬 高级模拟能力
- **两步酶级联**: S -(GOx)-> I -(HRP)-> P
- **双重模拟模式**:
  - **MSE模式**: 酶局域于中心颗粒周围的薄膜环区
  - **Bulk模式**: 酶在模拟盒中均匀分布
- **异质扩散**: 薄膜与体相区域的不同扩散系数
- **随机反应**: 基于概率的 $\tau$ -跳跃反应事件
- **拥挤抑制**: 局部酶密度通过抑制因子调节有效催化速率，公式为 $\text{抑制因子} = 1 - I_{\text{max}} \times \min(n_{\text{local}}/n_{\text{sat}}, 1)$

### 🔬 科学严谨性
- **可复现结果**: 使用固定随机种子的确定性模拟
- **批量蒙特卡洛**: 多个独立运行的统计分析
- **边界条件**: 盒壁和颗粒表面的反射边界
- **物理验证**: 基于已建立生物物理原理的模型

### ⚡ 高性能计算 (新功能 ✨)
- **自动CPU核心检测**: 自动检测并利用可用CPU核心以获得最佳性能
- **智能并行处理**: 智能工作进程分配（CPU核心数 - 1），保持系统响应性
- **灵活的工作进程配置**: 可选择自动模式或手动指定工作进程数
- **并行池管理**: 自动创建和优化并行池
- **性能扩展**: 大规模批处理模拟接近线性加速（8核系统可达6-7倍速度提升）
- **详见**: [并行计算配置指南](docs/parallel_computing_guide.md) 获取详细配置和性能优化建议

### 📊 全面分析
- **实时可视化**: 产物曲线、事件图和示踪轨迹
- **统计报告**: 自动生成CSV导出文件，包括批次结果(`batch_results.csv`)、种子记录(`seeds.csv`)和统计摘要(`mc_summary.csv`)，含均值、方差和置信区间
- **空间分析**: 反应事件和粒子分布的热图
- **性能指标**: 反应速率、产率和效率因子

### 📂 数据管理与对比 (新功能 ✨)
- **时间戳输出结构**: 自动时间戳的分层目录结构，便于数据管理
  - `out/single/` 和 `out/batch/` 目录，包含时间戳子目录
  - 自动创建 `latest` 快捷方式/符号链接指向最新运行
  - 结构化子目录：`data/`、`figures/`
- **历史数据导入**: 加载并对比之前的模拟运行结果
  - 交互式运行选择界面
  - 支持单模式和双模式历史数据
  - 自动元数据提取和验证
- **多数据集对比**: 同时可视化和对比多个历史运行
  - 出版级对比图，包含均值±标准差曲线
  - 统计可视化的阴影误差带
  - 交互式图例，点击切换可见性
  - 自动颜色和线型循环以提高清晰度
- **基于输出目录的可复现性**: 根据 `out/` 下的时间戳运行目录复现实验
  - 用目录名定位历史运行
  - 从 `data/run_metadata.json` 读取完整参数
  - 复现 Monte Carlo 批量运行时从 `data/seeds.csv` 读取批次种子
- **全面元数据**: JSON格式的运行元数据，完整可追溯
  - 配置参数、种子信息、输出文件清单
  - 系统信息和运行时统计
  - 每次运行自动生成和存储

## 算法说明

### 几何与状态
- 域： $L \times L$ 的二维正方形
- 中心颗粒：半径 r_p
- 薄膜环区：MSE 模式下的 [r_p, r_p + f_t]
- 物种：S、I、P 为可扩散粒子；酶固定在其位置（MSE 模式局域在环区，bulk 模式均匀分布）

### 扩散（布朗步进）
对每个粒子位置 $x \in \mathbb{R}^2$ ：

**布朗步进公式**： $x_{t+\Delta t} = x_t + \sqrt{2 D(x_t) \Delta t} \cdot \eta$，其中 $\eta \sim N(0, I_2)$。

- MSE：环区内 D = D_film，环区外 D = D_bulk
- Bulk：全域 D = D_bulk
实现：[diffusion_step()](modules/sim_core/diffusion_step.m)


### 边界
- 盒域边界：镜面反射，见 [boundary_reflection()](modules/sim_core/boundary_reflection.m)


### 反应（每步 $\tau$ -跳跃）
每步存在两条独立通道：

**反应通道**：

1. S + GOx $\rightarrow$ I，反应概率： $P_{\text{GOx}} = (1 - \exp(-k_{\text{cat,GOx}} \Delta t)) \times \text{抑制因子}_{\text{GOx}}$

2. I + HRP $\rightarrow$ P，反应概率： $P_{\text{HRP}} = (1 - \exp(-k_{\text{cat,HRP}} \Delta t)) \times \text{抑制因子}_{\text{HRP}}$

拥挤抑制（按酶局部密度）：

**拥挤抑制公式**： $\text{抑制因子} = 1 - I_{\text{max}} \times \min(n_{\text{local}}/n_{\text{sat}}, 1)$

MSE 模式同时要求反应位置在薄膜环区内。
实现：[reaction_step()](modules/sim_core/reaction_step.m)


### 记录与汇总
- 反应计数 $\rightarrow$ 反应速率曲线
- 产物曲线 $P(t) \leftarrow$ HRP 速率积分
- 可选：快照、示踪轨迹、事件空间坐标
实现：[record_data()](modules/sim_core/record_data.m)


### 调度与时序

时间循环：
```
for step = 1..N
  扩散 $\rightarrow$ 边界反射 $\rightarrow$ （可选）轨迹更新
  GOx/HRP 反应 $\rightarrow$ 记录
end
```
实现：[simulate_once()](modules/sim_core/simulate_once.m)


### 批处理与可复现
- 每批设置 RNG 种子，独立运行
- 聚合到表格并写出 CSV
批处理：[run_batches()](modules/batch/run_batches.m)
RNG 设置：[setup_rng()](modules/rng/setup_rng.m)
批次种子：[get_batch_seeds()](modules/seed_utils/get_batch_seeds.m)

### 精度与加速（关键设置）
- 连续时间计时器：酶的忙碌/周转以“秒”为单位计时，每步减`Δt`，避免整步取整造成的冷却期夸大。
- 邻域搜索后端（单次运行加速）：
  ```matlab
  % 计算/加速选项
  config.compute.neighbor_backend = 'auto';   % 'auto' | 'pdist2' | 'rangesearch' | 'gpu'
  config.compute.use_gpu = 'off';             % 'off'  | 'on'     | 'auto'
  ```
- 步长体检建议：优先满足`k_max * dt ≤ 0.05`，且`sqrt(2*D_bulk*dt) ≪ min(反应半径, 薄膜厚度)`；`config_sanity_checks()`会打印提醒。

- 自动自适应 `dt`（默认开启）
  ```matlab
  % 自动回退 dt 直至满足门槛，并记录历史
  config.simulation_params.enable_auto_dt = true;
  % 门槛（可选调节）
  config.simulation_params.auto_dt.target_k_fraction   = 0.05;  % 约束 k_max*dt ≤ 该值
  config.simulation_params.auto_dt.target_sigma_fraction = 0.3; % 约束 σ ≤ 该比例·最小几何尺度
  config.simulation_params.auto_dt.target_sigma_abs_nm   = 1.0; % 且 σ ≤ 该绝对上限
  ```
  - 整个批次共享同一“自适应后的 dt”（在运行前确定）；
  - 输出会在`out/.../data/dt_history.txt`记录初始/最终 dt 与迭代历史；
  - `run_metadata.json`中也会写入`dt_initial/dt_final/dt_history/kdt_final/sigma_final`等字段，保证完全复现。

- 交互 GPU 选项更简单
  - 交互里的`GPU strategy use_gpu`现在会自动映射到计算后端：
    - `on` 开启 GPU 邻域搜索（可用时），`auto` 自动检测且不可用时回退 CPU，`off` 固定 CPU；
    - RNG 的 GPU 种子设置也同时保持一致。

- 箱线图可读性（批次可视化）
  - 已默认增加上下留白，避免箱须/离群点贴边；如需调整：
    ```matlab
    config.plotting_controls.boxplot_y_pad_frac = 0.05; % 留白占数据跨度比例
    config.plotting_controls.boxplot_y_pad_min  = 1;    % 留白下限
    config.plotting_controls.boxplot_y_pad_max  = 200;  % 留白上限
    ```

## 📋 目录

- [项目概览](#-项目概览)
- [核心功能](#-核心功能)
- [安装指南](#-安装指南)
- [快速入门](#-快速入门)
- [快速复现](#-快速复现)
- [示例代码](#-示例代码)
- [算法原理](#-算法说明)
- [配置说明](#-配置说明)
- [可视化工具](#-可视化工具)
- [项目结构](#-项目结构)
- [贡献指南](#-贡献指南)
- [许可证](#-许可证)
- [作者与引用](#-作者与引用)

## 📦 安装指南

### 系统要求
- **MATLAB版本**: R2019b或更高版本（已在MATLAB 2023上测试）
- **必需工具箱**:
  - Statistics and Machine Learning Toolbox（用于`pdist2`）
  - Parallel Computing Toolbox（可选，用于批量处理加速）
- **操作系统**: Windows、macOS或Linux
- **内存**: 最小4GB RAM，大型模拟推荐8GB+
- **GPU**: 推荐NVIDIA GPU用于加速计算（可选）

### 快速安装
```bash
# 克隆仓库
git clone https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE.git
cd 2D-Enzyme-Cascade-Simulation

# 注意：运行模拟时会自动创建输出目录
# 可选：预先创建输出目录
mkdir -p out
```

### MATLAB设置
1. 打开MATLAB并导航到项目根目录
2. 主流程会自动将`modules/`添加到MATLAB路径
3. **GPU设置（可选）**: 如果您有NVIDIA GPU，请确保安装了CUDA并在MATLAB中启用GPU计算以获得最佳性能
4. 通过运行以下命令验证安装：
```matlab
% 在MATLAB中的项目根目录
main_2d_pipeline
```

## 🚀 快速入门

### 交互模式（推荐初学者使用）
```matlab
% 在MATLAB中的项目根目录
main_2d_pipeline
% 按照交互提示配置和运行模拟
```

### 编程模式（高级用户）
```matlab
% 加载默认配置
config = default_config();

% 设置模拟参数
config.simulation_params.simulation_mode = 'MSE';  % 或 'bulk'
config.batch.batch_count = 10;
config.ui_controls.visualize_enabled = true;

% 运行模拟
results = run_batches(config, (1001:1010)');

% 查看结果
disp(['最终产物数: ', num2str(results.products_final)]);
```

### 基本配置示例
```matlab
% 最简MSE模拟
config = default_config();
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 200;
config.ui_controls.visualize_enabled = true;

% 运行单次模拟
result = simulate_once(config, 1234);
fprintf('MSE模式产生了%d个产物\n', result.products_final);
```

## 🔄 快速复现

### 根据 `out/` 运行目录复现

本项目的复现入口是 `out/` 下的历史运行目录，而不是手动维护的 seed 文本文件。目录名用于快速定位一次运行，完整参数和输出文件清单记录在该目录的 `data/run_metadata.json` 中；批量 Monte Carlo 运行的每个批次种子记录在 `data/seeds.csv` 中。

典型目录名包含关键索引信息：

```text
out/single/20251017_154320_mse_enz100_sub9000_seed1234/
out/batch/20251016_110157_dual_enz20_sub9000_n200/
```

目录名中的时间戳、模式、酶数量、底物数量、seed 或批次数用于选择目标实验；真正用于复现的完整配置以 `data/run_metadata.json` 为准。

#### 方法1：查看历史运行并选择目标目录

```matlab
% 列出 out/single 和 out/batch 中的历史运行
browse_history_cli()

% 或只查看批量运行
browse_history_cli('batch')
```

也可以直接打开目标目录，例如：

```text
out/batch/20251016_110157_dual_enz20_sub9000_n200/data/run_metadata.json
out/batch/20251016_110157_dual_enz20_sub9000_n200/data/seeds.csv
```

#### 方法2：按元数据恢复单次运行

```matlab
% 示例：根据 run_metadata.json 中的 parameters 字段恢复配置
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

% seed 来自目录名或 run_metadata.json 的 seed_info.fixed_seed
result = simulate_once(config, 1234);
fprintf('复现结果: %d 个产物\n', result.products_final);
```

如果开启了自适应 dt，请同时使用 `run_metadata.json` 中记录的 `dt_final`、`dt_history` 和 dt 约束信息；README 中示例只展示核心参数，复现时不要只依赖示例。

#### 方法3：按 `seeds.csv` 复现批量运行

```matlab
config = default_config();

% 根据目标 run_metadata.json 恢复参数
config.simulation_params.simulation_mode = 'MSE';
config.particle_params.num_enzymes = 20;
config.particle_params.num_substrate = 9000;
config.batch.batch_count = 200;

% 从目标运行目录读取原始批次种子
seed_table = readtable('out/batch/20251016_110157_dual_enz20_sub9000_n200/data/seeds.csv');
seeds = seed_table.seed;

batch_results = run_batches(config, seeds);
fprintf('批量复现: %.1f ± %.1f 个产物\n', ...
    mean(batch_results.products_final), std(batch_results.products_final));
```

交互模式下也可以在 seed mode 选择 `from_file`，程序会从历史批量运行中选择 `seeds.csv` 并记录来源信息。

### 记录新实验

每次运行都会自动生成带时间戳的输出目录。保留或分享该目录即可保留复现实验所需的信息：

- `data/run_metadata.json`：运行类型、模式、关键参数、dt 自适应信息、seed 信息、输出文件清单、系统信息和运行时间
- `data/seeds.csv`：批量运行的每个 Monte Carlo 批次 seed
- `data/batch_results*.csv`：最终统计结果
- `data/timeseries_products*.csv`：产物时间序列
- `figures/`：本次运行生成的图

## 💡 示例代码

### 示例1：MSE与Bulk模式对比
```matlab
% 对比分析
config = default_config();
config.batch.batch_count = 1;

% MSE模式
config.simulation_params.simulation_mode = 'MSE';
mse_result = simulate_once(config, 1234);

% Bulk模式
config.simulation_params.simulation_mode = 'bulk';
bulk_result = simulate_once(config, 1234);

% 计算增强因子
enhancement = mse_result.products_final / max(bulk_result.products_final, 1);
fprintf('MSE增强因子: %.2fx\n', enhancement);
```

### 示例1.5：双体系对比统计可视化（新功能 ✨）
```matlab
% 新功能：集成的双体系对比，配合 mean±S.D. 可视化
% 通过交互式工作流运行 bulk 与 MSE 两种模式的蒙特卡洛采样

% 交互式工作流（推荐）
main_2d_pipeline
% 然后选择:
%   5b) Run dual-system comparison (bulk vs MSE) [y/n]: y
%   5)  Enable visualization [y/n]: y

% 编程方式使用 - 自定义配置
config = default_config();
config.particle_params.num_enzymes = 500;  % 可配置酶数量
config.batch.batch_count = 30;             % 蒙特卡洛采样数
config.batch.seed_mode = 'incremental';
config.batch.seed_base = 6000;
config.ui_controls.dual_system_comparison = true;  % 启用对比模式
config.ui_controls.visualize_enabled = true;       % 启用可视化

% 生成种子并运行对比
[seeds, ~] = get_batch_seeds(config);
[bulk_data, mse_data] = run_dual_system_comparison(config, seeds);

% 使用 mean±S.D. 误差带可视化
fig = plot_dual_system_comparison(bulk_data, mse_data, config);

% 提取统计信息
fprintf('Bulk:  %.1f ± %.1f 个产物\n', ...
    mean(bulk_data.product_curves(end,:)), std(bulk_data.product_curves(end,:), 0));
fprintf('MSE:   %.1f ± %.1f 个产物\n', ...
    mean(mse_data.product_curves(end,:)), std(mse_data.product_curves(end,:), 0));
fprintf('增强倍数: %.2fx\n', ...
    mean(mse_data.product_curves(end,:)) / mean(bulk_data.product_curves(end,:)));

% 详细使用说明请参考: docs/dual_system_comparison_guide.zh-CN.md
```

### 示例2：酶浓度研究
```matlab
% 测试不同酶浓度
enzyme_counts = [50, 100, 200, 400, 800];
results = zeros(size(enzyme_counts));

config = default_config();
config.simulation_params.simulation_mode = 'MSE';

for i = 1:length(enzyme_counts)
    config.particle_params.num_enzymes = enzyme_counts(i);
    result = simulate_once(config, 1000 + i);
    results(i) = result.products_final;
    fprintf('酶数量: %d, 产物数: %d\n', enzyme_counts(i), results(i));
end

% 绘制结果图
plot(enzyme_counts, results, '-o');
xlabel('酶数量');
ylabel('最终产物数');
title('酶浓度 vs 产物产率');
grid on;
```

### 示例3：批量统计分析
```matlab
% 多次运行的统计分析
config = default_config();
config.batch.batch_count = 30;  % 中心极限定理要求
config.simulation_params.simulation_mode = 'MSE';

% 运行批量模拟
batch_results = run_batches(config);

% 计算统计量
mean_products = mean(batch_results.products_final);
std_products = std(batch_results.products_final);
ci_lower = mean_products - 1.96 * std_products / sqrt(length(batch_results.products_final));
ci_upper = mean_products + 1.96 * std_products / sqrt(length(batch_results.products_final));

fprintf('平均产物数: %.2f ± %.2f\n', mean_products, std_products);
fprintf('95%%置信区间: [%.2f, %.2f]\n', ci_lower, ci_upper);
```

### 示例4：扩散参数研究
```matlab
% 研究扩散系数的影响
diff_coeff_film_values = [1, 5, 10, 20, 50];
results = zeros(size(diff_coeff_film_values));

config = default_config();
config.simulation_params.simulation_mode = 'MSE';

for i = 1:length(diff_coeff_film_values)
    config.particle_params.diff_coeff_film = diff_coeff_film_values(i);
    result = simulate_once(config, 2000 + i);
    results(i) = result.products_final;

    fprintf('D_film: %d, 产物数: %d\n', ...
        diff_coeff_film_values(i), results(i));
end
```

## ⚙️ 配置说明

### 关键配置参数

#### 模拟参数
```matlab
config.simulation_params.box_size = 500;          % nm
config.simulation_params.total_time = 100;        % s
config.simulation_params.time_step = 0.1;        % s
config.simulation_params.simulation_mode = 'MSE'; % 'MSE'或'bulk'
```

#### 粒子参数
```matlab
config.particle_params.num_enzymes = 400;
config.particle_params.num_substrate = 3000;
config.particle_params.diff_coeff_bulk = 1000;   % $\text{nm}^2/\text{s}$
config.particle_params.diff_coeff_film = 10;     % $\text{nm}^2/\text{s}$
config.particle_params.k_cat_GOx = 100;          % $\text{s}^{-1}$
config.particle_params.k_cat_HRP = 100;          % $\text{s}^{-1}$
```

#### 几何参数
```matlab
config.geometry_params.particle_radius = 20;      % nm
config.geometry_params.film_thickness = 5;        % nm
```

#### 抑制参数
```matlab
config.inhibition_params.R_inhibit = 10;          % nm
config.inhibition_params.n_sat = 5;
config.inhibition_params.I_max = 0.8;             % 0-1
```

#### 批量处理
```matlab
config.batch.batch_count = 30;
config.batch.seed_mode = 'fixed';                  % 'fixed'或'random'
config.batch.fixed_seed = 1234;
config.batch.use_parfor = false;                   % 并行处理
```

### 配置模板

#### 高通量筛选
```matlab
config = default_config();
config.batch.batch_count = 100;
config.ui_controls.visualize_enabled = false;
config.simulation_params.total_time = 0.5;        % 更快的筛选
```

#### 高分辨率分析
```matlab
config = default_config();
config.simulation_params.time_step = 1e-6;        % 更高时间分辨率
config.ui_controls.visualize_enabled = true;
config.ui_controls.save_snapshots = true;
```

## 📊 可视化工具

### 内置可视化工具

#### 1. 产物曲线分析
```matlab
% 绘制产物随时间积累曲线
config = default_config();
config.ui_controls.visualize_enabled = true;
result = simulate_once(config, 1234);

% 访问绘图数据
time_points = result.time_axis;
product_curve = result.product_curve;
reaction_rates_GOx = result.reaction_rates_GOx;
reaction_rates_HRP = result.reaction_rates_HRP;
```

#### 2. 空间事件图
- **目的**: 可视化反应事件的空间分布
- **特性**: 显示反应热点的热图
- **文件**: `modules/viz/plot_event_map.m`

#### 3. 粒子轨迹分析
- **目的**: 追踪单个粒子路径
- **特性**: 具有扩散模式的示踪可视化
- **文件**: `modules/viz/plot_tracers.m`

#### 4. 快照动画生成（新功能 ✨）
- **目的**: 从仿真快照生成 MP4 视频
- **特性**:
  - 零额外仿真成本（<5% 渲染开销）
  - MPEG-4/H.264 编码，默认 10fps，质量 95
  - 1920x1080 高清输出，带时间标签和进度指示
  - 内存高效的逐帧渲染
- **文件**: `modules/viz/animate_snapshots.m`
- **用法**:
  ```matlab
  config = default_config();
  config.ui_controls.visualize_enabled = true;
  config.ui_controls.enable_animation = true;  % 启用动画
  results = simulate_once(config, 12345);
  % 动画自动保存到 out/animation_seed_12345.mp4
  ```
- **注意**: 仅适用于单次运行可视化（不适用于批次运行）

### 自定义可视化示例
```matlab
% 创建自定义分析图
function plot_custom_analysis(results)
    figure('Position', [100, 100, 1200, 800]);

    % 产物产率对比
    subplot(2, 2, 1);
    plot_mse_vs_bulk(results);
    title('MSE与Bulk对比');

    % 反应速率分析
    subplot(2, 2, 2);
    plot_reaction_rates(results);
    title('反应速率分析');

    % 统计分布
    subplot(2, 2, 3);
    histogram(results.products_final);
    title('产物分布');
    xlabel('最终产物数');
    ylabel('频次');

    % 增强因子
    subplot(2, 2, 4);
    plot_enhancement_factor(results);
    title('增强因子分析');
end
```

## 📁 项目结构

```
2D-Enzyme-Cascade-MSE/
├── main_2d_pipeline.m              # 主入口
├── run_simulation.m                # 启动脚本
├── README.md / README.zh-CN.md     # 文档（英/中）
├── LICENSE / CONTRIBUTING.md / AUTHORS.md / BUGFIX_SUMMARY.md
├── docs/                           # 理论与指南
│   ├── 2d_model_theory.en.md       # 英文理论
│   └── 2d_model_theory.md          # 中文理论
├── modules/
│   ├── config/
│   │   ├── default_config.m        # 默认参数（自动 dt、计算后端）
│   │   └── interactive_config.m    # 交互设置（GPU 映射计算后端）
│   ├── sim_core/
│   │   ├── simulate_once.m         # 单次模拟协调器
│   │   ├── init_positions.m        # 初始化
│   │   ├── diffusion_step.m        # 布朗步进
│   │   ├── boundary_reflection.m   # 边界反射
│   │   ├── reaction_step.m         # 反应（连续计时器、邻域后端）
│   │   ├── precompute_inhibition.m # 拥挤抑制
│   │   ├── record_data.m           # 速率/曲线
│   │   └── neighbor_search.m       # pdist2 / rangesearch / GPU
│   ├── batch/
│   │   ├── run_batches.m           # 批次蒙特卡洛
│   │   └── auto_configure_parallel.m # 自动配置 parfor 并行池（自动选择 workers）
│   ├── viz/
│   │   ├── viz_style.m                 # 统一风格（主题自适应）
│   │   ├── plot_product_curve.m        # 产物动力学曲线
│   │   ├── plot_event_map.m            # 反应事件空间分布图
│   │   ├── plot_tracers.m              # 粒子轨迹可视化
│   │   ├── plot_reaction_rate_analysis.m # 反应速率诊断 + 指数拟合
│   │   ├── plot_dual_system_comparison.m # Bulk vs MSE 平均±标准差曲线
│   │   ├── plot_batch_distribution.m   # 箱线图 + 直方图叠加
│   │   └── plot_batch_timeseries_heatmap.m # 批次时序热力图
│   ├── rng/
│   │   └── setup_rng.m                 # CPU/GPU 随机数播种（可复现）
│   ├── seed_utils/
│   │   └── get_batch_seeds.m           # 按策略生成批次种子列表
│   ├── data_import/
│   │   ├── select_runs_interactive.m   # 交互式选择历史运行
│   │   ├── load_seeds_from_file.m      # 从历史文件导入种子
│   │   └── browse_history.m            # 命令行历史浏览器
│   ├── io/
│   │   ├── output_manager.m        # 根级 out/
│   │   ├── write_report_csv.m / save_timeseries.m / save_figures.m
│   │   └── write_metadata.m        # run_metadata.json（含 dt 自适应信息）
│   └── utils/
│       ├── timer_busy_update.m     # 连续计时器
│       ├── auto_adjust_dt.m / config_sanity_checks.m
│       └── getfield_or.m
└── out/                            # 运行时创建（根目录）
```

## 🤝 贡献指南

我们欢迎对本项目的改进贡献！请遵循以下指南：

### 开发工作流程
1. 在GitHub上**Fork该仓库**
2. **创建功能分支**: `git checkout -b feature/amazing-feature`
3. **进行修改**并进行适当的测试
4. **提交更改**: `git commit -m 'Add amazing feature'`
5. **推送到分支**: `git push origin feature/amazing-feature`
6. **提交Pull Request**并提供清晰的描述

### 代码风格指南
- 遵循MATLAB最佳实践和命名约定
- 为复杂算法包含全面的注释
- 确保所有函数都有适当的帮助文档
- 用不同参数组合进行彻底测试

### 报告问题
报告错误或建议功能时，请包含：
- **问题类型**: 错误报告或功能请求
- **MATLAB版本**和操作系统
- **最小复现示例**（针对错误）
- **预期vs实际行为**
- **错误消息**（如果适用）

详细指南请参见[CONTRIBUTING.md](CONTRIBUTING.md)。

## 📄 许可证

本项目采用MIT许可证 - 详见[LICENSE](LICENSE)文件。

### 许可证摘要
- ✅ **商业使用**: 允许
- ✅ **修改**: 允许
- ✅ **分发**: 允许
- ✅ **私人使用**: 允许
- ❌ **商标权**: 不授予商标权

## 👨‍🔬 作者与引用

### 主要作者
- **Rongfeng Zheng** — Sichuan Agricultural University · 设计中心算法、编写 MATLAB 主流程、实现批处理与模块化代码、执行测试
- **Weifeng Chen** — Sichuan Agricultural University · 共同设计算法思路与构建、开展性能与功能验证，执行全面测试
- **Zhaosen Luo** — Sichuan Agricultural University · 执行回归与复现测试、记录问题与验证结果

### 联系方式
- **GitHub Issues**: [在此提交问题](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **邮箱**: 一般咨询请使用GitHub Issues

### 引用格式
如果您在研究中使用此软件，请引用：

```bibtex
@software{enzyme_cascade_2d,
  title={2D酶级联模拟：矿物表面酶局域化研究的MATLAB框架},
  author={Rongfeng Zheng and Weifeng Chen and Zhaosen Luo},
  year={2025},
  publisher={GitHub},
  journal={GitHub仓库},
  howpublished={\\url{https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE}},
  license={MIT}
}
```

### 致谢
- 特别感谢所有贡献者和测试人员的帮助
- 基于已建立的生物物理建模原理构建

---


<div align="center">

**🌟 如果这个项目有助于您的研究，请考虑给它一个star！🌟**

[🔝 返回顶部](#-2d酶级联模拟)


</div>
