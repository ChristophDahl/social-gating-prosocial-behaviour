function cfTbl = sg_counterfactualNeedEffect(tasks, parameterRegimes, baseParams)
%SG_COUNTERFACTUALNEEDEFFECT Compute need-sensitivity by task/regime.
%
% Two related diagnostics are returned.
%
% counterfactualSocialGateEffect varies inferred need in both the other-benefit
% gate and the solicitation-amplified action term. This is the broad social
% gating perturbation.
%
% counterfactualNeedOnlyEffect varies inferred need only inside the other-
% benefit gate while holding the solicitation contribution at its task-baseline
% value. This is the cleaner diagnostic for other-state sensitivity.

rows = [];
r = 0;

for iTask = 1:height(tasks)
    task = tasks(iTask,:);
    for iRegime = 1:numel(parameterRegimes)
        parameterRegime = parameterRegimes{iRegime};
        p = localParameterRegimeParams(baseParams, parameterRegime);

        pAfford = sigmoidLocal(p.delta0 + p.deltaA * task.affordanceClarity + ...
            p.deltaG * task.goalTransparency + p.deltaF * task.familiarity - ...
            p.deltaO * task.occlusion);

        pNeedBaseline = sigmoidLocal(p.alpha0 + p.alphaV * task.visibility + ...
            p.alphaS * task.solicitation + p.alphaG * task.goalTransparency + ...
            p.alphaF * task.familiarity - p.alphaO * task.occlusion);

        pNeedLow = 0.10;
        pNeedHigh = 0.90;

        % Broad social-gate perturbation: need also changes the solicitation term.
        UlowBroad = sg_computeUtility(task, p, pNeedLow, pAfford, task.cost, task.competition, ...
            task.relationship, task.reciprocity, true);
        UhighBroad = sg_computeUtility(task, p, pNeedHigh, pAfford, task.cost, task.competition, ...
            task.relationship, task.reciprocity, true);

        % Need-only perturbation: solicitation term held at baseline need.
        UlowNeedOnly = sg_computeUtility(task, p, pNeedLow, pAfford, task.cost, task.competition, ...
            task.relationship, task.reciprocity, true, pNeedBaseline);
        UhighNeedOnly = sg_computeUtility(task, p, pNeedHigh, pAfford, task.cost, task.competition, ...
            task.relationship, task.reciprocity, true, pNeedBaseline);

        Uno = sg_computeUtility(task, p, pNeedBaseline, pAfford, task.cost, task.competition, ...
            task.relationship, task.reciprocity, false);

        pHelpLowBroad = sigmoidLocal(p.beta * (UlowBroad - Uno));
        pHelpHighBroad = sigmoidLocal(p.beta * (UhighBroad - Uno));
        pHelpLowNeedOnly = sigmoidLocal(p.beta * (UlowNeedOnly - Uno));
        pHelpHighNeedOnly = sigmoidLocal(p.beta * (UhighNeedOnly - Uno));

        r = r + 1;
        rows(r).task = string(task.Name{1}); %#ok<AGROW>
        rows(r).socialSystem = string(parameterRegime); %#ok<AGROW>
        rows(r).parameterRegime = string(parameterRegime); %#ok<AGROW>
        rows(r).pNeedBaseline = pNeedBaseline; %#ok<AGROW>
        rows(r).pAffordHeld = pAfford; %#ok<AGROW>
        rows(r).pHelpLowNeed = pHelpLowBroad; %#ok<AGROW>
        rows(r).pHelpHighNeed = pHelpHighBroad; %#ok<AGROW>
        rows(r).counterfactualNeedEffect = pHelpHighBroad - pHelpLowBroad; %#ok<AGROW>
        rows(r).counterfactualSocialGateEffect = pHelpHighBroad - pHelpLowBroad; %#ok<AGROW>
        rows(r).pHelpLowNeedOnly = pHelpLowNeedOnly; %#ok<AGROW>
        rows(r).pHelpHighNeedOnly = pHelpHighNeedOnly; %#ok<AGROW>
        rows(r).counterfactualNeedOnlyEffect = pHelpHighNeedOnly - pHelpLowNeedOnly; %#ok<AGROW>
    end
end

cfTbl = struct2table(rows);
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
        p.wSelf  = 1.00;
        p.wOther = 0.28;
        p.wJoint = 0.60;
        p.wCost  = 1.35;
        p.wComp  = 1.05;
        p.wRel   = 0.45;
        p.wRecip = 0.30;
        p.wSol   = 0.35;
        p.beta   = 3.00;

    case {'high_other_regard', 'highother_modcomp'}
        p.wSelf  = 1.00;
        p.wOther = 0.95;
        p.wJoint = 0.70;
        p.wCost  = 1.00;
        p.wComp  = 0.55;
        p.wRel   = 0.65;
        p.wRecip = 0.35;
        p.wSol   = 0.45;
        p.beta   = 3.20;

    case {'marmoset_like', 'highother_lowcomp'}
        p.wSelf  = 1.00;
        p.wOther = 0.65;
        p.wJoint = 0.60;
        p.wCost  = 1.15;
        p.wComp  = 0.45;
        p.wRel   = 0.55;
        p.wRecip = 0.30;
        p.wSol   = 0.35;
        p.beta   = 3.00;

    case {'self_interested', 'lowother_weight'}
        p.wSelf  = 1.00;
        p.wOther = 0.05;
        p.wJoint = 0.25;
        p.wCost  = 1.60;
        p.wComp  = 1.10;
        p.wRel   = 0.10;
        p.wRecip = 0.10;
        p.wSol   = 0.10;
        p.beta   = 3.00;

    case {'pureself', 'pure_self', 'pure_self_interest'}
        p.wSelf  = 1.00;
        p.wOther = 0.00;
        p.wJoint = 0.00;
        p.wCost  = 1.80;
        p.wComp  = 1.20;
        p.wRel   = 0.00;
        p.wRecip = 0.00;
        p.wSol   = 0.00;
        p.beta   = 4.00;

    otherwise
        error('Unknown parameter regime: %s', parameterRegime);
end
end
