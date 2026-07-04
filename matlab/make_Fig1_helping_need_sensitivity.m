function make_Fig1_helping_need_sensitivity(projectRoot)
%MAKE_FIG1_HELPING_NEED_SENSITIVITY Render manuscript Figure 1.
%
% Figure 1A: realised helping across task regimes.
% Figure 1B: counterfactual need sensitivity across task regimes.
%
% This script reads existing CSV files. It does not rerun the simulation.
%
% Expected input files:
%   <projectRoot>/results/summary_by_task_and_system.csv
%   <projectRoot>/results/counterfactual_need_effect.csv
%
% Output files:
%   <projectRoot>/figures/Fig1_helping_and_need_sensitivity.png
%   <projectRoot>/figures/Fig1_helping_and_need_sensitivity.pdf
%
% Usage:
%   make_Fig1_helping_need_sensitivity
%   make_Fig1_helping_need_sensitivity('I:\yourProjectFolder')

if nargin < 1 || isempty(projectRoot)
    projectRoot = inferProjectRoot();
end

resultsDir = fullfile(projectRoot, 'results');
figDir     = fullfile(projectRoot, 'figures');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

summaryFile = fullfile(resultsDir, 'summary_by_task_and_system.csv');
cfFile      = fullfile(resultsDir, 'counterfactual_need_effect.csv');

assert(exist(summaryFile, 'file') == 2, 'Missing file: %s', summaryFile);
assert(exist(cfFile, 'file') == 2, 'Missing file: %s', cfFile);

summaryTbl = readtable(summaryFile);
cfTbl      = readtable(cfFile);

summaryTbl.task         = string(summaryTbl.task);
summaryTbl.socialSystem = string(summaryTbl.socialSystem);
cfTbl.task              = string(cfTbl.task);
cfTbl.socialSystem      = string(cfTbl.socialSystem);

cfg = localFigureConfig();

taskKeep   = orderedPresent(cfg.taskOrder, unique(summaryTbl.task));
systemKeep = orderedPresent(cfg.systemOrder, unique(summaryTbl.socialSystem));

taskLabels   = labelsFor(taskKeep, cfg.taskOrder, cfg.taskLabels);
systemLabels = labelsFor(systemKeep, cfg.systemOrder, cfg.systemLabels);

% -------------------------------------------------------------------------
% Panel A: realised helping.
% -------------------------------------------------------------------------
Yhelp = nan(numel(taskKeep), numel(systemKeep));

for i = 1:numel(taskKeep)
    for j = 1:numel(systemKeep)
        idx = summaryTbl.task == taskKeep(i) & summaryTbl.socialSystem == systemKeep(j);
        if any(idx)
            Yhelp(i,j) = summaryTbl.helpingRate(find(idx, 1, 'first'));
        end
    end
end

% -------------------------------------------------------------------------
% Panel B: counterfactual need sensitivity.
% -------------------------------------------------------------------------
if any(strcmp(cfTbl.Properties.VariableNames, 'counterfactualNeedOnlyEffect'))
    cfVar = 'counterfactualNeedOnlyEffect';
elseif any(strcmp(cfTbl.Properties.VariableNames, 'counterfactualNeedEffect'))
    cfVar = 'counterfactualNeedEffect';
else
    error(['counterfactual_need_effect.csv must contain either ', ...
           'counterfactualNeedOnlyEffect or counterfactualNeedEffect.']);
end

Ycf = nan(numel(taskKeep), numel(systemKeep));

for i = 1:numel(taskKeep)
    for j = 1:numel(systemKeep)
        idx = cfTbl.task == taskKeep(i) & cfTbl.socialSystem == systemKeep(j);
        if any(idx)
            Ycf(i,j) = cfTbl.(cfVar)(find(idx, 1, 'first'));
        end
    end
end

% -------------------------------------------------------------------------
% Plot.
% -------------------------------------------------------------------------
fig = figure('Color', 'w', 'Position', [100 100 900 700], 'Renderer', 'painters');

tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% Panel A.
ax1 = nexttile(tl, 1);
b1 = bar(ax1, Yhelp, 'grouped', 'BarWidth', cfg.barWidth);
applyBarStyle(b1, cfg.regimeColors);
ylim(ax1, [0 1]);
ylabel(ax1, 'Proportion of trials with realised helping');
setTaskAxis(ax1, taskLabels);
applyAxisStyle(ax1, cfg);
panelLabel(ax1, 'A');

% Panel B.
ax2 = nexttile(tl, 2);
b2 = bar(ax2, Ycf, 'grouped', 'BarWidth', cfg.barWidth);
applyBarStyle(b2, cfg.regimeColors);
ylabel(ax2, '\Delta P(help): high need - low need');
setTaskAxis(ax2, taskLabels);
applyAxisStyle(ax2, cfg);
yline(ax2, 0, '-', 'Color', [0 0 0], 'LineWidth', cfg.axisLineWidth);
setCounterfactualLimits(ax2, Ycf);
panelLabel(ax2, 'B');

