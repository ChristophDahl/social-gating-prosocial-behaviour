function p = sg_parameterPresetParams(baseParams, parameterPreset)
%SG_PARAMETERPRESETPARAMS Resolve parameter-preset settings.
%
% These presets define interpretable regions of model space. They are not
% species simulations and should not be described as calibrated taxon models.
%
% Preferred parameter-preset labels:
%   modOther_highComp     - moderate other-outcome weighting, high competition sensitivity
%   highOther_modComp     - high other-outcome weighting, moderate competition sensitivity
%   highOther_lowComp     - high other-outcome weighting, low competition sensitivity
%   lowOther_weight       - weak other-outcome weighting with residual social terms
%   pureSelf              - strict actor-centred control with social terms removed
%
% Legacy aliases such as 'chimpanzee_like' and 'marmoset_like' are accepted
% only for backward compatibility with older scripts; new code should not use them.

p = baseParams;
label = lower(char(parameterPreset));

switch label

    case {'modother_highcomp', 'chimpanzee_like'}
        p.wSelf  = 1.00;
        p.wOther = 0.28;
        p.wJoint = 0.60;
        p.wCost  = 1.35;
        p.wComp  = 1.05;
        p.wRel   = 0.45;
        p.wRecip = 0.30;
        p.wSol   = 0.35;
        p.beta   = 3.00;

    case {'highother_modcomp', 'high_other_regard'}
        p.wSelf  = 1.00;
        p.wOther = 0.95;
        p.wJoint = 0.70;
        p.wCost  = 1.00;
        p.wComp  = 0.55;
        p.wRel   = 0.65;
        p.wRecip = 0.35;
        p.wSol   = 0.45;
        p.beta   = 3.20;

    case {'highother_lowcomp', 'marmoset_like'}
        p.wSelf  = 1.00;
        p.wOther = 0.65;
        p.wJoint = 0.60;
        p.wCost  = 1.15;
        p.wComp  = 0.45;
        p.wRel   = 0.55;
        p.wRecip = 0.30;
        p.wSol   = 0.35;
        p.beta   = 3.00;

    case {'lowother_weight', 'self_interested'}
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
        error('Unknown parameter preset: %s', parameterPreset);
end
end