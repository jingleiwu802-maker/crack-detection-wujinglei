function [imageOut, maskOut] = normaliseSize(imageIn, maskIn, targetSize)
%NORMALISESIZE Resize an image and label mask with appropriate interpolation.

imageOut = imresize(imageIn, targetSize, 'bilinear');
if ndims(maskIn) == 3
    maskIn = maskIn(:,:,1);
end
maskOut = imresize(maskIn, targetSize, 'nearest') > 0;
end

