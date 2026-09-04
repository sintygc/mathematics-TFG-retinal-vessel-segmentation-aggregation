function [ structuringElement ] = CreateStructuringElement( ...
    type, sizeStructuringElement, parameter )
%CREATESTRUCTURINGELEMENT Creates a static structuring element to be used
%with other morphological operations.
%
%   It returns a matrix of numbers, where the center is the point:
%       c = ceil( size(strElement)/2 );
%
%   It accepts the following types:
%       * 'flat' or 'flat-square': all ones.
%       * 'flat-diamond': diamond-shaped binary element.
%       * 'flat-circular': rounded flat shape.
%       * 'impulsive': just a single one in the center.
%       * 'pyramidal': squared pyramidal with one in the center.
%       * 'euclidean': escaled distance from the center.
%       * 'gaussian': gaussian function of the distance from the center.
%               parameter.center [x, y]. Default: ceil( size(strElement)/2 )
%               parameter.variance [pixels^2]. Default: mean(sizeStructuringElement / 4).^2
%       * 'linear': a gaussian function throughout a straight line.
%               parameter.inclination [degrees]. Default: 0
%               parameter.width [pixels]. Default: mean(sizeStructuringElement)/7.
%
%   Size can be a 2-element matrix or a single numeric element (where the
%   structuring element is considered to be squared).
%
%   Usages:
%   [ structuringElement ] = CreateStructuringElement( type, sizeStructuringElement ) -
%       Creates a structuring element of the given type and size. 
%       Parameters are set to default when needed.
%   [ structuringElement ] = CreateStructuringElement( type, sizeStructuringElement, parameter ) -
%       Creates a structuring element of the given type, size and 
%       parameters.
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
  
    if length(sizeStructuringElement) == 1
        sizeStructuringElement = [sizeStructuringElement, sizeStructuringElement];
    end
    
    if ~exist('type', 'var')
        error('--> Type of Structuring Element needed!');
    elseif ~exist('sizeStructuringElement', 'var')
        error('--> Size of Structuring Element needed!');
    elseif ~exist('parameter', 'var')
        parameter = struct();
    end
    
    if 1 == isequal(sizeStructuringElement, [1, 1]);
        
        structuringElement = 1;
        
    else
        
        structuringElement = zeros(sizeStructuringElement);
        center = double(sizeStructuringElement + [1, 1])/2;
        indexCenter = ceil( center );
        
        if 1 == strcmpi(type, 'flat') || 1 == strcmpi(type, 'flat-square')
            structuringElement = ones(sizeStructuringElement);
            
        elseif 1 == strcmpi(type, 'flat-diamond')
            maxManhattanDistance = min( sizeStructuringElement(:) - indexCenter(:) );
            [coordX, coordY] = meshgrid( 1:sizeStructuringElement(2), 1:sizeStructuringElement(1) );
            coordX = abs(coordX - indexCenter(2));
            coordY = abs(coordY - indexCenter(1));
            structuringElement(coordX + coordY <= maxManhattanDistance) = 1;
            figure, imagesc( structuringElement );
            
        elseif 1 == strcmpi(type, 'flat-circular')
            maxEuclideanDistance = 0.5 + min( sizeStructuringElement(:) - indexCenter(:) );
            [coordX, coordY] = meshgrid( 1:sizeStructuringElement(2), 1:sizeStructuringElement(1) );
            coordX = abs(coordX - center(2));
            coordY = abs(coordY - center(1));
            structuringElement(coordX.^2 + coordY.^2 <= maxEuclideanDistance.^2) = 1;
            
        elseif 1 == strcmpi(type, 'impulsive')
            structuringElement(indexCenter(1), indexCenter(2)) = 1;
            
        elseif 1 == strcmpi(type, 'pyramidal')
            for i=1:sizeStructuringElement(1)
                for j=1:sizeStructuringElement(2)
                    structuringElement(i,j) = abs(i-center(1)) + abs(j-center(2));
                end
            end;
            structuringElement = 1 - structuringElement/max( structuringElement(:) );
            
        elseif 1 == strcmpi(type, 'euclidean')
            [coordX, coordY] = meshgrid( 1:sizeStructuringElement(2), 1:sizeStructuringElement(1) );
            coordX = coordX - indexCenter(2);
            coordY = coordY - indexCenter(1);
            euclideanDistance = sqrt(coordX.^2 + coordY.^2);
            structuringElement = 1 - euclideanDistance/max( euclideanDistance(:) );
            
        elseif 1 == strcmpi(type, 'gaussian')
            if isfield(parameter, 'center'), gaussianCenter = parameter.center;
            else gaussianCenter = indexCenter; end
            [coordX, coordY] = meshgrid( 1:sizeStructuringElement(2), 1:sizeStructuringElement(1) );
            coordX = coordX - gaussianCenter(2);
            coordY = coordY - gaussianCenter(1);
            euclideanDistance = sqrt(coordX.^2 + coordY.^2);
            
            if isfield(parameter, 'variance'), variance = parameter.variance;
            else variance = mean(sizeStructuringElement / 4).^2; end
            
            structuringElement = exp(- euclideanDistance.^2/(2*variance) );
            
        elseif 1 == strcmpi(type, 'linear')
            if isfield(parameter, 'inclination'), m = tan(parameter.inclination * pi / 180);
            else m = 0; end
            [coordX, coordY] = meshgrid( 1:sizeStructuringElement(2), 1:sizeStructuringElement(1) );
            coordX = coordX - (sizeStructuringElement(2)+1)/2;
            coordY = coordY - (sizeStructuringElement(1)+1)/2;
            if m > 1e15
                distanceToLine = abs(coordX);
            else
                distanceToLine = abs( m * coordX - coordY ) / sqrt( m^2 + 1 );
            end
            
            
            if isfield(parameter, 'width'), variance = (parameter.width.^2)/16;
            else variance = max(1, mean(sizeStructuringElement)/7)/2; end
            
            structuringElement = exp(- distanceToLine.^2/(2*variance) );
%             structuringElement = max(0, exp(- ( 2*distanceToLine/mean(center) ).^2 ));
            
            
        else
            error('--> Type unknown. Try "Gaussian" for instance.');
            
        end
        
    end
        

end
