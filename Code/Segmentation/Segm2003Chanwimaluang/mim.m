function rt = mim(Y,sa)
% Thitiporn Chanwimaluang
% tchanwim@gmail.com
% Department of Electrical and Computer Engineering
% Oklahoma State University

[M,N] = size(Y);
x = [-6: 6];
tmp1 = exp(-(x.*x)/(2*sa*sa)); 
tmp1 = max(tmp1)-tmp1; 
ht1 = repmat(tmp1,[9 1]); 
sht1 = sum(ht1(:));
mean = sht1/(13*9);
ht1 = ht1 - mean;
ht1 = ht1/sht1; %ha normalizado ht1(?)

h{1} = zeros(15,16);
for i = 1:9
    for j = 1:13
        h{1}(i+3,j+1) = ht1(i,j);
    end
end

for k=1:11
    ag = 15*k;
    h{k+1} = imrotate(h{1},ag,'bicubic','crop');
end

for k=1:12
    R(:,:,k) = conv2(Y, h{k}, 'same');
end %R: 584x565x12 double u=3957929 [-10.1456,9.4324]

rt = max(R,[],3); %rt: 584x565 double u=329870 [-2.6671,9.4324]

rmin = abs(min(rt(:)));
rt = rt+rmin; %rt: 584x565 double u=329748 [0,12.0995]
rmax = max(max(rt));
rt = round(rt*255/rmax); %rt: 584x565 double u=254 [0,255]