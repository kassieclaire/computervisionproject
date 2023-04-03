%%function that tests the function stitched_img = stitchImg(varargin)
%reads in the images, calls the function to stitch them, and displays the result
function stitched_img = stitch_test(varargin)
    %read in the images
    img1 = im2single(imread(varargin{1}));
    img2 = im2single(imread(varargin{2}));
    %call the function to stitch the images
    stitched_img = stitchImg(img1, img2);
    %display the result
    figure;
    imshow(stitched_img);
end