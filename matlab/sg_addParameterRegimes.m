function params = sg_addParameterRegimes(params)
% sg_addParameterRegimes
% Converts species-like labels into parameter-regime labels and adds a strict
% pure-self-interest control.
%
% If your parameter presets are nested, e.g. params.systems.chimpanzee_like,
% then replace params.OLD by params.systems.OLD throughout this function.

% Preserve previous numerical presets, but relabel them more conservatively.
params.modOther_highComp  = params.chimpanzee_like;
params.highOther_lowComp  = params.marmoset_like;
params.highOther_modComp  = params.high_other_regard;
params.lowOther_weight    = params.self_interested;

% Add stricter control model.
params.pureSelf = params.self_interested;

% These field names follow the current model notation. If your actual struct
% uses slightly different names, change the entries in fieldsToZero.
fieldsToZero = {'wOther','wRel','wRecip','wSol','wJoint'};

for k = 1:numel(fieldsToZero)
    f = fieldsToZero{k};
    if isfield(params.pureSelf, f)
        params.pureSelf.(f) = 0;
    end
end

% Make pureSelf cost/competition-sensitive if those fields exist.
if isfield(params.pureSelf, 'wCost')
    params.pureSelf.wCost = max(params.pureSelf.wCost, 1.5);
end

if isfield(params.pureSelf, 'wComp')
    params.pureSelf.wComp = max(params.pureSelf.wComp, 1.5);
end
end