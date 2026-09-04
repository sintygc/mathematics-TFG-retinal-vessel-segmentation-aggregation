function [ closedImage, dilatedImage ] = FuzzyClosing( ...
    fuzzyImage, fuzzyStructuringElement, conjunction, implication )
%FUZZYCLOSING Performs the closing (erosion of dilation) of a fuzzy
%image (in [0, 1]) with a fuzzy structuring element (also in [0, 1]).
%
%   Usage:
%   [ closedImage, dilatedImage ] = FuzzyClosing( fuzzyImage, fuzzyStructuringElement, conjunction, implication ) - 
%       It returns the closing of the image, where the foreground object is
%       assumed to have positive values, whereas the background is assumed 
%       to have a 0 value. The conjunctor and implicator should be function
%       handlers that are used for computing dilations and erosions. They 
%       should be able to process matrices in a pixel-wise fashion.
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

    dilatedImage =  FuzzyDilation(fuzzyImage, fuzzyStructuringElement, conjunction);
    
    reflectedStructuringElement = ReflectStructuringElement( fuzzyStructuringElement );
    
    closedImage = FuzzyErosion(dilatedImage, reflectedStructuringElement, implication);

end