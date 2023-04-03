%%function that takes in a source image, the inverse homography matrix, and the canvas size and returns the warped image and the mask
function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
    dest_canvas_width_height)
    % % get the size of the source image
    % [src_img_height, src_img_width, ~] = size(src_img);
    % % get the size of the destination canvas
    % dest_canvas_width = dest_canvas_width_height(1);
    % dest_canvas_height = dest_canvas_width_height(2);
    % % create a meshgrid of the destination canvas
    % [dest_canvas_x, dest_canvas_y] = meshgrid(1:dest_canvas_width, 1:dest_canvas_height);
    % dest_xy = [dest_canvas_x(:), dest_canvas_y(:), ones(dest_canvas_width*dest_canvas_height, 1)];
    % % Map the destination pixel coordinates to source pixel coordinates using the homography matrix
    % src_xy = dest_xy * resultToSrc_H;
    % % Normalize the source pixel coordinates
    % src_x = src_xy(:,1)./src_xy(:,3);
    % src_y = src_xy(:,2)./src_xy(:,3);
    % % Create a warped image of the source image
    % result_img = zeros(dest_canvas_height, dest_canvas_width, 3);
    % % Create a mask of the source image
    % mask = zeros(dest_canvas_height, dest_canvas_width);
    % % Loop through the destination canvas
    % for i = 1:dest_canvas_height
    %     for j = 1:dest_canvas_width
    %         % Get the source pixel coordinates
    %         src_x_coord = src_x((i-1)*dest_canvas_width+j);
    %         src_y_coord = src_y((i-1)*dest_canvas_width+j);
    %         % Check if the source pixel coordinates are within the source image
    %         if src_x_coord > 0 && src_x_coord < src_img_width && src_y_coord > 0 && src_y_coord < src_img_height
    %             % Get the source pixel color
    %             %debugging: print out the source pixel coordinates
    %             %fprintf('src_x_coord: %f, src_y_coord: %f\n', src_x_coord, src_y_coord);
    %             result_img(i,j,:) = src_img(ceil(src_y_coord), ceil(src_x_coord), :);
    %             % Set the mask to 1
    %             mask(i,j) = 1;
    %         end
    %     end
    % end
    % % Convert the mask to logical
    % mask = logical(mask);
    % Get the size of the destination canvas
    dest_width = dest_canvas_width_height(1);
    dest_height = dest_canvas_width_height(2);

    % Create a grid of destination pixel coordinates
    [dest_x, dest_y] = meshgrid(1:dest_width, 1:dest_height);
    dest_xy = [dest_x(:), dest_y(:), ones(dest_width*dest_height, 1)];

    % Map the destination pixel coordinates to source pixel coordinates using the homography matrix
    src_xy = dest_xy * resultToSrc_H';
    src_x = src_xy(:, 1) ./ src_xy(:, 3);
    src_y = src_xy(:, 2) ./ src_xy(:, 3);

    %create a mask of the source image
    mask = zeros(dest_height, dest_width);
    % Interpolate the source image at the mapped source pixel coordinates
    result_img = zeros(dest_height, dest_width, size(src_img, 3));
    for i = 1:size(src_img, 3)
        result_img(:, :, i) = reshape(interp2(double(src_img(:, :, i)), src_x, src_y), dest_height, dest_width);
        %set the mask to 1 if the pixel is not NaN
        mask = mask | ~isnan(result_img(:, :, i));
        %if the pixel is NaN, set the pixel to 0
        result_img(isnan(result_img)) = 0;
    end

    % transform the mask to logical
    mask = logical(mask);
end

    