lgd = legend(ax2, b2, systemLabels, 'Location', 'southoutside', ...
             'Orientation', 'horizontal', 'Interpreter', 'none', 'Box', 'off');
lgd.FontSize = cfg.fontSize;

exportFigure(fig, fullfile(figDir, 'Fig1'));

end

% =========================================================================
% Local helper functions.
% =========================================================================

function projectRoot = inferProjectRoot()
scriptDir = fileparts(mfilename('fullpath'));
[~, folderName] = fileparts(scriptDir);

if strcmpi(folderName, 'matlab')
    projectRoot = fileparts(scriptDir);
else
    projectRoot = scriptDir;
end
end

function cfg = localFigureConfig()
cfg.taskOrder = string({ ...
    'instrumental_reaching', ...
    'visible_tool_transfer', ...
    'hidden_tool_transfer', ...
    'food_token_randomised', ...
    'food_token_fixed_position', ...
    'apparatus_bias_no_benefit', ...
    'low_competition_provisioning', ...
    'high_cost_help', ...
    'dominance_risk_help', ...
    'reliable_partner_collaboration'});

cfg.taskLabels = { ...
    'Instrumental', ...
    'Visible tool', ...
    'Hidden tool', ...
    'Food token rand.', ...
    'Food token fixed', ...
    'Bias/no benefit', ...
    'Provisioning', ...
    'High-cost', ...
    'Dominance-risk', ...
    'Collaboration'};

cfg.systemOrder = string({ ...
    'modOther_highComp', ...
    'highOther_modComp', ...
    'highOther_lowComp', ...
    'lowOther_weight', ...
    'pureSelf'});

cfg.systemLabels = { ...
    'Moderate other / high competition', ...
    'High other / moderate competition', ...
    'High other / low competition', ...
    'Low other', ...
    'Pure self-interest'};

% Restrained colour palette: muted, dark, publication-oriented.
cfg.regimeColors = [
    0.10 0.10 0.10   % near black
    0.22 0.36 0.55   % muted blue
    0.28 0.48 0.34   % muted green
    0.62 0.45 0.18   % muted ochre
    0.55 0.22 0.22   % muted red-brown
];

cfg.fontName      = 'Arial';
cfg.fontSize      = 8;
cfg.axisLineWidth = 0.75;
cfg.barWidth      = 0.70;
cfg.tickAngle     = 35;
cfg.exportDPI     = 600;
end

function keep = orderedPresent(order, present)
keep = order(ismember(order, present));
end

function labs = labelsFor(keep, order, allLabels)
labs = cell(1, numel(keep));
for i = 1:numel(keep)
    idx = find(order == keep(i), 1, 'first');
    labs{i} = allLabels{idx};
end
end

function applyBarStyle(b, colors)
for k = 1:numel(b)
    cidx = min(k, size(colors, 1));
    b(k).FaceColor = colors(cidx, :);
    b(k).EdgeColor = 'none';
end
end

function setTaskAxis(ax, taskLabels)
xticks(ax, 1:numel(taskLabels));
xticklabels(ax, taskLabels);
xtickangle(ax, 35);
xlim(ax, [0.5 numel(taskLabels) + 0.5]);
end

function applyAxisStyle(ax, cfg)
set(ax, ...
    'Box', 'off', ...
    'TickDir', 'out', ...
    'LineWidth', cfg.axisLineWidth, ...
    'FontName', cfg.fontName, ...
    'FontSize', cfg.fontSize, ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'Layer', 'top', ...
    'TickLabelInterpreter', 'none');
ax.TickLength = [0.005 0.005];
end

function setCounterfactualLimits(ax, Y)
vals = Y(:);
vals = vals(~isnan(vals));

if isempty(vals)
    ylim(ax, [-0.05 0.05]);
    return;
end

lo = min(vals);
hi = max(vals);
pad = 0.10 * max(abs([lo hi 0.05]));

if lo >= 0
    ylim(ax, [0 max(0.05, hi + pad)]);
else
    m = max(abs([lo hi 0.05]));
    ylim(ax, [-m - pad, m + pad]);
end
end

function panelLabel(ax, lab)
text(ax, -0.05, 1.06, lab, ...
    'Units', 'normalized', ...
    'FontName', 'Arial', ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top');
end

function exportFigure(fig, outBase)
try
    exportgraphics(fig, [outBase '.png'], 'Resolution', 600);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType', 'vector');
catch
    print(fig, [outBase '.png'], '-dpng', '-r600');
    print(fig, [outBase '.pdf'], '-dpdf', '-painters');
end
end
