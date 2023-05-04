%function which aligns a set of images to the first image in the set.
%Alignment is done using the function removeRotation. 
%[imageWithRotationRemoved, rotationAngle] = removeRotation(rotatedImage, originalImage)
%removeRotation is in the directory 'image_rotation'
function [aligned_images, rotations] = align_image_rotation(images)
    %get the first image
    first_image = images{1};
    %prepare a cell array for the aligned images
    aligned_images = cell(size(images));
    %prepare a vector for the rotation angles
    rotations = zeros(size(images));
    %the first image is aligned to itself
    aligned_images{1} = first_image;
    rotations(1) = 0;
    %iterate over the remaining images
    for i=2:length(images)
        %get the current image
        current_image = images{i};
        %align the current image to the first image
        [aligned_image, rotation] = removeRotation(current_image, first_image);
        %store the aligned image
        aligned_images{i} = aligned_image;
        %store the rotation angle
        rotations(i) = rotation;
    end
end