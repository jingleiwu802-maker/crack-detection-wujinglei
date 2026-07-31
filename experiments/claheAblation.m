%CLAHEABLATION Compare Sauvola with and without CLAHE preprocessing.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(fullfile(repoRoot,'config'));
addpath(fullfile(repoRoot,'evaluation'));
addpath(fullfile(repoRoot,'classical','utils'));

cfg = defaultConfig();
files = dir(fullfile(cfg.test_dir,['*' cfg.image_extension]));
N = min(numel(files),cfg.max_test_images);
assert(N > 0,'No test images found in %s.',cfg.test_dir);
methodNames = ["Sauvola","CLAHE + Sauvola"];
metrics = nan(N,2,6);

for i = 1:N
    imagePath = fullfile(files(i).folder,files(i).name);
    [folder,name] = fileparts(imagePath);
    maskPath = fullfile(folder,[name cfg.mask_suffix cfg.mask_extension]);
    if ~isfile(maskPath)
        continue;
    end

    image = imread(imagePath);
    gt = imread(maskPath);
    [image,gt] = normaliseSize(image,gt,cfg.target_size);
    gray = im2double(rgb2gray(image));
    enhanced = adapthisteq(gray,'ClipLimit',cfg.clahe_clip, ...
        'NumTiles',cfg.clahe_tiles);
    inputs = {gray,enhanced};

    for m = 1:2
        prediction = refineMask(segmentSauvola(inputs{m},cfg),cfg);
        metrics(i,m,:) = reshape(computeBinaryMetrics(prediction,gt),1,1,6);
    end
end

means = squeeze(mean(metrics,1,'omitnan'));
standardDeviations = squeeze(std(metrics,0,1,'omitnan'));
results = table(methodNames',means(:,1),means(:,2),means(:,3), ...
    standardDeviations(:,3),means(:,4),means(:,6), ...
    'VariableNames',{'Method','Precision','Recall','MeanF1','StdF1', ...
    'IoUCrack','mIoU'});
disp(results);
writetable(results,fullfile(cfg.results_dir,'clahe_ablation.csv'));
