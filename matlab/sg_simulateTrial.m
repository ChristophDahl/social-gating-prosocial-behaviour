function trial = sg_simulateTrial(task, socialSystem, p, trialIndex)
%SG_SIMULATETRIAL Simulate one trial for one task and one parameter regime.

% Sample bounded trial-to-trial variation in observed task variables.
visibility        = jitter01(task.visibility, 0.04);
solicitation      = jitter01(task.solicitation, 0.04);
goalTransparency  = jitter01(task.goalTransparency, 0.04);
affordanceClarity = jitter01(task.affordanceClarity, 0.04);
familiarity       = jitter01(task.familiarity, 0.04);
occlusion         = jitter01(task.occlusion, 0.04);
cost              = jitter01(task.cost, 0.03);
competition       = jitter01(task.competition, 0.04);
relationship      = jitter01(task.relationship, 0.04);
reciprocity       = jitter01(task.reciprocity, 0.04);

% Latent inference stage.
needLinear = p.alpha0 + p.alphaV * visibility + p.alphaS * solicitation + ...
    p.alphaG * goalTransparency + p.alphaF * familiarity - p.alphaO * occlusion + ...
    randn() * p.inferenceNoiseSD;

pNeed = sigmoidLocal(needLinear);
needDetected = rand() < pNeed;

affordLinear = p.delta0 + p.deltaA * affordanceClarity + p.deltaG * goalTransparency + ...
    p.deltaF * familiarity - p.deltaO * occlusion + randn() * p.inferenceNoiseSD;

pAfford = sigmoidLocal(affordLinear);
affordanceDetected = rand() < pAfford;

% Continuous gate used for valuation; binary variables are used for failure labels.
gate = pNeed * pAfford;

% Valuation stage.
Uhelp = sg_computeUtility(task, p, pNeed, pAfford, cost, competition, relationship, reciprocity, true);
UnoHelp = sg_computeUtility(task, p, pNeed, pAfford, cost, competition, relationship, reciprocity, false);

if p.utilityNoiseSD > 0
    Uhelp = Uhelp + randn() * p.utilityNoiseSD;
    UnoHelp = UnoHelp + randn() * p.utilityNoiseSD;
end

pHelp = sigmoidLocal(p.beta * (Uhelp - UnoHelp));
choiceHelp = rand() < pHelp;

% Realised outcomes. Recipient benefit and actor benefit are separate.
actualOtherBenefit = task.actualOtherBenefit;
actualSelfBenefit  = task.actualSelfBenefit;
actualSelfDelta    = actualSelfBenefit - cost;

actualHelping = choiceHelp && actualOtherBenefit > 0;
falsePositive = choiceHelp && actualOtherBenefit <= 0;

% Outcome labels. Prosociality is defined by recipient benefit with no
% meaningful net actor loss. Costly other-benefit behaviour means that the
% recipient benefits while the actor pays an action cost; it is not treated
% as altruism because the actor may still obtain direct or joint benefit.
% Strict altruism-like behaviour is reserved for cases in which recipient
% benefit occurs while the actor's net outcome is negative.
prosocial = actualHelping && actualSelfDelta >= -p.lowCostThreshold;
costlyOtherBenefit = actualHelping && cost > p.lowCostThreshold;
strictAltruismLike = actualHelping && actualSelfDelta < -p.lowCostThreshold;
collaborationLike = actualHelping && task.isCollaborative;

% Mutually exclusive diagnostic labels.
needFailure = false;
affordanceFailure = false;
costCompetitionOverride = false;
valuationNoHelp = false;
falsePositiveBias = false;
success = false;

if actualHelping
    success = true;
elseif falsePositive
    falsePositiveBias = true;
elseif ~needDetected
    needFailure = true;
elseif needDetected && ~affordanceDetected
    affordanceFailure = true;
else
    costCompetitionSignal = p.wCost * cost + p.wComp * competition;
    if costCompetitionSignal >= p.costOverrideThreshold && Uhelp < UnoHelp
        costCompetitionOverride = true;
    else
        valuationNoHelp = true;
    end
end

trial = struct();
trial.task = string(task.Name{1});
trial.socialSystem = string(socialSystem);
trial.parameterRegime = string(socialSystem);
trial.trial = trialIndex;

trial.visibility = visibility;
trial.solicitation = solicitation;
trial.goalTransparency = goalTransparency;
trial.affordanceClarity = affordanceClarity;
trial.familiarity = familiarity;
trial.occlusion = occlusion;
trial.cost = cost;
trial.competition = competition;
trial.relationship = relationship;
trial.reciprocity = reciprocity;
trial.expectedSelfBenefit = task.expectedSelfBenefit;
trial.expectedOtherBenefit = task.expectedOtherBenefit;
trial.jointBenefit = task.jointBenefit;
trial.motorBiasHelp = task.motorBiasHelp;
trial.actualOtherBenefit = actualOtherBenefit;
trial.actualSelfBenefit = actualSelfBenefit;
trial.actualSelfDelta = actualSelfDelta;
trial.isCollaborative = task.isCollaborative;

trial.pNeed = pNeed;
trial.pAfford = pAfford;
trial.gate = gate;
trial.needDetected = needDetected;
trial.affordanceDetected = affordanceDetected;
trial.Uhelp = Uhelp;
trial.UnoHelp = UnoHelp;
trial.pHelp = pHelp;
trial.choiceHelp = choiceHelp;
trial.helping = actualHelping;
trial.prosocial = prosocial;
trial.costlyOtherBenefit = costlyOtherBenefit;
trial.strictAltruismLike = strictAltruismLike;
trial.collaborationLike = collaborationLike;
trial.falsePositive = falsePositive;
trial.needFailure = needFailure;
trial.affordanceFailure = affordanceFailure;
trial.costCompetitionOverride = costCompetitionOverride;
trial.valuationNoHelp = valuationNoHelp;
trial.falsePositiveBias = falsePositiveBias;
trial.success = success;
end

function x = jitter01(mu, sd)
x = min(max(mu + randn() * sd, 0), 1);
end

function y = sigmoidLocal(x)
y = 1 ./ (1 + exp(-x));
end
