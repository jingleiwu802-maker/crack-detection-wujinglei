%EVALUATEPATCHCNN Evaluate a saved patch classifier.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(fullfile(repoRoot, 'config'));

cfg = defaultConfig();
modelPath = fullfile(cfg.model_dir, 'crack_patch_cnn.mat');
assert(isfile(modelPath), 'Train the model first: %s', modelPath);
loaded = load(modelPath, 'net', 'imdsValidation');
net = loaded.net;
imdsValidation = loaded.imdsValidation;

validationData = augmentedImageDatastore([64 64 3], imdsValidation);
scores = minibatchpredict(net, validationData);
classNames = categories(imdsValidation.Labels);
predicted = scores2label(scores, classNames);
truth = imdsValidation.Labels;

accuracy = mean(predicted == truth);
truthText = string(truth);
predictedText = string(predicted);
TP = nnz(truthText == "crack" & predictedText == "crack");
FP = nnz(truthText ~= "crack" & predictedText == "crack");
FN = nnz(truthText == "crack" & predictedText ~= "crack");
precision = TP / max(TP + FP, 1);
recall = TP / max(TP + FN, 1);
f1 = 2 * precision * recall / max(precision + recall, eps);

metrics = table(accuracy, precision, recall, f1, ...
    'VariableNames', {'Accuracy','Precision','Recall','F1'});
disp(metrics);
writetable(metrics, fullfile(cfg.results_dir, 'patch_cnn_metrics.csv'));

figure('Name','Patch CNN confusion matrix');
confusionchart(truth, predicted);
