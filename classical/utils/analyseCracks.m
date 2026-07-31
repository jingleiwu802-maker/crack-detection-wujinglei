function [skeleton, stats] = analyseCracks(mask, cfg)
%ANALYSECRACKS Measure skeleton length, width, orientation and centroid.

rawSkeleton = bwmorph(mask, 'thin', Inf);
skeleton = bwmorph(rawSkeleton, 'spur', cfg.spur_length);
skeleton = bwmorph(skeleton, 'clean');

components = bwconncomp(skeleton, 8);
distanceMap = bwdist(~mask);
properties = regionprops(components, ...
    'Centroid', 'Orientation', 'Eccentricity');

n = components.NumObjects;
lengthPixels = zeros(n,1);
meanWidthPixels = zeros(n,1);
orientationDegrees = zeros(n,1);
eccentricity = zeros(n,1);
centroid = zeros(n,2);

for k = 1:n
    indices = components.PixelIdxList{k};
    lengthPixels(k) = numel(indices);
    meanWidthPixels(k) = 2 * mean(distanceMap(indices));
    orientationDegrees(k) = properties(k).Orientation;
    eccentricity(k) = properties(k).Eccentricity;
    centroid(k,:) = properties(k).Centroid;
end

stats = table((1:n)', lengthPixels, meanWidthPixels, ...
    orientationDegrees, eccentricity, centroid, ...
    'VariableNames', {'ID','LengthPixels','MeanWidthPixels', ...
    'OrientationDegrees','Eccentricity','Centroid'});
end

