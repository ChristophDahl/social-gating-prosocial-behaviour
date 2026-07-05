function sg_plotResults_v2(summaryTbl, data, cfTbl, llTbl, figDir, cfg)
%SG_PLOTRESULTS_V2 Publication-oriented diagnostic plots.
%
% Produces manuscript-style grayscale figures from existing summary tables.
% The false-positive diagnostic figure is disabled by default because it is
% currently described in text rather than used as a manuscript figure.
%
% Outputs:
%   helping_rate_by_task_v2.png
%   failure_decomposition_by_task_v2.png
%   failure_decomposition_<system>.png
%   counterfactual_need_effect.png
%   model_ablation_delta_score_<system>.png
%
% Optional output, only if cfg.makeFalsePositiveFigure = true:
%   false_positive_diagnostic.png

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

summaryTbl.task = string(summaryTbl.task);
summaryTbl.socialSystem = string(summaryTbl.socialSystem);

if ~isempty(data)
    data.task = string(data.task);
    data.socialSystem = string(data.socialSystem);
end

if ~isempty(cfTbl)
    cfTbl.task = string(cfTbl.task);
    cfTbl.socialSystem = string(cfTbl.socialSystem);
end

if ~isempty(llTbl)
    llTbl.socialSystem = string(llTbl.socialSystem);
    llTbl.modelVariant = string(llTbl.modelVariant);
end

taskOrder   = string(cfg.taskOrder);
systemOrder = string(cfg.systemOrder);

taskKeep   = taskOrder(ismember(taskOrder, unique(summaryTbl.task)));
systemKeep = systemOrder(ismember(systemOrder, unique(summaryTbl.socialSystem)));

% Prefer clean manuscript labels here, rather than relying on older config labels.
taskLabels    = prettyTaskLabels(taskKeep);
systemLabels  = prettySystemLabels(systemKeep);
failureLabels = prettyFailureLabels(cfg.failureVars, cfg.failureLabels);

% Restrained grayscale palette. No decorative colour, no bar edges.
grayMap = [
    0.15 0.15 0.15
    0.35 0.35 0.35
    0.55 0.55 0.55
    0.72 0.72 0.72
    0.88 0.88 0.88
];

barWidthGrouped = 0.70;
barWidthStacked = 0.62;
barWidthSingle  = 0.55;

showTitles = isfield(cfg, 'showTitles') && logical(cfg.showTitles);
makeFalsePositiveFigure = isfield(cfg, 'makeFalsePositiveFigure') && logical(cfg.makeFalsePositiveFigure);

%% Figure 1: realised helping by task and parameter preset
Y = nan(numel(taskKeep), numel(systemKeep));

for i = 1:numel(taskKeep)
    for j = 1:numel(systemKeep)
        idx = summaryTbl.task == taskKeep(i) & summaryTbl.socialSystem == systemKeep(j);
        if any(idx)
            Y(i,j) = summaryTbl.helpingRate(find(idx,1,'first'));
        end
    end
end

fig = figure('Color','w','Position',[100 100 1100 560]);
b = bar(Y, 'grouped', 'BarWidth', barWidthGrouped);
applyBarStyle(b, grayMap);

ylim([0 1]);
ylabel('Proportion of trials with realised helping');
if showTitles
    title('Realised helping by task preset');
end
xticks(1:numel(taskKeep));
xticklabels(taskLabels);
xtickangle(32);
leg = legend(systemLabels, 'Location','eastoutside', 'Interpreter','none');
styleLegend(leg);
sg_applyFigureStyle(gca);
safeExport(fig, fullfile(figDir, 'helping_rate_by_task_v2.png'));

%% Figure 2: failure decomposition by task, averaged across parameter presets
F = nan(numel(taskKeep), numel(cfg.failureVars));

for i = 1:numel(taskKeep)
    idxTask = summaryTbl.task == taskKeep(i);
    for k = 1:numel(cfg.failureVars)
        F(i,k) = mean(summaryTbl.(cfg.failureVars{k})(idxTask), 'omitnan');
    end
end

