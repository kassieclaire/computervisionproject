%%Function to show the correspondence between two images
%%Input:
%%orig_img: original image
%%warped_img: warped image
%%src_pts_nx2: source points in the original image
%%dest_pts_nx2: destination points in the warped image
%%Output:
%%result_img: the image with the correspondence shown. The correspondence is shown by drawing lines between the source and destination points
function result_img = showCorrespondence(orig_img, warped_img, src_pts_nx2, dest_pts_nx2)
    %create the result image with the size of the original image and the warped image. 
    %The images should be placed side by side, and the height of the result image should 
    %be the maximum of the height of the original image and the warped image
    result_img = zeros(max(size(orig_img,1),size(warped_img,1)),size(orig_img,2)+size(warped_img,2),3);
    %copy the original image to the left side of the result image   
    result_img(1:size(orig_img,1),1:size(orig_img,2),:) = orig_img;
    %copy the warped image to the right side of the result image
    result_img(1:size(warped_img,1),size(orig_img,2)+1:size(orig_img,2)+size(warped_img,2),:) = warped_img;
    %draw the correspondence lines
    for i = 1:size(src_pts_nx2,1)
        %draw a line from the source point to the destination point
        result_img = insertShape(result_img,'Line',[src_pts_nx2(i,1),src_pts_nx2(i,2),dest_pts_nx2(i,1)+size(orig_img,2),dest_pts_nx2(i,2)],'LineWidth',2);
    end
    %conveert the result image to uint8
    result_img = uint8(result_img);
end
    
