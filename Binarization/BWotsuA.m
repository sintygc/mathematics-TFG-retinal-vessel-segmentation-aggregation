function [result,T] = BWotsuA(image,varargin)

%image: 584x565 uint8 u=256 [0,255]
result = imbinarize(image,'adaptive');
T = 0;

end