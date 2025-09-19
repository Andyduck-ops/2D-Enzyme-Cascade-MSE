function fig = plot_reaction_rate_analysis(results, config)
% PLOT_REACTION_RATE_ANALYSIS 绘制反应速率分析图
% 用法:
%   fig = plot_reaction_rate_analysis(results, config)
% 依赖:
%   - 美学规范: [viz_style()](./viz_style.m:1)
% 输入:
%   - results: [simulate_once()](../sim_core/simulate_once.m:1) 的输出
%   - config:  全局配置 [default_config()](../config/default_config.m:1)
%
% 行为:
%   - 上半部分: 绘制GOx与HRP的平滑瞬时速率曲线
%   - 下半部分: 对HRP速率尝试指数衰减拟合 y = A*exp(-k*t)，无法拟合时降级为原始曲线展示

time_axis = getfield_or(results, 'time_axis', []);
rate_gox  = getfield_or(results, 'reaction_rate_gox', []); 
rate_hrp  = getfield_or(results, 'reaction_rate_hrp', []);

fig = figure('Name', 'Reaction Rate Analysis', 'Color', 'w', 'Position', [100, 50, 700, 800]); 
% 使用 subplot 提升版本兼容性
figure(fig); % 确保当前图为 fig
ax1 = subplot(2, 1, 1); % 上半区

viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light'); 

% ---------------- 上: 平滑瞬时速率 ----------------
% ax1 = nexttile(tlo, 1);
viz_style(ax1, config.font_settings, viz_theme, config.plot_colors); % [viz_style()](./viz_style.m:1)
hold(ax1, 'on');

if ~isempty(time_axis) && ~isempty(rate_gox) && ~isempty(rate_hrp)
    sg = local_smooth(rate_gox);
    sh = local_smooth(rate_hrp);
    plot(ax1, time_axis, sg, 'LineWidth', 1.5, 'Color', config.plot_colors.GOx, 'DisplayName', 'GOx Rate'); 
    plot(ax1, time_axis, sh, 'LineWidth', 1.5, 'Color', config.plot_colors.HRP, 'DisplayName', 'HRP Rate'); 
    xlabel(ax1, 'Time (s)');	
    ylabel(ax1, 'Instantaneous Rate (reactions/s)'); 
    title(ax1, 'Instantaneous Reaction Rate (Smoothed)'); 
    legend(ax1, 'Location', 'northeast');
else
    text(0.5, 0.5, 'No rate data', 'HorizontalAlignment', 'center', 'Parent', ax1);
    axis(ax1, 'off'); 
end
hold(ax1, 'off'); 

% ---------------- 下: HRP指数拟合 ----------------
figure(fig);
ax2 = subplot(2, 1, 2);

viz_style(ax2, config.font_settings, viz_theme, config.plot_colors);

enable_fit = getfield_or(config, {'analysis_switches','enable_rate_fitting_plot'}, true);
if enable_fit && ~isempty(time_axis) && ~isempty(rate_hrp)
    rate_hrp_s = local_smooth(rate_hrp);
    hold(ax2, 'on');
    scatter(ax2, time_axis, rate_hrp_s, 16, 'MarkerFaceColor', config.plot_colors.HRP, ...
        'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.6, 'DisplayName', 'Smoothed HRP Rate'); 

    % 拟合 y = A*exp(-k*t)
    did_fit = false; Afit = NaN; kfit = NaN;
    try
        % 尝试使用 Curve Fitting Toolbox
        fit_model = fittype('A*exp(-k*x)', 'independent', 'x', 'dependent', 'y');
        x = time_axis(:); y = rate_hrp_s(:);
        % 过滤非正数据以避免log问题:
        y(y < 0) = 0;
        startA = max(y);
        if ~isfinite(startA) || startA <= 0, startA = 1; end
        startk = 1 / max(time_axis(end), eps);
        fr = fit(x, y, fit_model, 'StartPoint', [startA, startk]); Afit = fr.A; kfit = fr.k;
        xfine = linspace(min(x), max(x), 400).';
        yfit = Afit * exp(-kfit * xfine);
        plot(ax2, xfine, yfit, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Fit: A=%.2f, k=%.4f', Afit, kfit));
        did_fit = true;
    catch

        % 回退到对数线性近似拟合
        try
            x = time_axis(:); y = rate_hrp_s(:);
            % 仅使用正的y点
            mask = y > max(1e-9, 0); 
            x = x(mask); y = y(mask);
            if numel(x) >= 3
                p = polyfit(x, log(y), 1); % log(y)=b + m*x  => y=exp(b)*exp(m*x)
                kfit = -p(1); Afit = exp(p(2));
                xfine = linspace(min(time_axis), max(time_axis), 400).';
                yfit = Afit * exp(-kfit * xfine);
                plot(ax2, xfine, yfit, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Fit: A=%.2f, k=%.4f', Afit, kfit)); 
                did_fit = true;
            end
        catch
            % 继续降级
        end
    end

    if ~did_fit
        % 无法拟合则仅绘制平滑曲线
        plot(ax2, time_axis, rate_hrp_s, 'Color', config.plot_colors.HRP, 'LineWidth', 1.5, 'DisplayName', 'HRP Rate'); 
    end

    xlabel(ax2, 'Time (s)');
    ylabel(ax2, 'Instantaneous Rate (reactions/s)'); 
    title(ax2, 'HRP Reaction Rate with Exponential Fit'); 
    legend(ax2, 'Location', 'northeast');
    hold(ax2, 'off'); 
else
    text(0.5, 0.5, 'Fitting disabled or no HRP data', 'HorizontalAlignment', 'center', 'Parent', ax2);
    axis(ax2, 'off'); 
end

end

% ---------------- 辅助: 平滑函数 ----------------
function y = local_smooth(x)
% 优先使用 smooth, 不可用则用 movmean 51点窗口
x = x(:);
try
    y = smooth(x, 51);
catch
    w = min(51, max(3, 2*floor(numel(x)/20)+1)); % 自适应奇数窗口
    y = movmean(x, w);
end
end