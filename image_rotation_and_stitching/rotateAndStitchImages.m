%function which rotates and stitches images
function rotateAndStitchImages(imageFilename)
    %first, get the image
    image = imread(imageFilename);
    %scale the image and colormap down so that the max dimension is 1000
    image  = scaleImage(image, 1000);
    %randomly rotate the image
    rotated_image = randomlyRotateImage(image);
    %remove the rotation from the rotated image
    unrotated_image = removeRotation(rotated_image, image);
    %stitch the unrotated image and the original image together
    stitchedImage = stitchImg(image, unrotated_image);
    %display the original image, rotated image, unrotated image, and stitched image on a 2x2 subplot
    figure;
    subplot(2,2,1);
    imshow(image, colormap);
    title('Original Image');
    subplot(2,2,2);
    imshow(rotated_image);
    title('Rotated Image');
    subplot(2,2,3);
    imshow(unrotated_image);
    title('Unrotated Image');
    subplot(2,2,4);
    imshow(stitchedImage);
    title('Stitched Image');
end
%function which scales an image and colormap down so that the max dimension is the scale value
function [scaledImage, scaledColorMap] = scaleImage(image, scale)
    %scale the image down so that the maximum dimension is 1000 pixels
    scaledImage = imresize(image, scale/max(size(image)));
end