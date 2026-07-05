function make_FigS1_failure_decomposition_by_system(projectRoot)
%MAKE_FIGS1_FAILURE_DECOMPOSITION_BY_SYSTEM Render the sole supplementary figure.
%
% This function renders the non-averaged failure decomposition by task preset
% and parameter preset. It is intended to replace the broader supplementary
% figure pipeline when only the failure-decomposition figure is retained.
%
% Expected input:
%   <projectRoot>/results/summary_by_task_and_system.csv
%
% Output:
%   <projectRoot>/figures/supplement/FigS1_failure_decomposition_by_system.png
%   <projectRoot>/figures/supplement/FigS1_failure_decomposition_by_system.pdf
%
% Usage:
%   cd('I:\helpingBehaviour\programs')
%   addpath(genpath(pwd))
%   make_FigS1_failure_decomposition_by_system('I:\helpingBehaviour')
%
% To preserve the old numbering, change figStem below from
% 'FigS1_failure_decomposition_by_system' to
% 'FigS3_failure_decomposition_by_system'.

if nargin < 1 || isempty(projectRoot)
    projectRoot = inferProjectRoot();
end

resultsDir = fullfile(projectRoot, 'results');
figDir     = fullfile(projectRoot, 'figures', 'supplement');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

figStem = 'SupFig1';

summaryFile = fullfile(resultsDir, 'summary_by_task_and_system.csv');
assert(exist(summaryFile, 'file') == 2, 'Missing file: %s', summaryFile);

tbl = readtable(summaryFile);

taskVar   = findVar(tbl, {'task','taskRegime','regime'}, true, summaryFile);
systemVar = findVar(tbl, {'socialSystem','system','parameterRegime','paramRegime'}, true, summaryFile);

tbl.(taskVar)   = string(tbl.(taskVar));
tbl.(systemVar) = string(tbl.(systemVar));

cfg = localFigureConfig();

taskKeep   = orderedPresent(cfg.taskOrder, unique(tbl.(taskVar)));
systemKeep = orderedPresent(cfg.systemOrder, unique(tbl.(systemVar)));

taskLabels   = labelsFor(taskKeep, cfg.taskOrder, cfg.taskLabels);
systemLabels = labelsFor(systemKeep, cfg.systemOrder, cfg.systemLabels);

classSpecs = {
    {'helpingRate','realisedHelpingRate','realizedHelpingRate'}, ...
    'Realised helping';
    {'needFailureRate','needDetectionFailureRate','needInferenceFailureRate'}, ...
    'Need failure';
    {'affordanceFailureRate','affordanceRecognitionFailureRate'}, ...
    'Affordance failure';
    {'costCompetitionOverrideRate','costOrCompetitionOverrideRate','costOverrideRate','competitionOverrideRate'}, ...
    'Cost/competition override';
    {'valuationNoHelpRate','valuationFailureRate','valuationBasedNoHelpRate','noHelpValuationRate'}, ...
    'Valuation no-help';
    {'falsePositiveRate','taskBiasFalsePositiveRate','biasFalsePositiveRate'}, ...
    'False positive'
};

classVars   = strings(0, 1);
classLabels = {};

for c = 1:size(classSpecs, 1)
    thisVar = findVar(tbl, classSpecs{c, 1}, false, summaryFile);
    if thisVar ~= ""
        classVars(end+1, 1) = thisVar; %#ok<AGROW>
        classLabels{end+1} = classSpecs{c, 2}; %#ok<AGROW>
    end
end

if numel(classVars) < 2
    error(['Too few decomposition columns were found. ', ...
           'Expected columns such as helpingRate, needFailureRate, ', ...
           'affordanceFailureRate, costCompetitionOverrideRate, ', ...
           'valuationNoHelpRate, falsePositiveRate. Available variables are: %s'], ...
           strjoin(tbl.Properties.VariableNames, ', '));
end

% -------------------------------------------------------------------------
% Manual layout, rather than tiledlayout, gives stable legend placement in
% older MATLAB versions. The legend is placed outside, below the lowest
% subplot.
% -------------------------------------------------------------------------
nPanels = numel(systemKeep);

fig = figure('Color', 'w', ...
    'Position', [80 80 1050 1450], ...
    'Renderer', 'painters');

