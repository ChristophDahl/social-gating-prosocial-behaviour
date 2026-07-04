function p = sg_speciesParams(baseParams, socialSystem)
%SG_SPECIESPARAMS Legacy name for parameter-regime presets.
%
% The presets are not species simulations. This legacy function name is kept
% only so older scripts do not fail. New text and code should refer to
% parameter regimes rather than species.

p = baseParams;
label = lower(char(socialSystem));

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
        error('Unknown parameter regime / legacy social-system label: %s', socialSystem);
end
end
