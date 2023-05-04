%function which gets the average brightness from two images, and then changes the brightness of the first image to match the second image
function processed_image = postprocess_image(image1, image2)

    % Compute the average brightness of both images
    avg_brightness1 = mean2(im2gray(image1));
    avg_brightness2 = mean2(im2gray(image2));
    
    % Compute the brightness scaling factor
    scaling_factor = avg_brightness2 / avg_brightness1;
    
    % Scale the brightness of the first image to match the second image
    processed_image = imadjust(image1, [], [], scaling_factor);
    
end
    