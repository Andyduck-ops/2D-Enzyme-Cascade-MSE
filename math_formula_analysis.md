# 数学公式分析报告

## README.md 中发现的数学符号和公式

### 需要修复的数学符号：
1. **τ** (tau) - 出现在 "τ-leaping" 中
2. **Δ** (Delta) - 出现在多个公式中
3. **η** (eta) - 出现在布朗动力学公式中
4. **²** (上标2) - 出现在单位 nm²/s 中
5. **∈** (属于符号) - 出现在 "x ∈ ℝ²" 中
6. **ℝ** (实数集) - 出现在 "x ∈ ℝ²" 中
7. **→** (右箭头) - 出现在反应式中
8. **←** (左箭头) - 出现在赋值表达式中
9. **~** (分布符号) - 出现在 "η ~ N(0, I₂)" 中
10. **×** (乘号) - 出现在公式中

### 需要修复的具体公式：

#### 1. 布朗动力学公式 (行60)
**原始格式**: `Δr = sqrt(2D Δt) η, where η represents Gaussian white noise`
**目标格式**: `$\\Delta r = \\sqrt{2D \\Delta t} \\eta$, where $\\eta$ represents Gaussian white noise`

#### 2. 扩散系数 (行61)
**原始格式**: `D_bulk = 1000 nm²/s for bulk regions and D_film = 10 nm²/s`
**目标格式**: `$D_{\\text{bulk}} = 1000 \\text{ nm}^2/\\text{s}$ for bulk regions and $D_{\\text{film}} = 10 \\text{ nm}^2/\\text{s}$`

#### 3. τ-leaping反应概率 (行66)
**原始格式**: `P = 1 - exp(-k_cat Δt), where k_cat = 100 s⁻¹`
**目标格式**: `$P = 1 - \\exp(-k_{\\text{cat}} \\Delta t)$, where $k_{\\text{cat}} = 100 \\text{ s}^{-1}$`

#### 4. 拥挤抑制公式 (行67)
**原始格式**: `inhibition = I_max × max(0, 1 - n_local/n_sat)`
**目标格式**: `$\\text{inhibition} = I_{\\text{max}} \\times \\max(0, 1 - n_{\\text{local}}/n_{\\text{sat}})$`

#### 5. 位置更新公式 (行117)
**原始格式**: `x ← x + sqrt(2 D(x) Δt) · η, where η ~ N(0, I₂)`
**目标格式**: `$x \\leftarrow x + \\sqrt{2 D(x) \\Delta t} \\cdot \\eta$, where $\\eta \\sim N(0, I_2)$`

#### 6. 反应概率公式 (行131-132)
**原始格式**: 
- `S + GOx → I, P_GOx = 1 - exp(-k_cat,GOx (1 - inhibition_GOx) Δt)`
- `I + HRP → P, P_HRP = 1 - exp(-k_cat,HRP (1 - inhibition_HRP) Δt)`

**目标格式**:
- `S + GOx $\\rightarrow$ I, $P_{\\text{GOx}} = 1 - \\exp(-k_{\\text{cat,GOx}} (1 - \\text{inhibition}_{\\text{GOx}}) \\Delta t)$`
- `I + HRP $\\rightarrow$ P, $P_{\\text{HRP}} = 1 - \\exp(-k_{\\text{cat,HRP}} (1 - \\text{inhibition}_{\\text{HRP}}) \\Delta t)$`

#### 7. 抑制公式 (行136)
**原始格式**: `inhibition = I_max × max(0, 1 - n_local / n_sat)`
**目标格式**: `$\\text{inhibition} = I_{\\text{max}} \\times \\max(0, 1 - n_{\\text{local}} / n_{\\text{sat}})$`

#### 8. 统计公式 (行305-306)
**原始格式**: 
- `ci_lower = mean_products - 1.96 * std_products / sqrt(length(batch_results.products_final));`
- `ci_upper = mean_products + 1.96 * std_products / sqrt(length(batch_results.products_final));`

**目标格式**: 
- `ci_lower = mean_products - 1.96 * std_products / $\\sqrt{\\text{length}(\\text{batch\\_results.products\\_final})}$;`
- `ci_upper = mean_products + 1.96 * std_products / $\\sqrt{\\text{length}(\\text{batch\\_results.products\\_final})}$;`

