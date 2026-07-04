function sg_exportFigure(fig, outPath, resolution)
%SG_EXPORTFIGURE Export a MATLAB figure robustly.

if nargin < 3 || isempty(resolution)
    resolution = 600;
end

[folder, ~, ~] = fileparts(outPath);
if ~exist(folder, 'dir')
    mkdir(folder);
end

try
    exportgraphics(fig, outPath, 'Resolution', resolution);
catch
    [folder, name, ~] = fileparts(outPath);
    print(fig, fullfile(folder, name), '-dpng', sprintf('-r%d', resolution));
end
end
