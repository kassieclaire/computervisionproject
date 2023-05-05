%function which takes in a cell array of aligned images and the masks and finds the outliers in each image
%and masks them out. The function returns the masks with the outliers masked out
function outlier_masks = detect_outliers(aligned_images, masks, window_size, outlier_threshold, mode_bins)
    %get the number of images
    num_images = length(aligned_images);
    %get the size of the images
    [height, width, ~] = size(aligned_images{1});
    %initialize the outlier masks as the masks
    outlier_masks = masks;
    %determine the number of windows in the x and y direction of the image
    %note: windows can go over the edge of the image, but the window will
    %be cropped to the image size
    num_windows_x = floor(width/window_size);
    num_windows_y = floor(height/window_size);
    %create a window matrix which will hold the window median values
    window_median_matrix = zeros(num_windows_y, num_windows_x);
    %loop through the windows, and do the following:
    % 1. Get the window for each image
    % 2. Compute the image_similarity_histogram for each image's window
    % 3. Compute the median of the image_similarity_histograms
    % 4. Store the median in the window_median_matrix
    %first, create a vector of 0s to hold the image_similarity_histograms. These will be reused for each window
    image_similarity_histograms = zeros(1, num_images);
    %create a matrix to hold all of the similarity histograms for each image
    image_similarity_histogram_matrix = zeros(num_images, num_windows_y, num_windows_x);
    %create a matrix to hold the difference between the image_similarity_histogram and the window median
    window_difference_matrix = zeros(num_images, num_windows_y, num_windows_x);
    %create a matrix to keep track of the windows not valid for each image
    images_to_not_use = zeros(num_images, num_windows_y, num_windows_x);

    %loop through the windows
    for i = 1:num_windows_y
        for j = 1:num_windows_x
            %get the window of the  mask for each image, and check if any of the pixels in the mask are 0
            %if any of the pixels in the mask are 0, then the window is not valid for that image
            for k = 1:num_images
                %get the window for the mask
                mask_window = get_window(masks{k}, (j-1)*window_size+1, (i-1)*window_size+1, width, height, window_size);
                %check if any of the pixels in the mask are 0
                if any(mask_window(:) == 0)
                    %if any of the pixels in the mask are 0, then the window is not valid for that image
                    images_to_not_use(k, i, j) = 1;
                    %set the image_similarity_histogram_matrix value to -inf
                    image_similarity_histogram_matrix(k, i, j) = -inf;
                else
                    %get the window for the image
                    image_window = get_window(aligned_images{k}, (j-1)*window_size+1, (i-1)*window_size+1, width, height, window_size);
                    %store the image_similarity_histogram in the image_similarity_histogram_matrix
                    image_similarity_histogram_matrix(k, i, j) = image_similarity_histogram(image_window);
                end
            end
            %get the median of the image_similarity_histograms for this window, 
            %but only use the images which are valid for the window
            %window_median_matrix(i, j) = median(image_similarity_histograms(images_to_not_use(:, i, j) == 0));
            %bin the values in the image_similarity_histogram_matrix into a vector of bins
            image_similarity_histogram_vector = image_similarity_histogram_matrix(:, i, j);
            %use the function bin_values to bin the values in the image_similarity_histogram_vector
            indices_to_not_use = bin_values(image_similarity_histogram_vector);
            %set images_to_not_use to 1 for the indices in indices_to_not_use
            images_to_not_use(indices_to_not_use, i, j) = 1;
            %get the difference between the image_similarity_histogram and the window median
            window_difference_matrix(:, i, j) = abs(image_similarity_histogram_matrix(:, i, j) - window_median_matrix(i, j));
        end
    end
    %erode and then dilate each image_to_not_use mask
    for i = 1:num_images
        
        %images_to_not_use(i, :, :) = imdilate(squeeze(logical(images_to_not_use(i, :, :))), strel('disk', 3));
        images_to_not_use(i, :, :) = imerode(squeeze(logical(images_to_not_use(i, :, :))), strel('disk', 2));
        images_to_not_use(i, :, :) = imdilate(squeeze(logical(images_to_not_use(i, :, :))), strel('disk', 8));
        %dilate again, but not disk
        images_to_not_use(i, :, :) = imdilate(squeeze(logical(images_to_not_use(i, :, :))), strel('square', 6));
    end
    %perform a moving average on the window_difference_matrix
    %window_difference_matrix = movingAverageWithoutInf(window_difference_matrix, 3);
    %for each window, check if the image_similarity_histogram is an outlier
    for i = 1:num_windows_y
        for j = 1:num_windows_x
            %check each image similarity histogram to see if it is an outlier. It is automatically
            %an outlier if it is an image which is not valid for the window
            for k = 1:num_images
                %check if the image is valid for the window
                if images_to_not_use(k, i, j) == 0
                    %check if the image is an outlier
                    %get the difference between the image_similarity_histogram and the window median
                    window_difference = window_difference_matrix(k, i, j);
                    %debugging: print out the window difference
                    %fprintf('window_difference: %f\n', window_difference);
                    if abs(window_difference) > outlier_threshold
                        %debugging: print out that the image is an outlier
                        %fprintf('image %d is an outlier\n', k);
                        %if the image is an outlier, then mask out the window for that image
                        outlier_masks{k}((i-1)*window_size+1:min(i*window_size, height), (j-1)*window_size+1:min(j*window_size, width)) = 0;
                    end
                else
                    %debugging: print out that the image is not valid for the window
                    %fprintf('image %d is not valid for the window\n', k);
                    %if the image is not valid for the window, then mask out the window for that image
                    outlier_masks{k}((i-1)*window_size+1:min(i*window_size, height), (j-1)*window_size+1:min(j*window_size, width)) = 0;
                end
            end
            
        end
    end
