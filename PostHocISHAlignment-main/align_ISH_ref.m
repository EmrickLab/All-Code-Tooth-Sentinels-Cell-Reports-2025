moving_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\20230108Analysis\4x_combinedPOSTHOC_crop_rotate - corrected.tif';
fixed_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\20230108Analysis\ref1_focustacked.tif';
output_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\20230108Analysis\output.tif';

use_saved_points = 1;
points_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\20230108Analysis\ish_to_ref_points.mat';

ISH_ref_channel = 5;

fprintf('Loading images... ');
moving = bfOpen3DVolume(moving_filename);
moving = moving{1}{1};
original_moving = moving;
moving = double(moving(:,:,ISH_ref_channel));
moving = moving - prctile(moving(:), 0.1);
moving = moving / prctile(moving(:), 99.9);

fixed = bigread4(fixed_filename);
fixed = double(fixed);
fixed = fixed - prctile(fixed(:), 0.1);
fixed = fixed / prctile(fixed(:), 99.9);
fprintf(['done.', newline]);

fprintf('Calculating control points... ');
if use_saved_points
    load(points_filename);
else
    h = cpselect(moving, fixed);
    waitfor(h);
end
fprintf(['done.', newline]);

if size(movingPoints,1) ~= size(fixedPoints,1)
    disp('The number of points has to be the same in both images. Please run again.')
    return;
end

fprintf('Performing fine tuning using Demon''s algorithm... ');
tform = fitgeotform2d(movingPoints, fixedPoints, 'polynomial', 2);
A = imwarp(moving, imref2d(size(moving)), tform, 'linear', 'OutputView', imref2d(size(fixed)));
D = imregdemons(A, fixed, [5 1 1 1], 'PyramidLevels', 4);
fprintf(['done.', newline]);

fprintf('Applying the transformations on all channels... ')
A1 = zeros([size(fixed), size(original_moving,3)], 'like', original_moving);
for i = 1 : size(original_moving,3)
    A1(:,:,i) = imwarp(original_moving(:,:,i), imref2d(size(moving)), tform, 'linear', 'OutputView', imref2d(size(fixed)));
    A1(:,:,i) = imwarp(A1(:,:,i), D);
end
fprintf(['done.', newline]);

fprintf('Saving aligned time lapse... ');
FastTiffSave(A1, output_filename);
fprintf(['done.', newline, newline]);

