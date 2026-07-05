function params = sg_defaultParams()
%SG_DEFAULTPARAMS Base parameters for the social-gating model.
%
% The base structure contains inference parameters and default valuation
% weights. Parameter-preset-specific valuation weights are set in
% sg_parameterPresetParams.

% Need-inference weights.
params.alpha0 = -1.20;
params.alphaV = 1.90;   % visibility of recipient need
params.alphaS = 1.10;   % solicitation / request
params.alphaG = 1.15;   % goal transparency
params.alphaF = 0.75;   % task familiarity
params.alphaO = 1.80;   % occlusion or ambiguity

% Affordance-recognition weights.
params.delta0 = -1.10;
params.deltaA = 2.05;   % action-outcome clarity
params.deltaG = 0.95;   % goal transparency
params.deltaF = 0.85;   % task familiarity
params.deltaO = 1.45;   % occlusion or ambiguity

% Default valuation weights. These are overwritten for each parameter preset.
params.wSelf  = 1.00;
params.wOther = 0.30;
params.wJoint = 0.50;
params.wCost  = 1.25;
params.wComp  = 0.90;
params.wRel   = 0.30;
params.wRecip = 0.20;
params.wSol   = 0.25;
params.beta   = 3.00;

% Default action-initiation thresholds for choosing the help/action option.
%
% helpActionThreshold is applied when the action benefits the recipient but
% does not provide direct actor benefit or weighted joint benefit. This keeps
% the pure self-interest control from choosing low-cost recipient-benefiting
% actions too often merely because no-help has utility zero and choice is
% stochastic.
%
% actorBenefitActionThreshold is applied when the action carries direct actor
% benefit or model-weighted joint benefit. This prevents the threshold from
% artificially suppressing mutually beneficial collaboration.
params.helpActionThreshold = 0.25;
params.actorBenefitActionThreshold = 0.05;
params.actionBenefitTolerance = 1e-9;

% Legacy alias retained for older scripts that may still read this field.
params.actionThreshold = params.helpActionThreshold;

% Noise and thresholds.
params.inferenceNoiseSD = 0.18;
params.utilityNoiseSD   = 0.00;
params.lowCostThreshold = 0.15;
params.costOverrideThreshold = 0.70;
params.epsProb = 1e-9;
end
