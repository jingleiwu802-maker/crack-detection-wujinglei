%TRAINCRACKUNET Train a shallow weighted U-Net on paired CRACK500 crops.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(fullfile(repoRoot,'config'));
addpath(scriptDir);

cfg = defaultConfig();
rng(cfg.random_seed);
[imds, pxds, classNames] = prepareSegmentationData(cfg.train_crop_dir);

% Split indices before augmentation to keep validation independent.
n = numel(imds.Files);
order = randperm(n);
nTrain = max(1, floor(0.8*n));
trainIndex = order(1:nTrain);
validationIndex = order(nTrain+1:end);
assert(~isempty(validationIndex), 'At least two training pairs are required.');

imdsTrain = subset(imds,trainIndex);
pxdsTrain = subset(pxds,trainIndex);
imdsValidation = subset(imds,validationIndex);
pxdsValidation = subset(pxds,validationIndex);

classTable = countEachLabel(pxdsTrain);
frequency = classTable.PixelCount ./ classTable.ImagePixelCount;
classWeights = median(frequency) ./ frequency;
classWeights = dlarray(classWeights(:)','C');
lossFunction = @(Y,T) crossentropy(Y,T,classWeights, ...
    NormalizationFactor="all-elements");

trainingPairs = transform(combine(imdsTrain,pxdsTrain),@augmentPair);
trainingData = transform(trainingPairs,@encodeLabels);
validationPairs = transform(combine(imdsValidation,pxdsValidation), ...
    @(data) resizePair(data,[256 256]));
validationData = transform(validationPairs,@encodeLabels);

net = unet([256 256 3],numel(classNames),EncoderDepth=2);
options = trainingOptions('adam', ...
    'MaxEpochs',10, ...
    'MiniBatchSize',2, ...
    'InitialLearnRate',1e-3, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationData, ...
    'ValidationFrequency',max(1,floor(nTrain/2)), ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment','auto');

net = trainnet(trainingData,net,lossFunction,options);
modelPath = fullfile(cfg.model_dir,'crack_unet.mat');
save(modelPath,'net','classNames');
fprintf('Saved U-Net: %s\n',modelPath);

function output = resizePair(data,targetSize)
image = data{1};
labels = data{2};
if size(image,3) == 1
    image = repmat(image,[1 1 3]);
end
output = {imresize(image,targetSize,'bilinear'), ...
          imresize(labels,targetSize,'nearest')};
end

