%Function to compute the homography matrix between two sets of points in two corresponding images. 
 % 
 %Input: 
 %src_pts_nx2: n x 2 matrix of points in the source image 
 %dest_pts_nx2: n x 2 matrix of points in the destination image 
 % 
 %Output: 
 %H_3x3: 3 x 3 homography matrix 
 %
function H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2)
    % Convert the input points to homogeneous coordinates
    src_pts = [src_pts_nx2, ones(size(src_pts_nx2, 1), 1)];
    dest_pts = [dest_pts_nx2, ones(size(dest_pts_nx2, 1), 1)];
    n = size(src_pts, 1);
    % Construct matrix A using a loop
    % n = size(src_pts, 1);
    % A = zeros(n*2, 9);
    % for i = 1:n
    %     x = src_pts(i, 1);
    %     y = src_pts(i, 2);
    %     xp = dest_pts(i, 1);
    %     yp = dest_pts(i, 2);
    %     A(2*i-1, :) = [-x, -y, -1, 0, 0, 0, x*xp, y*xp, xp];
    %     A(2*i, :) = [0, 0, 0, -x, -y, -1, x*yp, y*yp, yp];
    % end
    %loop_A = A;
    %vectorized version of the above loop
    
    A = zeros(n*2, 9);
    A(1:2:end, :) = [-src_pts(:, 1), -src_pts(:, 2), -ones(n, 1), zeros(n, 3),...
     src_pts(:, 1).*dest_pts(:, 1), src_pts(:, 2).*dest_pts(:, 1), dest_pts(:, 1)];
    A(2:2:end, :) = [zeros(n, 3), -src_pts(:, 1), -src_pts(:, 2),...
     -ones(n, 1), src_pts(:, 1).*dest_pts(:, 2), src_pts(:, 2).*dest_pts(:, 2), dest_pts(:, 2)];
    %vectorized_A = A;
    %get the difference between the two matrices
    %diff = loop_A - vectorized_A;
    %print the difference
    %disp(diff);
    % Solve for the homography matrix using SVD (Singular Value Decomposition)
    [U, S, V] = svd(A);
    H_3x3 = reshape(V(:, end), 3, 3)';
end
