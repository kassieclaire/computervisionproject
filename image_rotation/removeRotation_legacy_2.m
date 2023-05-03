function [imageWithRotationRemoved, rotationAngle] = removeRotation(rotatedImage, originalImage)
    % Extract the red channel from both images
    grayRotatedImage = rotatedImage(:, :, 1);
    grayOriginalImage = originalImage(:, :, 1);

    % Increase the resolution of the radon transform by using more projection angles
    %theta = 0:0.1:180;
    theta = -89:0.1:89;

    % Smooth the radon transform to reduce noise
    R_rotated = imgaussfilt(radon(grayRotatedImage,theta), 1);
    R_original = imgaussfilt(radon(grayOriginalImage,theta), 1);

    % Plot the radon transform images
    figure, imshow(R_rotated,[],'Xdata',theta,'Ydata',1:size(R_rotated,1), 'InitialMagnification','fit')
    xlabel('\theta (degrees)')
    ylabel('x''')
    colormap(hot), colorbar
    saveas(gcf,'radonTransformRotated.png');

    figure, imshow(R_original,[],'Xdata',theta,'Ydata',1:size(R_original,1), 'InitialMagnification','fit')
    xlabel('\theta (degrees)')
    ylabel('x''')
    colormap(hot), colorbar
    saveas(gcf,'radonTransformOriginal.png');

    % Find the peak in the rotated image radon transform
    maxR_rotated = max(R_rotated(:));
    [rowOfMax_rotated, columnOfMax_rotated] = find(R_rotated == maxR_rotated);

    % Use edge detection to extract features indicative of the image orientation
    edgeRotatedImage = edge(grayRotatedImage, 'Canny');
    edgeOriginalImage = edge(grayOriginalImage, 'Canny');

    % Find the peak in the edge detection result
    [H_rotated,theta_rotated] = hough(edgeRotatedImage, 'Theta', theta);
    [H_original,theta_original] = hough(edgeOriginalImage, 'Theta', theta);

    % Find the peaks in the Hough transform
    P_rotated = houghpeaks(H_rotated, 1);
    P_original = houghpeaks(H_original, 1);

    % Get the angle of the peak in the Hough transform
    houghAngle_rotated = theta_rotated(P_rotated(2));

    % Use a weighted average of the rotation angles from the radon and Hough transforms
    rotationAngle = 0.5 * (columnOfMax_rotated - P_rotated(2));

    % Rotate the image back to its original orientation
    imageWithRotationRemoved = imrotate(rotatedImage, -rotationAngle);
end
