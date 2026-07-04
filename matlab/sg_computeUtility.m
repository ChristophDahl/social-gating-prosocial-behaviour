function U = sg_computeUtility(task, p, pNeed, pAfford, cost, competition, relationship, reciprocity, isHelpAction, pNeedForSolicitation)
%SG_COMPUTEUTILITY Compute action utility for help/action or no-help action.
%
% The actor's self-term is expectedSelfBenefit, not recipient benefit and not
% realised actualSelfDelta. Cost is subtracted separately. This keeps direct
% actor benefit, recipient benefit, and joint benefit distinct.
%
% The action-initiation threshold is not global. A larger default helping
% threshold is used when the action benefits the recipient but offers no
% direct actor benefit or weighted joint benefit. A smaller actor-benefit
% threshold is used when the action has direct actor benefit or weighted joint
% benefit, so mutually beneficial collaboration is not artificially suppressed.
%
% Optional argument:
%   pNeedForSolicitation -- value used only in the solicitation term. If this
%   argument is omitted, the solicitation term uses pNeed. This optional input
%   allows counterfactual analyses that vary the social gate while holding the
%   solicitation contribution fixed.

if nargin < 10 || isempty(pNeedForSolicitation)
    pNeedForSolicitation = pNeed;
end

if isHelpAction
    gate = pNeed * pAfford;
    actionThreshold = localActionThresholdForTask(task, p);

    U = p.wSelf  * task.expectedSelfBenefit + ...
        p.wOther * gate * task.expectedOtherBenefit + ...
        p.wJoint * task.jointBenefit + ...
        p.wRel   * relationship + ...
        p.wRecip * reciprocity + ...
        p.wSol   * pNeedForSolicitation * task.solicitation - ...
        p.wCost  * cost - ...
        p.wComp  * competition - ...
        actionThreshold + ...
        task.motorBiasHelp;
else
    % Minimal no-help baseline. This can later be expanded to include
    % alternative self-rewards, avoidance, or non-social action values.
    U = 0;
end
end

function actionThreshold = localActionThresholdForTask(task, p)
%LOCALACTIONTHRESHOLDFORTASK Select the task-appropriate action threshold.
%
% This switch uses independently specified task variables and model weights:
% expectedSelfBenefit and weighted jointBenefit. It does not inspect the
% realised outcome, the chosen action, or any post hoc helping label.

if isfield(p, 'helpActionThreshold')
    helpThreshold = p.helpActionThreshold;
elseif isfield(p, 'actionThreshold')
    helpThreshold = p.actionThreshold;
else
    helpThreshold = 0;
end

if isfield(p, 'actorBenefitActionThreshold')
    actorBenefitThreshold = p.actorBenefitActionThreshold;
else
    actorBenefitThreshold = helpThreshold;
end

if isfield(p, 'actionBenefitTolerance')
    tol = p.actionBenefitTolerance;
else
    tol = 1e-9;
end

hasDirectActorBenefit = task.expectedSelfBenefit > tol;
hasWeightedJointBenefit = (p.wJoint * task.jointBenefit) > tol;

if hasDirectActorBenefit || hasWeightedJointBenefit
    actionThreshold = actorBenefitThreshold;
else
    actionThreshold = helpThreshold;
end
end
