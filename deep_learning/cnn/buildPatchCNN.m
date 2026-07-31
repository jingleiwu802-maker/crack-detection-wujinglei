function layers = buildPatchCNN()
%BUILDPATCHCNN Compact binary classifier for 64x64 pavement patches.

layers = [
    imageInputLayer([64 64 3], 'Normalization','rescale-zero-one')

    convolution2dLayer(3,16,'Padding','same','Name','conv1')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,32,'Padding','same','Name','conv2')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,64,'Padding','same','Name','conv3')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)

    globalAveragePooling2dLayer
    fullyConnectedLayer(2)
    softmaxLayer
];
end

