%SEARCHSAUVOLAPARAMETERS Grid-search Sauvola k and window size by mean F1.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);
addpath(fullfile(repoRoot,'config'));
addpath(fullfile(repoRoot,'evaluation'));
addpath(fullfile(repoRoot,'classical','utils'));

cfg = defaultConfig();
cfg.show_figures = false;
kValues = [0.10 0.20 0.25 0.30 0.34 0.40];
windowValues = [15 25 35 51];

files = dir(fullfile(cfg.test_dir,['*' cfg.image_extension]));
warning(['Parameter search is currently using cfg.test_dir. For a final ' ...
    'report, point cfg.test_dir to a separate validation directory.']);
N = min(numel(files),cfg.max_test_images);
assert(N > 0,'No test images found in %s.',cfg.test_dir);
scores = nan(numel(kValues),numel(windowValues),N);

for a = 1:numel(kValues)
    for b = 1:numel(windowValues)
        localCfg = cfg;
        localCfg.sauvola_k = kValues(a);
        localCfg.sauvola_window = windowValues(b);

        for i = 1:N
            imagePath = fullfile(files(i).folder,files(i).name);
            [folder,name] = fileparts(imagePath);
            maskPath = fullfile(folder, ...
                [name cfg.mask_suffix cfg.mask_extension]);
            if ~isfile(maskPath)
                continue;
            end

            image = imread(imagePath);
            gt = imread(maskPath);
            [image,gt] = normaliseSize(image,gt,cfg.target_size);
            gray = im2double(rgb2gray(image));
            if cfg.gaussian_sigma > 0
                gray = imgaussfilt(gray,cfg.gaussian_sigma);
            end
            prediction = refineMask(segmentSauvola(gray,localCfg),localCfg);
            metrics = computeBinaryMetrics(prediction,gt);
            scores(a,b,i) = metrics(3);
        end
    end
end

meanF1 = mean(scores,3,'omitnan');
[bestF1,index] = max(meanF1(:));
[bestKIndex,bestWindowIndex] = ind2sub(size(meanF1),index);
fprintf('Best k=%.2f, window=%d, mean F1=%.4f\n', ...
    kValues(bestKIndex),windowValues(bestWindowIndex),bestF1);

[K,W] = ndgrid(kValues,windowValues);
results = table(K(:),W(:),meanF1(:), ...
    'VariableNames',{'SauvolaK','WindowSize','MeanF1'});
writetable(results,fullfile(cfg.results_dir,'sauvola_grid_search.csv'));
disp(sortrows(results,'MeanF1','descend'));

figure('Name','Sauvola parameter search');
imagesc(windowValues,kValues,meanF1);
xlabel('Window size'); ylabel('Sauvola k');
title('Mean F1'); colorbar;
exportgraphics(gcf,fullfile(cfg.results_dir,'sauvola_grid_search.png'));
