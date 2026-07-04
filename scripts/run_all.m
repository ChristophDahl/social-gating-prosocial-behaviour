% run_all.m
% Reproduce the simulation outputs and manuscript figures for:
% Prosocial Behaviour as Socially Gated Action Selection: A Computational Reframing
%
% Usage from repository root:
%   run('scripts/run_all.m')

clc;

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
matlabDir = fullfile(repoRoot, 'matlab');

if exist(matlabDir, 'dir') ~= 7
    error('MATLAB source folder not found: %s', matlabDir);
end

addpath(genpath(matlabDir));

fprintf('Repository root: %s\n', repoRoot);
fprintf('MATLAB source:   %s\n\n', matlabDir);

% The main simulation script clears the workspace, so paths and root folders
% are recomputed below before rendering the final manuscript figures.
run(fullfile(matlabDir, 'main_social_gating_simulation.m'));

% Recompute after main_social_gating_simulation.m calls clear.
thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
matlabDir = fullfile(repoRoot, 'matlab');
addpath(genpath(matlabDir));

render_main_figures_only(repoRoot);
make_FigS1_failure_decomposition_by_system(repoRoot);

fprintf('\nReproduction complete.\n');
fprintf('Results folder: %s\n', fullfile(repoRoot, 'results'));
fprintf('Figures folder: %s\n', fullfile(repoRoot, 'figures'));
