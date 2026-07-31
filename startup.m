%STARTUP Add repository modules to the MATLAB path.

repoRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(repoRoot,'config'));
addpath(fullfile(repoRoot,'classical'));
addpath(fullfile(repoRoot,'classical','utils'));
addpath(fullfile(repoRoot,'evaluation'));
addpath(fullfile(repoRoot,'deep_learning','cnn'));
addpath(fullfile(repoRoot,'deep_learning','unet'));
addpath(fullfile(repoRoot,'experiments'));

fprintf('Pavement Crack Detection project initialised.\n');
fprintf('Repository root: %s\n', repoRoot);
