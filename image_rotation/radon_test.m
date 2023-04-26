%This function takes in the filename of the image and tests the removeRotation function.
function radon_test(imageFilename)
    %close all figures
    close all;
    %read in the image
    originalImage= imread(imageFilename);
    %randomly rotate the image
    rotatedImage = randomlyRotateImage(imageFilename);
    %remove the rotation
    [imageWithRotationRemoved, rotationAngle] = removeRotation(rotatedImage, originalImage);
    %display the original image, the rotated image, and the image with the rotation removed on a 2x2 grid
    figure;
    subplot(2, 2, 1);
    imshow(originalImage, originalColorMap);
    axis on;
    title('Original Image', 'FontSize', 20);
    subplot(2, 2, 2);
    imshow(rotatedImage, rotatedColorMap);
    axis on;
    title('Rotated Image', 'FontSize', 20);
    subplot(2, 2, 3);
    imshow(imageWithRotationRemoved, rotatedColorMap);
    axis on;
    title('Image with Rotation Removed', 'FontSize', 20);
    %display the rotation angle
    disp(rotationAngle);
end
    
