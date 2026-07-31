function metrics = computeBinaryMetrics(prediction, groundTruth)
%COMPUTEBINARYMETRICS Return [P R F1 crack-IoU background-IoU mIoU].

prediction = logical(prediction);
groundTruth = logical(groundTruth);

if ~isequal(size(prediction), size(groundTruth))
    prediction = imresize(prediction, size(groundTruth), 'nearest');
end

TP = nnz(prediction & groundTruth);
FP = nnz(prediction & ~groundTruth);
FN = nnz(~prediction & groundTruth);
TN = nnz(~prediction & ~groundTruth);

precision = TP / max(TP + FP, 1);
recall = TP / max(TP + FN, 1);
f1 = 2 * precision * recall / max(precision + recall, eps);
iouCrack = TP / max(TP + FP + FN, 1);
iouBackground = TN / max(TN + FP + FN, 1);
mIoU = (iouCrack + iouBackground) / 2;

metrics = [precision, recall, f1, iouCrack, iouBackground, mIoU];
end