leftMargin   = 0.075;
rightMargin  = 0.025;
topMargin    = 0.035;
bottomMargin = 0.125;   % reserved for lowest x labels and legend
panelGap     = 0.026;

panelHeight = (1 - topMargin - bottomMargin - (nPanels - 1) * panelGap) / nPanels;
panelWidth  = 1 - leftMargin - rightMargin;

axAll = gobjects(nPanels, 1);
legendHandles = [];

for s = 1:nPanels
    y0 = 1 - topMargin - s * panelHeight - (s - 1) * panelGap;
    ax = axes('Parent', fig, 'Position', [leftMargin y0 panelWidth panelHeight]); %#ok<LAXES>
    axAll(s) = ax;

    Y = nan(numel(taskKeep), numel(classVars));

    for i = 1:numel(taskKeep)
        idx = tbl.(taskVar) == taskKeep(i) & tbl.(systemVar) == systemKeep(s);
        if any(idx)
            r = find(idx, 1, 'first');
            for c = 1:numel(classVars)
                Y(i, c) = tbl.(classVars(c))(r);
            end
        end
    end

    b = bar(ax, Y, 'stacked', 'BarWidth', cfg.barWidth);
    applyBarStyle(b, cfg.failureColors);

    if isempty(legendHandles)
        legendHandles = b;
    end

    ylim(ax, [0 1.05]);
    xlim(ax, [0.5 numel(taskKeep) + 0.5]);
    ylabel(ax, 'Proportion');
    title(ax, systemLabels{s}, ...
        'Interpreter', 'none', ...
        'FontWeight', 'normal', ...
        'FontSize', cfg.fontSize + 1);

    xticks(ax, 1:numel(taskKeep));
    xticklabels(ax, taskLabels);

    if s < nPanels
        xticklabels(ax, repmat({''}, 1, numel(taskKeep)));
    else
        xtickangle(ax, cfg.tickAngle);
    end

    applyAxisStyle(ax, cfg);
end

% Legend outside and below the lowest panel.
lgd = legend(axAll(end), legendHandles, classLabels, ...
    'Orientation', 'horizontal', ...
    'Interpreter', 'none', ...
    'Box', 'off');

lgd.Units = 'normalized';
lgd.Position = [0.15 0.035 0.72 0.045];
lgd.FontSize = cfg.fontSize;

exportFigure(fig, fullfile(figDir, figStem));
close(fig);

fprintf('Rendered supplementary failure-decomposition figure:\n  %s\n', ...
    fullfile(figDir, [figStem '.png']));

end

% =========================================================================
% Local helper functions.
% =========================================================================

function projectRoot = inferProjectRoot()
scriptDir = fileparts(mfilename('fullpath'));
[~, folderName] = fileparts(scriptDir);

if strcmpi(folderName, 'matlab') || strcmpi(folderName, 'programs')
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

cfg.failureColors = [
    0.28 0.48 0.34   % realised helping: muted green
    0.22 0.36 0.55   % need failure: muted blue
    0.62 0.45 0.18   % affordance failure: muted ochre
    0.55 0.22 0.22   % cost/competition override: muted red-brown
    0.45 0.45 0.45   % valuation no-help: grey
    0.45 0.32 0.55   % false positive: muted purple
];

cfg.fontName      = 'Arial';
cfg.fontSize      = 8;
cfg.axisLineWidth = 0.75;
cfg.barWidth      = 0.74;
cfg.tickAngle     = 35;
cfg.exportDPI     = 600;

end

function keep = orderedPresent(order, present)
present = string(present);
keep = order(ismember(order, present));
end

function labs = labelsFor(keep, order, allLabels)
labs = cell(1, numel(keep));
for i = 1:numel(keep)
    idx = find(order == keep(i), 1, 'first');
    labs{i} = allLabels{idx};
end
end

function varName = findVar(tbl, candidates, required, context)
vars = string(tbl.Properties.VariableNames);
candidates = string(candidates);

for i = 1:numel(candidates)
    idx = find(strcmpi(vars, candidates(i)), 1, 'first');
    if ~isempty(idx)
        varName = vars(idx);
        return;
    end
end

varName = "";

if required
    error('Required variable not found in %s. Tried: %s. Available variables are: %s', ...
        context, strjoin(candidates, ', '), strjoin(vars, ', '));
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
