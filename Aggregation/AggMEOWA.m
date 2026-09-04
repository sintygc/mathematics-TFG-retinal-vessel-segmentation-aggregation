function result = AggMEOWA(images,a)

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

b=(n-1)*a;
syms w1
x=double(solve(w1*(b+1-n*w1)^n-b^(n-1)*(b-n)*w1-b^(n-1)==0,w1,'Real',true));
% x=solve(w1*(b+1-n*w1)^n-b^(n-1)*(b-n)*w1-b^(n-1)==0,w1,'Real',true);
% x=unique(round(x,6));
if a==0.5
    w(1)=1/n;
else
%     w(1)=min(x);
%     w(1)=x(x<(((n-1)*a+1)/(n*(n+1))));
    w(1)=x(x<(1/n));
end
w(n)=((b-n)*w(1)+1)/(b+1-n*w(1));
for i=2:(n-1)
    w(i)=(w(1)^(n-i)*w(n)^(i-1))^(1/(n-1));
end

if rev==1
    w = flip(w);
end

for i=1:n
    w_im(:,:,i) = w(i)*im_s(:,:,i);
end

result = sum(w_im,3);

end