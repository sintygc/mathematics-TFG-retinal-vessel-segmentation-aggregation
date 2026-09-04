function [result,T] = BWotsu(image,varargin)

%image: 584x565 uint8 u=256 [0,255]
% image=double(image);
% image=scale_01(image); 
T = graythresh(image); %=0.1059
result = imbinarize(image,T);

end