### 总结
README.md 中共发现 8 个主要公式需要转换为 LaTeX 格式，涉及 10 种不同的数学符号。
## README
.zh-CN.md 中发现的数学符号和公式

### 需要修复的数学符号：
1. **τ** (tau) - 出现在 "τ-跳跃" 中
2. **Δ** (Delta) - 出现在多个公式中
3. **η** (eta) - 出现在布朗动力学公式中
4. **²** (上标2) - 出现在单位 nm²/s 中
5. **∈** (属于符号) - 出现在 "x ∈ ℝ²" 中
6. **ℝ** (实数集) - 出现在 "x ∈ ℝ²" 中
7. **→** (右箭头) - 出现在反应式和流程图中
8. **←** (左箭头) - 出现在流程描述中
9. **~** (分布符号) - 出现在 "η ~ N(0, I₂)" 中
10. **×** (乘号) - 出现在公式中
11. **⁻¹** (上标-1) - 出现在单位 s⁻¹ 中

### 需要修复的具体公式：

#### 1. 扩散系数 (行52)
**原始格式**: `D_film = 10 与 D_bulk = 1000 nm²/s`
**目标格式**: `$D_{\\text{film}} = 10$ 与 $D_{\\text{bulk}} = 1000 \\text{ nm}^2/\\text{s}$`

#### 2. 布朗步进公式 (行91)
**原始格式**: `x_{t+Δt} = x_t + sqrt(2 D(x_t) Δt) · η，其中 η ~ N(0, I₂)`
**目标格式**: `$x_{t+\\Delta t} = x_t + \\sqrt{2 D(x_t) \\Delta t} \\cdot \\eta$，其中 $\\eta \\sim N(0, I_2)$`

#### 3. 反应通道公式 (行107, 109)
**原始格式**: 
- `S + GOx → I，反应概率：P_GOx = 1 - exp(-k_cat,GOx (1 - inhibition_GOx) Δt)`
- `I + HRP → P，反应概率：P_HRP = 1 - exp(-k_cat,HRP (1 - inhibition_HRP) Δt)`

**目标格式**:
- `S + GOx $\\rightarrow$ I，反应概率：$P_{\\text{GOx}} = 1 - \\exp(-k_{\\text{cat,GOx}} (1 - \\text{inhibition}_{\\text{GOx}}) \\Delta t)$`
- `I + HRP $\\rightarrow$ P，反应概率：$P_{\\text{HRP}} = 1 - \\exp(-k_{\\text{cat,HRP}} (1 - \\text{inhibition}_{\\text{HRP}}) \\Delta t)$`

#### 4. 拥挤抑制公式 (行113)
**原始格式**: `inhibition = I_max × max(0, 1 - n_local/n_sat)`
**目标格式**: `$\\text{inhibition} = I_{\\text{max}} \\times \\max(0, 1 - n_{\\text{local}}/n_{\\text{sat}})$`

#### 5. 流程箭头 (行120-121, 131-132)
**原始格式**: 
- `反应计数 → 反应速率曲线`
- `产物曲线 P(t) ← HRP 速率积分`
- `扩散 → 边界反射 →（可选）轨迹更新`
- `GOx/HRP 反应 → 记录`

**目标格式**:
- `反应计数 $\\rightarrow$ 反应速率曲线`
- `产物曲线 $P(t) \\leftarrow$ HRP 速率积分`
- `扩散 $\\rightarrow$ 边界反射 $\\rightarrow$（可选）轨迹更新`
- `GOx/HRP 反应 $\\rightarrow$ 记录`

#### 6. 统计公式 (行286-287)
**原始格式**: 
- `ci_lower = mean_products - 1.96 * std_products / sqrt(length(batch_results.products_final));`
- `ci_upper = mean_products + 1.96 * std_products / sqrt(length(batch_results.products_final));`

**目标格式**: 
- `ci_lower = mean_products - 1.96 * std_products / $\\sqrt{\\text{length}(\\text{batch\\_results.products\\_final})}$;`
- `ci_upper = mean_products + 1.96 * std_products / $\\sqrt{\\text{length}(\\text{batch\\_results.products\\_final})}$;`