fig = figure('Color','w','Position',[100 100 1100 560]);
b = bar(F, 'stacked', 'BarWidth', barWidthStacked);
applyStackedBarStyle(b);

ylim([0 1]);
ylabel('Proportion of trials in class');
if showTitles
    title('Failure decomposition by task preset');
end
xticks(1:numel(taskKeep));
xticklabels(taskLabels);
xtickangle(32);
leg = legend(failureLabels, 'Location','eastoutside', 'Interpreter','none');
styleLegend(leg);
sg_applyFigureStyle(gca);
safeExport(fig, fullfile(figDir, 'failure_decomposition_by_task_v2.png'));

%% Figure 3: failure decomposition separately for each parameter preset
for j = 1:numel(systemKeep)
    Fsys = nan(numel(taskKeep), numel(cfg.failureVars));

    for i = 1:numel(taskKeep)
        idx = summaryTbl.task == taskKeep(i) & summaryTbl.socialSystem == systemKeep(j);
        for k = 1:numel(cfg.failureVars)
            if any(idx)
                Fsys(i,k) = summaryTbl.(cfg.failureVars{k})(find(idx,1,'first'));
            end
        end
    end

    fig = figure('Color','w','Position',[100 100 1100 560]);
    b = bar(Fsys, 'stacked', 'BarWidth', barWidthStacked);
    applyStackedBarStyle(b);

    ylim([0 1]);
    ylabel('Proportion of trials in class');
    if showTitles
        title(['Failure decomposition: ' systemLabels{j}], 'Interpreter','none');
    end
    xticks(1:numel(taskKeep));
    xticklabels(taskLabels);
    xtickangle(32);
    leg = legend(failureLabels, 'Location','eastoutside', 'Interpreter','none');
    styleLegend(leg);
    sg_applyFigureStyle(gca);

    outName = ['failure_decomposition_' char(systemKeep(j)) '.png'];
    safeExport(fig, fullfile(figDir, outName));
end

%% Optional figure: false-positive diagnostic
% Disabled by default. The manuscript currently explains this result in text
% rather than using it as a separate figure.
if makeFalsePositiveFigure
    falseTask = "apparatus_bias_no_benefit";

    if any(summaryTbl.task == falseTask)
        idx = summaryTbl.task == falseTask & ismember(summaryTbl.socialSystem, systemKeep);
        Tfalse = summaryTbl(idx,:);

        Yfalse = nan(numel(systemKeep), 3);
        for j = 1:numel(systemKeep)
            idxJ = Tfalse.socialSystem == systemKeep(j);
            if any(idxJ)
                Yfalse(j,1) = Tfalse.choiceHelpRate(find(idxJ,1,'first'));
                Yfalse(j,2) = Tfalse.helpingRate(find(idxJ,1,'first'));
                Yfalse(j,3) = Tfalse.falsePositiveRate(find(idxJ,1,'first'));
            end
        end

        fig = figure('Color','w','Position',[100 100 850 500]);
        b = bar(Yfalse, 'grouped', 'BarWidth', barWidthGrouped);
        applyBarStyle(b, grayMap(1:3,:));

        ylim([0 1]);
        ylabel('Proportion of trials');
        if showTitles
            title('Help-like choice without recipient benefit');
        end
        xticks(1:numel(systemKeep));
        xticklabels(systemLabels);
        xtickangle(25);
        leg = legend({'help-like choice','realised helping','false positive'}, ...
                     'Location','eastoutside', 'Interpreter','none');
        styleLegend(leg);
        sg_applyFigureStyle(gca);
        safeExport(fig, fullfile(figDir, 'false_positive_diagnostic.png'));
    end
end

%% Figure 4: counterfactual need effect
hasNeedOnly = ~isempty(cfTbl) && any(strcmp(cfTbl.Properties.VariableNames, 'counterfactualNeedOnlyEffect'));
hasNeed     = ~isempty(cfTbl) && any(strcmp(cfTbl.Properties.VariableNames, 'counterfactualNeedEffect'));

