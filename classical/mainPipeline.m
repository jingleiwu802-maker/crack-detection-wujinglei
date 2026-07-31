function output = mainPipeline(cfg, imagePath, maskPath)
%MAINPIPELINE Run all classical crack segmentation methods on one image.

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'config'));
addpath(fullfile(repoRoot, 'evaluation'));
addpath(fullfile(repoRoot, 'classical', 'utils'));

if nargin < 1 || isempty(cfg)
    cfg = defaultConfig();
end

if nargin < 2 || isempty(imagePath)
    files = dir(fullfile(cfg.test_dir, ['*' cfg.image_extension]));
    assert(~isempty(files), 'No test images found in %s.', cfg.test_dir);
    imagePath = fullfile(files(1).folder, files(1).name);
end

if nargin < 3 || isempty(maskPath)
    [folder, name] = fileparts(imagePath);
    maskPath = fullfile(folder, [name cfg.mask_suffix cfg.mask_extension]);
end

assert(isfile(imagePath), 'Image not found: %s', imagePath);
assert(isfile(maskPath), 'Ground-truth mask not found: %s', maskPath);

rgb = imread(imagePath);
gt  = imread(maskPath);
[rgb, gt] = normaliseSize(rgb, gt, cfg.target_size);

gray = im2double(rgb2gray(rgb));
if cfg.gaussian_sigma > 0
    processed = imgaussfilt(gray, cfg.gaussian_sigma);
else
    processed = gray;
end

maskOtsu = segmentOtsu(processed);
claheImage = adapthisteq(processed, ...
    'ClipLimit', cfg.clahe_clip, 'NumTiles', cfg.clahe_tiles);
maskCanny = segmentCanny(claheImage, cfg.canny_threshold);
maskSauvola = segmentSauvola(processed, cfg);
maskFinal = refineMask(maskSauvola, cfg);
[skeleton, crackStats] = analyseCracks(maskFinal, cfg);

names = ["Otsu","CLAHE + Canny","Sauvola raw","Sauvola + morphology"];
masks = {maskOtsu, maskCanny, maskSauvola, maskFinal};
metrics = zeros(numel(masks), 6);
for k = 1:numel(masks)
    metrics(k,:) = computeBinaryMetrics(masks{k}, gt);
end

metricsTable = array2table(metrics, ...
    'VariableNames', {'Precision','Recall','F1','IoUCrack','IoUBackground','mIoU'}, ...
    'RowNames', cellstr(names));
disp(metricsTable);

if cfg.show_figures
    showPipelineFigure(rgb, gt, processed, masks, names, cfg);
end

output.imagePath = imagePath;
output.groundTruth = gt;
output.masks = masks;
output.methodNames = names;
output.metrics = metricsTable;
output.skeleton = skeleton;
output.crackStats = crackStats;
end

function showPipelineFigure(rgb, gt, processed, masks, names, cfg)
fig = figure('Name','Classical crack detection','NumberTitle','off');
tiledlayout(2,4, 'Padding','compact');
nexttile; imshow(rgb); title('Input');
nexttile; imshow(processed); title('Processed grayscale');
nexttile; imshow(gt); title('Ground truth');
nexttile; imshow(labeloverlay(rgb, logical(gt))); title('Ground-truth overlay');
for k = 1:numel(masks)
    nexttile; imshow(masks{k}); title(names(k));
end
exportgraphics(fig, fullfile(cfg.results_dir, 'single_image_pipeline.png'));
end

