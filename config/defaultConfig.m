function cfg = defaultConfig()
%DEFAULTCONFIG Shared configuration for all repository workflows.

repoRoot = fileparts(fileparts(mfilename('fullpath')));

cfg.repo_root       = repoRoot;
cfg.data_root       = fullfile(repoRoot, 'data');
cfg.test_dir        = fullfile(cfg.data_root, 'testdata');
cfg.train_crop_dir  = fullfile(cfg.data_root, 'traincrop');
cfg.test_crop_dir   = fullfile(cfg.data_root, 'testcrop');
cfg.patch_dir       = fullfile(cfg.data_root, 'patches');
cfg.results_dir     = fullfile(repoRoot, 'results');
cfg.model_dir       = fullfile(cfg.results_dir, 'models');

cfg.image_extension = '.jpg';
cfg.mask_extension  = '.png';
cfg.mask_suffix     = '_mask';

% Use [480 640] for the original classical-resolution experiment.
cfg.target_size     = [256 256];
cfg.gaussian_sigma  = 0;       % 0 preserves the Wk4 classical baseline
cfg.sauvola_window  = 25;
cfg.sauvola_k       = 0.34;
cfg.sauvola_R       = 0.5;     % input is converted to double in [0,1]
cfg.min_blob_area   = 30;
cfg.close_radius    = 1;
cfg.spur_length     = 5;

cfg.clahe_clip      = 0.02;
cfg.clahe_tiles     = [8 8];
cfg.canny_threshold = [];

cfg.show_figures    = true;
cfg.max_test_images = inf;
cfg.random_seed     = 42;

if ~isfolder(cfg.results_dir)
    mkdir(cfg.results_dir);
end
if ~isfolder(cfg.model_dir)
    mkdir(cfg.model_dir);
end
end

