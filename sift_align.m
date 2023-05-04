%function which takes in a cell array of images and aligns them to the first
%use the align_image_pair function, which is defined below:
%function [result, mask] = align_image_pair(imgd, imgs, maskd)
function [aligned_images, masks] = sift_align(images)
    %create a cell array to store the aligned images
    aligned_images = cell(size(images));
    %create a cell array to store the masks
    masks = cell(size(images));
    %first image is aligned to itself
    aligned_images{1} = images{1};
    %the mask of the first image is all ones
    mask = ones(size(images{1},1), size(images{1},2));
    %convert the mask to logical
    mask = logical(mask);
    %store the mask
    masks{1} = mask;
    %loop through the rest of the images, aligning them to the first image and
    %getting the region of the original image that they cover (the mask)
    for i = 2:length(images)
        [aligned_images{i}, masks{i}] = align_image_pair(images{1}, images{i}, mask);
    end
end