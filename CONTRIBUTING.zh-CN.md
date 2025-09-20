# 2D酶级联模拟项目贡献指南

感谢您对2D酶级联模拟项目的关注和支持！本文件提供了项目贡献的指南和说明。

## 📋 目录

- [入门指南](#入门指南)
- [开发工作流程](#开发工作流程)
- [代码风格指南](#代码风格指南)
- [测试指南](#测试指南)
- [文档指南](#文档指南)
- [问题报告](#问题报告)
- [提交Pull Request](#提交pull-request)
- [审核流程](#审核流程)

## 🚀 入门指南

### 前置要求

- **MATLAB**: R2019b或更高版本
- **Git**: 版本控制工具
- **GitHub账户**: 用于提交PR和Issue
- **MATLAB工具箱**:
  - Statistics and Machine Learning Toolbox
  - Parallel Computing Toolbox（可选）

### 首次设置

1. **Fork仓库**
   ```bash
   # 访问GitHub仓库页面
   # 点击右上角的"Fork"按钮
   ```

2. **克隆您的Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/2D-Enzyme-Cascade-Simulation.git
   cd 2D-Enzyme-Cascade-Simulation
   ```

3. **设置上游远程仓库**
   ```bash
   git remote add upstream https://github.com/your-org/2D-Enzyme-Cascade-Simulation.git
   ```

4. **安装依赖**
   ```matlab
   % 打开MATLAB并导航到项目根目录
   % 运行主流程验证设置
   main_2d_pipeline
   ```

## 🔄 开发工作流程

### 分支策略

我们采用简单的分支策略：

- **main**: 稳定的生产就绪代码
- **develop**: 新功能的集成分支
- **feature/***: 功能分支
- **bugfix/***: 错误修复分支
- **hotfix/***: 生产环境的紧急修复

### 工作流程步骤

1. **创建新分支**
   ```bash
   # 新功能
   git checkout -b feature/amazing-feature develop

   # 错误修复
   git checkout -b bugfix/fix-important-issue main

   # 紧急修复
   git checkout -b hotfix/critical-security-issue main
   ```

2. **进行更改**
   - 遵循[代码风格指南](#代码风格指南)
   - 为新功能编写测试
   - 必要时更新文档

3. **运行测试**
   ```matlab
   % 运行所有测试
   run_tests()

   % 运行特定类别测试
   run_tests('category', 'unit')
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```

5. **推送到您的Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **提交Pull Request**
   - 访问您在GitHub上的fork
   - 点击"Compare & pull request"
   - 确保与正确的基分支比较
   - 填写PR模板

7. **处理审核意见**
   - 进行请求的更改
   - 将额外提交推送到您的功能分支
   - 回应审核意见

## 📝 代码风格指南

### MATLAB代码风格

#### 文件组织
- **前缀组织**: 使用前缀表示模块组织：
  - `sim_*.m` - 模拟核心函数
  - `viz_*.m` - 可视化函数
  - `io_*.m` - 输入输出函数
  - `config_*.m` - 配置函数

#### 函数命名
- 使用`下划线分隔的小写字母`作为函数名
- 描述性但简洁
- 对执行动作的函数使用动作动词：
  ```matlab
  % 好的做法
  function results = simulate_once(config, seed)
  function positions = initialize_particles(config)

  % 差的做法
  function r = sim1(c, s)
  function p = initp(c)
  ```

#### 变量命名
- 使用`下划线分隔的小写字母`作为变量名
- 描述变量的用途：
  ```matlab
  % 好的做法
  num_enzymes = config.particle_params.num_enzymes;
  diffusion_coefficient = config.particle_params.diff_coeff_bulk;

  % 差的做法
  n = config.particle_params.num_enzymes;
  d = config.particle_params.diff_coeff_bulk;
  ```

#### 注释和文档
- **文件头**: 每个.m文件应以以下内容开始：
  ```matlab
  function [output1, output2] = function_name(input1, input2)
  %FUNCTION_NAME - 函数用途的简要描述
  %
  % 语法: [output1, output2] = function_name(input1, input2)
  %
  % 输入:
  %   input1  - input1的描述
  %   input2  - input2的描述
  %
  % 输出:
  %   output1 - output1的描述
  %   output2 - output2的描述
  %
  % 示例:
  %   % 函数使用示例
  %   result = function_name(input_value);
  %
  % 另请参见: RELATED_FUNCTION1, RELATED_FUNCTION2

      % 函数实现在此

  end
  ```

- **行内注释**: 使用注释解释复杂算法：
  ```matlab
  % 布朗动力学步骤: x = x + sqrt(2*D*dt)*N(0,1)
  random_displacement = sqrt(2 * diffusion_coeff * time_step) * randn(2, 1);
  new_position = current_position + random_displacement;
  ```

#### 常量和魔数
- 在函数顶部或单独的配置文件中定义常量
- 避免在代码中使用魔数：
  ```matlab
  % 好的做法
  BOLTZMANN_CONSTANT = 1.38e-23;  % J/K
  ROOM_TEMPERATURE = 298;        % K

  % 差的做法
  energy = 1.38e-23 * 298 * value;
  ```

### 配置指南

#### 配置结构
- 使用结构化配置：
  ```matlab
  function config = default_config()
      %DEFAULT_CONFIG - 创建默认模拟配置
      config = struct();

      % 模拟参数
      config.simulation_params = struct();
      config.simulation_params.box_size = 500;          % nm
      config.simulation_params.total_time = 1.0;        % s
      config.simulation_params.time_step = 1e-5;       % s
      config.simulation_params.simulation_mode = 'MSE'; % 'MSE'或'bulk'

      % 粒子参数
      config.particle_params = struct();
      config.particle_params.num_enzymes = 200;
      config.particle_params.num_substrate = 1000;
      % ... 其他参数
  end
  ```

### 错误处理

#### 输入验证
- 在函数开始时验证输入：
  ```matlab
  function simulate_once(config, seed)
      % 验证输入
      if nargin < 2
          error('simulate_once:missingInput', 'config和seed都是必需的');
      end

      if ~isstruct(config)
          error('simulate_once:invalidConfig', 'config必须是结构体');
      end

      if ~isnumeric(seed) || ~isscalar(seed)
          error('simulate_once:invalidSeed', 'seed必须是数字标量');
      end
  end
  ```

#### Try-Catch块
- 对关键操作使用try-catch：
  ```matlab
  try
      % 关键操作
      data = load(data_file);
  catch ME
      warning('加载数据文件失败: %s', ME.message);
      data = [];  % 提供默认值
  end
  ```

## 🧪 测试指南

### 测试组织

在`tests/`目录中创建测试，遵循以下结构：

```
tests/
├── test_basic_simulation.m    % 基本功能测试
├── test_batch_processing.m    % 批量处理测试
├── test_reproducibility.m    % 可复现性测试
├── test_visualization.m       % 可视化测试
└── test_config_validation.m   % 配置验证测试
```

### 测试命名约定

- 使用`test_`前缀命名所有测试文件
- 使用描述性名称：
  ```matlab
  % 好的做法
  function test_mse_vs_bulk_enhancement()
  function test_diffusion_coefficient_effects()

  % 差的做法
  function test1()
  function test_mse_bulk()
  ```

### 测试结构

每个测试函数应遵循以下结构：

```matlab
function test_feature_name()
    %TEST_FEATURE_NAME - 测试描述

    %% 设置
    config = default_config();
    test_seed = 1234;

    %% 测试执行
    result1 = function_to_test(config, test_seed);

    %% 断言结果
    assertTrue(result1.success, '测试应该成功');
    assertEqual(result1.value, expected_value, '值应与期望值匹配');

    %% 清理（如需要）
    % 清理临时文件等
end
```

### 测试类别

#### 单元测试
- 单独测试各个函数
- 必要时模拟外部依赖
- 执行快速

#### 集成测试
- 测试多个组件协同工作
- 使用真实配置
- 比单元测试慢

#### 性能测试
- 测试执行时间和内存使用
- 比较不同参数集的性能
- 确保优化不破坏功能

### 运行测试

```matlab
% 运行所有测试
cd('tests');
runtests;

% 运行特定测试文件
runtests('test_basic_simulation.m');

% 带覆盖率运行测试
results = runtests('tests', 'CodeCoverage', 'on');
disp(results);
```

## 📚 文档指南

### 行内文档

- 使用MATLAB内置帮助系统
- 包括：
  - 函数用途
  - 输入输出描述
  - 使用示例
  - 参见引用

### README更新

添加新功能时：
1. 更新主README.md
2. 更新README.zh-CN.md（如适用）
3. 向示例部分添加新示例
4. 必要时更新目录

### 代码注释

- **算法文档**: 解释复杂的数学运算
- **配置注释**: 解释参数选择及其效果
- **性能注释**: 提及优化考虑因素

### 理论文档

更新`docs/`中的理论文档：
- `docs/2d_model_theory.md`
- `docs/2d_model_theory.en.md`

包括：
- 数学公式
- 物理假设
- 实现细节
- 文献引用

## 🐛 问题报告

### 问题模板

报告问题时使用此模板：

```markdown
## 问题类型
- 错误报告
- 功能请求
- 文档改进
- 问题咨询

## 环境
- MATLAB版本: [例如 R2023a]
- 操作系统: [例如 Windows 11, macOS 13.0]
- 项目提交: [例如 abc1234]

## 描述
[问题或请求的详细描述]

## 复现步骤（针对错误）
1. [第一步]
2. [第二步]
3. [第三步]

## 期望行为
[应该发生什么]

## 实际行为
[实际发生了什么]

## 错误信息（如有）
```
错误信息或堆栈跟踪在此
```

## 其他上下文
[任何其他相关信息]
```

### 错误报告

包括：
- 最小重现示例
- 期望vs实际行为
- 错误信息和堆栈跟踪
- 使用的配置
- MATLAB版本和操作系统

### 功能请求

包括：
- 问题描述
- 建议的解决方案
- 用例
- 预期影响

### 问题咨询

- 明确说明需要什么帮助
- 包括已经尝试过的内容
- 提供相关代码片段

## 📤 提交Pull Request

### PR模板

```markdown
## Pull Request类型
- [ ] 错误修复
- [ ] 新功能
- [ ] 文档改进
- [ ] 性能改进
- [ ] 代码重构
- [ ] 测试

## 描述
[更改的详细描述]

## 所做更改
- [ ] 添加新功能
- [ ] 修复错误
- [ ] 更新文档
- [ ] 添加/更新测试
- [ ] 改进性能

## 相关问题
[链接到相关GitHub问题]

## 执行的测试
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 执行了手动测试
- [ ] 完成性能测试

## 检查清单
- [ ] 遵循代码风格指南
- [ ] 文档已更新
- [ ] 已添加/更新测试
- [ ] 无破坏性更改
- [ ] 准备审核
```

### PR要求

提交PR之前：

1. **更新文档**
   - 更新相关README文件
   - 必要时添加行内注释
   - 更新理论文档（如适用）

2. **编写测试**
   - 为新功能添加单元测试
   - 确保所有现有测试通过
   - 为复杂功能添加集成测试

3. **代码质量**
   - 遵循编码标准
   - 删除调试代码和控制台输出
   - 确保MATLAB中无警告

4. **性能**
   - 测试不同参数集
   - 确保无性能回归
   - 如进行性能更改则进行性能分析

## 👀 审核流程

### 审核标准

审核者将检查：

#### 代码质量
- 遵循编码标准
- 无魔数或硬编码值
- 适当的错误处理
- 清晰可读的代码

#### 功能性
- 按预期工作
- 无破坏性更改
- 保持向后兼容性
- 处理边缘情况

#### 测试
- 全面的测试覆盖率
- 测试可靠通过
- 性能考虑因素

#### 文档
- 清晰的函数文档
- 更新了README文件
- 提供了示例
- 更新了理论文档

### 审核时间表

- **初步审核**: 2-3个工作日内
- **反馈回应**: 1周内
- **最终审核**: 请求更改后2个工作日内

### 合并流程

1. **自动化检查**必须通过
2. **至少一个审核者批准**必需
3. **所有审核意见已处理**
4. **文档已更新**
5. **测试通过**

## 🏆 认可

### 贡献者认可

- 贡献者将在发布说明中被认可
- 重要贡献可能包括共同作者身份
- 贡献者在AUTHORS文件中被记名

### 发布说明

贡献格式：
```
### 添加/更改/修复
- [贡献描述] 由 [@username](https://github.com/username) 贡献
```

## 📞 获取帮助

如果需要贡献相关的帮助：

1. **GitHub Discussions**: 用于一般问题
2. **GitHub Issues**: 用于特定错误或功能
3. **邮件联系**: 适用于敏感事项

## 🎯 社区指南

### 行为准则

- 保持尊重和包容
- 提供建设性反馈
- 专注于技术优点
- 帮助新人入门

### 沟通

- 使用清晰、描述性的语言
- 提供上下文和背景
- 对回应保持耐心
- 假设善意

---

再次感谢您对2D酶级联模拟项目的贡献！您的努力帮助改进了这个为研究社区服务的科学计算工具。