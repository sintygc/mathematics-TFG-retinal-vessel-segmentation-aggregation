function result = AggMVOWA(images,a)

%minimum Variance OWA from page 79-81, for unspecified alpha=a
%2003_Fuller

if a<0 || a>1
    disp('error')
end

[l,m,n] = size(images);
im_s = sort(images,3,'descend');
rev=0;
if a>0.5
    a=1-a;
    rev = 1;
end

r = floor(n-3*(n-1)*a);
if r<1
    r=1;
end
if r>1
    for i=1:(r-1)
        w(i)=0;
    end
end
w(r)=(6*(n-1)*a-2*(n-r-1))/((n-r+1)*(n-r+2));
w(n)=(2*(2*n-2*r+1)-6*(n-1)*a)/((n-r+1)*(n-r+2));
if (n-r)>1
    for j=(r+1):(n-1)
        w(j)=w(r)+(j-r)/(n-r)*(w(n)-w(r));
    end
end
if rev==1
    w = flip(w);
end

for i=1:n
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end