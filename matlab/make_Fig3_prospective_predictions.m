function make_Fig3_prospective_predictions(projectRoot)
%MAKE_FIG3_PROSPECTIVE_PREDICTIONS Plot architecture-derived predictions.
%
% Inputs:
%   results/prospective_need_affordance.csv
%   results/prospective_relationship_gate.csv
%   results/prospective_cost_threshold.csv
%
% Output:
%   figures/Fig3_prospective_predictions.png
%   figures/Fig3_prospective_predictions.pdf
%
% The main figure uses the highOther_modComp regime for visual clarity. The
% CSV outputs contain all parameter regimes, including pureSelf as a negative
% control.

if nargin < 1 || isempty(projectRoot)
    scriptDir = fileparts(mfilename('fullpath'));
    [~, folderName] = fileparts(scriptDir);
    if strcmpi(folderName, 'matlab')
        projectRoot = fileparts(scriptDir);
    else
        projectRoot = fileparts(scriptDir);
    end
end

resultsDir = fullfile(projectRoot, 'results');
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end

needFile = fullfile(resultsDir, 'prospective_need_affordance.csv');
relFile  = fullfile(resultsDir, 'prospective_relationship_gate.csv');
costFile = fullfile(resultsDir, 'prospective_cost_threshold.csv');
assert(exist(needFile,'file')==2, 'Missing file: %s', needFile);
assert(exist(relFile,'file')==2, 'Missing file: %s', relFile);
assert(exist(costFile,'file')==2, 'Missing file: %s', costFile);

N = readtable(needFile);
R = readtable(relFile);
C = readtable(costFile);
N.parameterRegime = string(N.parameterRegime);
R.parameterRegime = string(R.parameterRegime);
R.gateCondition = string(R.gateCondition);
C.parameterRegime = string(C.parameterRegime);

regime = "highOther_modComp";
N = N(N.parameterRegime == regime,:);
R = R(R.parameterRegime == regime,:);
C = C(C.parameterRegime == regime,:);

fig = figure('Color','w','Position',[100 100 800 300],'Renderer','painters');
tl = tiledlayout(fig,1,3,'TileSpacing','compact','Padding','compact');

% Panel A: Need x affordance.
ax1 = nexttile(tl,1); hold(ax1,'on');
lowAff = N(N.pAfford==0.20,:);
highAff = N(N.pAfford==0.80,:);
lowAff = sortrows(lowAff,'pNeed'); highAff = sortrows(highAff,'pNeed');
plot(ax1,lowAff.pNeed,lowAff.pHelp,'-o','LineWidth',1,'MarkerSize',4);
plot(ax1,highAff.pNeed,highAff.pHelp,'-s','LineWidth',1,'MarkerSize',4);
xlim(ax1,[0.15 0.85]); ylim(ax1,[0 1]);
xlabel(ax1,'Inferred need'); ylabel(ax1,'P(recipient-benefiting action)');
legend(ax1,{'Low affordance','High affordance'},'Location','northwest','Box','off');
title(ax1,'Need \times affordance','Interpreter','tex');
text(ax1,-0.16,1.06,'A','Units','normalized','FontWeight','bold');
axis square

% Panel B: Relationship x gate.
ax2 = nexttile(tl,2); hold(ax2,'on');
weak = sortrows(R(R.gateCondition=="weak_gate",:),'relationship');
strong = sortrows(R(R.gateCondition=="strong_gate",:),'relationship');
plot(ax2,weak.relationship,weak.pHelp,'-o','LineWidth',1,'MarkerSize',4);
plot(ax2,strong.relationship,strong.pHelp,'-s','LineWidth',1,'MarkerSize',4);
xlim(ax2,[-0.05 1.05]); ylim(ax2,[0 1]);
xlabel(ax2,'Relationship value'); ylabel(ax2,'P(recipient-benefiting action)');
legend(ax2,{'Weak gate','Strong gate'},'Location','northwest','Box','off');
title(ax2,'Relationship \times gate','Interpreter','tex');
text(ax2,-0.16,1.06,'B','Units','normalized','FontWeight','bold');
axis square

% Panel C: Need-dependent cost threshold.
ax3 = nexttile(tl,3); hold(ax3,'on');
C = sortrows(C,'pNeed');
plot(ax3,C.pNeed,C.costIndifferencePoint,'-o', ...
    'Color','k', ...
    'LineWidth',1, ...
    'MarkerSize',4);
yline(ax3,0,'-','LineWidth',0.75);
xlim(ax3,[0.25 0.85]);
ylim(ax3,[min(-0.05,min(C.costIndifferencePoint)-0.05), ...
          max(0.9,max(C.costIndifferencePoint)+0.05)]);
xlabel(ax3,'Inferred need'); ylabel(ax3,'Cost at P(action) = 0.5');
title(ax3,'Need-dependent cost threshold');
text(ax3,-0.16,1.06,'C','Units','normalized','FontWeight','bold');
axis square

axs = [ax1 ax2 ax3];
for ax = axs
    box(ax,'off');
    set(ax,'FontName','Arial','FontSize',8,'LineWidth',0.75,'TickDir','out');
end

sg_exportFigure(fig, fullfile(figDir,'Fig3_prospective_predictions.png'), 600);
try
    exportgraphics(fig, fullfile(figDir,'Fig3_prospective_predictions.pdf'), 'ContentType','vector');
catch
    print(fig, fullfile(figDir,'Fig3_prospective_predictions'), '-dpdf', '-painters');
end
end
