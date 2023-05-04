%function which loads images from the given directory and returns them as a cell array
%of images. The images are resized so that the largest dimension is equal to max_size.
function images = load_images(directory, max_size)
    files = dir(directory);
    images = cell(1, length(files) - 2);
    for i = 3:length(files)
        images{i - 2} = imread(strcat(directory, '/', files(i).name));
        images{i - 2} = imresize(images{i - 2}, max_size / max(size(images{i - 2})));
    end
end