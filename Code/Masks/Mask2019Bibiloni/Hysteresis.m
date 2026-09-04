function [ binarizedImage ] = Hysteresis( fuzzyImage, lowerBound, upperBound )
%HYSTERESIS Thresholds a grayscale image with values in [0, 1] through an 
%histeresys procedure.
%
%   Usage:
%   [ binarizedImage ] = Hysteresis( fuzzyImage, lowerBound, upperBound ) - 
%       It returns all connected components above a given threshold
%       (lowerBound), that have at least one pixel above another threshold
%       (upperBound).
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

aboveLower = fuzzyImage > lowerBound;
[aboveUpperRow, aboveUpperCol] = find(fuzzyImage > upperBound);
binarizedImage = double( bwselect(aboveLower, aboveUpperCol, aboveUpperRow, 8) );

end

