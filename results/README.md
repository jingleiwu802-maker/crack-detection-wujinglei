# Classical Crack Detection Results

MATLAB R2026a evaluation on 20 CRACK500 test images at 256 x 256 working
resolution. The experiment was executed with `run_classical.m`.

| Method | Precision | Recall | F1 | Crack IoU | mIoU |
|---|---:|---:|---:|---:|---:|
| Otsu | 0.0503 | 0.9267 | 0.0929 | 0.0499 | 0.2799 |
| CLAHE + Canny | 0.0798 | 0.1113 | 0.0850 | 0.0453 | 0.4914 |
| Sauvola raw | 0.4771 | 0.5829 | 0.4581 | 0.3139 | 0.6369 |
| **Sauvola + morphology** | **0.6516** | 0.4430 | **0.4824** | **0.3311** | **0.6546** |

The best overall classical method by F1 and mean IoU was Sauvola adaptive
thresholding followed by morphological area filtering and closing.

- `classical_summary.csv`: mean and standard deviation for every method.
- `classical_per_image.csv`: metrics for each test image and method.

These values are experimental results for the selected 20-image subset. They
should not be compared directly with results produced at a different image
resolution or on a different test subset.
