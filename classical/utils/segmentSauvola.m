function mask = segmentSauvola(grayImage, cfg)
%SEGMENTSAUVOLA Local thresholding for dark pavement cracks.

I = im2double(grayImage);
w = cfg.sauvola_window;
kernel = fspecial('average', w);
localMean = imfilter(I, kernel, 'replicate');
localSquareMean = imfilter(I.^2, kernel, 'replicate');
localStd = sqrt(max(localSquareMean - localMean.^2, 0));
threshold = localMean .* ...
    (1 + cfg.sauvola_k .* (localStd ./ cfg.sauvola_R - 1));
mask = I < threshold;
end

