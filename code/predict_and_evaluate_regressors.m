%% ===== PREDICTION + METRICS  =====
close all; clc; clear all;

%% ===== USER: EDIT THESE PATHS =====
featuresMat = 'C:\YOUR\PATH\TO\ResNet-101\Resnet-101_features_test';   % contains variable "features"
mosMat      = 'C:\YOUR\PATH\TO\Test_MOS_New';                          % contains variable "MOS" (vector Nx1 or 1xN)
modelsMat   = 'C:\YOUR\PATH\TO\ResNet-101\Cubic_SVM';                  % contains exported models, refer the cnn files (e.g., Linear_SVM, Quadratic_SVM, ...)
outCSV      = 'C:\YOUR\PATH\TO';                                       % where to save the metrics table
%% ==================================

% (optional) If your variable names differ:
featuresVar = 'features';   % change if your features variable has a different name
mosVar      = 'MOS';        % change if your MOS variable has a different name

% ---- Load data ----
Sfeat = load(featuresMat);
assert(isfield(Sfeat, featuresVar), 'Variable "%s" not found in %s', featuresVar, featuresMat);
features = double(Sfeat.(featuresVar));

Sm = load(mosMat);
assert(isfield(Sm, mosVar), 'Variable "%s" not found in %s', mosVar, mosMat);
MOS = double(Sm.(mosVar)); MOS = MOS(:);   % make column

% ---- Load models (exported from Regression Learner) ----
M = load(modelsMat);

% ===== USER: PICK WHICH MODELS TO EVALUATE =====
% Put the variable names that exist inside the cnn network file. Ex: If
% Ex: If you choose ResNet-101, there is Cubic_SVM.mat file
model_names = { ...
    % 'Linear_SVM', ...
    % 'Quadratic_SVM', ...
    % 'Cubic_SVM', ...
    % 'Fine_Gaussian_SVM', ...
    % 'Medium_Gaussian_SVM', ...
    % 'Coarse_Gaussian_SVM', ...
    % 'Fine_Tree', ...
    % 'Medium_Tree', ...
    % 'Coarse_Tree' ...
    % 'Linear'                % choose only one regressor models, the rest will be comments

};

% ---- Sanity checks ----
N = size(features,1);
assert(numel(MOS) == N, 'MOS length (%d) must match number of feature rows (%d).', numel(MOS), N);

% ---- Loop and evaluate ----
plcc = zeros(numel(model_names),1);
srocc = zeros(numel(model_names),1);
krocc = zeros(numel(model_names),1);
rmse = zeros(numel(model_names),1);

pred_store = cell(numel(model_names),1);

for i = 1:numel(model_names)
    name = model_names{i};
    assert(isfield(M, name), 'Model "%s" not found in %s', name, modelsMat);
    mdl = M.(name);
    assert(isfield(mdl, 'predictFcn'), 'Model "%s" has no predictFcn.', name);

    yhat = mdl.predictFcn(features);          % predict
    yhat = double(yhat(:));                   % column
    pred_store{i} = yhat;

    % metrics
    plcc(i)  = corr(MOS, yhat, 'type', 'Pearson');
    srocc(i) = corr(MOS, yhat, 'type', 'Spearman');
    krocc(i) = corr(MOS, yhat, 'type', 'Kendall');
    rmse(i)  = sqrt(mean((MOS - yhat).^2));
end

% ---- Show results ----
T = table(model_names(:), plcc, srocc, krocc, rmse, ...
    'VariableNames', {'Model','PLCC','SROCC','KROCC','RMSE'});
disp(T);

% ---- Save metrics to CSV ----
try
    writetable(T, outCSV);
    fprintf('Metrics saved to: %s\n', outCSV);
catch
    warning('Could not write CSV to: %s', outCSV);
end

