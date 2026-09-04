function [ reflectedStructuringElement ] = ReflectStructuringElement( ...
    originalStructuringElement )
%REFLECTSTRUCTURINGELEMENT. Computes the ``flipped'' structured element by
%flipping it in each of its dimensions.
%
%   Usage:
%   [ ReflectedStructuringElement ] = ReflectStructuringElement( originalStructuringElement ) - 
%       With a matrix as input, it produces a matrix as output in which all
%       elements are rotated around the center, given as the central point
%       (or the central point + 0.5 if the length is odd).
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


% Pad with zeros where center is not matrix center (even length)
indexCenter = ceil( (size(originalStructuringElement) + 1)/2.0 );
dimensionWithPairNumberOfRows = indexCenter ~= (size(originalStructuringElement)+1)/2.0;
originalStructuringElement = padarray(originalStructuringElement, ...
    1.0 .* dimensionWithPairNumberOfRows, ...
    'post' );

% Turn upside down in each dimension
reflectedStructuringElement = originalStructuringElement;
for i=1:ndims(originalStructuringElement)
    reflectedStructuringElement = flip( reflectedStructuringElement, i );
end

end