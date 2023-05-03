function reorient_images(base_image_path, image_set_path, output_folder, edge_folder)

    % Read the base image
    base_image = imread(base_image_path);
    
    % Get a list of images in the image_set_path folder
    image_files = dir(fullfile(image_set_path, '*.jpg'));
    
    % Loop through each image and reorient it using the removeRotation function
    for i = 1:numel(image_files)
        % Read the rotated image
        rotated_image_path = fullfile(image_set_path, image_files(i).name);
        rotated_image = imread(rotated_image_path);
        
        % Remove the rotation from the image
        [reoriented_image, ~, edge_image] = removeRotation(rotated_image, base_image);
        % Save the edge image to the output folder
        [~, filename, ext] = fileparts(rotated_image_path);
        output_path = fullfile(edge_folder, [filename, '_edge', ext]);
        imwrite(edge_image, output_path);
        % Save the reoriented image to the output folder
        [~, filename, ext] = fileparts(rotated_image_path);
        output_path = fullfile(output_folder, [filename, '_reoriented', ext]);
        imwrite(reoriented_image, output_path);
    end
    
    end
    