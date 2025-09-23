function fig = plot_reaction_rate_analysis(results, config)
% PLOT_REACTION_RATE_ANALYSIS Plot reaction rate diagnostics.
% Usage:
%   fig = plot_reaction_rate_analysis(results, config)
% Dependencies:
%   - viz_style() (./viz_style.m:1)
% Inputs:
%   - results: output struct from simulate_once() (../sim_core/simulate_once.m:1)
%   - config: configuration struct from default_config()/interactive_config()
%
% Panels:
%   - Upper panel: smoothed instantaneous GOx and HRP reaction rates.
%   - Lower panel: exponential decay fit y = A*exp(-k*t) on HRP rate (fallback to raw data when fitting fails).

time_axis = getfield_or(results, 'time_axis', []);
rate_gox  = getfield_or(results, 'reaction_rate_gox', []); 
rate_hrp  = getfield_or(results, 'reaction_rate_hrp', []);

fig = figure('Name', 'Reaction Rate Analysis', 'Color', 'w', 'Position', [100, 50, 700, 800]); 
% Arrange subplots for the analysis views
figure(fig); % Ensure the target figure is active
ax1 = subplot(2, 1, 1); % Upper panel

viz_theme = getfield_or(config, {'ui_controls','theme'}, 'light'); 

% ---------------- Upper: instantaneous rates ----------------
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

% ---------------- Lower: HRP exponential fit ----------------
figure(fig);
ax2 = subplot(2, 1, 2); % Lower panel

viz_style(ax2, config.font_settings, viz_theme, config.plot_colors);

enable_fit = getfield_or(config, {'analysis_switches','enable_rate_fitting_plot'}, true);
if enable_fit && ~isempty(time_axis) && ~isempty(rate_hrp)
    rate_hrp_s = local_smooth(rate_hrp);
    hold(ax2, 'on');
    scatter(ax2, time_axis, rate_hrp_s, 16, 'MarkerFaceColor', config.plot_colors.HRP, ...
        'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.6, 'DisplayName', 'Smoothed HRP Rate'); 

    % Fit y = A*exp(-k*t)
    did_fit = false; Afit = NaN; kfit = NaN;
    try
        % Prefer Curve Fitting Toolbox when available
        fit_model = fittype('A*exp(-k*x)', 'independent', 'x', 'dependent', 'y');
        x = time_axis(:); y = rate_hrp_s(:);
        % Guard against log transform issues
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

        % Fallback: use log-linear least squares
        try
            x = time_axis(:); y = rate_hrp_s(:);
            % Keep only positive rate values
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
            % Fitting failed
        end
    end

    if ~did_fit
        % Fit unavailable; plot HRP rate only
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

% ---------------- Helper: smoothing ----------------
function y = local_smooth(x)
% Use smooth when available; otherwise fall back to movmean with a 51-point window
x = x(:);
try
    y = smooth(x, 51);
catch
    w = min(51, max(3, 2*floor(numel(x)/20)+1)); % Choose window size relative to data length
    y = movmean(x, w);
end
end
