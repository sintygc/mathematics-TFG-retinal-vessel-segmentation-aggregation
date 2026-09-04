function result = AggEx1(images)

%First weighting vector of Example 2.52 from page 70

[l,m,n] = size(images);
im_s = sort(images,3,'descend');
j = 1./(1:n);
for i=1:n
    w(i) = 1/n*sum(j(i:n));
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end