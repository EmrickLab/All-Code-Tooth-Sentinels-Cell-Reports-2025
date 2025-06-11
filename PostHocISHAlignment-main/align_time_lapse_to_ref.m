moving_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\ref1_focustacked.tif';
fixed_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\m1g1-cold.tif';
output_filename = 'C:\Users\jjemrick\Desktop\Akash\PostHocAnalysis\20231204_boduan_1814_vibrattion\ref1_corrected';

disp('Loading time lapse:');
moving = bfOpen3DVolume(moving_filename);
moving = moving{1}{1};
moving_original = moving;
moving = max(moving, [], 3);
moving = double(moving);
moving = moving - prctile(moving(:), 0.1);
moving = moving / prctile(moving(:), 99.9);

disp('Loading reference:');
fixed = bfOpen3DVolume(fixed_filename);
fixed = fixed{1}{1};
fixed_original = fixed;
fixed = max(moving,[], 3);
fixed = double(fixed);
fixed = fixed - prctile(fixed(:), 0.1);
fixed = fixed / prctile(fixed(:), 99.9);

fprintf('Aligning reference to time lapse... ');
[optimizer, metric] = imregconfig('multimodal');
tform = imregtform(fixed, moving, 'translation', optimizer, metric); % Swap 'fixed' and 'moving'
fprintf(['done.', newline]);

fprintf('Transforming reference... ');
for i = 1 : size(fixed, 3)
    fixed(:,:,i) = imwarp(fixed(:,:,i), imref2d(size(fixed)), tform, 'linear', 'OutputView', imref2d(size(moving_original)));
end
fprintf(['done.', newline]);

fprintf('Saving aligned reference... ');
fixed = uint16(fixed * 65535);
FastTiffSave(fixed, output_filename); % Save the aligned reference
fprintf(['done.', newline, newline]);
