function final_image = main(folder_path, max_size, debug)
    %close all figures
    close all;
    %delete all files in correspondence_images directory
    delete correspondence_images/*.png;
    %define parameters
    window_size = 4;
    outlier_threshold = 1.5;
    num_bins = 2;
    max_rotation_angle = 5;
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
    [aligned_images, rotations, figs] = align_image_rotation(images, max_rotation_angle);
    %if debug = 1, show the aligned images and the rotation angles
    if debug == 1
        figure;
        for i = 1:length(aligned_images)
            %subplot(1, length(aligned_images), i);
            %instead of one row, show the images 3 per row
            subplot(ceil(length(aligned_images)/3), 3, i);
            imshow(aligned_images{i});
            title(sprintf('Rotation: %f', rotations(i)));
            %create another subplot for the figures, which should also be 3 per row
            %subplot(ceil(length(aligned_images)/3), 3, i + length(aligned_images));
            %imshow(figs{i});

        end
    end
    %if debug = 1, show the figs
    if debug == 1
        figure;
        for i = 1:length(figs)
            %subplot(1, length(figs), i);
            %instead of one row, show the images 3 per row
            %subplot(ceil(length(figs)/3), 3, i);
            %imshow(figs{i});
            fig = figs{i};
            % save the figure as a PNG image
            saveas(fig, sprintf('radon_figures/figure_%d.png', i));
        end
    end
    % Use SIFT to align images post-rotation and get the masks for original image coverage
    [aligned_images, masks] = sift_align(aligned_images);
    %if debug = 1, show the aligned images and the masks
    if debug == 1
        %show the aligned images
        figure;
        for i = 1:length(aligned_images)
            %subplot(1, length(aligned_images), i);
            %instead of one row, show the images 3 per row
            subplot(ceil(length(aligned_images)/3), 3, i);
            imshow(aligned_images{i});
        end
        %show the masks
        figure;
        for i = 1:length(masks)
            %subplot(1, length(masks), i);
            %instead of one row, show the images 3 per row
            subplot(ceil(length(masks)/3), 3, i);
            imshow(masks{i});
        end
    end
    %debug: create a subplot with the last image (unaligned) and the last image (aligned) and the aligned image mask
    if debug == 1
        figure;
        subplot(1, 3, 1);
        imshow(images{length(images)});
        %add a title to the subplot
        title('Unaligned image');
        %subplot(1, 3, 2);
        %instead of one row, show the images 3 per row
        subplot(ceil(3/3), 3, 2);
        imshow(aligned_images{length(aligned_images)});
        %add a title to the subplot
        title('Aligned image');
        %subplot(1, 3, 3);
        %instead of one row, show the images 3 per row
        subplot(ceil(3/3), 3, 3);
        imshow(masks{length(masks)});
        %add a title to the subplot
        title('Aligned image mask');
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
            %subplot(1, length(outlier_masks), i);
            %instead of one row, show the images 3 per row
            subplot(ceil(length(outlier_masks)/3), 3, i);
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