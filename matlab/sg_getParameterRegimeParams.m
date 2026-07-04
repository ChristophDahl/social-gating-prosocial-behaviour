function p = sg_getParameterRegimeParams(baseParams, parameterRegime)
%SG_GETPARAMETERREGIMEPARAMS Compatibility wrapper for parameter-regime presets.
%
% This function is retained only for backwards compatibility with v5.1. The
% current v5.2 core functions resolve parameter regimes locally and do not
% require this file to be present on the MATLAB path.

p = sg_speciesParams(baseParams, parameterRegime);
end
