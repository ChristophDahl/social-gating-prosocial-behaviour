function [needAffordTbl, relationshipGateTbl, costThresholdTbl, summaryTbl] = ...
    sg_prospectivePredictions(baseParams, parameterRegimes)
%SG_PROSPECTIVEPREDICTIONS Architecture-derived tests not based on task presets.
%
% These diagnostics are deliberately constructed from synthetic factorial
% manipulations rather than the literature-derived task presets. They test
% consequences of the formal architecture itself:
%
%   1) Need x affordance interaction implied by gate = pNeed * pAfford.
%   2) Relationship x gate interaction implied by placing wRel*relationship
%      inside the gated recipient-benefit term.
%   3) Need-dependent cost threshold implied by gated recipient value opposing
%      the subtractive action-cost term.
%
% The outputs are deterministic choice probabilities from the utility and
% softmax equations. They are prospective model predictions, not empirical
% validation and not fitted estimates.

if nargin < 2 || isempty(parameterRegimes)
    parameterRegimes = {'modOther_highComp', 'highOther_modComp', ...
        'highOther_lowComp', 'lowOther_weight', 'pureSelf'};
end

% -------------------------------------------------------------------------
% Synthetic diagnostic context. These values are not copied from any one
% empirical task preset. Direct actor benefit, joint benefit, and motor bias
% are set to zero so that the diagnostics isolate the gated recipient-value
% structure.
% -------------------------------------------------------------------------
task = struct();
task.expectedSelfBenefit = 0.0;
task.expectedOtherBenefit = 0.8;
task.jointBenefit = 0.0;
task.solicitation = 0.20;
task.motorBiasHelp = 0.0;

fixedCost = 0.20;
fixedCompetition = 0.10;
fixedRelationship = 0.40;
fixedReciprocity = 0.20;

% -------------------------------------------------------------------------
% Prediction 1: Need x affordance factorial.
% -------------------------------------------------------------------------
needLevels = [0.20 0.80];
affordLevels = [0.20 0.80];
rows = [];
r = 0;

for iRegime = 1:numel(parameterRegimes)
    regime = parameterRegimes{iRegime};
    p = localParameterRegimeParams(baseParams, regime);

    for iNeed = 1:numel(needLevels)
        for iAff = 1:numel(affordLevels)
            pNeed = needLevels(iNeed);
            pAfford = affordLevels(iAff);
            Uhelp = sg_computeUtility(task, p, pNeed, pAfford, fixedCost, ...
                fixedCompetition, fixedRelationship, fixedReciprocity, true);
            Uno = sg_computeUtility(task, p, pNeed, pAfford, fixedCost, ...
                fixedCompetition, fixedRelationship, fixedReciprocity, false);
            pHelp = sigmoidLocal(p.beta * (Uhelp - Uno));

            r = r + 1;
            rows(r).parameterRegime = string(regime); %#ok<AGROW>
            rows(r).pNeed = pNeed; %#ok<AGROW>
            rows(r).pAfford = pAfford; %#ok<AGROW>
            rows(r).gate = pNeed * pAfford; %#ok<AGROW>
            rows(r).Uhelp = Uhelp; %#ok<AGROW>
            rows(r).pHelp = pHelp; %#ok<AGROW>
        end
    end
end
needAffordTbl = struct2table(rows);

% -------------------------------------------------------------------------
% Prediction 2: Relationship effect under weak versus strong gate.
% -------------------------------------------------------------------------
gateLabels = {'weak_gate','strong_gate'};
gateNeed = [0.20 0.80];
gateAfford = [0.20 0.80];
relationshipLevels = [0.0 1.0];
rows = [];
r = 0;

for iRegime = 1:numel(parameterRegimes)
    regime = parameterRegimes{iRegime};
    p = localParameterRegimeParams(baseParams, regime);

    for iGate = 1:numel(gateLabels)
        pNeed = gateNeed(iGate);
        pAfford = gateAfford(iGate);
        for iRel = 1:numel(relationshipLevels)
            relationship = relationshipLevels(iRel);
            Uhelp = sg_computeUtility(task, p, pNeed, pAfford, fixedCost, ...
                fixedCompetition, relationship, fixedReciprocity, true);
            Uno = sg_computeUtility(task, p, pNeed, pAfford, fixedCost, ...
                fixedCompetition, relationship, fixedReciprocity, false);
            pHelp = sigmoidLocal(p.beta * (Uhelp - Uno));

            r = r + 1;
            rows(r).parameterRegime = string(regime); %#ok<AGROW>
            rows(r).gateCondition = string(gateLabels{iGate}); %#ok<AGROW>
            rows(r).pNeed = pNeed; %#ok<AGROW>
            rows(r).pAfford = pAfford; %#ok<AGROW>
            rows(r).gate = pNeed * pAfford; %#ok<AGROW>
            rows(r).relationship = relationship; %#ok<AGROW>
            rows(r).Uhelp = Uhelp; %#ok<AGROW>
            rows(r).pHelp = pHelp; %#ok<AGROW>
        end
    end
end
relationshipGateTbl = struct2table(rows);

% -------------------------------------------------------------------------
% Prediction 3: inferred need shifts the p(help)=0.5 cost-indifference point.
% A slightly more favourable but still synthetic diagnostic context is used
% so that thresholds lie inside the 0--1 cost range for informative regimes.
% -------------------------------------------------------------------------
costTask = task;
costTask.expectedOtherBenefit = 1.0;
costTask.solicitation = 0.20;
costAfford = 0.90;
costCompetition = 0.05;
costRelationship = 0.60;
costReciprocity = 0.20;
needForCost = [0.30 0.50 0.80];

