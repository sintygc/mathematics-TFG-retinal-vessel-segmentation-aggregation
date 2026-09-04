function result = AggMEOWAda(images,a)

%Maximum Entropy OWA from page 78-79, for unspecified alpha=a
%2001_Fuller

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

d=-a*(n-1);
syms t
f = 0;
for p = 0:(n-1)
    f = f+(d+n-1-p)*t^p;
end
x=double(solve(f==0,t,'Real',true));
% x=unique(round(x,6));
sol = x(x>0);
T = 0;
for j=1:n
    T = T+sol^j;
end
for i=1:n
    w(i)=(sol^i)/T;
end

if rev==1
    w = flip(w);
end

for i=1:n
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end