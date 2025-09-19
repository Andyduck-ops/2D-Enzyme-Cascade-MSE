# 2D 酶级联模拟

<!-- 语言切换 -->
**🌍 Language / 语言**
[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![中文](https://img.shields.io/badge/Lang-中文-red.svg)](README.zh-CN.md)


[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange.svg)](https://www.mathworks.com/products/matlab.html)

- 理论说明：[2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)


一个模块化的 MATLAB 框架，用于在二维空间中模拟两步酶级联反应（S —(GOx)→ I —(HRP)→ P）。框架支持两种场景（MSE vs bulk）、异质扩散、τ-跳跃反应、拥挤抑制、批量蒙特卡洛与可复现输出。

## 概览

- 两步级联：S —(GOx)→ I —(HRP)→ P
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
- 2D 抽象：用环区 $[r_p, r_p+f_t]$ 近似中心颗粒周围的表面薄膜，酶在 MSE 模式固定于环区，bulk 模式则在盒域均匀分布。默认参数体现强扩散对比（如 $D_{\text{film}}=10$ vs $D_{\text{bulk}}=1000$ nm$^2$/s）与适中的膜厚（$f_t=5$ nm），见 [modules/config/default_config.m](modules/config/default_config.m)。
- 反应语境：两步级联 S —(GOx)→ I —(HRP)→ P；酶数量按比例 `gox_hrp_split`（默认 50/50）划分 GOx 与 HRP。
- 模型假设（范围）：酶不移动；S/I/P 扩散；盒域与颗粒边界为镜面反射；固定步长 τ‑跳跃；无吸附/解吸；MSE 下仅接受薄膜环区内的反应事件。
- 面向论文的输出：MSE vs bulk 的产物优势、反应速率曲线、空间事件图、示踪轨迹；批量 CSV 用于均值/方差等统计汇总。可视化入口： [modules/viz/plot_event_map.m](modules/viz/plot_event_map.m)、[modules/viz/plot_tracers.m](modules/viz/plot_tracers.m)、[modules/viz/plot_product_curve.m](modules/viz/plot_product_curve.m)。

## 算法说明

### 几何与状态
- 域：$L \times L$ 的二维正方形
- 中心颗粒：半径 $r_p$
- 薄膜环区：MSE 模式下的 $[r_p, r_p + f_t]$ 
- 物种：S、I、P 为可扩散粒子；酶固定在其位置（MSE 模式局域在环区，bulk 模式均匀分布）

### 扩散（布朗步进）
对每个粒子位置 $x \in \mathbb{R}^2$：

$$
\mathbf{x} \leftarrow \mathbf{x} + \sqrt{2\,D(\mathbf{x})\,\Delta t}\,\boldsymbol{\eta},\quad \boldsymbol{\eta}\sim \mathcal{N}(\mathbf{0}, \mathbf{I}_2)
$$

- MSE：环区内 $D = D_{\text{film}}$，环区外 $D = D_{\text{bulk}}$
- Bulk：全域 $D = D_{\text{bulk}}$
实现：[diffusion_step()](modules/sim_core/diffusion_step.m)  


### 边界
- 盒域边界：镜面反射，见 [boundary_reflection()](modules/sim_core/boundary_reflection.m)


### 反应（每步 τ-跳跃）
每步存在两条独立通道：

$$
\mathrm{S} + \mathrm{GOx} \rightarrow \mathrm{I},\quad P_{\mathrm{GOx}} = 1 - e^{-k_{\mathrm{cat,GOx}}\,\Delta t}\,\bigl(1 - \mathrm{inhibition}_{\mathrm{ERP}}\bigr)
$$

$$
\mathrm{I} + \mathrm{HRP} \rightarrow \mathrm{P},\quad P_{\mathrm{HRP}} = 1 - e^{-k_{\mathrm{cat,HRP}}\,\Delta t}\,\bigl(1 - \mathrm{inhibition}_{\mathrm{HRP}}\bigr)
$$

拥挤抑制（按酶局部密度）：

$$
\mathrm{inhibition} = I_{\max}\,\max\!\left(0,\, 1 - \frac{n_{\text{local}}}{n_{\text{sat}}}\right)
$$

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

## 工程结构

```
2D/
├─ main_2d_pipeline.m                  # 顶层主流程
├─ modules/
│  ├─ config/
│  │  ├─ default_config.m              # 默认参数
│  │  └─ interactive_config.m          # 交互式覆盖
│  ├─ sim_core/
│  │  ├─ simulate_once.m               # 单次模拟调度
│  │  ├─ init_positions.m              # 初始状态
│  │  ├─ diffusion_step.m              # 布朗扩散
│  │  ├─ boundary_reflection.m         # 反射边界
│  │  ├─ reaction_step.m               # τ-跳跃反应
│  │  └─ record_data.m                 # 数据累计
│  ├─ batch/
│  │  └─ run_batches.m                 # 批处理
│  ├─ viz/
│  │  ├─ plot_product_curve.m
│  │  ├─ plot_event_map.m
│  │  └─ plot_tracers.m
│  └─ io/
│     └─ write_report_csv.m
└─ docs/
   └─ 2d_model_theory.md               # 扩展理论说明
```

直达链接：  
- 主流程：[main_2d_pipeline.m](main_2d_pipeline.m)  
- 理论说明：[2D Theory (English)](docs/2d_model_theory.en.md) | [理论（中文）](docs/2d_model_theory.md)

## 安装

依赖：  
- MATLAB R2019b+  
- Statistics and Machine Learning Toolbox（用于 `pdist2`）  
- Parallel Computing Toolbox（可选，用于批处理）

获取并在 MATLAB 打开：
```bash
git clone https://github.com/your-org/2D-Enzyme-Cascade-Simulation.git
cd 2D-Enzyme-Cascade-Simulation
```

在 [main_2d_pipeline.m](main_2d_pipeline.m) 中会自动将 `modules/` 加入路径。


## 快速开始

交互运行：  
```matlab
% MATLAB 工作目录置于工程根
main_2d_pipeline
```

非交互示例：  
```matlab
config = default_config();                        % default_config()  
config.simulation_params.simulation_mode = 'MSE';
config.batch.batch_count = 5;
config.ui_controls.visualize_enabled = true;
T = run_batches(config, (1001:1005)');            % run_batches()       
```

输出：  
- `out/batch_results.csv` ← [write_report_csv()](modules/io/write_report_csv.m)
- 若启用可视化：产物曲线、事件图、轨迹图等



## 示例

MSE vs Bulk 对比：  
```matlab
config = default_config();
config.batch.batch_count = 1;

config.simulation_params.simulation_mode = 'MSE';
r1 = simulate_once(config, 1234);                 % simulate_once()

config.simulation_params.simulation_mode = 'bulk';
r2 = simulate_once(config, 1234);

fprintf('Final products | MSE=%d, bulk=%d, factor=%.2fx\n', ...
  r1.products_final, r2.products_final, r1.products_final / max(r2.products_final,1));
```

高/低酶数量：  
```matlab
config = default_config();
for ne = [100, 400]
  config.particle_params.num_enzymes = ne;
  rr = simulate_once(config, 1000 + ne);
  fprintf('num_enzymes=%d  products_final=%d\n', ne, rr.products_final);
end
```

## 可视化说明

- 开关：`config.ui_controls.visualize_enabled = true;`
- 图表：
  - 产物曲线：[modules/viz/plot_product_curve.m](modules/viz/plot_product_curve.m)
  - 空间事件图：[modules/viz/plot_event_map.m](modules/viz/plot_event_map.m)
  - 示踪轨迹：[modules/viz/plot_tracers.m](modules/viz/plot_tracers.m)
- 最小示例：
```matlab
config = default_config();
config.ui_controls.visualize_enabled = true;
res = simulate_once(config, 2025);
```


## 关键配置项（节选）

来源：[default_config()](modules/config/default_config.m:1)  
- `simulation_params.box_size` (nm), `total_time` (s), `time_step` (s), `simulation_mode` ('MSE'|'bulk')
- `particle_params.num_enzymes`, `num_substrate`, `diff_coeff_bulk` (nm²/s), `diff_coeff_film` (nm²/s), `k_cat_GOx`, `k_cat_HRP`
- `geometry_params.particle_radius` (nm), `film_thickness` (nm)
- `inhibition_params.R_inhibit` (nm), `n_sat`, `I_max` (0..1)
- `batch.batch_count`, `seed_mode`, `fixed_seed`, `use_gpu`, `use_parfor`
- `io.outdir` 

## 可复现性

- 通过 `batch.seed_mode` 与 `batch.fixed_seed` 控制 RNG
- 批处理结果聚合到 CSV；[main_2d_pipeline.m](main_2d_pipeline.m) 末尾含 MC 摘要写出逻辑
- τ-跳跃基于固定步长 $\Delta t$，在给定种子与配置下结果可完全复现

## 许可与致谢

- 许可：MIT（见 [LICENSE](LICENSE)）
- 作者：Rongfeng Zheng，Weifeng Chen —— 四川农业大学
- 联系方式：通过 GitHub Issues 提问或在此处添加邮箱约定
