%This function takes in the rotated image and the original image and returns the rotation angle and the image rotated back to its original orientation.
function [imageWithRotationRemoved, rotationAngle, orig_fig, rotated_fig] = removeRotation(rotatedImage, originalImage, max_rotation_angle)
    %Extract the red channel from both images
    %from the rotated image
    grayRotatedImage = rotatedImage(:, :, 1);
    %from the original image
    grayOriginalImage = originalImage(:, :, 1);
    %Do the radon transform on both images
    %from the rotated image
    theta = 0:1:180;
    [R_rotated,xp_rotated] = radon(grayRotatedImage,theta);
    %get the radon transform for the original image
    [R_original,xp_original] = radon(grayOriginalImage,theta);
    %get the max of the radon transform image for the rotated and original
    maxR_rotated = max(R_rotated(:));
    maxR_original = max(R_original(:));
    %get the column of the max
    [rowOfMax_rotated, columnOfMax_rotated] = find(R_rotated == maxR_rotated);
    [rowOfMax_original, columnOfMax_original] = find(R_original == maxR_original);
    %set rotation angle to columnOfMax_rotated - columnOfMax_original
    rotationAngle = columnOfMax_rotated - columnOfMax_original;
    %keep looping until the rotation angle is less than max_rotation_angle degrees
    while (abs(rotationAngle) > max_rotation_angle)
        %remove the max from the radon transform image for the rotated image
        R_rotated(rowOfMax_rotated, columnOfMax_rotated) = 0;
        %get the new max
        maxR_rotated = max(R_rotated(:));
        %get the column of the new max
        [rowOfMax_rotated, columnOfMax_rotated] = find(R_rotated == maxR_rotated);
        %set rotation angle to columnOfMax_rotated - columnOfMax_original
        rotationAngle = columnOfMax_rotated - columnOfMax_original;
    end
    %scale the width of R_rotated by 20
    xScale = 20;
    %save the R_rotated before scaling
    R_rot = R_rotated;
    maxR_rotated = max(R_rotated(:));
    [rowOfMax_rotated, columnOfMax_rotated] = find(R_rotated == maxR_rotated);
    %R_rotated = imresize(R_rotated, [size(R_rotated, 1), size(R_rotated, 2) * xScale]);
    %plot the radon transform image
    figure, imshow(R_rotated,[],'Xdata',theta,'Ydata',xp_rotated,...
        'InitialMagnification','fit')
    axis on;
    % Set aspect ratio to 1:1
    set(gca, 'DataAspectRatio', [1 xScale 1]);
    xlabel('\theta (degrees)')
    ylabel('x''')
    colormap(hot), colorbar
    %get the peak of the radon transform image
    
    %plot a blue circle around the peak of the radon transform image
    hold on
    plot(theta(columnOfMax_rotated),xp_rotated(rowOfMax_rotated),'bo');
    hold off
    %save the radon transform image
    %saveas(gcf,'radonTransformRotated.png');
    %recalculate the max with the original R_rot
    maxR_rotated = max(R_rot(:));
    [rowOfMax_rotated, columnOfMax_rotated] = find(R_rot == maxR_rotated);
    %add a title, which includes the max theta (max column) of the rotated image
    title(sprintf('Radon transform of rotated image with max column %d', columnOfMax_rotated));
    %save the figure into an image variable
    rotated_fig = gcf;
    %from the original image
    [R_original,xp_original] = radon(grayOriginalImage,theta);
    

    %create the same figure but with the original R
    %scale the width of R_original by 20
    %save the R_original before scaling
    R_orig = R_original;
    %get the peak of the radon transform image
    maxR_original = max(R_original(:));
    [rowOfMax_original, columnOfMax_original] = find(R_orig == maxR_original);
    %R_original = imresize(R_original, [size(R_original, 1), size(R_original, 2) * xScale]);
    figure, imshow(R_original,[],'Xdata',theta,'Ydata',xp_original,...
        'InitialMagnification','fit')
    axis on
    % Set aspect ratio to 1:1
    set(gca, 'DataAspectRatio', [1 xScale 1]);
    xlabel('\theta (degrees)')
    ylabel('x''')
    colormap(hot), colorbar
    
    %plot a blue circle around the peak of the radon transform image
    hold on
    plot(theta(columnOfMax_original),xp_original(rowOfMax_original),'bo');
    hold off
    
    %recalculate the max with the original R
    maxR_original = max(R_orig(:));
    [rowOfMax_original, columnOfMax_original] = find(R_orig == maxR_original);
    %add a title, which includes the max theta (max column) of the rotated image
    title(sprintf('Radon transform of original image with max column %d', columnOfMax_original));
    %save the figure as an image
    orig_fig = gcf;
    %debugging: print out the column of the max for both images
    %fprintf('The column of the max for the rotated image is %d.\n', columnOfMax_rotated);
    %fprintf('The column of the max for the original image is %d.\n', columnOfMax_original);
    %The column of the max is the angle of the image. Get the difference between the two angles.
    rotationAngle = columnOfMax_rotated - columnOfMax_original;
    %if the rotation angle is more than 10 degrees, try again with the next max

    %print out the rotation angle
    fprintf('The rotation angle is %d degrees.\n', rotationAngle);
    %Rotate the image by the difference in angles.
    imageWithRotationRemoved = imrotate(rotatedImage, -rotationAngle);
end