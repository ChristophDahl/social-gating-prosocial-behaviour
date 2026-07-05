function make_Fig2_failure_decomposition(projectRoot)
%MAKE_FIG2_FAILURE_DECOMPOSITION Render manuscript Figure 2.
%
% Figure 2: failure decomposition by task preset, averaged across parameter
% presets.
%
% This script reads existing CSV files. It does not rerun the simulation.
%
% Expected input file:
%   <projectRoot>/results/summary_by_task_and_system.csv
%
% Output files:
%   <projectRoot>/figures/Fig2_failure_decomposition.png
%   <projectRoot>/figures/Fig2_failure_decomposition.pdf
%
% Usage:
%   make_Fig2_failure_decomposition
%   make_Fig2_failure_decomposition('I:\yourProjectFolder')

if nargin < 1 || isempty(projectRoot)
    projectRoot = inferProjectRoot();
end

resultsDir = fullfile(projectRoot, 'results');
figDir     = fullfile(projectRoot, 'figures');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

summaryFile = fullfile(resultsDir, 'summary_by_task_and_system.csv');
assert(exist(summaryFile, 'file') == 2, 'Missing file: %s', summaryFile);

summaryTbl = readtable(summaryFile);
summaryTbl.task         = string(summaryTbl.task);
summaryTbl.socialSystem = string(summaryTbl.socialSystem);

cfg = localFigureConfig();

taskKeep = orderedPresent(cfg.taskOrder, unique(summaryTbl.task));
taskLabels = labelsFor(taskKeep, cfg.taskOrder, cfg.taskLabels);

% Check which failure columns exist.
missingVars = setdiff(cfg.failureVars, summaryTbl.Properties.VariableNames);
if ~isempty(missingVars)
    error('Missing failure-decomposition columns: %s', strjoin(missingVars, ', '));
end

% Average over parameter presets.
F = nan(numel(taskKeep), numel(cfg.failureVars));

for i = 1:numel(taskKeep)
    idxTask = summaryTbl.task == taskKeep(i);
    for k = 1:numel(cfg.failureVars)
        F(i,k) = mean(summaryTbl.(cfg.failureVars{k})(idxTask), 'omitnan');
    end
end

% Numerical protection: keep tiny floating-point deviations from causing
% stacked bars to exceed one visually.
F(F < 0 & F > -1e-12) = 0;
F(F > 1 & F < 1 + 1e-12) = 1;

% -------------------------------------------------------------------------
% Plot.
% -------------------------------------------------------------------------
fig = figure('Color', 'w', 'Position', [200 200 750 350], 'Renderer', 'painters');

ax = axes(fig);
b = bar(ax, F, 'stacked', 'BarWidth', cfg.barWidth);
applyBarStyle(b, cfg.failureColors);

ylim(ax, [0 1]);
ylabel(ax, 'Proportion of trials in class');
xticks(ax, 1:numel(taskKeep));
xticklabels(ax, taskLabels);
xtickangle(ax, cfg.tickAngle);
xlim(ax, [0.5 numel(taskKeep) + 0.5]);

applyAxisStyle(ax, cfg);

lgd = legend(ax, cfg.failureLabels, 'Location', 'eastoutside', ...
             'Interpreter', 'none', 'Box', 'off');
lgd.FontSize = cfg.fontSize;

exportFigure(fig, fullfile(figDir, 'Fig2'));

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

% These columns sum to one in the current simulation output.
cfg.failureVars = { ...
    'successRate', ...
    'needFailureRate', ...
    'affordanceFailureRate', ...
    'costCompetitionOverrideRate', ...
    'valuationNoHelpRate', ...
    'falsePositiveBiasRate'};

cfg.failureLabels = { ...
    'Realised helping', ...
    'Need inference failed', ...
    'Affordance failed', ...
    'Cost/competition override', ...
    'Valuation no-help', ...
    'False-positive bias'};

% Restrained categorical palette for stacked classes.
cfg.failureColors = [
    0.28 0.48 0.34   % realised helping: muted green
    0.22 0.36 0.55   % need inference: muted blue
    0.62 0.45 0.18   % affordance: muted ochre
    0.55 0.22 0.22   % cost/competition: muted red-brown
    0.45 0.45 0.45   % valuation no-help: grey
    0.45 0.32 0.55   % false-positive bias: muted purple
];

cfg.fontName      = 'Arial';
cfg.fontSize      = 8;
cfg.axisLineWidth = 0.75;
cfg.barWidth      = 0.74;
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

function exportFigure(fig, outBase)
try
    exportgraphics(fig, [outBase '.png'], 'Resolution', 600);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType', 'vector');
catch
    print(fig, [outBase '.png'], '-dpng', '-r600');
    print(fig, [outBase '.pdf'], '-dpdf', '-painters');
end
end