#### 7. 配置参数 (行328-329, 331-332)
**原始格式**: 
- `config.particle_params.diff_coeff_bulk = 1000;   % nm²/s`
- `config.particle_params.diff_coeff_film = 10;     % nm²/s`
- `config.particle_params.k_cat_GOx = 100;          % s⁻¹`
- `config.particle_params.k_cat_HRP = 100;          % s⁻¹`

**目标格式**: 
- `config.particle_params.diff_coeff_bulk = 1000;   % $\\text{nm}^2/\\text{s}$`
- `config.particle_params.diff_coeff_film = 10;     % $\\text{nm}^2/\\text{s}$`
- `config.particle_params.k_cat_GOx = 100;          % $\\text{s}^{-1}$`
- `config.particle_params.k_cat_HRP = 100;          % $\\text{s}^{-1}$`

### 总结
README.zh-CN.md 中共发现 7 个主要公式组需要转换为 LaTeX 格式，涉及 11 种不同的数学符号。## d
ocs/2d_model_theory.en.md 中发现的数学符号和公式

### 需要修复的数学符号：
1. **∂** (偏导数符号) - 出现在偏微分方程中
2. **∇** (梯度算子) - 出现在拉普拉斯算子中
3. **²** (上标2) - 出现在拉普拉斯算子和单位中
4. **Δ** (Delta) - 出现在多个公式中
5. **η** (eta) - 出现在布朗动力学公式中
6. **∈** (属于符号) - 出现在集合表示中
7. **→** (右箭头) - 出现在反应式中
8. **~** (分布符号) - 出现在概率分布中
9. **≈** (约等于) - 出现在近似公式中
10. **×** (乘号) - 出现在公式中
11. **μ** (mu) - 出现在统计公式中
12. **σ** (sigma) - 出现在统计公式中
13. **τ** (tau) - 出现在τ-leaping中

### 需要修复的具体公式：

#### 1. 扩散系数 (行34)
**原始格式**: `D_bulk = 1000 nm²/s, D_film = 10 nm²/s`
**目标格式**: `$D_{\\text{bulk}} = 1000 \\text{ nm}^2/\\text{s}$, $D_{\\text{film}} = 10 \\text{ nm}^2/\\text{s}$`

#### 2. 反应-扩散方程组 (行48-50)
**原始格式**: 
```
- ∂[S]/∂t = D ∇²[S] - k_GOx [S][GOx]
- ∂[I]/∂t = D ∇²[I] + k_GOx [S][GOx] - k_HRP [I][HRP]
- ∂[P]/∂t = D ∇²[P] + k_HRP [I][HRP]
```

**目标格式**: 
```
$$
\\begin{align}
\\frac{\\partial [S]}{\\partial t} &= D \\nabla^2 [S] - k_{\\text{GOx}} [S][\\text{GOx}] \\\\
\\frac{\\partial [I]}{\\partial t} &= D \\nabla^2 [I] + k_{\\text{GOx}} [S][\\text{GOx}] - k_{\\text{HRP}} [I][\\text{HRP}] \\\\
\\frac{\\partial [P]}{\\partial t} &= D \\nabla^2 [P] + k_{\\text{HRP}} [I][\\text{HRP}]
\\end{align}
$$
```

#### 3. 拉普拉斯算子 (行54)
**原始格式**: `∇² = ∂²/∂x² + ∂²/∂y²`
**目标格式**: `$\\nabla^2 = \\frac{\\partial^2}{\\partial x^2} + \\frac{\\partial^2}{\\partial y^2}$`

#### 4. 集合表示 (行55)
**原始格式**: `r ∈ [r_p, r_p + f_t]`
**目标格式**: `$r \\in [r_p, r_p + f_t]$`

#### 5. 布朗步进公式 (行68)
**原始格式**: `Δr = sqrt(2 D Δt) · η, where η ~ N(0, I₂)`
**目标格式**: `$\\Delta r = \\sqrt{2 D \\Delta t} \\cdot \\eta$, where $\\eta \\sim N(0, I_2)$`

