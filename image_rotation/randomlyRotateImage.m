%function that takes in the filename of an image, loads in the image, and prandomly produces a rotation of that image and its colormap
function rotatedImage = randomlyRotateImage(image) 
    %get the size of the image 
    [rows, columns, numberOfColorChannels] = size(image); 
    %get the center of the image 
    centerRow = rows/2; centerColumn = columns/2; 
    %get the angle of rotation 
    angle = rand()*360; 
    %rotate the image
    rotatedImage = imrotate(image, angle, 'bilinear');
end
