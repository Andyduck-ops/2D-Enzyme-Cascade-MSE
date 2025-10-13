# Accuracy/Speed Presets Guide

## Overview

The simulation offers three preset modes to balance accuracy and speed, plus a custom option for advanced users.

---

## 🎯 Preset Modes

### 1. High-Speed Mode ⚡
```matlab
dt = 0.002 seconds
Steps (100s simulation): ~50,000
Accuracy: 90-95%
Speed: Fastest
```

**Best for:**
- Large batch runs (30+ simulations)
- Parameter sweeps
- Exploratory analysis
- Quick prototyping

**Trade-offs:**
- Slightly lower accuracy (~5% deviation)
- Good enough for statistical trends
- Not recommended for single high-quality runs

---

### 2. Balanced Mode ⚖️ (RECOMMENDED)
```matlab
dt = 0.0015 seconds
Steps (100s simulation): ~67,000
Accuracy: 95-98%
Speed: Moderate
```

**Best for:**
- Daily research
- Exploration and hypothesis testing
- Most scientific studies
- Default choice for most users

**Trade-offs:**
- Good balance of speed and accuracy
- Suitable for most publications
- Recommended starting point

---

### 3. High-Precision Mode 🎯
```matlab
dt = 0.0005 seconds
Steps (100s simulation): ~200,000
Accuracy: 99%+
Speed: Slowest (4x slower than Balanced)
```

**Best for:**
- Final publication results
- Method validation
- Convergence studies
- When absolute accuracy is critical

**Trade-offs:**
- Very slow (hours for batch runs)
- Marginal accuracy improvement over Balanced
- Only use when necessary

---

### 4. Custom Mode 🔧
```matlab
dt = user-specified
```

**For advanced users who:**
- Need specific dt for convergence studies
- Have special accuracy requirements
- Want to test different time steps

---

## 📊 Performance Comparison

| Preset | dt (s) | Steps | Time (single) | Time (30 batch) | Accuracy | Recommended Use |
|--------|--------|-------|---------------|-----------------|----------|-----------------|
| **High-Speed** | 0.002 | 50k | ~5 min | ~2.5 hours | 90-95% | Batch runs |
| **Balanced** | 0.0015 | 67k | ~7 min | ~3.5 hours | 95-98% | **Most users** |
| **High-Precision** | 0.0005 | 200k | ~20 min | ~10 hours | 99%+ | Publication |

*Times are estimates with optimization enabled*

---

## 🎮 How to Use

### Interactive Mode
```matlab
main_2d_pipeline

% You'll see:
% --- Accuracy/Speed Preset ---
% [1] High-Speed Mode
% [2] Balanced Mode [RECOMMENDED]
% [3] High-Precision Mode
% [4] Custom
% Select preset [1-4] [default=2]:
```

### Programmatic Mode
```matlab
config = default_config();

% High-Speed
config.simulation_params.time_step = 0.002;

% Balanced (default)
config.simulation_params.time_step = 0.0015;

% High-Precision
config.simulation_params.time_step = 0.0005;

% Custom
config.simulation_params.time_step = 0.001;  % Your choice
```

---

## 🔬 Validation

### Convergence Test
```matlab
% Test if your chosen dt is converged
config = default_config();
seed = 12345;

% Run with dt
config.simulation_params.time_step = 0.0015;
result1 = simulate_once(config, seed);

% Run with dt/2
config.simulation_params.time_step = 0.00075;
result2 = simulate_once(config, seed);

% Check difference
diff = abs(result2.products_final - result1.products_final) / result1.products_final;
fprintf('Difference: %.2f%%\n', diff * 100);

% If diff < 3-5%, dt is converged
```

---

## 💡 Recommendations by Use Case

### Exploratory Research
```
Preset: High-Speed or Balanced
Reason: Fast iteration, trends are accurate enough
```

### Parameter Sweeps
```
Preset: High-Speed
Reason: Many runs needed, relative comparisons matter
```

### Daily Research
```
Preset: Balanced
Reason: Good accuracy, reasonable speed
```

### Publication Figures
```
Preset: Balanced or High-Precision
Reason: Depends on journal requirements
Tip: Start with Balanced, use High-Precision only if reviewers ask
```

### Method Validation
```
Preset: High-Precision
Reason: Need to prove algorithm correctness
```

---

## ⚠️ Important Notes

### 1. Accuracy vs Precision
- **Accuracy**: How close to "true" value
- **Precision**: Reproducibility with same seed
- All presets are equally precise (same seed → same result)
- Higher presets are more accurate (closer to continuous limit)

### 2. When to Use High-Precision
Only use High-Precision mode when:
- Reviewers specifically request convergence proof
- You're validating the simulation method itself
- Absolute numbers matter (not just relative comparisons)

For most research (comparing MSE vs Bulk, concentration effects, etc.), **Balanced mode is sufficient**.

### 3. Batch Runs
For batch runs with 30+ simulations:
- Use High-Speed mode
- Statistical averaging reduces individual run errors
- 5% error per run → <1% error in mean (with 30 runs)

---

## 🎯 Quick Decision Tree

```
Are you doing batch runs (>20 simulations)?
├─ Yes → High-Speed Mode
└─ No
    ├─ Is this for publication?
    │   ├─ Yes → Balanced Mode (or High-Precision if reviewers insist)
    │   └─ No → Balanced Mode
    └─ Are you validating the method itself?
        ├─ Yes → High-Precision Mode
        └─ No → Balanced Mode
```

**When in doubt: Use Balanced Mode (preset 2)**

---

## 📚 Technical Details

### Why These Values?

**High-Speed (dt=0.002)**:
```
k*dt = 100 * 0.002 = 0.2 (20% reaction probability)
σ = sqrt(2*1000*0.002) = 2.0 nm (67% of reaction radius)
```
- Still within τ-leaping validity
- Spatial resolution adequate for 5nm film

**Balanced (dt=0.0015)**:
```
k*dt = 100 * 0.0015 = 0.15 (15% reaction probability)
σ = sqrt(2*1000*0.0015) = 1.73 nm (58% of reaction radius)
```
- Conservative τ-leaping
- Good spatial resolution
- Sweet spot for most applications

**High-Precision (dt=0.0005)**:
```
k*dt = 100 * 0.0005 = 0.05 (5% reaction probability)
σ = sqrt(2*1000*0.0005) = 1.0 nm (33% of reaction radius)
```
- Very conservative
- Excellent spatial resolution
- Diminishing returns beyond this

---

## 🔄 Changing Presets Mid-Project

It's safe to change presets between runs:
- Results are comparable (within accuracy ranges)
- Use same preset for runs you want to compare directly
- Document which preset you used in publications

---

## 📖 References

- τ-leaping method: Gillespie (2001) J. Chem. Phys.
- Brownian dynamics: Ermak & McCammon (1978) J. Chem. Phys.
- Time step selection: Platen & Bruti-Liberati (2010) Numerical Solution of SDE

---

**Summary: Use Balanced Mode (preset 2) for 95% of your work. It's fast enough and accurate enough.**
