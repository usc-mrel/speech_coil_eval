
function [reordered] = reorder_slices(image)
% Function to reorder slices from a 3D interleaved acquisition
% with an even number of slices.
% Original ordering of slices: [ 2 4 6 ...32, 1 3 5...31]
% Output ordering of slices:   [ 1 2 3 4 ... 32];
%
%          
%
even = image(:,:,1:size(image,3)/2,:);

odd  = image(:,:, (size(image,3)/2) +1 :size(image,3),:);

reordered = zeros(size(image));
for i = 1:size(image,3)/2
    reordered(:,:,i + (i-1),:) = odd(:,:,i,:);
end

for i = 1:size(image,3)/2
    reordered(:,:,2*i,:) = even(:,:,i,:);
end

end 