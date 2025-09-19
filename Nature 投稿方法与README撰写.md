

# **撰写高影响力期刊发表级的“方法”与代码文档的研究者指南**

## **第一部分：为您的随机动力学模拟撰写“方法”章节**

本部分旨在将您复杂的模拟过程提炼成一段清晰、简洁且可复现的描述，以满足《自然》等顶级期刊的严苛标准。

### **1.1 《自然》级别“方法”章节的撰写哲学**

#### **核心原则：清晰、简洁与可复现性**

撰写“方法”章节的首要目标是确保清晰性、简洁性和可复现性。它并非一份详尽的教程，而是专家之间的高效沟通，旨在为其他具备相应技能的研究者提供足够的信息以重复该项工作 1。根据《自然》的作者指南，方法章节应尽可能简洁，但必须包含理解和复现研究结果所需的所有关键要素 3。

#### **为广泛而专业的读者群写作**

《自然》拥有一个跨学科的读者群体。因此，方法描述必须让非本领域的科学家也能理解，同时又要为同行专家提供足够的专业精度 4。这意味着需要对非标准术语进行定义，并避免使用过度的行业术语。

#### **将“方法”章节视为严谨性的论证**

一份精心撰写的“方法”章节不仅仅是在描述过程，它更是在无声地论证您研究结果的有效性和严谨性。每一个参数、假设和选择都应显得经过深思熟虑且有理有据。在稿件的初审和同行评审阶段，这能有效地与编辑和审稿人建立信任 5。您的研究（“矿物引导的分子富集：原始细胞出现的界面驱动力”）提出了关于原始细胞出现的重大论断 7。其中的随机动力学模拟是支撑这一论断的关键证据之一 7。审稿人无疑会对此进行严格审查。如果“方法”章节中的描述含糊不清、信息不完整或看似随意，将会直接削弱模拟结果的可信度。反之，一份精确、对其假设保持透明、并清晰列出所有参数的描述，则彰显了高水平的科学严谨性，使您的研究结果更具说服力，从而显著提高稿件通过评审的概率。

### **1.2 描述计算模拟的结构化模板**

基于对模拟研究报告指南 8 和期刊要求 2 的分析，以下提供一个通用模板。该结构能确保所有关键信息都以合乎逻辑的方式被完整呈现。

1. **模型概述与科学目的**：用一句话陈述模型的名称/类型及其在本研究中的具体目的。  
2. **核心假设与理论框架**：以清晰的列表形式，阐明模型的基本假设。这对保证透明度至关重要。  
3. **模拟设置与条件**：描述模拟的初始状态和所测试的不同情景。  
4. **关键参数与实现**：提供最关键的定量细节。为了控制篇幅，通常建议将详细参数汇总在一个独立的表格中，并在正文中引用该表格。同时，提及用于实现模拟的软件或编程语言。

### **1.3 为您量身定制的250词“方法”章节草案**

本节将您在“NOTE S2”中提供的模拟细节 7 整合进上述模板，形成一份可以直接用于投稿的精炼草案。

**随机动力学模拟**

为定量评估矿物表面介导富集（MSE）的动力学优势，我们对固定在中心颗粒上的两步酶级联反应（图3）进行了随机动力学模拟。该模型假设在一个500 nm的立方空间内，底物、中间产物和最终产物可自由扩散，而酶的位置保持固定。在每个0.1 s的时间步长内，分子进行随机布朗运动（扩散系数D=100 nm2/s），反应概率则由酶的催化常数（kcat​=100 s−1）决定。我们对比了两种条件：一种是“体相”（Bulk）系统，其中酶均匀分散在整个空间；另一种是“MSE”系统，其中每种酶各有100个分子随机分布在一个直径为100 nm的无机颗粒周围10 nm厚的球壳内。两种情况下，初始均有2000个底物分子随机分布于除颗粒内部以外的空间中。该计算模型旨在验证MSE能够产生类似于底物通道效应的局部底物浓度梯度，从而缓解稀释溶液中固有的扩散限制。模拟的详细框架见补充说明S2，所有关键模拟参数总结于补充表X。用于该模拟的自定义代码已根据《自然》期刊政策存放在公共代码库中，可供审阅和复现。

### **表1：随机动力学模型的关键模拟参数**

