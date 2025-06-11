clear all;
close all;

% write here the path to the folder with the images:
dirname = 'C:\Users\Tomer\Desktop\Data from Josh\To analyze\';
ISH_filename = fullfile(dirname, '20230125_mouse698_10xstitch.tif');
time_lapse_filename = fullfile(dirname, 'raw_aligned.tif');
output_filename = fullfile(dirname, 'ish_to_time_lapse_points.mat');

use_percentiles = 0;

ISH = bfOpen3DVolume(ISH_filename);
ISH = ISH{1}{1};
time_lapse = bfOpen3DVolume(time_lapse_filename);
time_lapse = time_lapse{1}{1};

if use_percentiles
    tmp = time_lapse;
    time_lapse = zeros(size(time_lapse(:,:,1)), 'like', time_lapse);
    img_fractions = unique([0 : 50 : size(time_lapse,1), size(time_lapse,1)]);
    for i = 1 : length(img_fractions)-1
        time_lapse(img_fractions(i)+1:img_fractions(i+1),:) = ...
            prctile(tmp(img_fractions(i)+1:img_fractions(i+1),:,:), 99.5, 3) - ...
            prctile(tmp(img_fractions(i)+1:img_fractions(i+1),:,:), 0.5, 3);
    end
else % use range / max / mean projection
    time_lapse = range(time_lapse,3);
    % time_lapse = max(time_lapse, [], 3);
    % time_lapse = mean(time_lapse, 3);
end

ISH_ref_channel = 2;

moving = double(ISH(:,:,ISH_ref_channel));
moving = moving - prctile(moving(:), 0.1);
moving = moving / prctile(moving(:), 99.9);
fixed = double(time_lapse);
fixed = fixed - prctile(fixed(:), 0.1);
fixed = fixed / prctile(fixed(:), 99.9);

h = cpselect(moving, fixed);
waitfor(h);

save(output_filename, 'fixedPoints', 'movingPoints');

if size(movingPoints,1) ~= size(fixedPoints,1)
    disp('The number of points has to be the same in both images. Please run again.')
    return;
end

disp(['Saved ', num2str(size(movingPoints,1)), ' points.']);

