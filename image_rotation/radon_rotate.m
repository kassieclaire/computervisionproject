% Demo to use the radon transform to determine the angle to rotate an image to straighten it.
% Initialization / clean-up code.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

% Read in the color demo image.
[rgbImage, colorMap] = imread('image_1.png');
subplot(2, 3, 1);
imshow(rgbImage, colorMap);
axis on;
title('Original Color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
drawnow;

% Extract the red channel and display it.
grayImage = rgbImage(:, :, 1);
subplot(2, 3, 2);
imshow(grayImage, colorMap);
axis on;
title('Red Channel Image', 'FontSize', fontSize);
drawnow;

% Do the Radon transform.
theta = 0:0.5:180;
[R,xp] = radon(grayImage,theta);
% Find the location of the peak of the radon transform image.
maxR = max(R(:));
[rowOfMax, columnOfMax] = find(R == maxR)
% Display the Radon Transform image.
h3 = subplot(2, 3, [3,6]);
imshow(R,[],'Xdata',theta,'Ydata',xp,...
            'InitialMagnification','fit')
axis on;
% Plot a blue circle over the max.
hold on;
plot(h3, columnOfMax, xp(rowOfMax), 'bo', 'MarkerSize', 3, 'LineWidth', 3);
line([columnOfMax, columnOfMax], [xp(end), xp(rowOfMax)+15], 'Color', 'b', 'LineWidth', 3);
caption = sprintf('Radon Transform.  Max at angle %.1f', columnOfMax);
title(caption, 'FontSize', fontSize);
xlabel('\theta (degrees)', 'FontSize', fontSize)
ylabel('x''', 'FontSize', fontSize)
colormap(h3, hot(256));



colorbar;
drawnow;

% The column of the max is the angle of the football --
% the angle that the projected sum (profile) will have the highest sum.
% Rotate it by minus that angle to straighten it.
rotatedImage = imrotate(rgbImage, -columnOfMax);
% Display the rotated image.
subplot(2, 3, 4);
imshow(rotatedImage);
axis on;
title('Rotated Color Image', 'FontSize', fontSize);
drawnow;

% Rotate perpendicular to that angle and display that rotation.
rotatedImage = imrotate(rgbImage, -columnOfMax+90);
subplot(2, 3, 5);
imshow(rotatedImage);
axis on;
title('Rotated Color Image', 'FontSize', fontSize);

%Display the Radon Transform image on its own figure
f = figure;
%scale the x axis
xScale = 20;
%resize R
R = imresize(R, [size(R,1), size(R,2)*xScale]);
imshow(R,[],'Xdata',theta,'Ydata',xp,...
            'InitialMagnification','fit')
axis on;
% Set aspect ratio to 1:1
set(gca, 'DataAspectRatio', [1 xScale 1]);
% Plot a blue circle over the max.
hold on;
plot(columnOfMax, xp(rowOfMax), 'bo', 'MarkerSize', 3, 'LineWidth', 3);
line([columnOfMax, columnOfMax], [xp(end), xp(rowOfMax)+15], 'Color', 'b', 'LineWidth', 3);
caption = sprintf('Radon Transform.  Max at angle %.1f', columnOfMax);
title(caption, 'FontSize', fontSize);
xlabel('\theta (degrees)', 'FontSize', fontSize)
ylabel('x''', 'FontSize', fontSize)
colormap(f, hot(256));
%set the aspect ratio to 1