这张表格提供了审稿人或后续研究者评估与复现您的模拟工作所需的全部定量细节，同时避免了在“方法”正文中冗长罗列，体现了您工作的专业性和对可复现性的重视。

| 参数 | 符号 | 数值 | 单位 | 描述 |
| :---- | :---- | :---- | :---- | :---- |
| 模拟域边长 | \- | 500 | nm | 立方体模拟空间的一边长度。 |
| 模拟总时长 | T | 5000 | s | 每个模拟运行的总时间。 |
| 时间步长 | dt | 0.1 | s | 模拟更新的离散时间间隔。 |
| 无机颗粒直径 | \- | 100 | nm | MSE条件下中心颗粒的直径。 |
| 酶薄膜厚度 | \- | 10 | nm | MSE条件下酶所在球壳的厚度。 |
| 酶数量（每种） | \- | 100 | \- | 酶I和酶II的分子数量。 |
| 催化效率 | kcat​ | 100 | s−1 | 两种酶的转换数。 |
| 初始底物数量 | \- | 2000 | \- | t=0时的底物分子数量。 |
| 小分子扩散系数 | D | 100 | nm2/s | 底物、中间产物和最终产物的扩散系数。 |
| 酶直径 | \- | 2 | nm | 用于碰撞检测/空间表示的假定直径。 |
| 小分子直径 | \- | 1 | nm | 用于碰撞检测/空间表示的假定直径。 |

---

## **第二部分：构建专业级的README以实现科学可复现性**

本部分将提供一个全面的蓝图，指导您创建一个不仅满足而且超越顶级期刊期望的README文件。

### **2.1 将README视为通往您研究的门户**

#### **第一印象至关重要**

README文件通常是审稿人或外部研究者与您的代码的首次互动 9。一个专业、清晰、全面的

README文件能够立刻传递出这是一个高质量、值得信赖的研究项目。微软为其发表于《自然》的AI2BMD项目所撰写的README文件，就是一个可供参考的黄金标准 10。

#### **服务双重读者**

README必须同时满足两类读者的需求 9：

1. **浏览者（编辑/第一审稿人）**：他们需要快速了解项目的概况、代码的核心目的以及一个关键的视觉化结果。  
2. **复现者（第二审稿人/未来研究者）**：他们需要细致、按部就班的指引，以成功运行代码并复现论文中的结果。

#### **README非论文，亦非完整文档**

这是一个在最佳实践中反复强调的关键区别 12。

README是一个入口点，它总结项目并链接到更详细的文档（如您的补充说明S2）和原始论文 7。其首要任务是帮助用户快速定位和上手。

### **2.2 高影响力科研项目README的剖析**

本节将解构README文件的基本组成部分，综合了大量指南 9 和现实案例 10 的最佳实践。

#### **2.2.1 头部信息：身份与信誉**

* **项目标题**：清晰且具有描述性。例如：Stochastic Kinetic Simulation of Enzyme Cascades on Mineral Surfaces。  
* **简短描述**：一句话总结项目的目的。  
* **徽章 (Badges)**：这些小而信息丰富的图标能一目了然地传达元数据 11。强烈建议包含：  
  * **DOI徽章**：至关重要！链接到在Zenodo或Figshare上的代码存档版本。  
  * **许可证徽章**：声明代码的重用权限（例如，MIT, GPL-3.0）。  
  * **出版物徽章**：直接链接到您在《自然》网站上的论文。

#### **2.2.2 概览：项目“电梯演讲”**

* **项目描述**：一个段落，解释代码的科学背景、它解决了什么问题，以及它如何与您手稿中的发现相关联 7。  
* **关键视觉化**：这是吸引注意力的核心元素 11。对于您的项目，最理想的视觉材料是补充图4a中的“累积产物生成曲线”，它直观地展示了MSE的动力学优势。

#### **2.2.3 核心技术章节：实现可复现性**

* **系统要求**：列出所有必需的软件、库及其特定版本（例如，Python 3.9+, NumPy 1.21+）。这是实现可复现性的最低要求 8。  
* **安装说明**：提供明确、可直接复制粘贴的安装命令 11。  
  * **强制使用容器化技术**：为确保万无一失的可复现性，强烈建议并提供使用Docker的说明。Docker能够将整个运行环境（操作系统、库、依赖项）封装起来，彻底杜绝“在我的电脑上可以运行”这类问题。微软的AI2BMD代码库就采用了这种做法，树立了高标准 10。这不仅仅是列出依赖项，而是提供一个预先构建好、保证可以工作的环境，是实现真正稳健可复现性的关键一步。  
