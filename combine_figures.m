% Set the path to the image directory
img_dir = 'radon_figures';

% Get a list of image files in the directory
img_files = dir(fullfile(img_dir, '*.png'));

% Set the number of images per row
num_cols = 3;

%Create a combined image, with the images arranged in a grid
combined_img = combine_images(img_dir, img_files, num_cols);

% Save the combined image
imwrite(combined_img, fullfile(img_dir, 'combined.png'));

%combined_image function
function combined_img = combine_images(img_dir, img_files, num_cols)
    % Create a cell array to store the images
    img_cells = cell(1, length(img_files));
    % Loop over the images
    for idx = 1:length(img_files)
        % Read the image
        img = imread(fullfile(img_dir, img_files(idx).name));
        % Add the image to the cell array
        img_cells{idx} = img;
    end
    % Combine the images into a single image
    combined_img = combine_images_helper(img_cells, num_cols);
end
%combine_images_helper function
function combined_img = combine_images_helper(img_cells, num_cols)
    % Get the number of rows and columns
    num_rows = ceil(length(img_cells) / num_cols);
    % Create a cell array to store the rows
    row_cells = cell(1, num_rows);
    % Loop over the rows
    for row = 1:num_rows
        % Get the indices of the images in this row
        start_idx = (row - 1) * num_cols + 1;
        end_idx = min(row * num_cols, length(img_cells));
        % Get the images in this row
        img_cells_in_row = img_cells(start_idx:end_idx);
        % Combine the images in this row
        row_cells{row} = cat(2, img_cells_in_row{:});
    end
    % Combine the rows into a single image
    combined_img = cat(1, row_cells{:});
end

