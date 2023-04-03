%function which
function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)

    %rename the input variables
    src_pt = Xs;
    dest_pt = Xd;
    ransac_eps = eps;
    % Initialize variables
    max_inliers = 0;
    inliers_id = [];
    
    for i = 1:ransac_n
        % Randomly select 4 point correspondences
        subset_idx = randperm(size(src_pt, 1), 4);
        subset_src_pt = src_pt(subset_idx, :);
        subset_dest_pt = dest_pt(subset_idx, :);
    
        % Compute homography using the subset of points
        subset_H = computeHomography(subset_src_pt, subset_dest_pt);
        
        % Compute the projected points using the current homography
        dest_pt_hat = applyHomography(subset_H, src_pt);
    
        % Compute the Euclidean distance between the projected and actual points
        err = sqrt(sum((dest_pt - dest_pt_hat).^2, 2));
    
        % Find the inliers within the specified error threshold
        inliers = find(err < ransac_eps);
    
        % Update the maximum number of inliers found so far
        if length(inliers) > max_inliers
            max_inliers = length(inliers);
            inliers_id = inliers;
        end
        
    end
    % Compute homography using all the inliers
    H = computeHomography(src_pt(inliers_id, :), dest_pt(inliers_id, :));
    
end
    