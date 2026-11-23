clear;clc;close;
rho=[1420.6	279.9	53.9	63	61.1	57.9	39.5	31.4	21.2
238.7	3782.1	432.2	92	94.56	74.8	60.7	49	33
111.6	455.9	9000.56	616.9	135.56	108.6	79.22	64.2	39.1
78.5	193.8	737	18441.2	764.6	169.2	111.5	78.1	61.1
80.6	107.3	236	922.3	23866	472.1	142.3	111.2	71.44
60.5	91.22	124	253	1184.67	19084.4	714.2	109.5	85.2
50.7	66.9	85.9	113.2	160.4	1305.2	9272.4	675.3	79.8
35.7	42.7	65.8	82	104.4	158.7	832.2	3891.1	474.6
21.3	32.9	41.1	56.9	67.4	61	112.9	395.8	1350.25];


addpath('C:\Users\16943\Documents\quantum randomness\code');
specialL = [-4 0 4];

ellSignal = -4:4;
ellIdler  =  4:-1:-4;

[SignalGrid, IdlerGrid] = ndgrid(ellSignal, ellIdler);

mask = ismember(SignalGrid, specialL) | ismember(IdlerGrid, specialL);

highlightEll = [SignalGrid(mask), IdlerGrid(mask)];
% plot_coincidence_bar3(rho, ...
%     'ColorMap', mymap("cmocean_deep"), ...
%     'HighlightEll', highlightEll,...
%     'ShowColorbar', false);


plot_coincidence_bar3(rho, ...
     'ColorMap', mymap("cmocean_deep"), ...
    'HighlightEll', highlightEll,...
    'ShowColorbar', false, ...
    'FontSize', 40, ...
    'LabelPositions', [5 11.5 0; -2.0 5 0]);

function [ax, c] = plot_coincidence_bar3(rho, varargin)
%PLOT_COINCIDENCE_BAR3 Draw an adaptive 3-D coincidence bar chart.
%
%   ax = plot_coincidence_bar3(rho)
%   ax = plot_coincidence_bar3(rho, 'ShowValues', true)
%   ax = plot_coincidence_bar3(rho, 'ColorMap', mymap('MPL_PuBu'))
%   [ax, c] = plot_coincidence_bar3(rho, 'ShowColorbar', true)
%   ax = plot_coincidence_bar3(rho, 'HighlightIndices', [5 5; 4 6])
%   ax = plot_coincidence_bar3(rho, 'HighlightEll', [0 0; 1 -1])
%
% The matrix size is inferred automatically. X ticks correspond to columns,
% and Y ticks correspond to rows. Tick labels are centered integers, e.g.
% 11 columns -> -5:5, 9 columns -> -4:4.