#### 6. 反应概率公式 (行84)
**原始格式**: `p = 1 - exp(-k_eff · Δt), where k_eff = k_cat (1 - inhibition)`
**目标格式**: `$p = 1 - \\exp(-k_{\\text{eff}} \\cdot \\Delta t)$, where $k_{\\text{eff}} = k_{\\text{cat}} (1 - \\text{inhibition})$`

#### 7. 反应事件 (行86)
**原始格式**: `Sample u ~ U(0,1); if u < p, then a reaction event occurs (S→I or I→P)`
**目标格式**: `Sample $u \\sim U(0,1)$; if $u < p$, then a reaction event occurs (S$\\rightarrow$I or I$\\rightarrow$P)`

#### 8. 拥挤抑制公式 (行96)
**原始格式**: `inhibition = I_max × max(0, 1 - n_local/n_sat)`
**目标格式**: `$\\text{inhibition} = I_{\\text{max}} \\times \\max(0, 1 - n_{\\text{local}}/n_{\\text{sat}})$`

#### 9. 速率公式 (行102-103)
**原始格式**: 
- `r_GOx(t) = n_GOx,step / Δt`
- `P(t) ≈ Σ r_HRP(t) · Δt`

**目标格式**: 
- `$r_{\\text{GOx}}(t) = n_{\\text{GOx,step}} / \\Delta t$`
- `$P(t) \\approx \\sum r_{\\text{HRP}}(t) \\cdot \\Delta t$`

#### 10. 蒙特卡洛统计公式 (行115)
**原始格式**: `μ̂ = (1/M) Σ_{m=1}^{M} P_m`
**目标格式**: `$\\hat{\\mu} = \\frac{1}{M} \\sum_{m=1}^{M} P_m$`

### 总结
docs/2d_model_theory.en.md 中共发现 10 个主要公式组需要转换为 LaTeX 格式，涉及 13 种不同的数学符号。这个文档包含最复杂的数学公式，特别是偏微分方程组。#
# docs/2d_model_theory.md 中发现的数学符号和公式

### 需要修复的数学符号：
1. **∂** (偏导数符号) - 出现在偏微分方程中
2. **∇** (梯度算子) - 出现在拉普拉斯算子中
3. **²** (上标2) - 出现在拉普拉斯算子和单位中
4. **Δ** (Delta) - 出现在多个公式中
5. **η** (eta) - 出现在布朗动力学公式中
6. **∈** (属于符号) - 出现在集合表示中
7. **→** (右箭头) - 出现在反应式中
8. **~** (分布符号) - 出现在概率分布中
9. **≈** (约等于) - 出现在近似公式中
10. **×** (乘号) - 出现在公式中
11. **μ** (mu) - 出现在统计公式中
12. **σ** (sigma) - 出现在统计公式中
13. **τ** (tau) - 出现在τ-leaping中

### 需要修复的具体公式：

#### 1. 扩散系数 (行35)
**原始格式**: `D_bulk = 1000 nm²/s，D_film = 10 nm²/s`
**目标格式**: `$D_{\\text{bulk}} = 1000 \\text{ nm}^2/\\text{s}$，$D_{\\text{film}} = 10 \\text{ nm}^2/\\text{s}$`

#### 2. 反应-扩散方程组 (行49-51)
**原始格式**: 
```
- ∂[S]/∂t = D ∇²[S] - k_GOx [S][GOx]
- ∂[I]/∂t = D ∇²[I] + k_GOx [S][GOx] - k_HRP [I][HRP]
- ∂[P]/∂t = D ∇²[P] + k_HRP [I][HRP]
```

**目标格式**: 
```
$$
\\begin{align}
\\frac{\\partial [S]}{\\partial t} &= D \\nabla^2 [S] - k_{\\text{GOx}} [S][\\text{GOx}] \\\\
\\frac{\\partial [I]}{\\partial t} &= D \\nabla^2 [I] + k_{\\text{GOx}} [S][\\text{GOx}] - k_{\\text{HRP}} [I][\\text{HRP}] \\\\
\\frac{\\partial [P]}{\\partial t} &= D \\nabla^2 [P] + k_{\\text{HRP}} [I][\\text{HRP}]
\\end{align}
$$
```

