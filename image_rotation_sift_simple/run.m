% Load the base image
baseImage = imread('base_image.jpg');

% Load the set of images to be stabilized
imageFiles = dir('image_set/*.jpg');
numImages = numel(imageFiles);
setOfImages = cell(1, numImages);
for i = 1:numImages
    setOfImages{i} = imread(fullfile('image_set', imageFiles(i).name));
end

% Stabilize the set of images
stabilizedImages = stabilizeImages(baseImage, setOfImages);

% Save the stabilized images
for i = 1:numImages
    [~, name, ext] = fileparts(imageFiles(i).name);
    imwrite(stabilizedImages{i}, fullfile('stabilized_images', [name, '_stabilized', ext]));
end
