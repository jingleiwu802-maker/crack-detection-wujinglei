%EVALUATEUNET Compare U-Net and the classical Sauvola baseline.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(fullfile(repoRoot,'config'));
addpath(fullfile(repoRoot,'evaluation'));
addpath(fullfile(repoRoot,'classical','utils'));
addpath(scriptDir);

cfg = defaultConfig();
modelPath = fullfile(cfg.model_dir,'crack_unet.mat');
assert(isfile(modelPath), 'Train the U-Net first: %s',modelPath);
loaded = load(modelPath,'net','classNames');
net = loaded.net;
classNames = loaded.classNames;

[testImages,testLabels] = prepareSegmentationData(cfg.test_crop_dir);
N = min(numel(testImages.Files),cfg.max_test_images);
methodNames = ["Classical","U-Net"];
allMetrics = nan(N,2,6);

for k = 1:N
    image = readimage(testImages,k);
    gt = readimage(testLabels,k) == "crack";
    image = imresize(image,[256 256],'bilinear');
    gt = imresize(gt,[256 256],'nearest');

    if size(image,3) == 3
        gray = im2double(rgb2gray(image));
    else
        gray = im2double(image);
    end
    classicalRaw = segmentSauvola(gray,cfg);
    classicalMask = refineMask(classicalRaw,cfg);

    labels = semanticseg(image,net,Classes=classNames);
    unetMask = labels == "crack";

    allMetrics(k,1,:) = reshape( ...
        computeBinaryMetrics(classicalMask,gt),1,1,6);
    allMetrics(k,2,:) = reshape( ...
        computeBinaryMetrics(unetMask,gt),1,1,6);
end

means = squeeze(mean(allMetrics,1,'omitnan'));
standardDeviations = squeeze(std(allMetrics,0,1,'omitnan'));
comparison = table(methodNames', ...
    means(:,1),standardDeviations(:,1), ...
    means(:,2),standardDeviations(:,2), ...
    means(:,3),standardDeviations(:,3), ...
    means(:,4),standardDeviations(:,4), ...
    means(:,6),standardDeviations(:,6), ...
    'VariableNames',{'Method','MeanPrecision','StdPrecision', ...
    'MeanRecall','StdRecall','MeanF1','StdF1', ...
    'MeanIoUCrack','StdIoUCrack','MeanmIoU','StdmIoU'});

disp(comparison);
writetable(comparison,fullfile(cfg.results_dir,'unet_vs_classical.csv'));
