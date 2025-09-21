# 2D 酶级联模拟


<!-- 语言切换 -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)


<!-- 项目徽章 -->
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](#)
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-purple.svg)](docs/)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)


<!-- 核心链接 -->
- 📖 **文档资料**: [2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)
- 🎯 **快速入门**: [安装指南](#-安装指南) | [使用方法](#-快速入门) | [示例代码](#-示例代码)
- ⚡ **功能特性**: [核心功能](#-核心功能) | [算法原理](#-算法说明) | [可视化](#-visualization)

## 🎯 项目概览

一个全面、模块化的MATLAB框架，用于在二维空间中模拟矿物表面局域化酶的两步级联反应。该框架实现了先进的随机模拟，包括异质扩散、τ-跳跃反应、拥挤抑制、批量蒙特卡洛分析和完全可复现的科学计算。

### 核心科学背景

本研究专注于**矿物表面酶（MSE）局域化效应**——一个关键现象，即酶在矿物表面附近的限制通过空间组织和局域化高浓度环境显著提高反应效率。该计算框架实现了两步酶级联反应系统的随机布朗动力学模拟，能够定量评估矿物表面介导富集的动力学优势。

### 研究影响
- **主要目标**: 通过系统计算研究，量化MSE局域化与体相分散在反应效率方面的差异
- **核心洞察**: 在空间受限环境中，局域化酶系统可以通过增加相遇概率实现显著更高的产物产率
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

- 科学动机：矿物表面酶（MSE）局域化使底物/中间体在颗粒附近富集，相遇概率显著高于体相（bulk）分散体系，从而提升级联效率。
- 2D 抽象：用环区 [r_p, r_p + f_t] 近似中心颗粒周围的表面薄膜，酶在 MSE 模式固定于环区，bulk 模式则在盒域均匀分布。默认参数体现强扩散对比（如 D_film = 10 与 D_bulk = 1000 nm²/s）与适中的膜厚（f_t = 5 nm），见 [modules/config/default_config.m](modules/config/default_config.m)。
- 反应语境：两步级联 S -(GOx)-> I -(HRP)-> P；酶数量按比例 `gox_hrp_split`（默认 50/50）划分 GOx 与 HRP。
- 模型假设（范围）：酶不移动；S/I/P 扩散；盒域与颗粒边界为镜面反射；固定步长 τ‑跳跃；无吸附/解吸；MSE 下仅接受薄膜环区内的反应事件。
- 面向论文的输出：MSE vs bulk 的产物优势、反应速率曲线、空间事件图、示踪轨迹；批量 CSV 用于均值/方差等统计汇总。可视化入口： [modules/viz/plot_event_map.m](modules/viz/plot_event_map.m)、[modules/viz/plot_tracers.m](modules/viz/plot_tracers.m)、[modules/viz/plot_product_curve.m](modules/viz/plot_product_curve.m)。

## ⚡ 核心功能

### 🧬 高级模拟能力
- **两步酶级联**: S -(GOx)-> I -(HRP)-> P
- **双重模拟模式**:
  - **MSE模式**: 酶局域于中心颗粒周围的薄膜环区
  - **Bulk模式**: 酶在模拟盒中均匀分布
- **异质扩散**: 薄膜与体相区域的不同扩散系数
- **随机反应**: 基于概率的τ-跳跃反应事件
- **拥挤抑制**: 局部密度对催化效率的影响

### 🔬 科学严谨性
- **可复现结果**: 使用固定随机种子的确定性模拟
- **批量蒙特卡洛**: 多个独立运行的统计分析
- **边界条件**: 盒壁和颗粒表面的反射边界
- **物理验证**: 基于已建立生物物理原理的模型

### 📊 全面分析
- **实时可视化**: 产物曲线、事件图和示踪轨迹
- **统计报告**: 包含均值、方差和置信区间的CSV输出
- **空间分析**: 反应事件和粒子分布的热图
- **性能指标**: 反应速率、产率和效率因子

## 算法说明

### 几何与状态
- 域：L × L 的二维正方形
- 中心颗粒：半径 r_p
- 薄膜环区：MSE 模式下的 [r_p, r_p + f_t]
- 物种：S、I、P 为可扩散粒子；酶固定在其位置（MSE 模式局域在环区，bulk 模式均匀分布）

### 扩散（布朗步进）
对每个粒子位置 x ∈ ℝ²：

**布朗步进公式**：x_{t+Δt} = x_t + sqrt(2 D(x_t) Δt) · η，其中 η ~ N(0, I₂)。

- MSE：环区内 D = D_film，环区外 D = D_bulk
- Bulk：全域 D = D_bulk
实现：[diffusion_step()](modules/sim_core/diffusion_step.m)


### 边界
- 盒域边界：镜面反射，见 [boundary_reflection()](modules/sim_core/boundary_reflection.m)


### 反应（每步 τ-跳跃）
每步存在两条独立通道：

**反应通道**：

1. S + GOx → I，反应概率：P_GOx = 1 - exp(-k_cat,GOx (1 - inhibition_GOx) Δt)

2. I + HRP → P，反应概率：P_HRP = 1 - exp(-k_cat,HRP (1 - inhibition_HRP) Δt)

拥挤抑制（按酶局部密度）：

**拥挤抑制公式**：inhibition = I_max × max(0, 1 - n_local/n_sat)

MSE 模式同时要求反应位置在薄膜环区内。
实现：[reaction_step()](modules/sim_core/reaction_step.m)


### 记录与汇总
- 反应计数 → 反应速率曲线
- 产物曲线 P(t) ← HRP 速率积分
- 可选：快照、示踪轨迹、事件空间坐标
实现：[record_data()](modules/sim_core/record_data.m)


### 调度与时序

时间循环：
```
for step = 1..N
  扩散 → 边界反射 →（可选）轨迹更新
  GOx/HRP 反应 → 记录
end
```
实现：[simulate_once()](modules/sim_core/simulate_once.m)


### 批处理与可复现
- 每批设置 RNG 种子，独立运行
- 聚合到表格并写出 CSV
批处理：[run_batches()](modules/batch/run_batches.m)
RNG 设置：[setup_rng()](modules/rng/setup_rng.m)
批次种子：[get_batch_seeds()](modules/seed_utils/get_batch_seeds.m)

## 📋 目录

- [项目概览](#-项目概览)
- [核心功能](#-核心功能)
- [安装指南](#-安装指南)
- [快速入门](#-快速入门)
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
- **MATLAB版本**: R2019b或更高版本
- **必需工具箱**:
  - Statistics and Machine Learning Toolbox（用于`pdist2`）
  - Parallel Computing Toolbox（可选，用于批量处理加速）
- **操作系统**: Windows、macOS或Linux
- **内存**: 最小4GB RAM，大型模拟推荐8GB+

### 快速安装
```bash
# 克隆仓库
git clone https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE.git
cd 2D-Enzyme-Cascade-Simulation

# 可选：创建输出目录
mkdir -p out
```

### MATLAB设置
1. 打开MATLAB并导航到项目根目录
2. 主流程会自动将`modules/`添加到MATLAB路径
3. 通过运行以下命令验证安装：
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
config.simulation_params.total_time = 1.0;        % s
config.simulation_params.time_step = 1e-5;       % s
config.simulation_params.simulation_mode = 'MSE'; % 'MSE'或'bulk'
```

#### 粒子参数
```matlab
config.particle_params.num_enzymes = 200;
config.particle_params.num_substrate = 1000;
config.particle_params.diff_coeff_bulk = 1000;   % nm²/s
config.particle_params.diff_coeff_film = 10;     % nm²/s
config.particle_params.k_cat_GOx = 100;          % s⁻¹
config.particle_params.k_cat_HRP = 100;          % s⁻¹
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
2D-Enzyme-Cascade-Simulation/
├── 📄 main_2d_pipeline.m              # 主入口点
├── 📄 README.md                       # 英文文档
├── 📄 README.zh-CN.md                 # 中文文档
├── 📄 LICENSE                         # MIT许可证
├── 📄 CONTRIBUTING.md                 # 贡献指南
├── 📁 modules/                        # 核心模拟模块
│   ├── 📁 config/                     # 配置管理
│   │   ├── 📄 default_config.m       # 默认参数
│   │   └── 📄 interactive_config.m   # 交互式设置
│   ├── 📁 sim_core/                  # 核心模拟算法
│   │   ├── 📄 simulate_once.m        # 单次模拟协调器
│   │   ├── 📄 init_positions.m       # 初始状态设置
│   │   ├── 📄 diffusion_step.m       # 布朗动力学
│   │   ├── 📄 boundary_reflection.m  # 边界条件
│   │   ├── 📄 reaction_step.m        # 反应处理
│   │   ├── 📄 precompute_inhibition.m # 拥挤效应
│   │   └── 📄 record_data.m          # 数据记录
│   ├── 📁 batch/                     # 批量处理
│   │   └── 📄 run_batches.m          # 蒙特卡洛批次
│   ├── 📁 viz/                       # 可视化工具
│   │   ├── 📄 plot_product_curve.m   # 产物动力学
│   │   ├── 📄 plot_event_map.m       # 空间事件
│   │   └── 📄 plot_tracers.m         # 粒子追踪
│   ├── 📁 io/                        # 输入输出工具
│   │   └── 📄 write_report_csv.m     # 数据导出
│   └── 📁 rng/                       # 随机数管理
│       └── 📄 setup_rng.m            # RNG设置
├── 📁 docs/                          # 文档
│   ├── 📄 2d_model_theory.md         # 英文理论
│   └── 📄 2d_model_theory.en.md      # 中文理论
├── 📁 out/                           # 输出目录
│   ├── 📄 batch_results.csv          # 批量结果
│   ├── 📄 mc_summary.csv            # 统计摘要
│   └── 📁 figures/                   # 生成的图
└── 📁 tests/                         # 测试套件
    ├── 📄 test_basic_simulation.m   # 基本功能测试
    ├── 📄 test_batch_processing.m   # 批量处理测试
    └── 📄 test_reproducibility.m    # 可复现性测试
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
- ❌ **责任**: 不提供保证
- ❌ **商标权**: 不授予商标权

## 👨‍🔬 作者与引用

### 主要作者
- **郑蓉锋** (Rongfeng Zheng) — 四川农业大学 · 设计中心算法、编写 MATLAB 主流程、执行全面测试
- **陈为锋** (Weifeng Chen) — 四川农业大学 · 共同设计算法、实现批处理与模块化代码、开展性能与功能验证
- **罗照森** (Zhaosen Luo) — 四川农业大学 · 执行回归与复现测试、记录问题与验证结果

### 联系方式
- **GitHub Issues**: [在此提交问题](https://github.com/Andyduck-ops/2D-Enzyme-Cascade-MSE/issues)
- **邮箱**: 一般咨询请使用GitHub Issues

### 引用格式
如果您在研究中使用此软件，请引用：

```bibtex
@software{enzyme_cascade_2d,
  title={2D酶级联模拟：矿物表面酶局域化研究的MATLAB框架},
  author={郑蓉锋 and 陈为锋 and 罗照森},
  year={2024},
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