if hasNeedOnly || hasNeed
    Ycf = nan(numel(taskKeep), numel(systemKeep));
    if hasNeedOnly
        cfEffectVar = 'counterfactualNeedOnlyEffect';
        cfTitle = 'Counterfactual need-only sensitivity';
    else
        cfEffectVar = 'counterfactualNeedEffect';
        cfTitle = 'Counterfactual need sensitivity';
    end

    for i = 1:numel(taskKeep)
        for j = 1:numel(systemKeep)
            idx = cfTbl.task == taskKeep(i) & cfTbl.socialSystem == systemKeep(j);
            if any(idx)
                Ycf(i,j) = cfTbl.(cfEffectVar)(find(idx,1,'first'));
            end
        end
    end

    fig = figure('Color','w','Position',[100 100 1100 560]);
    b = bar(Ycf, 'grouped', 'BarWidth', barWidthGrouped);
    applyBarStyle(b, grayMap);

    ylabel('\Delta P(help): high need minus low need');
    if showTitles
        title(cfTitle);
    end
    xticks(1:numel(taskKeep));
    xticklabels(taskLabels);
    xtickangle(32);
    leg = legend(systemLabels, 'Location','eastoutside', 'Interpreter','none');
    styleLegend(leg);
    yline(0, 'k-', 'LineWidth', 0.65);
    sg_applyFigureStyle(gca);
    safeExport(fig, fullfile(figDir, 'counterfactual_need_effect.png'));
end

%% Figure 5: model-ablation score comparison
if ~isempty(llTbl) && any(strcmp(llTbl.Properties.VariableNames, 'AICApprox'))
    modelOrder = ["bias_only", "self_interest", "competition", ...
                  "relationship", "full_social_gating"];

    modelLabels = {'Bias only','Self-interest','Competition', ...
                   'Relationship','Full social-gating'};

    for j = 1:numel(systemKeep)
        idxSys = llTbl.socialSystem == systemKeep(j);
        if ~any(idxSys)
            continue;
        end

        Tll = llTbl(idxSys,:);
        deltaScore = nan(numel(modelOrder),1);

        for m = 1:numel(modelOrder)
            idxM = Tll.modelVariant == modelOrder(m);
            if any(idxM)
                if any(strcmp(Tll.Properties.VariableNames, 'ablationICApprox'))
                    deltaScore(m) = Tll.ablationICApprox(find(idxM,1,'first'));
                else
                    deltaScore(m) = Tll.AICApprox(find(idxM,1,'first'));
                end
            end
        end

        deltaScore = deltaScore - min(deltaScore, [], 'omitnan');

        fig = figure('Color','w','Position',[100 100 720 460]);
        b = bar(deltaScore, 'BarWidth', barWidthSingle);
        b.FaceColor = [0.35 0.35 0.35];
        b.EdgeColor = 'none';

        ylabel('\Delta ablation score');
        if showTitles
            title(['Component-ablation score: ' systemLabels{j}], 'Interpreter','none');
        end
        xticks(1:numel(modelOrder));
        xticklabels(modelLabels);
        xtickangle(25);
        sg_applyFigureStyle(gca);
        safeExport(fig, fullfile(figDir, ...
            ['model_ablation_delta_score_' char(systemKeep(j)) '.png']));
    end
end

end

function labels = prettyTaskLabels(taskKeys)
%PRETTYTASKLABELS Manuscript-friendly task labels.

taskKeys = string(taskKeys);
labels = cell(numel(taskKeys),1);

for i = 1:numel(taskKeys)
    switch taskKeys(i)
        case "instrumental_reaching"
            labels{i} = 'Instrumental';
        case "visible_tool_transfer"
            labels{i} = 'Visible tool';
        case "hidden_tool_transfer"
            labels{i} = 'Hidden tool';
        case "food_token_randomised"
            labels{i} = 'Food token rand.';
        case "food_token_fixed_position"
            labels{i} = 'Food token fixed';
        case "apparatus_bias_no_benefit"
            labels{i} = 'Bias/no benefit';
        case "low_competition_provisioning"
            labels{i} = 'Provisioning';
        case "high_cost_help"
            labels{i} = 'High-cost';
        case "dominance_risk_help"
            labels{i} = 'Dominance-risk';
        case "reliable_partner_collaboration"
            labels{i} = 'Collaboration';
        otherwise
            labels{i} = char(strrep(taskKeys(i), '_', ' '));
    end