rows = [];
r = 0;
for iRegime = 1:numel(parameterRegimes)
    regime = parameterRegimes{iRegime};
    p = localParameterRegimeParams(baseParams, regime);

    for iNeed = 1:numel(needForCost)
        pNeed = needForCost(iNeed);

        % With Uno = 0 and a logistic choice rule, p(help)=0.5 exactly when
        % Uhelp=0. Because cost enters linearly as -wCost*cost, evaluating
        % Uhelp at cost=0 gives the exact cost-indifference point.
        UatZeroCost = sg_computeUtility(costTask, p, pNeed, costAfford, 0, ...
            costCompetition, costRelationship, costReciprocity, true);

        if p.wCost > 0
            costThreshold = UatZeroCost / p.wCost;
        else
            costThreshold = NaN;
        end

        r = r + 1;
        rows(r).parameterRegime = string(regime); %#ok<AGROW>
        rows(r).pNeed = pNeed; %#ok<AGROW>
        rows(r).pAfford = costAfford; %#ok<AGROW>
        rows(r).costIndifferencePoint = costThreshold; %#ok<AGROW>
        rows(r).withinUnitCostRange = costThreshold >= 0 && costThreshold <= 1; %#ok<AGROW>
    end
end
costThresholdTbl = struct2table(rows);

% -------------------------------------------------------------------------
% Compact summary of the architecture-derived contrasts.
% -------------------------------------------------------------------------
rows = [];
r = 0;
for iRegime = 1:numel(parameterRegimes)
    regime = string(parameterRegimes{iRegime});

    D = needAffordTbl(needAffordTbl.parameterRegime == regime,:);
    pll = D.pHelp(D.pNeed == 0.20 & D.pAfford == 0.20);
    phl = D.pHelp(D.pNeed == 0.80 & D.pAfford == 0.20);
    plh = D.pHelp(D.pNeed == 0.20 & D.pAfford == 0.80);
    phh = D.pHelp(D.pNeed == 0.80 & D.pAfford == 0.80);
    interactionContrast = (phh - plh) - (phl - pll);

    R = relationshipGateTbl(relationshipGateTbl.parameterRegime == regime,:);
    weak0 = R.pHelp(R.gateCondition == "weak_gate" & R.relationship == 0);
    weak1 = R.pHelp(R.gateCondition == "weak_gate" & R.relationship == 1);
    strong0 = R.pHelp(R.gateCondition == "strong_gate" & R.relationship == 0);
    strong1 = R.pHelp(R.gateCondition == "strong_gate" & R.relationship == 1);
    weakRelEffect = weak1 - weak0;
    strongRelEffect = strong1 - strong0;

    C = costThresholdTbl(costThresholdTbl.parameterRegime == regime,:);
    cLow = C.costIndifferencePoint(C.pNeed == 0.30);
    cHigh = C.costIndifferencePoint(C.pNeed == 0.80);

    r = r + 1;
    rows(r).parameterRegime = regime; %#ok<AGROW>
    rows(r).needAffordanceInteraction = interactionContrast; %#ok<AGROW>
    rows(r).relationshipEffectWeakGate = weakRelEffect; %#ok<AGROW>
    rows(r).relationshipEffectStrongGate = strongRelEffect; %#ok<AGROW>
    rows(r).relationshipGateInteraction = strongRelEffect - weakRelEffect; %#ok<AGROW>
    rows(r).costThresholdLowNeed = cLow; %#ok<AGROW>
    rows(r).costThresholdHighNeed = cHigh; %#ok<AGROW>
    rows(r).needShiftInCostThreshold = cHigh - cLow; %#ok<AGROW>
end
summaryTbl = struct2table(rows);
end

function y = sigmoidLocal(x)
y = 1 ./ (1 + exp(-x));
end

function p = localParameterRegimeParams(baseParams, parameterRegime)
%LOCALPARAMETERREGIMEPARAMS Parameter-regime presets used locally.

p = baseParams;
label = lower(char(parameterRegime));

switch label
    case {'chimpanzee_like', 'modother_highcomp'}
        p.wSelf=1.00; p.wOther=0.28; p.wJoint=0.60; p.wCost=1.35;
        p.wComp=1.05; p.wRel=0.45; p.wRecip=0.30; p.wSol=0.35; p.beta=3.00;
    case {'high_other_regard', 'highother_modcomp'}
        p.wSelf=1.00; p.wOther=0.95; p.wJoint=0.70; p.wCost=1.00;
        p.wComp=0.55; p.wRel=0.65; p.wRecip=0.35; p.wSol=0.45; p.beta=3.20;
    case {'marmoset_like', 'highother_lowcomp'}
        p.wSelf=1.00; p.wOther=0.65; p.wJoint=0.60; p.wCost=1.15;
        p.wComp=0.45; p.wRel=0.55; p.wRecip=0.30; p.wSol=0.35; p.beta=3.00;
    case {'self_interested', 'lowother_weight'}
        p.wSelf=1.00; p.wOther=0.05; p.wJoint=0.25; p.wCost=1.60;
        p.wComp=1.10; p.wRel=0.10; p.wRecip=0.10; p.wSol=0.10; p.beta=3.00;
    case {'pureself', 'pure_self', 'pure_self_interest'}
        p.wSelf=1.00; p.wOther=0.00; p.wJoint=0.00; p.wCost=1.80;
        p.wComp=1.20; p.wRel=0.00; p.wRecip=0.00; p.wSol=0.00; p.beta=4.00;
    otherwise
        error('Unknown parameter regime: %s', parameterRegime);
end
end
