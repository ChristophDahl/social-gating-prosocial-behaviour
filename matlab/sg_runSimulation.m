function data = sg_runSimulation(tasks, parameterRegimes, baseParams, nTrialsPerTask, seeds)
%SG_RUNSIMULATION Run the social-gating simulation across tasks and regimes.
%
% seeds may be a scalar or vector. A vector of seeds provides a simple
% simulation-stability check. The returned trial table contains a seed column.
%
% Version 5.2 note:
% Parameter-regime settings are resolved locally inside this function. This
% avoids fragile path dependencies on newly renamed helper functions.

if nargin < 5 || isempty(seeds)
    seeds = 11;
end
seeds = seeds(:)';

nRowsExpected = height(tasks) * numel(parameterRegimes) * nTrialsPerTask * numel(seeds);
rows = cell(nRowsExpected, 1);
r = 0;

for iSeed = 1:numel(seeds)
    seed = seeds(iSeed);
    rng(seed);

    for iTask = 1:height(tasks)
        task = tasks(iTask,:);
        for iRegime = 1:numel(parameterRegimes)
            parameterRegime = parameterRegimes{iRegime};
            p = localParameterRegimeParams(baseParams, parameterRegime);

            for tr = 1:nTrialsPerTask
                r = r + 1;
                trial = sg_simulateTrial(task, parameterRegime, p, tr);
                trial.seed = seed;
                rows{r} = trial;
            end
        end
    end
end

rows = rows(1:r);
data = struct2table([rows{:}]');
end

function p = localParameterRegimeParams(baseParams, parameterRegime)
%LOCALPARAMETERREGIMEPARAMS Parameter-regime presets used by the simulation.
% These are parameter regimes, not species simulations. Legacy labels are
% accepted only as aliases for backwards compatibility.

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
