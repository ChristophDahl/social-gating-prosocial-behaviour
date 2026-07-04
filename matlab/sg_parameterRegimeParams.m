function p = sg_parameterRegimeParams(baseParams, parameterRegime)
%SG_PARAMETERREGIMEPARAMS Compatibility wrapper for parameter-regime presets.
%
% This wrapper calls sg_speciesParams, whose name is retained only for legacy
% compatibility. The presets themselves are parameter regimes, not species
% simulations.

p = sg_speciesParams(baseParams, parameterRegime);
end
