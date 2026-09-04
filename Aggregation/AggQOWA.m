function result = AggQOWA(images)

%weight generating functions OWA from page 81-82

[l,m,n] = size(images);
im_s = sort(images,3,'descend');

for i=1:n
    w(i)=Q(i/n)-Q((i-1)/n);
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end

function q = Q(t)

% for "most", (a,b)=(0.3,0.8)
a=0.3;
b=0.8;
if t<=a
    q=0;
elseif t>=b
    q=1;
else
    q=(t-a)/(b-a);
end

end
