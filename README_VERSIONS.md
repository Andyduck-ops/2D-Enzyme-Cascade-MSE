# README 版本说明

本文档说明项目中的不同 README 文件版本及其适用场景。

## 文件概览

| 文件名 | 用途 | LaTeX支持 | 适用平台 | 特点 |
|--------|------|-----------|----------|------|
| `README.md` | GitHub 仓库主文档 | ❌ 不支持 | GitHub 仓库页面 | 使用 Unicode 字符，兼容性最佳 |
| `README.render.md` | 英文文档站点版本 | ✅ 完全支持 | KaTeX/MathJax站点 | 完整 LaTeX 公式渲染 |
| `README.zh-CN.md` | 中文 GitHub 仓库文档 | ❌ 不支持 | GitHub 仓库页面 | 使用 Unicode 和简单表示 |
| `README.render.zh-CN.md` | 中文文档站点版本 | ✅ 完全支持 | KaTeX/MathJax站点 | 完整 LaTeX 公式渲染 |

## 详细说明

### 1. GitHub 仓库版本（默认）

#### `README.md` (英文)
- **用途**: GitHub 仓库首页默认显示
- **特点**:
  - 不依赖 LaTeX 渲染
  - 使用 Unicode 字符表示数学符号
  - 例如：nm²/s, s⁻¹, ≥, ≤, →, ×
- **适用场景**:
  - GitHub 仓库浏览
  - 代码编辑器中查看
  - 不需要 MathJax/KaTeX 的简单文档站点

#### `README.zh-CN.md` (中文)
- **用途**: 中文环境下的 GitHub 仓库展示
- **特点**:
  - 完全使用中文界面
  - 避免了 GitHub 对 LaTeX 公式的不良渲染
  - 使用简单表达式：`D_bulk`、`k_cat_GOx`
- **适用场景**:
  - 需要用中文展示的 GitHub 仓库
  - 中文用户快速了解项目

### 2. 文档站点版本（render）

#### `README.render.md` (英文)
- **用途**: 支持 LaTeX 渲染的文档站点
- **特点**:
  - 包含完整 LaTeX 数学公式
  - 公式周围有适当空格避免 CJK 混排问题
  - 专业的数学排版
- **适用场景**:
  - GitHub Pages（配合 KaTeX 插件）
  - MkDocs + KaTeX
  - GitBook
  - 其他支持 LaTeX 的文档站点

#### `README.render.zh-CN.md` (中文)
- **用途**: 中文文档站点的专业展示
- **特点**:
  - 中英双语环境中正确渲染
  - LaTeX 公式与中文文本混合
  - 保持数学表达式的专业性
- **适用场景**:
  - 中文技术文档站点
  - 需要专业公式展示的学术网站
  - 支持双语的国际合作项目

## 使用建议

### GitHub 仓库
- 使用 `README.md` 和 `README.zh-CN.md`
- 确保在 GitHub 页面正常显示

### 文档站点
```markdown
例如 MkDocs 配置示例：

# mkdocs.yml
site_name: 2D Enzyme Cascade Simulation
docs_dir: docs

extra_javascript:
  - https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.js
  - https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/contrib/auto-render.min.js

extra_css:
  - https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.css

theme:
  name: material
```

### 开发者指南
1. 同时维护四个版本
2. 修改内容时需要同步更新所有版本
3. 测试在目标平台的显示效果
4. 优先使用 Unicode 表示的稳定版本

## 版本策略

### 核心原则
- **兼容性优先**: GitHub 版本使用 Unicode 确保最广泛兼容
- **专业性次之**: 文档站点版本保留 LaTeX 专业排版
- **一致性**: 所有版本的核心内容保持一致
- **本地化**: 中英文版本考虑各自语言环境的阅读习惯

### 公式处理示例

| 类型 | GitHub 版本 | 网站版本 |
|------|-------------|-----------|
| 扩散系数 | `D_bulk = 1000 nm²/s` | `D_{\mathrm{bulk}} = 1000\,\mathrm{nm}^2/\mathrm{s}` |
| 反应方程 | `S —(GOx)→ I —(HRP)→ P` | `\mathrm{S} \xrightarrow{\mathrm{GOx}} \mathrm{I} \xrightarrow{\mathrm{HRP}} \mathrm{P}` |
| 指数函数 | `k = 100 s⁻¹` | `k = 100\,\mathrm{s}^{-1}` |

## FAQ

### Q: 为什么要维护多个版本？
A: 因为 GitHub 默认不支持 LaTeX 渲染，而文档站点需要专业的公式展示。多个版本确保各种场景下都能获得最佳阅读体验。

### Q: 如何同步更新内容？
A: 建议创建脚本自动提取内容并转换格式，或者手动更新时注意保持核心内容的一致性。

### Q: 能否自动转换？
A: 可以使用正则表达式或自定义脚本进行半自动转换，但复杂的公式混排仍需人工调整。

### Q: 哪个版本是"权威"版本？
A: 建议将文档站点版本作为内容主体，GitHub 版本作为适应平台限制的简化版本。

---

## 相关文档

- [GitHub Markdown 支持说明](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
- [LaTeX 数学公式参考](https://katex.org/docs/supported.html)
- [Unicode 数学符号表](https://unicode.org/charts/PDF/U2200.pdf)