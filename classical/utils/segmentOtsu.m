function mask = segmentOtsu(grayImage)
%SEGMENTOTSU Global Otsu baseline for dark cracks.

threshold = graythresh(grayImage);
mask = ~imbinarize(grayImage, threshold);
end

