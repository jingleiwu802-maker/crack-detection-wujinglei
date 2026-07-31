%% Run Classical Pavement Crack Detection
% Runs Otsu, CLAHE+Canny, Sauvola and Sauvola+morphology on CRACK500.
% No CNN or U-Net training is performed by this script.

clear;
clc;
close all;

%% Initialise project
repoRoot = fileparts(mfilename('fullpath'));
cd(repoRoot);
run(fullfile(repoRoot, 'startup.m'));

%% Configuration
cfg = defaultConfig();

% Location of the local CRACK500 test set.
cfg.test_dir = fullfile('/Users/wujinglei/Desktop', ...
    'pavement-crack-detection-master', 'crack', ...
    'pavement crack datasets', 'CRACK500', 'testdata');

% Use 20 images to match the comparison experiment in the reference repo.
% Change this to inf to evaluate every lowercase .jpg image in testdata.
cfg.max_test_images = 20;

% Classical parameters inherited from the workshop implementation.
cfg.target_size     = [256 256];
cfg.gaussian_sigma  = 0;
cfg.sauvola_window  = 25;
cfg.sauvola_k       = 0.34;
cfg.sauvola_R       = 0.5;
cfg.min_blob_area   = 30;
cfg.close_radius    = 1;
cfg.show_figures    = false;

assert(isfolder(cfg.test_dir), ...
    'CRACK500 test directory not found: %s', cfg.test_dir);

%% Run all classical methods and save CSV results
fprintf('\nRunning classical crack detection on up to %d images...\n', ...
    cfg.max_test_images);
summaryTable = batchEvaluate(cfg);

fprintf('\nClassical evaluation complete.\n');
fprintf('Summary:   %s\n', ...
    fullfile(cfg.results_dir, 'classical_summary.csv'));
fprintf('Per image: %s\n', ...
    fullfile(cfg.results_dir, 'classical_per_image.csv'));

disp(summaryTable);
