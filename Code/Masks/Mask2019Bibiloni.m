function [maskRes, elapsedMask] = Mask2019Bibiloni( originalRGBImage )
%ESTIMATEMASKEYEFUNDUS Creates a mask estimating the background of an eye 
%fundus image.
%
%   Usage:
%   [ estimatedMask ] = EstimateMaskEyeFundus( sample ) - 
%       It returns a mask of zeros and ones, where zero indicates that the
%       pixel belongs to the background, and zero that the pixel belongs to
%       the retina.
%

%
% Copyright (C) 2015  Pedro Bibiloni Serrano
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

timerElapsed = tic;

originalRGBImage = double(originalRGBImage);
%originalRGBImage: 584x565x3 uint8 u=256 [0,255]
sizeOriginal = size( originalRGBImage ); %=[584,565,3]
dimensionOriginal = numel( sizeOriginal ~= 1 ); %=3
if dimensionOriginal == 3
    luminance = originalRGBImage(:,:,1) * 0.2989 + ...
    originalRGBImage(:,:,2) * 0.5870 + ...
    originalRGBImage(:,:,3) * 0.1140; %luminance: 584x565 uint8 u=224 [0,223]
    luminance = luminance / max( luminance(:) ); %luminance: 584x565 uint8 u=2 {0,1}
%     g=rgb2gray(originalRGBImage);
elseif  dimensionOriginal == 2
    luminance = originalRGBImage;
    luminance = luminance / max( luminance(:) );
    fprintf('--> Warning: AngiographyMethodEstimateMask: there is only one channel, which has been assumed to be the luminance one!\n');
else
    error('--> The dimension of original image mismatches');
end

B = ones(3);
B = B / sum( B(:) );
filtered1 = imfilter( luminance, B); %filtered1: 584x565 uint8 u=2 {0,1}

minImage = min( filtered1(:) ); %= 0
meanImage = mean( filtered1(:) ); %= 0.4114
maxImage = max( filtered1(:) ); %= 1
autoLowerBound = (0*double(minImage) + 1*meanImage)/2; %0+0.4114=0??????????????????????????????
autoUpperBound = (0.8*double(maxImage) + 0.2*meanImage)/2;
hysteresis1 = Hysteresis( filtered1, ...
    autoLowerBound, ...
    autoUpperBound );

maskRes = hysteresis1;

elapsedMask = toc(timerElapsed);

end

