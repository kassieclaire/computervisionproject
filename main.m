function final_image = main(folder_path, max_size, debug)
    %close all figures
    close all;
    %define parameters
    window_size = 20;
    outlier_threshold = 1.5;
    num_bins = 2;
    % Load images from folder
    images = load_images(folder_path, max_size);
    %if debug = 1, show the images
    if debug == 1
        figure;
        for i = 1:length(images)
            subplot(1, length(images), i);
            imshow(images{i});
        end
    end
    % Align images
    [aligned_images, rotations] = align_image_rotation(images);
    %if debug = 1, show the aligned images and the rotation angles
    if debug == 1
        figure;
        for i = 1:length(aligned_images)
            subplot(1, length(aligned_images), i);
            imshow(aligned_images{i});
            title(sprintf('Rotation: %f', rotations(i)));
        end
    end
    % Use SIFT to align images post-rotation and get the masks for original image coverage
    [aligned_images, masks] = sift_align(aligned_images);
    %if debug = 1, show the aligned images and the masks
    if debug == 1
        %show the aligned images
        figure;
        for i = 1:length(aligned_images)
            subplot(1, length(aligned_images), i);
            imshow(aligned_images{i});
        end
        %show the masks
        figure;
        for i = 1:length(masks)
            subplot(1, length(masks), i);
            imshow(masks{i});
        end
    end
    %check that all the images are the same size
    for i = 1:length(aligned_images)
        %print the size of the image
        %fprintf('Image %d size: %d x %d\n', i, size(aligned_images{i}, 1), size(aligned_images{i}, 2));
        if size(aligned_images{i}) ~= size(aligned_images{1})
            error('Images are not the same size');
        end
    end
    %check that all the masks are the same size
    for i = 1:length(masks)
        %print the size of the mask
        %fprintf('Mask %d size: %d x %d\n', i, size(masks{i}, 1), size(masks{i}, 2));
        if size(masks{i}) ~= size(masks{1})
            error('Masks are not the same size');
        end
    end
    % Detect outliers and create masks
    outlier_masks = detect_outliers(aligned_images, masks, window_size, outlier_threshold, num_bins);
    %if debug = 1, show the outlier masks
    if debug == 1
        figure;
        for i = 1:length(outlier_masks)
            subplot(1, length(outlier_masks), i);
            imshow(outlier_masks{i});
            %save the outlier masks in the image_masks folder
            imwrite(outlier_masks{i}, sprintf('image_masks/outlier_mask_%d.png', i));
        end
    end
    % Blend images, avoiding outlier regions
    result_image = blend_images(aligned_images, outlier_masks);
    %if debug = 1, show the blended image
    if debug == 1
        figure;
        imshow(result_image);
    end
    % Post-process the blended image
    processed_image = postprocess_image(result_image, images{1});
    %if debug = 1, show the processed image
    if debug == 1
        figure;
        imshow(processed_image);
    end
    % Output the final result
    final_image = processed_image;
end