end
end

function labels = prettySystemLabels(systemKeys)
%PRETTYSYSTEMLABELS Manuscript-friendly parameter-preset labels.

systemKeys = string(systemKeys);
labels = cell(numel(systemKeys),1);

for i = 1:numel(systemKeys)
    switch systemKeys(i)
        case "moderateOther_highComp"
            labels{i} = 'Moderate other / high competition';
        case "highOther_modComp"
            labels{i} = 'High other / moderate competition';
        case "highOther_lowComp"
            labels{i} = 'High other / low competition';
        case "lowOther"
            labels{i} = 'Low other';
        case "pureSelf"
            labels{i} = 'Pure self-interest';
        otherwise
            labels{i} = char(strrep(systemKeys(i), '_', ' '));
    end
end
end

function labels = prettyFailureLabels(failureVars, fallbackLabels)
%PRETTYFAILURELABELS Short labels for stacked failure plots.

labels = fallbackLabels;
if isstring(labels)
    labels = cellstr(labels);
end

for i = 1:numel(failureVars)
    key = string(failureVars{i});
    switch key
        case {"needFailureRate", "need_detection_failure_rate"}
            labels{i} = 'Need detection';
        case {"goalFailureRate", "goal_inference_failure_rate"}
            labels{i} = 'Goal inference';
        case {"affordanceFailureRate", "affordance_failure_rate"}
            labels{i} = 'Affordance';
        case {"costCompetitionFailureRate", "cost_competition_failure_rate"}
            labels{i} = 'Cost/competition';
        case {"valuationFailureRate", "valuation_failure_rate"}
            labels{i} = 'Valuation/action';
        case {"falsePositiveRate", "false_positive_rate"}
            labels{i} = 'False positive';
        case {"helpingRate", "realised_helping_rate"}
            labels{i} = 'Realised helping';
        otherwise
            if i > numel(labels) || isempty(labels{i})
                labels{i} = char(strrep(key, '_', ' '));
            end
    end
end
end

function applyBarStyle(b, grayMap)
%APPLYBARSTYLE Apply restrained grayscale style to grouped bars.

if isempty(b)
    return;
end

nBars = numel(b);
if size(grayMap,1) < nBars
    g = linspace(0.15, 0.88, nBars)';
    grayMap = [g g g];
end

for k = 1:nBars
    b(k).FaceColor = grayMap(k,:);
    b(k).EdgeColor = 'none';
end
end

function applyStackedBarStyle(b)
%APPLYSTACKEDBARSTYLE Apply grayscale fills to stacked bars.

if isempty(b)
    return;
end

nBars = numel(b);
g = linspace(0.18, 0.86, nBars)';
stackGray = [g g g];

for k = 1:nBars
    b(k).FaceColor = stackGray(k,:);
    b(k).EdgeColor = 'none';
end
end

function sg_applyFigureStyle(ax)
%SG_APPLYFIGURESTYLE Restrained manuscript figure style.

if nargin < 1 || isempty(ax)
    ax = gca;
end

set(ax, ...
    'Box', 'off', ...
    'TickDir', 'out', ...
    'LineWidth', 0.75, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'Layer', 'top');

ax.TickLength = [0.015 0.015];
end

function styleLegend(leg)
%STYLELEGEND Match legend style to the manuscript figure style.

if isempty(leg) || ~isvalid(leg)
    return;
end

set(leg, ...
    'Box', 'off', ...
    'FontName', 'Arial', ...
    'FontSize', 8);
end

function safeExport(fig, outPath)
%SAFEEXPORT Use exportgraphics when available; otherwise fall back to print.

[folder, name, ~] = fileparts(outPath);
if ~exist(folder, 'dir')
    mkdir(folder);
end

set(fig, 'PaperPositionMode', 'auto');

try
    exportgraphics(fig, outPath, 'Resolution', 600);
catch
    print(fig, fullfile(folder, name), '-dpng', '-r600');
end
end
