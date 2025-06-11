clear all;
close all;

% write here the path to the folder with the ISH channels image:
dirname = 'F:\Deanna\Gland-validated\Ai95D_infused\2024-09-13\4225\posthoc analysis';
ISH_filename = fullfile(dirname, 'ISHstack.tif');
output_filename = fullfile(dirname, 'ISH_corrected.tif');

% defining the channel we want to correct and the reference:
moving_channel =2;
fixed_channel = 1;

% loading the image:
ISH = bfOpen3DVolume(ISH_filename);
ISH = ISH{1}{1};

% normalizing the intensities of the two channels (don't worry, the saved image will have the same range of values as the original image):
moving = double(ISH(:,:,moving_channel));
moving = uint8(moving / prctile(moving(:), 99.9) * 255);
fixed = double(ISH(:,:,fixed_channel));
fixed = uint8(fixed / prctile(fixed(:), 99.9) * 255);
refs = imref2d(size(moving));

% performing the alignment (we use 'translation' - 2 degrees of freedom):
[optimizer, metric] = imregconfig('monomodal');
tfmat = imregtform(moving, refs, fixed, refs, 'translation', optimizer, metric);
ISH(:,:,moving_channel) = imwarp(ISH(:,:,moving_channel), refs, tfmat, 'linear', 'OutputView', refs);

% displaying the results:
disp(['Detected XY shifts: ', mat2str(tfmat.T(end,1:2))]);

% saving the corrected image:
bfsave(ISH, output_filename);

