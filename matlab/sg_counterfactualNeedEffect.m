function cfTbl = sg_counterfactualNeedEffect(tasks, parameterRegimes, baseParams)
%SG_COUNTERFACTUALNEEDEFFECT Compute need-sensitivity by task and parameter preset.
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
        p = sg_parameterPresetParams(baseParams, parameterRegime);

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
