%% ===== DISTORTION GENERATOR  =====
% EDIT THESE PATHS:
inputFolderPath  = 'C:\YOUR\PATH\TO\ReferenceImages'; % folder with pristine .jpg
outputRoot       = 'C:\YOUR\PATH\TO\New Distorted Images'; % root where outputs will be saved

% OPTIONAL: tweak distortion levels (kept same style as your code)
gwn_levels       = 10:10:90;         % Gaussian White Noise std on 0–255 scale
snp_levels       = 0.01:0.01:0.09;   % Salt & Pepper density
speckle_levels   = 0.01:0.01:0.09;   % Speckle variance
jpeg_start       = 10;               % initial JPEG quality
jpeg_inc         = 5;                % quality increment
jpeg_numLevels   = 9;                % number of quality levels

saveMAT          = true;             % save .mat alongside images (like your scripts)

%% =============================================
clear all; close all; clc;

% Prepare output folder structure (same naming as yours)
outGWN_img = fullfile(outputRoot,'Gaussian White Noise','Images');
outGWN_mat = fullfile(outputRoot,'Gaussian White Noise','Matlab Data');

outSNP_img = fullfile(outputRoot,'Salt and Pepper','Images');
outSNP_mat = fullfile(outputRoot,'Salt and Pepper','Matlab Data');

outSPK_img = fullfile(outputRoot,'Speckle Noise','Images');
outSPK_mat = fullfile(outputRoot,'Speckle Noise','Matlab Data');

outJPG_img = fullfile(outputRoot,'JPEG Compression','Images');
outJPG_mat = fullfile(outputRoot,'JPEG Compression','Matlab Data');

% Make folders if missing
cellfun(@(p) ifNotExistMkDir(p), {outGWN_img,outGWN_mat,outSNP_img,outSNP_mat,outSPK_img,outSPK_mat,outJPG_img,outJPG_mat});

% Read input images
imageFiles = dir(fullfile(inputFolderPath,'*.jpg'));
if isempty(imageFiles)
    error('No .jpg found in: %s', inputFolderPath);
end

% ===== MAIN LOOP =====
for fileIdx = 1:numel(imageFiles)
    % Read the image
    filename  = imageFiles(fileIdx).name;
    imagePath = fullfile(inputFolderPath, filename);
    Ref_im    = imread(imagePath);

    % ---- Save the reference (as in your code) into each distortion group ----
    % (Image)
    imwrite(Ref_im, fullfile(outGWN_img, sprintf('%d.jpg', fileIdx)));
    imwrite(Ref_im, fullfile(outSNP_img, sprintf('%d.jpg', fileIdx)));
    imwrite(Ref_im, fullfile(outSPK_img, sprintf('%d.jpg', fileIdx)));
    imwrite(Ref_im, fullfile(outJPG_img, sprintf('%d.jpg', fileIdx)));
    % (MAT)
    if saveMAT
        save(fullfile(outGWN_mat, sprintf('%d.mat', fileIdx)), 'Ref_im');
        save(fullfile(outSNP_mat, sprintf('%d.mat', fileIdx)), 'Ref_im');
        save(fullfile(outSPK_mat, sprintf('%d.mat', fileIdx)), 'Ref_im');
        save(fullfile(outJPG_mat, sprintf('%d.mat', fileIdx)), 'Ref_im');
    end

    % Convert to double for noise ops (keep color)
    Ref_d = double(Ref_im);
    Ref_d = (Ref_d / max(Ref_d(:))) * 255;   % scale like your GWN code
    Ref_01 = double(Ref_im)/255;             % for imnoise (expects [0,1])

    %% ---- GAUSSIAN WHITE NOISE  ----
    for sgb = gwn_levels
        gwn_img = uint8(Ref_d + sgb * randn(size(Ref_d)));
        imwrite(gwn_img, fullfile(outGWN_img, sprintf('%d-%d-GWN.jpg', fileIdx, sgb)));
        if saveMAT
            save(fullfile(outGWN_mat, sprintf('%d-%d-GWN.mat', fileIdx, sgb)), 'gwn_img');
        end
    end

    %% ---- SALT AND PEPPER ----
    for noiseLevel = snp_levels
        snp_img = imnoise(Ref_01, 'salt & pepper', noiseLevel);
        snp_img_uint8 = uint8(snp_img * 255);
        imwrite(snp_img_uint8, fullfile(outSNP_img, sprintf('%d-%g-SNP.jpg', fileIdx, noiseLevel)));
        if saveMAT
            save(fullfile(outSNP_mat, sprintf('%d-%g-SNP.mat', fileIdx, noiseLevel)), 'snp_img_uint8');
        end
    end

    %% ---- SPECKLE NOISE ----
    for v = speckle_levels
        spck_img = imnoise(Ref_01, 'speckle', v);
        spck_img_uint8 = uint8(spck_img * 255);
        imwrite(spck_img_uint8, fullfile(outSPK_img, sprintf('%d-%g-Speckle.jpg', fileIdx, v)));
        if saveMAT
            save(fullfile(outSPK_mat, sprintf('%d-%g-Speckle.mat', fileIdx, v)), 'spck_img_uint8');
        end
    end

    %% ---- JPEG COMPRESSION ----
    q = jpeg_start;
    for levelIdx = 1:jpeg_numLevels
        imwrite(Ref_im, fullfile(outJPG_img, sprintf('%d-%d-JPEG.jpg', fileIdx, q)), 'Mode','lossy','Quality',q);
        if saveMAT
            save(fullfile(outJPG_mat, sprintf('%d-%d-JPEG.mat', fileIdx, q)), 'Ref_im');
        end
        q = q + jpeg_inc;
    end
end

disp('Distortion completed.');

%% ===== helper =====
function ifNotExistMkDir(p)
    if ~exist(p,'dir'), mkdir(p); end
end
