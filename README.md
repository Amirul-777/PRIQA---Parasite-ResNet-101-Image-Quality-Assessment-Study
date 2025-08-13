# PRIQA---Parasite-ResNet-101-Image-Quality-Assessment-Study

Code and resources for PRIQA, an Image Quality Assessment (IQA) framework for Cryptosporidium and Giardia microscopy images.
The framework supports multiple CNN backbones for feature extraction and uses regression models to map features to Mean Opinion Scores (MOS).

## Repository Structure

- **cnn_model/** — Pretrained/backbone-specific assets (no huge session files committed)
  - AlexNet/
  - DarkNet-19/
  - DarkNet-53/
  - EfficientNet-b0/
  - GoogleNet/
  - Inception-ResNet-v2/
  - ResNet-18/
  - ResNet-50/
  - ResNet-101/
  
- **code/** — Main MATLAB scripts
  - `extract_features.m` — Extracts features from images for a chosen CNN architecture.
  - `make_distortions.m` — Generates distorted images for IQA experiments.
  - `predict_and_evaluate_regressors.m` — Uses pre-extracted features, MOS scores, and trained regressors to predict image quality.

- **MOS/** — Subjective scores and test splits
  - `MOS_New.mat`
  - `Test_MOS_New.mat`


## Supported CNN Architectures

- AlexNet
- DarkNet-19, DarkNet-53
- EfficientNet-B0
- GoogleNet
- Inception-ResNet-v2
- ResNet-18, ResNet-50, ResNet-101

## Quick Start

Option A — Use the provided features/MOS/regressor setup
If you just want to reproduce evaluation with the included features/MOS and preconfigured regressors:
    run('code/predict_and_evaluate_regressors.m')
This script loads the included feature matrices and MOS files and runs the regression and evaluation pipeline (for example, SVM variants and trees).

Option B — Use a different architecture or regenerate features
If you want to try a different CNN backbone or recompute features:
1. (Optional) Create distorted images for benchmarking or augmentation:
       run('code/make_distortions.m')
2. Extract features using your chosen backbone(s):
       run('code/extract_features.m')
   Inside extract_features.m, set the backbone list or selection, for example switch to EfficientNet-B0 or DarkNet-53.
   The script will create feature matrices compatible with the next step.
3. Train and evaluate regressors on your newly extracted features:
       run('code/predict_and_evaluate_regressors.m')

Tip: If you only change the backbone, you typically only need to run extract_features.m and then predict_and_evaluate_regressors.m. make_distortions.m is only necessary if you also want to regenerate the distorted dataset.

## Parameters to Edit

In extract_features.m:
- modelName: Name of the CNN backbone, for example 'resnet101', 'alexnet', 'googlenet'.
- inputSize: Input image resolution for the chosen network.
- batchSize: Batch size for feature extraction.

In make_distortions.m:
- Distortion types (Gaussian noise, blur, contrast changes, and so on) can be enabled or disabled by commenting or uncommenting relevant lines.
- Distortion severity parameters can be tuned.

## Requirements

- MATLAB R2020a or later
- Deep Learning Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

## License

MIT — see LICENSE.

## Acknowledgements

- MATLAB Deep Learning Toolbox and pretrained CNNs
- Human evaluators who contributed MOS ratings
