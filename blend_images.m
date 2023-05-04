%function which blends a set of images together using a simple averaging
%each image has a mask of the pixels that should be used from that image for blending
%the blending is done by taking averaging the pixels from the images where the mask is 1
%the function takes in a cell array of images and a cell array of masks
function result_image = blend_images(images, masks)
    %get the number of images
    num_images = length(images);
    %convert the images to double
    for i = 1:num_images
        images{i} = im2double(images{i});
    end
    %get the first image. We will use this as the base image
    result_image = images{1};
    %get the size of the image
    [height, width, ~] = size(result_image);
    %instantiate the images_to_use vector
    images_to_use = logical(zeros(num_images, 1));
    %instantiate a matrix to store the pixel values. This should be a num_images x 3 matrix
    pixel_values = zeros(num_images, 3);
    %instantiate a vector to store the pixel value for the base image
    pixel_value = zeros(1, 3);
    %go over every pixel in the image
    for i = 1:height
        for j = 1:width
            %vector for storing which images used for this pixel. If the mask is 1, then the image is used
            images_to_use = logical(zeros(num_images, 1));
            %go over every image
            for k = 1:num_images
                %if the mask is 1, then the image is used
                if masks{k}(i, j) == 1
                    images_to_use(k) = 1;
                end
                %get the pixel values for this pixel from each image
                pixel_values(k, :) = images{k}(i, j, :);
            end
            %output an error if no images are used for this pixel
            if sum(images_to_use) == 0
                %error('No images used for this pixel');
                %print out a warning and use the base image
                %fprintf('No images used for this pixel at %f, %f. Using base image\n', i, j);
                %just use all the images
                images_to_use = logical(ones(num_images, 1));
                continue;
            end
            %populate a vector with the pixel values for this pixel from each image
            %pixel_values = images{:}(i, j, :);
            %average each channel of the pixel values for the images that are used
            %debugging: print out images_to_use
            %fprintf('Images to use: %d\n', images_to_use);
            %set the indices to use
            indices_to_use = find(images_to_use);
            %debugging: print out indices_to_use
            %disp(indices_to_use)
            %disp(pixel_values)
            pixel_value_1 = mean(pixel_values(indices_to_use, 1));
            pixel_value_2 = mean(pixel_values(indices_to_use, 2));
            pixel_value_3 = mean(pixel_values(indices_to_use, 3));
            pixel_value = [pixel_value_1, pixel_value_2, pixel_value_3];
            %debugging: print out pixel_value
            %disp(pixel_value)
            %set the pixel value for the base image to the averaged pixel values
            result_image(i, j, :) = pixel_value;
        end
    end

