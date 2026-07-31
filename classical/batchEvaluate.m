function summaryTable = batchEvaluate(cfg)
%BATCHEVALUATE Evaluate classical methods over a CRACK500 test directory.

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'config'));
addpath(fullfile(repoRoot, 'evaluation'));
addpath(fullfile(repoRoot, 'classical'));
addpath(fullfile(repoRoot, 'classical', 'utils'));

if nargin < 1 || isempty(cfg)
    cfg = defaultConfig();
end

cfg.show_figures = false;
files = dir(fullfile(cfg.test_dir, ['*' cfg.image_extension]));
N = min(numel(files), cfg.max_test_images);
assert(N > 0, 'No test images found in %s.', cfg.test_dir);

methodNames = ["Otsu","CLAHE + Canny","Sauvola raw","Sauvola + morphology"];
metricNames = ["Precision","Recall","F1","IoUCrack","IoUBackground","mIoU"];
values = nan(N, numel(methodNames), numel(metricNames));
imageNames = strings(N,1);

for i = 1:N
    imagePath = fullfile(files(i).folder, files(i).name);
    [folder, name] = fileparts(imagePath);
    maskPath = fullfile(folder, [name cfg.mask_suffix cfg.mask_extension]);
    imageNames(i) = files(i).name;

    if ~isfile(maskPath)
        warning('Skipping %s: mask not found.', files(i).name);
        continue;
    end

    result = mainPipeline(cfg, imagePath, maskPath);
    values(i,:,:) = reshape(table2array(result.metrics), ...
        1, numel(methodNames), numel(metricNames));
end

rows = N * numel(methodNames);
imageColumn = strings(rows,1);
methodColumn = strings(rows,1);
metricColumns = nan(rows, numel(metricNames));
row = 0;
for i = 1:N
    for m = 1:numel(methodNames)
        row = row + 1;
        imageColumn(row) = imageNames(i);
        methodColumn(row) = methodNames(m);
        metricColumns(row,:) = reshape(values(i,m,:),1,numel(metricNames));
    end
end

perImage = array2table(metricColumns, 'VariableNames', cellstr(metricNames));
perImage = addvars(perImage, imageColumn, methodColumn, ...
    'Before', 1, 'NewVariableNames', {'Image','Method'});
writetable(perImage, fullfile(cfg.results_dir, 'classical_per_image.csv'));

meanMetrics = squeeze(mean(values, 1, 'omitnan'));
stdMetrics  = squeeze(std(values, 0, 1, 'omitnan'));
summaryTable = table(methodNames', ...
    meanMetrics(:,1), stdMetrics(:,1), ...
    meanMetrics(:,2), stdMetrics(:,2), ...
    meanMetrics(:,3), stdMetrics(:,3), ...
    meanMetrics(:,4), stdMetrics(:,4), ...
    meanMetrics(:,6), stdMetrics(:,6), ...
    'VariableNames', {'Method','MeanPrecision','StdPrecision', ...
    'MeanRecall','StdRecall','MeanF1','StdF1', ...
    'MeanIoUCrack','StdIoUCrack','MeanmIoU','StdmIoU'});

disp(summaryTable);
writetable(summaryTable, fullfile(cfg.results_dir, 'classical_summary.csv'));
end
