function mask = createlabelled(featurefilename, segmentationfilename,outputfilename, roisize)
% mask = createlabelled(featurefilename, segmentationfilename, outputfilename, roisize)
%
% Opens the features from an image from "featurefilename" and writes
% each pixel's features in file "outputfilename", along with the
% pixel's labels. "segmentationfilename" is the image with the labels
% (should be a segmentation of the vessels), which will be used for
% classifier training. The pixels forming the labelled file are
% determined by a rectangle in random position of size (x * "roisize",
% y * "roisize"), where (x, y) is the original image size. All other
% pixels will be ignored. The region used is returned in mask.
%
% mask = createlabelled(featurefilename, segmentationfilename, outputfilename)
%		         
% Opens the features from an image from "featurefilename" and writes
% each pixel's features in file "outputfilename", along with the
% pixel's labels. "segmentationfilename" is the image with the labels
% (should be a segmentation of the vessels), which will be used for
% classifier training. 

%
% Copyright (C) 2006  João Vitor Baldini Soares
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301, USA.
%

F = load(featurefilename);

% Creating the matrix with the labels.
class = imread(segmentationfilename); %el GT de la imagen correspondiente
%solo una matriz, binaria {0,255}

if ( size(class, 3) == 3 ) % si está en color
  class = rgb2gray(class); % pasar a escala de grises
end  %no se hace
class = class > 128; %binariza con threshold=128
vessels = class; %le pone el nombre 'vessels'
rest = ~class; %'rest' es el negativo de 'vessels'

% Creates the mask with a random part of the image.
% if ( nargin == 4 ) %no está definido roisize
%   rectmask = logical(zeros(size(class)));
%   width = round(size(class, 2) * roisize) - 1;
%   height = round(size(class, 1) * roisize) - 1;
% 
%   x0 = floor( rand(1) * (size(class, 2) - width) ) + 1;
%   y0 = floor( rand(1) * (size(class, 1) - height) ) + 1;
%   rectmask(y0:y0 + height, x0:x0 + width ) = logical(1);
% 
%   mask = F.mask & rectmask;
% else % Normal mask.
  mask = F.mask; %es la máscara: negro fondo, blanco ojo
% end

% Adds labels to features.
features = cat(3, double(vessels), F.features); %concatenate arrays
%...x1 es double(vessels), ...x2 inverted green channel, ...x3,4,5,6 los 4 morlets
% description = strvcat('class', F.description); %añade la descripción de la 1a matriz
% description:
% "class                         
% Inverted green channel        
% Morlet a = 2, k0y = 3, eps = 4
% Morlet a = 3, k0y = 3, eps = 4
% Morlet a = 4, k0y = 3, eps = 4
% Morlet a = 5, k0y = 3, eps = 4"


% Arranges features in a matrix, taking only pixels from the region of
% interest.
[rows, columns, pages] = size(features); %rows y columns da las dimensiones de la imagen, pages=6
featurematrix = reshape(features, [rows * columns, pages]);
%matriz de rows*columns filas y pages=6 columnas
%habrá de dos tamaños: 
%para las imágenes de DRIVE 329 960
%para las imágenes de STARE 423 500
featurematrix = featurematrix(mask(:) & (rest(:) | vessels(:)), :);
%se cogen todas las entradas donde mask (es decir GT) coincida con (rest o vessels)
%rest(:) | vessels(:) = todas las entradas donde alguno de los dos sea blanco, es decir, todo
%por tanto se cogen todas las entradas donde mask=1, i.e. los píxeles de ojo
%features tiene sum(mask(:)==1) filas

% Saves in "outputfilename" in matlab format.
save(outputfilename, 'featurematrix', 'mask', '-MAT');
