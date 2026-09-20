function U = sg_computeUtility(task, p, pNeed, pAfford, cost, competition, relationship, reciprocity, isHelpAction, varargin)
%SG_COMPUTEUTILITY Compute utility for the help/action or no-help action.
%
% Revision for reviewer-2 prospective tests:
% The implementation is synchronized with the manuscript equation
%
%   U = wSelf*selfBenefit - wCost*cost - wComp*competition + motorBias
%       + gate * (wOther + wRel*relationship + wRecip*reciprocity
%                 + wSol*solicitation) * expectedOtherBenefit
%       + wJoint*jointBenefit,
%
% where gate = pNeed * pAfford.
%
% Thus relationship value, reciprocal history, and solicitation modulate the
% value of the recipient's expected outcome only when need and an effective
% affordance are represented. They are not independent additive incentives to
% select the nominal helping action.
%
% A trailing legacy argument is accepted and ignored so that older analysis
% scripts that passed pNeedForSolicitation do not fail.

if isHelpAction
    gate = pNeed * pAfford;
    actionThreshold = localActionThresholdForTask(task, p);

    socialWeight = p.wOther + ...
        p.wRel   * relationship + ...
        p.wRecip * reciprocity + ...
        p.wSol   * task.solicitation;

    U = p.wSelf  * task.expectedSelfBenefit - ...
        p.wCost  * cost - ...
        p.wComp  * competition + ...
        task.motorBiasHelp + ...
        gate * socialWeight * task.expectedOtherBenefit + ...
        p.wJoint * task.jointBenefit - ...
        actionThreshold;
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
