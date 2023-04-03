% This function takes two images and binary masks and blends them together
function out_img = blendImagePair(wrapped_imgs, masks, wrapped_imgd, maskd, mode)
    %rename the input variables
    img1 = wrapped_imgs; %img1 is the source image
    mask1 = logical(masks); %mask1 is the binary mask of the source image
    img2 = wrapped_imgd; %img2 is the destination image
    mask2 = logical(maskd); %mask2 is the binary mask of the destination image
    blending_mode = mode;
    
    %normalize the mask to be between 0 and 1
    out_img = zeros(size(mask1));
    %blend the images
    if strcmp(blending_mode, 'overlay')
        %overlay the source image on the destination image
        out_img = double(img1) .* (mask1-mask2) + double(img2) .* (mask2);
    elseif strcmp(blending_mode, 'blend')
        % convert masks to double and normalize to [0, 1] range
        mask1 = im2double(masks);
        mask2 = im2double(maskd);

        % compute the Euclidean distance transform of the masks
        dist1 = bwdist(1 - mask1);
        dist2 = bwdist(1 - mask2);

        % blend the images based on the distance from the mask centers
        %for each color channel
        %debugging: print out the sizes of the images and distance transforms
        % fprintf('size of img1: %d %d %d\n', size(img1));
        % fprintf('size of img2: %d %d %d\n', size(img2));
        % fprintf('size of dist1: %d %d\n', size(dist1));
        % fprintf('size of dist2: %d %d\n', size(dist2));
        for c = 1:size(wrapped_imgs, 3)
            out_img(:, :, c) = (im2double(wrapped_imgs(:, :, c)) .* dist1 + im2double(wrapped_imgd(:, :, c)) .* dist2) ./ (dist1 + dist2);
        end
        %scale the output image to be between 0 and 255
        out_img = out_img .* 255;
    else
        error('Error: blending mode not recognized');
    end
    out_img = uint8(out_img);
end