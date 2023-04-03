%%Apply a homography to a set of points. 
%Inputs:
% H_3x3 - 3x3 homography matrix 
% src_pts_nx2 - Nx2 matrix of [x,y] coordinates of points to transform 
% Outputs: 
% dest_pts_nx2 - Nx2 matrix of [x,y] coordinates of transformed points
function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)
    % Convert the input points to homogeneous coordinates
    src_pts = [src_pts_nx2, ones(size(src_pts_nx2, 1), 1)];

    % Transform the points using the homography matrix
    dest_pts = src_pts * H_3x3';

    % Convert the result back to Euclidean coordinates
    dest_pts_nx2 = dest_pts(:, 1:2) ./ dest_pts(:, 3);

end
    