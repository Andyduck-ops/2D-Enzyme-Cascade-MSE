# GitHub数学公式渲染测试

## 测试1：纯英文环境下的数学公式
This is a test of math formulas in English context:

The reaction probability is: $P_{\text{GOx}} = 1 - \exp(-k_{\text{cat,GOx}} (1 - \text{inhibition}_{\text{GOx}}) \Delta t)$

## 测试2：中文环境下的数学公式
这是中文环境下的数学公式测试：

反应概率为：$P_{\text{GOx}} = 1 - \exp(-k_{\text{cat,GOx}} (1 - \text{inhibition}_{\text{GOx}}) \Delta t)$

## 测试3：中文与数学公式混合（无空格）
反应概率：$P_{\text{GOx}} = 1 - \exp(-k_{\text{cat,GOx}} (1 - \text{inhibition}_{\text{GOx}}) \Delta t)$

## 测试4：中文与数学公式混合（有空格）
反应概率： $P_{\text{GOx}} = 1 - \exp(-k_{\text{cat,GOx}} (1 - \text{inhibition}_{\text{GOx}}) \Delta t)$

## 测试5：块级数学公式
中文描述的块级公式：

$$P_{\text{GOx}} = 1 - \exp(-k_{\text{cat,GOx}} (1 - \text{inhibition}_{\text{GOx}}) \Delta t)$$

## 测试6：复杂的中文数学混合
拥挤抑制公式：$\text{inhibition} = I_{\text{max}} \times \max(0, 1 - n_{\text{local}}/n_{\text{sat}})$

布朗步进公式：$\Delta r = \sqrt{2 D \Delta t} \cdot \eta$，其中$\eta \sim N(0, I_2)$

## 测试7：中文标点符号影响
反应概率：$P = 1 - \exp(-k \Delta t)$，其中$k$为速率常数。

反应概率：$P = 1 - \exp(-k \Delta t)$ ，其中 $k$ 为速率常数。