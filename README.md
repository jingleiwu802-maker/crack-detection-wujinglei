# Pavement Crack Detection: Classical Methods, CNN and U-Net

MATLAB implementation of a pavement-crack analysis workflow developed for
ELEC9773. The repository grows from interpretable classical image processing
to patch classification and pixel-wise semantic segmentation.

## Methods

### Classical segmentation

The default pipeline is:

```text
resize → grayscale → Sauvola thresholding → area filtering
       → morphological closing → skeletonisation → crack measurements
```

Default parameters are inherited from the workshop implementation:

- working size: 256 × 256 for direct comparison with U-Net;
- Sauvola window: 25;
- Sauvola `k`: 0.34;
- minimum component area: 30 pixels;
- morphological closing: disk radius 1.

Otsu and CLAHE + Canny are retained as comparison baselines. A separate
640 × 480 preset is supplied for higher-resolution classical analysis.

### CNN patch classification

A compact three-block CNN classifies 64 × 64 RGB patches as `crack` or
`no_crack`. Training includes rotation, reflection and translation
augmentation.

### U-Net semantic segmentation

A shallow U-Net performs two-class pixel segmentation at 256 × 256. It uses
paired image/mask augmentation and median-frequency class weighting.

## Repository structure

```text
config/
  defaultConfig.m                 Shared paths and parameters
classical/
  mainPipeline.m                  Run all classical methods on one image
  batchEvaluate.m                 Evaluate a test directory
  utils/                          One function per processing stage
deep_learning/
  cnn/trainPatchCNN.m             Train the patch classifier
  cnn/evaluatePatchCNN.m          Evaluate the patch classifier
  unet/trainCrackUNet.m           Train U-Net
  unet/evaluateUNet.m             Compare U-Net with the classical method
evaluation/
  computeBinaryMetrics.m          Precision, recall, F1, IoU and mIoU
experiments/
  searchSauvolaParameters.m       Grid search over k and window size
  claheAblation.m                 Sauvola input ablation
data/                             Dataset placeholder (not committed)
results/                          Generated outputs (not committed)
```

## Dataset layout

Download CRACK500 separately. The default scripts expect:

```text
data/
  testdata/
    image_name.jpg
    image_name_mask.png
  traincrop/
    patch_name.jpg
    patch_name.png
  testcrop/
    patch_name.jpg
    patch_name.png
  patches/
    crack/
    no_crack/
```

If your masks use the same basename as the image without `_mask`, set
`cfg.mask_suffix = ""` in `config/defaultConfig.m`.

## Quick start

Open MATLAB at the repository root. The included `startup.m` adds the project
folders to the MATLAB path. Then run:

```matlab
cfg = defaultConfig();
mainPipeline(cfg);
```

For a test-set comparison:

```matlab
cfg = defaultConfig();
T = batchEvaluate(cfg);
```

The batch script writes per-image and summary CSV files into `results/`.

To tune the classical method on a dedicated validation set:

```matlab
searchSauvolaParameters
claheAblation
```

Do not tune parameters on the final test set when reporting benchmark results.

To train the neural networks:

```matlab
trainPatchCNN
trainCrackUNet
```

The project requires MATLAB, Image Processing Toolbox and Deep Learning
Toolbox. A recent MATLAB release using `trainnet` is recommended.

## Evaluation

All segmentation methods are evaluated with the same definitions:

- precision;
- recall;
- F1 score;
- crack-class IoU;
- background IoU;
- mean IoU.

No benchmark numbers are hard-coded in this repository. Run
`batchEvaluate` or `evaluateUNet` on your local dataset to generate results.

## Reproducibility notes

- Keep training and test source images separate before extracting patches.
- Do not randomly split patches from the same source image across training
  and validation sets.
- Width and length are reported in pixels unless a calibrated
  pixel-to-millimetre scale is supplied.
- Dataset files, trained models and generated results are excluded from Git.

## Author

Wujinglei — ELEC9773 pavement crack detection project.
