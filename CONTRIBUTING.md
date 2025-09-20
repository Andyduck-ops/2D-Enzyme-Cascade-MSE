# Contributing to 2D Enzyme Cascade Simulation

Thank you for your interest in contributing to the 2D Enzyme Cascade Simulation project! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Guidelines](#documentation-guidelines)
- [Reporting Issues](#reporting-issues)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Review Process](#review-process)

## 🚀 Getting Started

### Prerequisites

- **MATLAB**: R2019b or later
- **Git**: For version control
- **GitHub Account**: To submit pull requests and issues
- **MATLAB Toolboxes**:
  - Statistics and Machine Learning Toolbox
  - Parallel Computing Toolbox (optional)

### First Steps

1. **Fork the Repository**
   ```bash
   # Visit the repository on GitHub
   # Click the "Fork" button in the top-right corner
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/2D-Enzyme-Cascade-Simulation.git
   cd 2D-Enzyme-Cascade-Simulation
   ```

3. **Set Upstream Remote**
   ```bash
   git remote add upstream https://github.com/your-org/2D-Enzyme-Cascade-Simulation.git
   ```

4. **Install Dependencies**
   ```matlab
   % Open MATLAB and navigate to project root
   % Run the main pipeline to verify setup
   main_2d_pipeline
   ```

## 🔄 Development Workflow

### Branch Strategy

We use a simple branching strategy:

- **main**: Stable, production-ready code
- **develop**: Integration branch for new features
- **feature/***: Feature branches
- **bugfix/***: Bug fix branches
- **hotfix/***: Critical fixes for production

### Workflow Steps

1. **Create a New Branch**
   ```bash
   # For new features
   git checkout -b feature/amazing-feature develop

   # For bug fixes
   git checkout -b bugfix/fix-important-issue main

   # For hot fixes
   git checkout -b hotfix/critical-security-issue main
   ```

2. **Make Your Changes**
   - Follow the [Code Style Guidelines](#code-style-guidelines)
   - Write tests for new functionality
   - Update documentation as needed

3. **Run Tests**
   ```matlab
   % Run all tests
   run_tests()

   % Run specific test category
   run_tests('category', 'unit')
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Submit Pull Request**
   - Go to your fork on GitHub
   - Click "Compare & pull request"
   - Ensure you're comparing to the correct base branch
   - Fill in the PR template

7. **Address Review Comments**
   - Make requested changes
   - Push additional commits to your feature branch
   - Respond to review comments

## 📝 Code Style Guidelines

### MATLAB Code Style

#### File Organization
- **Prefix Organization**: Use prefixes to indicate module organization:
  - `sim_*.m` - Simulation core functions
  - `viz_*.m` - Visualization functions
  - `io_*.m` - Input/output functions
  - `config_*.m` - Configuration functions

#### Function Naming
- Use `lowercase_with_underscores` for function names
- Be descriptive but concise
- Use action verbs for functions that perform actions:
  ```matlab
  % Good
  function results = simulate_once(config, seed)
  function positions = initialize_particles(config)

  % Bad
  function r = sim1(c, s)
  function p = initp(c)
  ```

#### Variable Naming
- Use `lowercase_with_underscores` for variable names
- Be descriptive about variable purpose:
  ```matlab
  % Good
  num_enzymes = config.particle_params.num_enzymes;
  diffusion_coefficient = config.particle_params.diff_coeff_bulk;

  % Bad
  n = config.particle_params.num_enzymes;
  d = config.particle_params.diff_coeff_bulk;
  ```

#### Comments and Documentation
- **File Headers**: Every .m file should start with:
  ```matlab
  function [output1, output2] = function_name(input1, input2)
  %FUNCTION_NAME - Brief description of function purpose
  %
  % Syntax: [output1, output2] = function_name(input1, input2)
  %
  % Inputs:
  %   input1  - Description of input1
  %   input2  - Description of input2
  %
  % Outputs:
  %   output1 - Description of output1
  %   output2 - Description of output2
  %
  % Example:
  %   % Example of function usage
  %   result = function_name(input_value);
  %
  % See also: RELATED_FUNCTION1, RELATED_FUNCTION2

      % Function implementation here

  end
  ```

- **Inline Comments**: Use comments to explain complex algorithms:
  ```matlab
  % Brownian dynamics step: x = x + sqrt(2*D*dt)*N(0,1)
  random displacement = sqrt(2 * diffusion_coeff * time_step) * randn(2, 1);
  new_position = current_position + random_displacement;
  ```

#### Constants and Magic Numbers
- Define constants at the top of functions or in separate config files
- Avoid magic numbers in the code:
  ```matlab
  % Good
  BOLTZMANN_CONSTANT = 1.38e-23;  % J/K
  ROOM_TEMPERATURE = 298;        % K

  % Bad
  energy = 1.38e-23 * 298 * value;
  ```

### Configuration Guidelines

#### Configuration Structure
- Use structured configurations:
  ```matlab
  function config = default_config()
      %DEFAULT_CONFIG - Create default simulation configuration
      config = struct();

      % Simulation parameters
      config.simulation_params = struct();
      config.simulation_params.box_size = 500;          % nm
      config.simulation_params.total_time = 1.0;        % s
      config.simulation_params.time_step = 1e-5;       % s
      config.simulation_params.simulation_mode = 'MSE'; % 'MSE' or 'bulk'

      % Particle parameters
      config.particle_params = struct();
      config.particle_params.num_enzymes = 200;
      config.particle_params.num_substrate = 1000;
      % ... other parameters
  end
  ```

### Error Handling

#### Input Validation
- Validate inputs at the beginning of functions:
  ```matlab
  function simulate_once(config, seed)
      % Validate inputs
      if nargin < 2
          error('simulate_once:missingInput', 'Both config and seed are required');
      end

      if ~isstruct(config)
          error('simulate_once:invalidConfig', 'Config must be a structure');
      end

      if ~isnumeric(seed) || ~isscalar(seed)
          error('simulate_once:invalidSeed', 'Seed must be a numeric scalar');
      end
  end
  ```

#### Try-Catch Blocks
- Use try-catch for critical operations:
  ```matlab
  try
      % Critical operation
      data = load(data_file);
  catch ME
      warning('Failed to load data file: %s', ME.message);
      data = [];  % Provide default value
  end
  ```

## 🧪 Testing Guidelines

### Test Organization

Create tests in the `tests/` directory following this structure:

```
tests/
├── test_basic_simulation.m    % Basic functionality tests
├── test_batch_processing.m    % Batch processing tests
├── test_reproducibility.m    % Reproducibility tests
├── test_visualization.m       % Visualization tests
└── test_config_validation.m   % Configuration validation tests
```

### Test Naming Convention

- Use `test_` prefix for all test files
- Use descriptive names:
  ```matlab
  % Good
  function test_mse_vs_bulk_enhancement()
  function test_diffusion_coefficient_effects()

  % Bad
  function test1()
  function test_mse_bulk()
  ```

### Test Structure

Each test function should follow this structure:

```matlab
function test_feature_name()
    %TEST_FEATURE_NAME - Test description

    %% Setup
    config = default_config();
    test_seed = 1234;

    %% Test execution
    result1 = function_to_test(config, test_seed);

    %% Assert results
    assertTrue(result1.success, 'Test should succeed');
    assertEqual(result1.value, expected_value, 'Value should match expected');

    %% Cleanup (if needed)
    % Clean up temporary files, etc.
end
```

### Test Categories

#### Unit Tests
- Test individual functions in isolation
- Mock external dependencies when necessary
- Fast to execute

#### Integration Tests
- Test multiple components working together
- Use real configurations
- Slower than unit tests

#### Performance Tests
- Test execution time and memory usage
- Compare performance across different parameter sets
- Ensure optimizations don't break functionality

### Running Tests

```matlab
% Run all tests
cd('tests');
runtests;

% Run specific test file
runtests('test_basic_simulation.m');

% Run tests with coverage
results = runtests('tests', 'CodeCoverage', 'on');
disp(results);
```

## 📚 Documentation Guidelines

### Inline Documentation

- Use MATLAB's built-in help system
- Include:
  - Function purpose
  - Input/output descriptions
  - Usage examples
  - See also references

### README Updates

When adding new features:
1. Update the main README.md
2. Update README.zh-CN.md if applicable
3. Add new examples to the Examples section
4. Update the table of contents if needed

### Code Comments

- **Algorithm Documentation**: Explain complex mathematical operations
- **Configuration Notes**: Explain parameter choices and their effects
- **Performance Notes**: Mention optimization considerations

### Theory Documentation

Update theoretical documentation in `docs/`:
- `docs/2d_model_theory.md`
- `docs/2d_model_theory.en.md`

Include:
- Mathematical formulations
- Physical assumptions
- Implementation details
- References to literature

## 🐛 Reporting Issues

### Issue Template

When reporting issues, use this template:

```markdown
## Issue Type
- Bug Report
- Feature Request
- Documentation Improvement
- Question

## Environment
- MATLAB Version: [e.g., R2023a]
- Operating System: [e.g., Windows 11, macOS 13.0]
- Project Commit: [e.g., abc1234]

## Description
[Detailed description of the issue or request]

## Steps to Reproduce (for bugs)
1. [First step]
2. [Second step]
3. [Third step]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Error Messages (if any)
```
Error messages or stack traces here
```

## Additional Context
[Any other relevant information]
```

### Bug Reports

Include:
- Minimal reproduction example
- Expected vs actual behavior
- Error messages and stack traces
- Configuration used
- MATLAB version and OS

### Feature Requests

Include:
- Problem description
- Proposed solution
- Use cases
- Expected impact

### Questions

- Be specific about what you need help with
- Include what you've already tried
- Provide relevant code snippets

## 📤 Submitting Pull Requests

### PR Template

```markdown
## Pull Request Type
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation improvement
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Tests

## Description
[Detailed description of changes]

## Changes Made
- [ ] Added new functionality
- [ ] Fixed bugs
- [ ] Updated documentation
- [ ] Added/updated tests
- [ ] Improved performance

## Related Issues
[Link to related GitHub issues]

## Testing Performed
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing performed
- [ ] Performance testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Tests are added/updated
- [ ] No breaking changes
- [ ] Ready for review
```

### PR Requirements

Before submitting a PR:

1. **Update Documentation**
   - Update relevant README files
   - Add inline comments where necessary
   - Update theory documentation if applicable

2. **Write Tests**
   - Add unit tests for new functionality
   - Ensure all existing tests pass
   - Add integration tests for complex features

3. **Code Quality**
   - Follow coding style guidelines
   - Remove debug code and console output
   - Ensure no warnings in MATLAB

4. **Performance**
   - Test with different parameter sets
   - Ensure no performance regression
   - Profile if making performance changes

## 👀 Review Process

### Review Criteria

Reviewers will check for:

#### Code Quality
- Follows coding standards
- No magic numbers or hardcoded values
- Proper error handling
- Clean, readable code

#### Functionality
- Works as intended
- No breaking changes
- Backward compatibility maintained
- Edge cases handled

#### Testing
- Comprehensive test coverage
- Tests pass reliably
- Performance considerations

#### Documentation
- Clear function documentation
- Updated README files
- Examples provided
- Theory documentation updated

### Review Timeline

- **Initial Review**: Within 2-3 business days
- **Feedback Response**: Within 1 week
- **Final Review**: Within 2 business days of requested changes

### Merge Process

1. **Automated Checks** must pass
2. **At least one reviewer approval** required
3. **All review comments addressed**
4. **Documentation updated**
5. **Tests passing**

## 🏆 Recognition

### Contributor Recognition

- Contributors will be acknowledged in release notes
- Significant contributions may include co-authorship
- Contributors are credited in the AUTHORS file

### Release Notes

Format for contributions:
```
### Added/Changed/Fixed
- [Description of contribution] contributed by [@username](https://github.com/username)
```

## 📞 Getting Help

If you need help with contributing:

1. **GitHub Discussions**: Use for general questions
2. **GitHub Issues**: Use for specific bugs or features
3. **Email Contact**: Available for sensitive matters

## 🎯 Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on technical merit
- Help newcomers get started

### Communication

- Use clear, descriptive language
- Provide context and background
- Be patient with responses
- Assume good intentions

---

Thank you for contributing to the 2D Enzyme Cascade Simulation project! Your efforts help improve this scientific computing tool for the research community.