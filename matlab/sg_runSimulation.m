function data = sg_runSimulation(tasks, parameterRegimes, baseParams, nTrialsPerTask, seeds)
%SG_RUNSIMULATION Run the social-gating simulation across task and parameter presets.
%
% seeds may be a scalar or vector. A vector of seeds provides a simple
% simulation-stability check. The returned trial table contains a seed column.
%
% Parameter-preset settings are resolved by sg_parameterPresetParams.

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
            p = sg_parameterPresetParams(baseParams, parameterRegime);

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
