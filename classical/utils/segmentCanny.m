function mask = segmentCanny(grayImage, thresholds)
%SEGMENTCANNY Canny baseline using the median threshold heuristic.

if nargin < 2 || isempty(thresholds)
    medianIntensity = median(grayImage(:));
    thresholds = [max(0, 0.66 * medianIntensity), ...
                  min(1, 1.33 * medianIntensity)];
end
mask = edge(grayImage, 'Canny', thresholds);
end

