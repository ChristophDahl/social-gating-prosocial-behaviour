function render_main_figures_only(projectRoot)
%RENDER_MAIN_FIGURES_ONLY Render only the two main manuscript figures.
%
% This script does not rerun the simulation. It only reads existing CSV
% outputs from <projectRoot>/results and writes figure files to
% <projectRoot>/figures.
%
% Usage:
%   render_main_figures_only
%   render_main_figures_only('I:\yourProjectFolder')

if nargin < 1 || isempty(projectRoot)
    scriptDir = fileparts(mfilename('fullpath'));
    [~, folderName] = fileparts(scriptDir);
    if strcmpi(folderName, 'matlab')
        projectRoot = fileparts(scriptDir);
    else
        projectRoot = scriptDir;
    end
end

make_Fig1_helping_need_sensitivity(projectRoot);
make_Fig2_failure_decomposition(projectRoot);

fprintf('\nMain figures rendered to:\n%s\n', fullfile(projectRoot, 'figures'));
end
