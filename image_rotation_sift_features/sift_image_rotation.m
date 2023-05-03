% Load the images
base_image = imread('base_image.jpg');
image_set = dir('image_set/*.jpg'); % Assumes that all images in the image_set directory are part of the set of images

% Convert the images to grayscale
base_image_gray = rgb2gray(base_image);
image_set_gray = cell(length(image_set), 1);
for i = 1:length(image_set)
    image_set_gray{i} = rgb2gray(imread(fullfile(image_set(i).folder, image_set(i).name)));
end

% Detect key features in the base image
base_points = detectSURFFeatures(base_image_gray);
[base_features, base_points] = extractFeatures(base_image_gray, base_points);

% Detect key features in the set of images
image_set_points = cell(length(image_set), 1);
image_set_features = cell(length(image_set), 1);
for i = 1:length(image_set)
    image_points = detectSURFFeatures(image_set_gray{i});
    [image_features, image_points] = extractFeatures(image_set_gray{i}, image_points);
    image_set_points{i} = image_points;
    image_set_features{i} = image_features;
end

% Find corresponding features between the base image and each image in the set of images
base_image_indices = cell(length(image_set), 1);
image_set_indices = cell(length(image_set), 1);
for i = 1:length(image_set)
    index_pairs = matchFeatures(base_features, image_set_features{i}, 'MaxRatio', 0.7);
    base_image_indices{i} = index_pairs(:, 1);
    image_set_indices{i} = index_pairs(:, 2);
end

% Compute the transformation matrix between the base image and each image in the set of images
tforms = cell(length(image_set), 1);
for i = 1:length(image_set)
    base_points_matched = base_points(base_image_indices{i});
    image_points_matched = image_set_points{i}(image_set_indices{i});
    tforms{i} = estimateGeometricTransform(image_points_matched, base_points_matched, 'affine');
end

% Apply the transformation matrix to each image in the set of images to reorient them to the base rotation
image_set_reoriented = cell(length(image_set), 1);
for i = 1:length(image_set)
    image_set_reoriented{i} = imwarp(image_set_gray{i}, tforms{i}, 'OutputView', imref2d(size(base_image_gray)));
end
%create a new folder to store the reoriented images
mkdir('image_set_reoriented');
% Save the reoriented images
for i = 1:length(image_set)
    [~, filename, ext] = fileparts(image_set(i).name);
    %write the reoriented images to the image_set_reoriented folder
    imwrite(image_set_reoriented{i}, fullfile('image_set_reoriented', strcat(filename, ext)));
end
