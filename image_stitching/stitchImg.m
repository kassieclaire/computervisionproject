%%function which stitches an arbitrary number of images together
%%The images are given in order of increasing x coordinate
%%This function uses the following functions:
%function H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2)
%function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)
%function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H, dest_canvas_width_height)
%function function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)
%function out_img = blendImagePair(wrapped_imgs, masks, wrapped_imgd, maskd, mode)
function stitched_img = stitchImg(varargin)
    %first, check if there are less than 2 images, if there are, the images are already stored in a cell array in the first argument
    images = {};
    if nargin == 1
        %read in the images into a cell array of images from varargin
        images = cell(1, length(varargin{1}));
        for i = 1:length(varargin{1})
            images{i} = varargin{1}{i};
        end
    else
        %read in the images into a cell array of images from varargin
        images = cell(1, nargin);
        for i = 1:nargin
            images{i} = varargin{i};
        end
    end
    %convert the images back to uint8
    for i = 1:nargin
        images{i} = im2uint8(images{i});
    end
    %start with the first image as the result
    result = images{1};
    %create a mask for the first image -- the mask is the same size as the image (not including the colors) and is all ones
    mask = ones(size(result, 1), size(result, 2));
    %for each image, run the function stich_image_pair to stitch it with the result
    for i = 2:nargin
        [result, mask] = stitch_image_pair(result, images{i}, mask);
    end
    %debugging: show the result
    %figure, imshow(result);
    %return the stitched image
    stitched_img = result;
end
