function [imds, pxds, classNames] = prepareSegmentationData(imageDir)
%PREPARESEGMENTATIONDATA Match crop images to their pixel masks.

imageListing = dir(fullfile(imageDir, '*.jpg'));
assert(~isempty(imageListing), 'No JPG images found in %s.', imageDir);
imageFiles = fullfile(imageDir, {imageListing.name});
[~, basenames] = cellfun(@fileparts, imageFiles, 'UniformOutput',false);
labelFiles = cellfun(@(name) fullfile(imageDir, [name '.png']), ...
    basenames, 'UniformOutput',false);
assert(all(cellfun(@isfile,labelFiles)), ...
    'One or more image masks are missing in %s.', imageDir);

sampleMask = imread(labelFiles{1});
uniqueValues = unique(sampleMask(:));
if all(ismember(uniqueValues, [0 1]))
    labelIDs = [0 1];
elseif all(ismember(uniqueValues, [0 255]))
    labelIDs = [0 255];
else
    error('Unsupported mask values: %s', mat2str(uniqueValues'));
end

classNames = ["background","crack"];
imds = imageDatastore(imageFiles);
pxds = pixelLabelDatastore(labelFiles, classNames, labelIDs);
end