* **使用方法 / 快速上手**：这是对审稿人而言最重要的部分。它必须提供运行一个最小示例并复现论文中一个关键结果的确切命令 9。对于您的项目，这个目标可以具体化为：“如何复现补充图4”。

#### **2.2.4 基础文档章节：用户手册**

* **代码库结构**：使用树状图展示代码库的文件结构，并对每个主要目录（如/data, /scripts, /results）进行简要说明 15。  
* **数据可用性**：清晰说明运行模拟所需的输入数据来源。由于您的模拟是从初始参数生成数据，本节应说明无需外部数据输入。这符合期刊对数据透明度的政策要求 21。  
* **许可证**：明确声明项目的许可证（例如，“本项目采用MIT许可证 \- 详情请见LICENSE.md文件”）。选择一个合适的开源许可证至关重要。  
* **如何引用**：提供论文和软件本身（使用存档步骤中获得的DOI）的BibTeX条目。这确保了您在学术上的贡献得到恰当的承认 16。  
* **联系方式/支持**：提供问题咨询的联系方式 18。

### **2.3 最后一步：代码存档与“代码可用性声明”**

#### **GitHub的非永久性**

本节将详细阐述一个关键点：根据《自然》和施普林格·自然的政策，仅提供一个GitHub链接是不足以满足存档要求的，因为GitHub上的内容可以随时被更改或删除 23。

#### **代码存档分步指南**

为了解决这个问题，需要将代码存放在一个能够提供永久标识符（如DOI）的档案库中。Zenodo是欧洲核子研究中心（CERN）维护的一个广受欢迎的免费服务，它与GitHub有良好的集成。具体步骤如下：

1. 登录Zenodo，使用您的GitHub账户授权。  
2. 在Zenodo中，找到您希望存档的GitHub代码库并启用它。  
3. 在GitHub中，创建一个新的“Release”。这个动作会触发Zenodo自动抓取该版本的代码，并为其创建一个永久的、可引用的DOI。

#### **撰写“代码可用性声明”**

