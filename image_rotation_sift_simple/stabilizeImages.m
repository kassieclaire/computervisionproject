function stabilizedImages = stabilizeImages(baseImage, setOfImages)
    % Convert images to grayscale
    baseImageGray = rgb2gray(baseImage);
    setOfImagesGray = cellfun(@(image) rgb2gray(image), setOfImages, 'UniformOutput', false);

    % Detect and extract features from images
    baseImagePoints = detectSURFFeatures(baseImageGray);
    baseImageFeatures = extractFeatures(baseImageGray, baseImagePoints);
    setOfImagesPoints = cellfun(@(image) detectSURFFeatures(image), setOfImagesGray, 'UniformOutput', false);
    setOfImagesFeatures = cellfun(@(points, image) extractFeatures(image, points), setOfImagesPoints, setOfImagesGray, 'UniformOutput', false);

    % Match features between images and find affine transformations
    imagePairs = matchFeaturesBetweenImages(baseImageFeatures, setOfImagesFeatures);
    affineTransforms = computeAffineTransformsBetweenImages(baseImagePoints, setOfImagesPoints, imagePairs);

    % Stabilize images
    [stabilizedImages, ~] = imwarpMultiple(setOfImages, affineTransforms, 'OutputView', imref2d(size(baseImageGray)));

    % Crop images
    for i = 1:numel(stabilizedImages)
        stabilizedImages{i} = cropToContent(stabilizedImages{i});
    end
end
function [imagePairs, matchedFeatures] = matchFeaturesBetweenImages(features1, features2)
    % Match features between two sets of features using SURF descriptors and the nearest-neighbor ratio test
    indexPairs = matchFeatures(features1, features2, 'MatchThreshold', 10.0, 'MaxRatio', 0.6);
    matchedFeatures = features1(indexPairs(:, 1));
    imagePairs = indexPairs;
end
