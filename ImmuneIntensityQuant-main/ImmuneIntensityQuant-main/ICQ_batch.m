% Intensity-based Immune Cell Quantification: Batch Program (see ICQ_single.m for single file processing)
% aditijha Emrick Lab 12/20/2024

% files (batch)
folderPath = '/Users/ExampleUser/Downloads/Etc';  % add in FOLDER file path
tiffFiles = dir(fullfile(folderPath, '*.tif'));

% initialize results table
results = table('Size', [numel(tiffFiles), 2], ...
                'VariableTypes', {'string', 'double'}, ...
                'VariableNames', {'FileName', 'AvgIntensity'});

for i = 1:numel(tiffFiles)
    % read tif
    filepath = fullfile(folderPath, tiffFiles(i).name);
    info = imfinfo(filepath);

    % read each tif channel
    img_dapi = imread(filepath, 1, 'Info', info);   % DAPI channel
    img_background = imread(filepath, 2, 'Info', info); % background (noise) channel
    img_immune = imread(filepath, 3, 'Info', info); % immune cell channel


    % step 1: detect ROI using DAPI channel

    % thresholding DAPI image to mark active areas
    threshold_value_dapi = 850;  % ADJUSTABLE: image intensity range
    bw_dapi = img_dapi > threshold_value_dapi;

    % remove small objects/fill small holes
    bw_dapi_cleaned = bwareaopen(bw_dapi, 200); % ADJUSTABLE: higher number fills larger holes
    bw_dapi_cleaned = imfill(bw_dapi_cleaned, 'holes');

    % (optional) smooth the edges
    se = strel('disk', 5);
    bw_dapi_cleaned = imclose(bw_dapi_cleaned, se);

    % labels connected components in the binarized image
    labeledROI = bwlabel(bw_dapi_cleaned);

    % step 2: normalize immune cell channel across images by subtracting non-ROI background intensity

    % calculate avg intensity of the non-ROI area
    ROI_mask = bw_dapi_cleaned;
    non_ROI_mask = ~ROI_mask;
    avg_non_ROI_intensity = mean(img_immune(non_ROI_mask), 'all'); % Compute the mean of non-ROI areas
    
    % normalize the entire image using avg non-ROI intensity
    img_immune_normalized = img_immune - uint16(avg_non_ROI_intensity);
    
    % correct any negative values
    img_immune_normalized(img_immune_normalized < 0) = 0;

    % step 3: background subtraction from channel 2

    % threshold background channel
    threshold_value_bg = 1100;  % ADJUSTABLE: image intensity range
    bw_background_thresholded = img_background > threshold_value_bg;
    original_background_to_subtract = img_background .* uint16(bw_background_thresholded);  % original intensities
    
    % subtract the original background intensity from the normalized immune cell channel
    img_immune_bg_subtracted = img_immune_normalized - original_background_to_subtract;
    
    % correct any negative values
    img_immune_bg_subtracted(img_immune_bg_subtracted < 0) = 0;
    
    % step 4: calculate avg brightness withing ROI(s)
    num_ROIs = max(labeledROI(:)); % # of ROI(s)
    total_intensity = 0;
    total_area = 0;

    for j = 1:num_ROIs
        ROI_mask = (labeledROI == j);
        intensity_in_ROI = img_immune_bg_subtracted(ROI_mask);

        % calculate total intensity and area
        total_intensity = total_intensity + sum(intensity_in_ROI(:));
        total_area = total_area + nnz(ROI_mask);
    end

    % avg intensity
    if total_area > 0
        avg_intensity = total_intensity / total_area;
    else
        avg_intensity = 0;
    end

    % store results in table
    results.FileName(i) = string(tiffFiles(i).name);
    results.AvgIntensity(i) = avg_intensity;
end

% display results (table)
disp(results);

% save results to a csv file (optional: you can comment this out)
writetable(results, fullfile(folderPath, 'average_intensities.csv'));