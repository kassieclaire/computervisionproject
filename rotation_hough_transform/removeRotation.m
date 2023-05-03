function [imageWithRotationRemoved, rotationAngle, edge_image] = removeRotation(rotatedImage, originalImage)

    % Save the rotated image rgb version
    rotatedImageRGB = rotatedImage;
    % Convert the images to grayscale
    rotatedImage = rgb2gray(rotatedImage);
    originalImage = rgb2gray(originalImage);
    
    % Detect edges using Canny edge detection
    %edgeRotated = edge(rotatedImage, 'Canny');
    %edgeOriginal = edge(originalImage, 'Canny');
    %use sobel edge detection instead
    thresh = 0.2;
    edgeRotated = edge(rotatedImage, 'Sobel', thresh);
    edgeOriginal = edge(originalImage, 'Sobel', thresh);
    %remove the noise
    edgeRotated = bwareaopen(edgeRotated, 10);
    edgeOriginal = bwareaopen(edgeOriginal, 10);
    %save the edge image
    edge_image = edgeRotated;
    
    % Calculate the Hough transform
    [H, T, R] = hough(edgeRotated);
    
    % Find the longest line in the Hough transform
    P = houghpeaks(H, 1);
    theta = T(P(2));
    rho = R(P(1));
    
    % Calculate the perpendicular line to the longest line
    perpendicular_theta = theta + 90;
    
    % Rotate the rotated image to obtain the image with the rotation removed
    imageWithRotationRemoved = imrotate(rotatedImageRGB, -perpendicular_theta);
    
    % Calculate the rotation angle
    rotationAngle = -perpendicular_theta;
    
    end
    