end
%get an rgb histogram for the image
function value = image_similarity_histogram(image)
    %get the number of bins for the histogram
    num_bins = 256;
    %get the number of pixels in the image
    num_pixels = numel(image);
    %get the histogram for the image
    [counts, ~] = imhist(image, num_bins);
    %normalize the histogram
    counts = counts/num_pixels;
    %compute the entropy of the histogram
    value = entropy(counts);
end
%window_x and window_y are the top left corner of the window
%image_width and image_height are the width and height of the image
%window_size is the size of the window
function image_window = get_window(image, window_x, window_y, image_width, image_height, window_size)
    %get the window for the image but crop it if it goes over the edge of the image
    %get the maximum x and y values for the window
    %note: the window will be cropped if it goes over the edge of the image
    max_x = min(window_x + window_size - 1, image_width);
    max_y = min(window_y + window_size - 1, image_height);
    %debugging: print out the window coordinates
    %fprintf('window_x: %d, window_y: %d, max_x: %d, max_y: %d, image_width: %d, image_height: %d\n', window_x, window_y, max_x, max_y, image_width, image_height);
    image_window = image(window_y:max_y, window_x:max_x);
end
function avgMat = movingAverageWithoutInf(mat, windowSize)
    % MOVINGAVERAGEWITHOUTINF computes a moving average of a matrix while ignoring -Inf values
    %   AVG_MAT = MOVINGAVERAGEWITHOUTINF(MAT, WINDOW_SIZE) computes a moving average of the input matrix MAT 
    %   using a window of size WINDOW_SIZE. The output matrix AVG_MAT has the same size as MAT and contains the 
    %   moving average values computed for each element. Any element with -Inf value is ignored when computing the 
    %   moving average.
    %
    %   Example:
    %       mat = [1, 2, -Inf, 4, 5; 6, 7, 8, 9, -Inf; 11, 12, 13, -Inf, 15];
    %       windowSize = 3;
    %       avgMat = movingAverageWithoutInf(mat, windowSize);
    %       disp(avgMat);
    
    % Initialize output matrix
    avgMat = zeros(size(mat));
    
    % Compute the moving average for each row in the matrix
    for i = 1:size(mat, 1)
        % Pad row with NaN values at the start and end to handle edge cases
        paddedRow = padarray(mat(i,:), [0, windowSize-1], NaN, 'both');
        
        % Compute the moving average for each element in the row
        for j = 1:size(mat, 2)
            %check if the element is -Inf
            if isinf(paddedRow(j))
                %if the element is -Inf, then set the output value to -Inf
                avgMat(i,j) = -Inf;
                %skip the rest of the loop
                continue;
            end
            % Find the window of elements to average
            window = paddedRow(j:j+windowSize-1);
            
            % Compute the average of the window, ignoring -Inf values
            avg = mean(window(~isinf(window)));
            
            % Set the output value to the computed average
            avgMat(i,j) = avg;
        end
    end
end
%function which bins values based on if they are closer to the min or the max, and then returns
%a logical array which says which values are in the bin with less values
function binned_out_values = bin_values(values)
    n = length(values);

    % Find the maximum and minimum values in the vector
    maxVal = max(values);
    minVal = min(values);

    % Compute the distances of each value from the max and min values
    distToMax = abs(values - maxVal);
    distToMin = abs(values - minVal);
    %instantiate vectors to hold the bin values
    binToMax = zeros(1,n);
    binToMin = zeros(1,n);
    % Determine which bin each value belongs to based on the distances
    for i = 1:n
        if distToMax(i) < distToMin(i)
            binToMax(i) = 1;
            binToMin(i) = 0;
        else
            binToMax(i) = 0;
            binToMin(i) = 1;
        end
    end

    % Compute the lengths of each bin (i.e., the number of values in each bin)
    binToMaxLength = sum(binToMax);
    binToMinLength = sum(binToMin);

    % Get the bin value vector for the bin with the smallest number of values
    if binToMaxLength < binToMinLength
        binValues = binToMax;
    else
        binValues = binToMin;
    end
    %print out the binValues vector and the values that belong to that bin
    %disp(binValues)
    %disp(values(binValues == 1))
    binned_out_values = logical(binValues);
end
        