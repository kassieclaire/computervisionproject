# Moving Object Removal from Unstabilized Images
This is Kassie's approach to removing moving objects from unstabilized images as part of the CS766 project
## Running the code
To run the code, add all folders and subfolders from this project to your MATLAB path and run the following command:
```main('path/to/imageset', max_image_resolution, debug)```

Where:

- path/to/imageset is the path to the folder containing the images you want to process (all images should be jpg or png files)
- max_image_resolution is the maximum size that the height or width can be. If the image is larger than this, it will be resized to fit. This is useful for speeding up the code if you have very large images.
- debug is a boolean value that determines whether or not to displays the artifacts used between the image processing and moving object removal steps. This is useful for finding inputs that work well for the moving object removal step.
There are also variables that you can change in the main function that are located at the top of the file. We do not recommend changing these unless the other steps do not work. These variables are:
- window_size: the size of the window used to find the moving objects. Larger windows sometimes have higher accuracy, but result in more blocking artifacts.
- threshold: the threshold used to determine if a window is part of a moving object. Higher thresholds result in less windows being classified as moving objects.
- max_rotation_angle limits the values that can be returned from the rotation estimation step. This is useful for when an image set doesn't transform as well with the radon transform and you can estimate the maximum rotation angle.

Here is an example using the image set in the image_set folder (the dinosaur toy on desk) with a max image resolution of 1000 and debug set to true:
```main('image_set', 1000, true)```

Here is another example using the image set in the image_set_2 folder (the amsterdam imageset) with a max image resolution of 1500 and debug set to false:
```main('image_set_2', 1500, false)```
## Dependencies
- Ensure that you have the MATLAB image toolbox installed
## The functions
### align_image_rotation
inputs:
- images: a cell array of images, with the first being the base image
- max_rotation_angle: the maximum rotation angle that can be returned from the rotation estimation step

outputs:
- aligned_images: a cell array of images, with the first being the base image, each image is rotated to match the base image
- rotations: a vector of rotation angles (in degrees) for each image
- figs: a cell array of the radon transform figures for each image with the max theta value marked with a blue circle

This function aligns the image rotations using the radon transform. The solution uses the radon function for both the original and rotated images, and calculates the max theta for each. The difference between the max theta values is the rotation angle. The sub-functions used in this function can be found in the image_rotation folder.
### sift_align
inputs:
- images: a cell array of images, with the first being the base image

outputs:
- aligned_images: a cell array of images, with the first being the base image, each image is rotated to match the base image
- masks: a cell array of masks for each image, indicating their coverage of the base image

This function aligns the images using SIFT with RANSAC. The sub-functions can be found in the image_stitching folder.

### detect_outliers
inputs:
- images: a cell array of images, with the first being the base image
- masks: a cell array of masks for each image, indicating their coverage of the base image
- window_size: the size of the window used to find the moving objects
- threshold: the threshold used to determine if a window is part of a moving object
- num_bins: the number of bins used for the binning implementation (not used currently, since 2 bins is the best)

outputs:
- outlier_masks: a cell array of masks for each image, indicating the moving objects in the image (0 = moving object or no coverage, 1 = not a moving object and has coverage)

This function detects the moving objects in the images. It uses a sliding window to compare the images to the base image. If the window is part of a moving object, it is marked as an outlier. All subfunctions are located in the detect_outliers file. There are various implementations, and it is currently set up for the binning implementation. This implementation is explained on the website.
### blend_images
inputs:
- images: a cell array of images, with the first being the base image
- outlier_masks: a cell array of masks for each image, indicating the moving objects in the image (0 = moving object or no coverage, 1 = not a moving object and has coverage)

outputs:
- result_image: the blended image

This function blends the images together using the outlier masks. It uses the mean of the non-outlier pixels to blend the images together.