#### 3. 拉普拉斯算子 (行55)
**原始格式**: `∇² = ∂²/∂x² + ∂²/∂y²`
**目标格式**: `$\\nabla^2 = \\frac{\\partial^2}{\\partial x^2} + \\frac{\\partial^2}{\\partial y^2}$`

#### 4. 集合表示 (行56)
**原始格式**: `r ∈ [r_p, r_p + f_t]`
**目标格式**: `$r \\in [r_p, r_p + f_t]$`

#### 5. 布朗步进公式 (行69)
**原始格式**: `Δr = sqrt(2 D Δt) · η，其中 η ~ N(0, I₂)`
**目标格式**: `$\\Delta r = \\sqrt{2 D \\Delta t} \\cdot \\eta$，其中 $\\eta \\sim N(0, I_2)$`

#### 6. 反应概率公式 (行85)
**原始格式**: `p = 1 - exp(-k_eff · Δt)，其中 k_eff = k_cat · (1 - inhibition)`
**目标格式**: `$p = 1 - \\exp(-k_{\\text{eff}} \\cdot \\Delta t)$，其中 $k_{\\text{eff}} = k_{\\text{cat}} \\cdot (1 - \\text{inhibition})$`

#### 7. 反应事件 (行87)
**原始格式**: `采样 u ~ U(0,1)，若 u < p，则发生反应事件（S→I 或 I→P）`
**目标格式**: `采样 $u \\sim U(0,1)$，若 $u < p$，则发生反应事件（S$\\rightarrow$I 或 I$\\rightarrow$P）`

#### 8. 拥挤抑制公式 (行95)
**原始格式**: `inhibition = I_max × max(0, 1 - n_local / n_sat)`
**目标格式**: `$\\text{inhibition} = I_{\\text{max}} \\times \\max(0, 1 - n_{\\text{local}} / n_{\\text{sat}})$`

#### 9. 速率公式 (行102-103, 106)
**原始格式**: 
- `r_GOx(t) = n_GOx,step / Δt`
- `r_HRP(t) = n_HRP,step / Δt`
- `P(t) ≈ Σ r_HRP(t) · Δt`

**目标格式**: 
- `$r_{\\text{GOx}}(t) = n_{\\text{GOx,step}} / \\Delta t$`
- `$r_{\\text{HRP}}(t) = n_{\\text{HRP,step}} / \\Delta t$`
- `$P(t) \\approx \\sum r_{\\text{HRP}}(t) \\cdot \\Delta t$`

#### 10. 蒙特卡洛统计公式 (行120-121)
**原始格式**: 
- `μ̂ = (1/M) Σ_{m=1}^{M} P_m`
- `Var(μ̂) = σ² / M`

**目标格式**: 
- `$\\hat{\\mu} = \\frac{1}{M} \\sum_{m=1}^{M} P_m$`
- `$\\text{Var}(\\hat{\\mu}) = \\sigma^2 / M$`

### 总结
docs/2d_model_theory.md 中共发现 10 个主要公式组需要转换为 LaTeX 格式，涉及 13 种不同的数学符号。与英文版类似，包含复杂的偏微分方程组。

## 整体分析总结

### 所有文档统计：
- **README.md**: 8个公式组，10种符号
- **README.zh-CN.md**: 7个公式组，11种符号  
- **docs/2d_model_theory.en.md**: 10个公式组，13种符号
- **docs/2d_model_theory.md**: 10个公式组，13种符号

### 最常见的需要转换的符号：
1. **Δ** (Delta) - 出现频率最高
2. **→** (右箭头) - 反应式中常用
3. **²** (上标2) - 单位和算子中
4. **η** (eta) - 布朗动力学
5. **∂** (偏导数) - 理论文档中
6. **∇** (梯度) - 理论文档中
7. **~** (分布符号) - 概率表示
8. **×** (乘号) - 数学运算
9. **≈** (约等于) - 近似公式
10. **∈** (属于) - 集合表示

### 转换优先级：
1. **高优先级**: 核心数学公式（微分方程、概率公式）
2. **中优先级**: 常用符号和函数
3. **低优先级**: 单位和装饰性符号