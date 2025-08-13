% ===== FEATURE EXTRACTION (your style, pick one CNN) =====
% === USER: EDIT THESE TWO LINES BELOW ===
modelName  = 'efficientnetb0';  
% <- choose: 'efficientnetb0','resnet18','resnet50','resnet101','googlenet',
% 'inceptionresnetv2','alexnet','darknet19','darknet53'

dataFolder = 'C:\YOUR\PATH\TO\DATASET';  
% <- FULL PATH to your dataset folder. 
% Example: 'D:\MyProject\Dataset\All_Distortion'
% Must contain subfolders for each class.

% ========================================

% Load Data
close all; clc; clear all;
imds = imageDatastore(dataFolder,'IncludeSubfolders',true,'LabelSource','foldernames');

% Load Pretrained Network (auto-picks the correct deepest layer)
switch lower(modelName)
    case 'efficientnetb0'
        net = efficientnetb0;
        layer = 'efficientnet-b0|model|head|global_average_pooling2d|GlobAvgPool';

    case 'resnet18'
        net = resnet18;
        layer = 'pool5';

    case 'resnet50'
        net = resnet50;
        layer = 'avg_pool';

    case 'resnet101'
        net = resnet101;
        layer = 'pool5';

    case 'googlenet'
        net = googlenet;
        layer = 'pool5-7x7_s1';

    case 'inceptionresnetv2'
        net = inceptionresnetv2;
        layer = 'global_average_pooling2d_1';

    case 'alexnet'
        net = alexnet;
        layer = 'pool5';

    case 'darknet19'
        % NOTE: You must have a DarkNet-19 network available in MATLAB.
        net = darknet19();           
        layer = 'avg1';

    case 'darknet53'
        % NOTE: You must have a DarkNet-53 network available in MATLAB.
        net = darknet53();           
        layer = 'avg1';

    otherwise
        error('Unknown modelName: %s', modelName);
end

inputSize = net.Layers(1).InputSize;
analyzeNetwork(net);   % optional; comment out if you don’t need the viewer

% Extract Image Features
augimds  = augmentedImageDatastore(inputSize(1:2), imds, 'ColorPreprocessing','gray2rgb');
features = activations(net, augimds, layer, OutputAs="rows");

% Retrieve image filenames
[~, imageNames, ~] = cellfun(@fileparts, imds.Files, 'UniformOutput', false);

% (optional) show sizes
disp(size(features));
disp(numel(imageNames));
