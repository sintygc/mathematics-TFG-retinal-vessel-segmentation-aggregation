function result = AggEx2(images)

%Second weighting vector of Example 2.52 from page 70

[l,m,n] = size(images);
im_s = sort(images,3,'descend');
for i=1:n
    w(i) = (2*(n+1-i))/(n*(n+1));
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end