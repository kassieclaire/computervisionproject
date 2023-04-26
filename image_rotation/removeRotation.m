%This function takes in the rotated image and the original image and returns the rotation angle and the image rotated back to its original orientation.
function [imageWithRotationRemoved, rotationAngle] = removeRotation(rotatedImage, originalImage)
    %Extract the red channel from both images
    %from the rotated image
    grayRotatedImage = rotatedImage(:, :, 1);
    %from the original image
    grayOriginalImage = originalImage(:, :, 1);
    %Do the radon transform on both images
    %from the rotated image
    theta = 0:180;
    [R_rotated,xp_rotated] = radon(grayRotatedImage,theta);
    %from the original image
    [R_original,xp_original] = radon(grayOriginalImage,theta);
    %Find the location of the peak of the radon transform image.
    %from the rotated image
    maxR_rotated = max(R_rotated(:));
    [rowOfMax_rotated, columnOfMax_rotated] = find(R_rotated == maxR_rotated);
    %from the original image
    maxR_original = max(R_original(:));
    [rowOfMax_original, columnOfMax_original] = find(R_original == maxR_original);
    %The column of the max is the angle of the image. Get the difference between the two angles.
    rotationAngle = columnOfMax_rotated - columnOfMax_original;
    %Rotate the image by the difference in angles.
    imageWithRotationRemoved = imrotate(rotatedImage, -rotationAngle);
end