一旦您获得了Zenodo的DOI，就可以为您的手稿撰写正式的声明。这是期刊的强制要求。示例如下：  
“本研究中用于随机动力学模拟的自定义代码，已根据MIT许可证在Zenodo代码库公开发布，访问地址为 \[https://doi.org/10.5281/zenodo.XXXXXXX\]。” 24

### **表2：高影响力科研项目README的剖析与设计原理**

这张表格不仅提供了一个模板，更重要的是解释了每个部分的设计*目的*及其主要服务*受众*。理解这些背后的战略思考，将帮助您更有效地构建和调整您的README文件，使其发挥最大作用。例如，用户可能认为“徽章”只是装饰，但这张表会阐明，它们是为“浏览者”设计的，目的是“一目了然地建立信誉”。同样，“安装说明”是为“复现者”准备的，其目的是“消除模糊性，降低使用门槛”。通过将每个组件与其功能和受众联系起来，您将掌握优秀文档的核心原则，而不仅仅是复制一个格式。

| README 章节 | 主要受众 | 核心目的 / “它解决什么问题” | 您的项目示例 |
| :---- | :---- | :---- | :---- |
| **头部信息** (标题, 徽章) | 浏览者, 复现者 | 一目了然地建立项目身份、信誉和许可信息。 | 项目标题，来自Zenodo的DOI徽章，MIT许可证徽章。 |
| **概览** (描述, 视觉化) | 浏览者, 编辑 | 提供引人注目的“电梯演讲”；快速传达核心科学贡献和关键结果。 | 一段将代码与论文中MSE假说联系起来的文字；包含补充图4a的图表。 |
| **系统要求** | 复现者 | 防止环境相关错误，清晰陈述先决条件。 | 列出Python版本、所需的库（NumPy, Matplotlib）。 |
| **安装说明** | 复现者 | 提供一个万无一失、可直接复制粘贴的路径来建立工作环境。 | git clone..., docker build..., docker run...。 |
| **使用方法 / 快速上手** | 复现者, 审稿人 | 展示代码功能，并提供复现关键发现的直接路径。 | “要复现补充图4，请运行：python run\_simulation.py \--condition MSE”。 |
| **代码库结构** | 复现者, 贡献者 | 提供代码库的地图，便于导航和理解。 | tree命令输出，显示/scripts, /results等目录。 |
| **如何引用** | 所有未来用户 | 确保对论文和软件本身的学术贡献给予恰当的承认。 | 提供您的《自然》论文和Zenodo DOI的BibTeX条目。 |
| **许可证** | 所有未来用户 | 清晰定义代码的使用和重用条款。 | “本项目采用MIT许可证。” |
| **存档DOI** | 编辑, 期刊工作人员 | 满足期刊对代码长期、永久访问的强制要求。 | 链接到永久的Zenodo记录。 |

### **结论与建议**

为向《自然》等顶级期刊投稿，您的研究工作不仅需要在科学上具有突破性，还必须在透明度和可复现性方面达到最高标准。本文档为您提供了两个关键部分的详细指南：

1. **“方法”章节的模拟描述**：一份简洁而全面的文本草案，辅以详尽的参数表，旨在清晰地传达您计算工作的严谨性。  
2. **代码README文件**：一个结构化、专业化的文档蓝图，它不仅能引导审稿人顺利复现您的结果，还能作为您研究成果的一个持久、开放的门户。

**核心建议如下：**

* **拥抱透明度**：在“方法”和README中，对模型的假设、参数和局限性保持完全透明。这会建立信任，而不是削弱您的论点。  
* **优先考虑可复现性**：采用容器化技术（如Docker）来封装您的计算环境。这是消除复现障碍、满足最高科学标准的黄金准则。  
* **遵守期刊政策**：认识到代码存档的必要性。在提交手稿前，通过Zenodo等服务为您的代码获取一个永久DOI，并在稿件中提供正式的“代码可用性声明”。

遵循这些指南，您将能够创建出不仅支持您的科学发现，而且本身就体现了卓越科研实践的文档，从而最大化您稿件被成功接收的机会。

#### **引用的著作**

1. Publication Ethics Statements \- Simulation Journal, Acta Simulatio, 访问时间为 九月 18, 2025， [https://actasimulatio.eu/index.php?stranka=ethics](https://actasimulatio.eu/index.php?stranka=ethics)  
2. Submission Guidelines | PLOS One, 访问时间为 九月 18, 2025， [https://journals.plos.org/plosone/s/submission-guidelines](https://journals.plos.org/plosone/s/submission-guidelines)  
3. Manuscript formatting, 访问时间为 九月 18, 2025， [https://ftp.cpc.ncep.noaa.gov/hwang/OLD/Refs\_2015ENSO/2a\_Manuscript\_formatting.pdf](https://ftp.cpc.ncep.noaa.gov/hwang/OLD/Refs_2015ENSO/2a_Manuscript_formatting.pdf)  
4. Nature journal submission guidelines, 访问时间为 九月 18, 2025， [https://cdn.prod.website-files.com/65f010d0fe988ed08ccf59d9/67fde1e459edc39ee3204388\_14063563681.pdf](https://cdn.prod.website-files.com/65f010d0fe988ed08ccf59d9/67fde1e459edc39ee3204388_14063563681.pdf)  
5. Nature Guide to Authors \- WearCam, 访问时间为 九月 18, 2025， [http://wearcam.org/figs/photocell\_experiment/nature\_guide\_to\_authors.pdf](http://wearcam.org/figs/photocell_experiment/nature_guide_to_authors.pdf)  
6. What proportion of papers submitted to Nature are actually sent for review?, 访问时间为 九月 18, 2025， [https://academia.stackexchange.com/questions/8755/what-proportion-of-papers-submitted-to-nature-are-actually-sent-for-review](https://academia.stackexchange.com/questions/8755/what-proportion-of-papers-submitted-to-nature-are-actually-sent-for-review)  
7. 修改版本（无批注） (1).pdf  
8. Reporting Guidelines for Simulation-Based Research in Social Sciences \- ResearchGate, 访问时间为 九月 18, 2025， [https://www.researchgate.net/publication/262863102\_Reporting\_Guidelines\_for\_Simulation-Based\_Research\_in\_Social\_Sciences](https://www.researchgate.net/publication/262863102_Reporting_Guidelines_for_Simulation-Based_Research_in_Social_Sciences)  
9. How to write a good README \- GitHub, 访问时间为 九月 18, 2025， [https://github.com/banesullivan/README](https://github.com/banesullivan/README)  
10. microsoft/AI2BMD: AI-powered ab initio biomolecular ... \- GitHub, 访问时间为 九月 18, 2025， [https://github.com/microsoft/AI2BMD](https://github.com/microsoft/AI2BMD)  
11. Make a README, 访问时间为 九月 18, 2025， [https://www.makeareadme.com/](https://www.makeareadme.com/)  
12. How to write a good README? \#discuss \- DEV Community, 访问时间为 九月 18, 2025， [https://dev.to/jmfayard/how-to-write-a-good-readme-discuss-4hkl](https://dev.to/jmfayard/how-to-write-a-good-readme-discuss-4hkl)  
13. README Files \- Harvard Biomedical Data Management, 访问时间为 九月 18, 2025， [https://datamanagement.hms.harvard.edu/collect-analyze/documentation-metadata/readme-files](https://datamanagement.hms.harvard.edu/collect-analyze/documentation-metadata/readme-files)  
14. readme-files – Best Practices for Writing Reproducible Code \- GitHub Pages, 访问时间为 九月 18, 2025， [https://utrechtuniversity.github.io/workshop-computational-reproducibility/chapters/readme-files.html](https://utrechtuniversity.github.io/workshop-computational-reproducibility/chapters/readme-files.html)  
15. README Best Practices \- Tilburg Science Hub, 访问时间为 九月 18, 2025， [https://tilburgsciencehub.com/topics/collaborate-share/share-your-work/content-creation/readme-best-practices/](https://tilburgsciencehub.com/topics/collaborate-share/share-your-work/content-creation/readme-best-practices/)  
16. README template \- University of Reading, 访问时间为 九月 18, 2025， [https://www.reading.ac.uk/research-services/-/media/project/functions/research-and-enterprise-services/documents/readme\_template2.txt?la=en\&hash=08422814D7744838578C1DBB0B0ADFF1](https://www.reading.ac.uk/research-services/-/media/project/functions/research-and-enterprise-services/documents/readme_template2.txt?la=en&hash=08422814D7744838578C1DBB0B0ADFF1)  
17. Writing READMEs for Research Data \- Cornell Data Services, 访问时间为 九月 18, 2025， [https://data.research.cornell.edu/data-management/sharing/readme/](https://data.research.cornell.edu/data-management/sharing/readme/)  
18. Writing READMEs for Research Code & Software \- Cornell Data Services, 访问时间为 九月 18, 2025， [https://data.research.cornell.edu/data-management/sharing/writing-readmes-for-research-code-software/](https://data.research.cornell.edu/data-management/sharing/writing-readmes-for-research-code-software/)  
19. Template README and Guidance \- Social Science Data Editors, 访问时间为 九月 18, 2025， [https://social-science-data-editors.github.io/template\_README/template-README.html](https://social-science-data-editors.github.io/template_README/template-README.html)  
20. othneildrew/Best-README-Template: An awesome README template to jumpstart your projects\! \- GitHub, 访问时间为 九月 18, 2025， [https://github.com/othneildrew/Best-README-Template](https://github.com/othneildrew/Best-README-Template)  
21. Write a data availability statement for a paper \- Nature Support, 访问时间为 九月 18, 2025， [https://support.nature.com/en/support/solutions/articles/6000237611-write-a-data-availability-statement-for-a-paper](https://support.nature.com/en/support/solutions/articles/6000237611-write-a-data-availability-statement-for-a-paper)  
22. Data Availability Statements | Publish your research \- Springer Nature, 访问时间为 九月 18, 2025， [https://www.springernature.com/gp/authors/research-data-policy/data-availability-statements](https://www.springernature.com/gp/authors/research-data-policy/data-availability-statements)  
23. Code and Data Availability Policy | Journal of Privacy and Confidentiality, 访问时间为 九月 18, 2025， [https://journalprivacyconfidentiality.org/index.php/jpc/codedataavailabilitypolicy](https://journalprivacyconfidentiality.org/index.php/jpc/codedataavailabilitypolicy)  
24. Code Policy | Open science \- Springer Nature, 访问时间为 九月 18, 2025， [https://www.springernature.com/gp/open-science/code-policy](https://www.springernature.com/gp/open-science/code-policy)