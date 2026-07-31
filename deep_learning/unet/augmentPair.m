function output = augmentPair(data)
%AUGMENTPAIR Apply identical geometry to an RGB image and label mask.

targetSize = [256 256];
image = data{1};
labels = data{2};
if size(image,3) == 1
    image = repmat(image,[1 1 3]);
end

image = imresize(image,targetSize,'bilinear');
labels = imresize(labels,targetSize,'nearest');
angle = 30 * rand() - 15;
image = imrotate(image,angle,'bilinear','crop');
labels = imrotate(labels,angle,'nearest','crop');
if rand() > 0.5
    image = fliplr(image);
    labels = fliplr(labels);
end
output = {image, labels};
end