p = inputParser;
addRequired(p, 'rho', @(x) isnumeric(x) && ismatrix(x));
addParameter(p, 'ShowValues', false, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'BarWidth', 0.82, @(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p, 'View', [-45 32], @(x) isnumeric(x) && numel(x) == 2);
addParameter(p, 'ColorMap', [], @(x) isempty(x) || (isnumeric(x) && size(x, 2) == 3));
addParameter(p, 'ShowColorbar', true, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'HighlightIndices', [], @(x) isempty(x) || (isnumeric(x) && size(x, 2) == 2));
addParameter(p, 'HighlightEll', [], @(x) isempty(x) || (isnumeric(x) && size(x, 2) == 2));
addParameter(p, 'HighlightLocation', 'top', @(x) ischar(x) || isstring(x));
addParameter(p, 'HighlightColor', [0.62 0.62 0.62], @(x) isnumeric(x) && numel(x) == 3);
addParameter(p, 'HighlightLineWidth', 0.8, @(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p, 'HighlightAlpha', 0.28, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
addParameter(p, 'HighlightColumnHeight', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
addParameter(p, 'HighlightRemoveColor', true, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'CenterLabels', true, @(x) islogical(x) || isnumeric(x));
addParameter(p, 'LabelPositions', [], @(x) isempty(x) || (isnumeric(x) && isequal(size(x), [2 3])));
addParameter(p, 'LabelRotations', [0 -35], @(x) isnumeric(x) && numel(x) == 2);
addParameter(p, 'FontSize', 36, @(x) isnumeric(x) && isscalar(x) && x > 0);
addParameter(p, 'TickLabelRotations', [0 0], @(x) isnumeric(x) && numel(x) == 2);
addParameter(p, 'TickLabelGap', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0));
parse(p, rho, varargin{:});

rho = double(p.Results.rho);

showValues = logical(p.Results.ShowValues);
barWidth = p.Results.BarWidth;
viewAngles = p.Results.View;
colorMap = p.Results.ColorMap;
showColorbar = logical(p.Results.ShowColorbar);
highlightIndices = p.Results.HighlightIndices;
highlightEll = p.Results.HighlightEll;
highlightLocation = char(p.Results.HighlightLocation);
highlightColor = p.Results.HighlightColor;
highlightLineWidth = p.Results.HighlightLineWidth;
highlightAlpha = p.Results.HighlightAlpha;
highlightColumnHeight = p.Results.HighlightColumnHeight;
highlightRemoveColor = logical(p.Results.HighlightRemoveColor);
centerLabels = logical(p.Results.CenterLabels);
labelPositions = p.Results.LabelPositions;
labelRotations = p.Results.LabelRotations;
fontSize = p.Results.FontSize;
tickLabelRotations = p.Results.TickLabelRotations;
tickLabelGap = p.Results.TickLabelGap;
c = [];

[rows, cols] = size(rho);
if mod(cols, 2) == 1
    xHalfWidth = floor(cols / 2);
    xLabels = -xHalfWidth:xHalfWidth;
else
    xLabels = (1:cols) - (cols / 2 + 1);
end
xLabels = fliplr(xLabels);

if mod(rows, 2) == 1
    yHalfWidth = floor(rows / 2);
    yLabels = -yHalfWidth:yHalfWidth;
else
    yLabels = (1:rows) - (rows / 2 + 1);
end

if ~isempty(highlightEll)
    highlightFromEll = nan(size(highlightEll));
    for idx = 1:size(highlightEll, 1)
        ellSignal = highlightEll(idx, 1);
        ellIdler = highlightEll(idx, 2);

        rowMatch = find(yLabels == ellSignal, 1);
        colMatch = find(xLabels == ellIdler, 1);

        if ~isempty(rowMatch) && ~isempty(colMatch)
            highlightFromEll(idx, :) = [rowMatch, colMatch];
        end
    end
    highlightFromEll = highlightFromEll(~any(isnan(highlightFromEll), 2), :);
    highlightIndices = [highlightIndices; highlightFromEll];
end

highlightMask = false(rows, cols);
rhoForBars = rho;
if highlightRemoveColor && ~isempty(highlightIndices)
    for idx = 1:size(highlightIndices, 1)
        i = highlightIndices(idx, 1);
        j = highlightIndices(idx, 2);

        if i >= 1 && i <= rows && j >= 1 && j <= cols
            highlightMask(i, j) = true;
            rhoForBars(i, j) = 0;
        end
    end
end

figure('Color', 'w');
ax = axes('Color', 'w');
axes(ax);
b = bar3(rhoForBars, barWidth);
hold(ax, 'on');

for k = 1:numel(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
    b(k).EdgeColor = [0.25 0.25 0.25];
    b(k).LineWidth = 0.45;
end

zTop = 25000;
zStep = 5000;
zTicks = 0:zStep:zTop;

if ~isempty(colorMap)
    axes(ax);
    colormap(colorMap);
end
caxis([0 zTop]);

if showColorbar
    c = colorbar(ax);
    try
        set(c, 'TickDirection', 'out', ...
               'Ticks', zTicks, ...
               'TickLabels', cellstr(num2str(zTicks(:), '%d')), ...
               'FontName', 'Times New Roman', ...
               'FontSize', fontSize);
    catch
        set(c, 'tickdir', 'out');
        set(c, 'YTick', zTicks);
        set(c, 'YTickLabel', cellstr(num2str(zTicks(:), '%d')), ...
               'FontName', 'Times New Roman', ...
               'FontSize', fontSize);
    end
end

xlim(ax, [0.5 cols + 0.5]);
ylim(ax, [0.5 rows + 0.5]);
zlim(ax, [0 zTop]);

set(ax, 'XTick', 1:cols, ...
        'YTick', 1:rows, ...
        'ZTick', zTicks, ...
        'XTickLabel', repmat({''}, cols, 1), ...
        'YTickLabel', repmat({''}, rows, 1), ...
        'ZTickLabel', cellstr(num2str(zTicks(:), '%d')));

% X/Y labels are added later as 3-D text so their positions and rotations
% remain tied to the plotted axes after resizing.
xlabel(ax, '');
ylabel(ax, '');
hZLabel = zlabel(ax, 'Coincidence (s^{-1})', 'Interpreter', 'tex');
set(hZLabel, 'FontName', 'Times New Roman', 'FontSize', fontSize);

view(ax, viewAngles(1), viewAngles(2));
grid(ax, 'on');
box(ax, 'on');

ax.FontName = 'Times New Roman';
ax.FontSize = fontSize;
ax.LineWidth = 0.8;
ax.GridColor = [0.72 0.72 0.72];
ax.GridAlpha = 0.75;
ax.XMinorGrid = 'off';
ax.YMinorGrid = 'off';
ax.ZMinorGrid = 'off';
ax.TickDir = 'out';
ax.TickLength = [0.012 0.012];

% Keep X/Y visually equal without forcing the Z scale to match them.
pbaspect(ax, [1.0 1.0 0.9]);
daspect(ax, 'auto');

if isempty(tickLabelGap)
    tickLabelGap = max(0.45, 0.018 * fontSize);
end

for j = 1:cols
    text(ax, j, rows + 0.5 + tickLabelGap, 0, sprintf('%d', xLabels(j)), ...
        'Interpreter', 'tex', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', tickLabelRotations(1), ...
        'Clipping', 'off');
end

for i = 1:rows
    text(ax, 0.5 - tickLabelGap, i, 0, sprintf('%d', yLabels(i)), ...
        'Interpreter', 'tex', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', tickLabelRotations(2), ...
        'Clipping', 'off');
end

if centerLabels
    drawnow;
    if isempty(labelPositions)
        xMid = (cols + 1) / 2;
        yMid = (rows + 1) / 2;
        xLabelGap = max(1.7, 0.18 * rows);
        yLabelGap = max(1.7, 0.18 * cols);
        labelPositions = [xMid, rows + xLabelGap, 0; ...
                          0.5 - yLabelGap, yMid, 0];
    end

    text(ax, labelPositions(1, 1), labelPositions(1, 2), labelPositions(1, 3), ...
        'Bob', ...
        'Interpreter', 'tex', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', labelRotations(1), ...
        'Clipping', 'off');

    text(ax, labelPositions(2, 1), labelPositions(2, 2), labelPositions(2, 3), ...
        'Alice', ...
        'Interpreter', 'tex', ...
        'FontName', 'Times New Roman', ...
        'FontSize', fontSize, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Rotation', labelRotations(1), ...
        'Clipping', 'off');
end

if showValues
    for j = 1:cols
        for i = 1:rows
            val = rho(i, j);
            if val == 0
                continue
            end
            if highlightRemoveColor && highlightMask(i, j)
                continue
            end

            text(ax, j, i, val, sprintf('%.3g', val), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', ...
                'FontName', 'Times New Roman', ...
                'FontSize', fontSize, ...
                'Color', [0 0 0]);
        end
    end
end

if ~isempty(highlightIndices)
    highlightPad = 0.03;
    halfWidth = barWidth / 2 + highlightPad;
    edgeColor = max(highlightColor * 0.55, [0 0 0]);

    for idx = 1:size(highlightIndices, 1)
        i = highlightIndices(idx, 1);
        j = highlightIndices(idx, 2);

        if i < 1 || i > rows || j < 1 || j > cols
            continue
        end

        x1 = j - halfWidth;
        x2 = j + halfWidth;
        y1 = i - halfWidth;
        y2 = i + halfWidth;
        z1 = 0;
        if isempty(highlightColumnHeight)
            z2 = rho(i, j);
        else
            z2 = highlightColumnHeight;
        end
        z2 = min(z2, zTop);

        vertices = [x1 y1 z1;
                    x2 y1 z1;
                    x2 y2 z1;
                    x1 y2 z1;
                    x1 y1 z2;
                    x2 y1 z2;
                    x2 y2 z2;
                    x1 y2 z2];

        faces = [1 2 3 4;
                 5 6 7 8;
                 1 2 6 5;
                 2 3 7 6;
                 3 4 8 7;
                 4 1 5 8];

        patch('Parent', ax, ...
              'Vertices', vertices, ...
              'Faces', faces, ...
              'FaceColor', highlightColor, ...
              'FaceAlpha', highlightAlpha, ...
              'EdgeColor', edgeColor, ...
              'LineWidth', highlightLineWidth);
    end
end

hold(ax, 'off');
end
