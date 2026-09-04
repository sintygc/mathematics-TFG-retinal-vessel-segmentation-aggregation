function [ dilatedImage ] = FuzzyDilation( fuzzyImage, fuzzyStructuringElement, conjunction )
%FUZZYDILATION Performs the dilation of a fuzzy image (in [0, 1]) with a 
%fuzzy structuring element (also in [0, 1]).
%
%   Usage:
%   [ dilatedImage ] = FuzzyDilation( fuzzyImage, fuzzyStructuringElement, conjunction ) - 
%       Returns the dilation of the image, where the foreground object is
%       assumed to have positive values, whereas the background is assumed 
%       to have a 0 value. The conjunction should be function handler able
%       to process matrices in a pixel-wise fashion.
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

sz = size(fuzzyStructuringElement);
c = ceil( size(fuzzyStructuringElement)/2 );

dilatedImage = zeros( sz );
for i=1:size(fuzzyImage, 1)
    for j=1:size(fuzzyImage, 2)
        
        kMin = max(1, 1 + c(1) - i);
        kMax = min(sz(1), size(fuzzyImage, 1) + c(1) - i);
        
        lMin = max(1, 1 + c(2) - j);
        lMax = min(sz(2), size(fuzzyImage, 2) + c(2) - j);
        
        
        values = conjunction( fuzzyStructuringElement( kMin:kMax, lMin:lMax), ...
            fuzzyImage( i-c(1)+kMin : i-c(1)+kMax, j-c(2)+lMin : j-c(2)+lMax) );
        
        dilatedImage(i,j) = max( values(:) );
        
    end
end