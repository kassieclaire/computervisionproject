%function which takes in two images, finds SIFT features in both images, performs RANSAC, prints the two images with lines between the corresponding points to an image,
%and then stitches the two images together to create a panorama
function [result, mask] = stitch_image_pair(imgd, imgs, maskd)
% Test RANSAC -- outlier rejection
imgd_ransac = imgd;
imgs_ransac = imgs;
%imgd_ransac = imread(img_name_1); %destination image -- the image that will be used as the starting point
%imgs_ransac = imread(img_name_2); %source image -- the image that will be warped
%convert the images to double (these versions will not be used for ransac)
imgd = im2double(imgd_ransac);
imgs = im2double(imgs_ransac);
%start with the maximum canvas size -- the maximum canvas size is the destination image surrounded by the source image on all sides
max_canvas_width = size(imgd_ransac, 2) + 2*size(imgs_ransac, 2);
max_canvas_height = size(imgd_ransac, 1) + 2*size(imgs_ransac, 1);
dest_canvas_width_height = [max_canvas_width, max_canvas_height];
%create the image on a black background, having it in the center of the canvas
%first, create a black canvas
%ransac canvas (uint8)
canvas_ransac = zeros(max_canvas_height, max_canvas_width, 3, 'uint8');
%canvas (double)
canvas = zeros(max_canvas_height, max_canvas_width, 3, 'double');
%now, copy the destination image into the center of the canvas
%calculate the starting x and y coordinates for the destination image
%the starting x coordinate is the width of the source image
start_x = size(imgs_ransac, 2);
%the starting y coordinate is the height of the source image
start_y = size(imgs_ransac, 1);
%copy the destination image into the canvas (for both the double and uint8 versions)
canvas_ransac(start_y:start_y+size(imgd_ransac, 1)-1, start_x:start_x+size(imgd_ransac, 2)-1, :) = imgd_ransac;
canvas(start_y:start_y+size(imgd, 1)-1, start_x:start_x+size(imgd, 2)-1, :) = imgd;
%get the mask for the destination image whithin the canvas.
%start with a logical array of all zeros
canvas_mask = zeros(max_canvas_height, max_canvas_width, 'logical');
%paste the destination image mask into the canvas mask such that it is offset by the starting x and y coordinates
%for every pixel in the destination image mask, if the pixel is 1, then set the corresponding pixel in the canvas mask (using the offset) to 1
% for x = 1:size(maskd, 2)
%     for y = 1:size(maskd, 1)
%         if maskd(y, x) == 1
%             canvas_mask(start_y+y-1, start_x+x-1) = 1;
%         end
%     end
% end
%vectorize the above loop
canvas_mask(start_y:start_y+size(maskd, 1)-1, start_x:start_x+size(maskd, 2)-1) = maskd;
%set the maskd to the canvas mask
maskd = canvas_mask;
%imgd is now the canvas with the destination image in the center
%ransac canvas
imgd_ransac = canvas_ransac;
%canvas (double)
imgd = canvas;
% If you cannot get the VLFeat library to work for you, you can use a
% native MATLAB-based implementation by setting 'impl' to 'MATLAB' below.
% You need to have version R2021b or later for it to work (according to
% MATLAB documentation).
%
% Raise an issue on Piazza if neither works for you.
%
%impl = 'VLFeat'; % change to 'MATLAB' to use native MATLAB implementation
impl = 'MATLAB';
[xs, xd] = genSIFTMatches(imgs_ransac, imgd_ransac, impl);

% Use RANSAC to reject outliers
%ransac_n = ??; % Max number of iterations
%ransac_eps = ??; Acceptable alignment error
ransac_n = 100000;
ransac_eps = 1;

[inliers_id, H_3x3] = runRANSAC(xs, xd, ransac_n, ransac_eps);

%after_img = showCorrespondence(imgs, imgd, xs(inliers_id, :), xd(inliers_id, :));
%figure, imshow(after_img);
%create the name for the output image -- the name of the first image, followed by corresponding, followed by the name of the second image
%out_img = strcat(img_name_1, '_corresponding_', img_name_2);
%imwrite(after_img, out_img);
%stitch the two images together by doing the following:
%1. warp the source image using the homography matrix
%2. combine the two images together by blending the two images together
%3. save the output image to a file
%4. display the output image
%5. return the output image
%6. (optional) crop the output image to remove the black borders
%warp the source image using the homography matrix
[masks, imgs] = backwardWarpImg(imgs, inv(H_3x3), dest_canvas_width_height);
% mask should be of the type logical
masks = logical(masks);
maskd = logical(maskd);
%masks = ~masks;
%debugging: what is the first value of the mask?
%maskd = ~maskd;
% Superimpose the image
%OR the masks together
mask = masks | maskd;
%Get the minimum and maximum x and y coordinates for the mask
%get the minimum and maximum x and y coordinates in one loop
% min_x = max_canvas_width;
% max_x = 1;
% min_y = max_canvas_height;
% max_y = 1;
%loop through the whole mask
% for x = 1:max_canvas_width
%     for y = 1:max_canvas_height
%         %if the mask is 1, then the pixel is part of the image
%         if mask(y, x) == 1
%             %if the x coordinate is less than the current minimum x coordinate, then update the minimum x coordinate
%             if x < min_x
%                 min_x = x;
%             end
%             %if the x coordinate is greater than the current maximum x coordinate, then update the maximum x coordinate
%             if x > max_x
%                 max_x = x;
%             end
%             %if the y coordinate is less than the current minimum y coordinate, then update the minimum y coordinate
%             if y < min_y
%                 min_y = y;
%             end
%             %if the y coordinate is greater than the current maximum y coordinate, then update the maximum y coordinate
%             if y > max_y
%                 max_y = y;
%             end
%         end
%     end
% end
%vectorize the above loop
[y, x] = find(mask == 1);
min_x = min(x);
max_x = max(x);
min_y = min(y);
max_y = max(y);
%debugging: show the combined mask
%figure, imshow(mask);
%Given that the combined mask is 1 for the white pixels, which represent the back
%result = imgs .* cat(3, masks, masks, masks) + imgd .* cat(3, maskd, maskd, maskd);
%debugging: display the warped source image
%figure, imshow(imgs);
%debugging: show the mask for the warped source image
%figure, imshow(masks);
%debugging: show the destination image
%figure, imshow(imgd);
%debugging: show the mask for the destination image
%figure, imshow(maskd);
%using the masks, combine the two images together by blending the two images together
%result = imgs .* cat(3, masks, masks, masks) + imgd .* cat(3, maskd, maskd, maskd);
%debugging test: swap the masks
%result = imgs .* cat(3, maskd, maskd, maskd) + imgd .* cat(3, masks, masks, masks);
%debugging test: use the combined mask
%result = imgs .* cat(3, mask, mask, mask) + imgd .* cat(3, mask, mask, mask);
%debugging: show the result
%figure, imshow(result);
%Blend the two images together
result = blendImagePair(imgs, masks, imgd, maskd,...
    'blend');
%crop the result to remove the black borders
result = result(min_y:max_y, min_x:max_x, :);
%crop the mask to remove the black borders
mask = mask(min_y:max_y, min_x:max_x);
%debugging: show the result
%figure, imshow(result);
end