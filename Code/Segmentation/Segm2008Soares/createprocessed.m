function createprocessed(labelledfilenames, processedfilename, nsamples)
% createprocessed(labelledfilenames, processedfilename, nsamples)
%
% Receives a two-dimensional array "labelledfilenames" with the names
% of labelles files containg labelled pixels along with their
% features. Creates "processedfilename", used for training
% classifiers. "nsamples" random samples are selected among all of the
% available.

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

featurematrix = [];
samples = [];
means = [];
vars = [];

nfiles = size(labelledfilenames, 1); %número de imágenes de entrenamiento = 45
% Will randomly select nsamplesperfile from each file.
nsamplesperfile = ceil(nsamples / nfiles); %cuántos samples se cogerán de cada .mat

for i = 1:nfiles %para cada feature-labelled.mat
  L = load(deblank(labelledfilenames(i,:)));

  [rows, columns] = size(L.featurematrix); %muchas filas, 6 columnas
  if (nargin == 3 & nsamplesperfile < rows & nsamples ~= 0) 
      %si el número de samples es menor al número de filas (el resto se cumple)
    % Selecting the random samples from the file.
    
    factor = nsamplesperfile/rows; 

    vesselmatrix = L.featurematrix(L.featurematrix(:, 1) == 1, :);
    %coge todas las filas que corresponden a vaso en el GT
    restmatrix = L.featurematrix(L.featurematrix(:, 1) == 0, :);
    %coge todas las filas que NO corresponden a vaso en el GT
        
    nvessel = size(vesselmatrix, 1); %=num de vasos
    nrest = size(restmatrix, 1); %=num de no vasos

    randindex = randperm(nvessel); %cada vez sale diferente! 
    %tiene sentido porque se hace una selección para cada training image
    vesselmatrix = vesselmatrix(randindex(1:ceil(nvessel * factor)), :);
    %coge nvessel*factor píxeles de vasos aleatorios

    randindex = randperm(nrest);
    restmatrix = restmatrix(randindex(1:ceil(nrest * factor)), :);
    %coge nrest*factor píxeles de NO vasos aleatorios
   
    addmatrix = [vesselmatrix; restmatrix];
  else % preserves all samples
    addmatrix = L.featurematrix; %si no se cogen todas las filas
  end

  % Normalizes each feature matrix individually.
  m = mean(addmatrix(:, 2:end)); 
  %media de los píxeles cogidos aleatoriamente de cada imagen menos GT, 1x5
  var0 = var(addmatrix(:, 2:end));
  %varianza normalizada con N-1, donde N es el número de observaciones
  var1 = var(addmatrix(:, 2:end), 1);
  %varianza normalizada con N, donde N es el número de observaciones
  addmatrix(:, 2:end) = normfeats(addmatrix(:, 2:end), m, sqrt(var0));
  %normaliza todas las imágenes menos la GT, (...-mean)/std

  % Accumulates each set of sample's means, vars, and count.
  samples = [samples; size(addmatrix, 1)]; 
  %cada fila es el tamaño de la muestra para cada imagen
  means = [means; m];
  %en cada fila hay las 5 medias de la imagen correspondiente
  vars = [vars; var1];
  %en cada fila hay las 5 varianzas con N de la imagen correspondiente

  % Adds the new samples.
  featurematrix = [featurematrix; addmatrix];
  %añade como filas los píxeles de muestra para cada imagen: habrá 24x45=1080
end

% description = L.description;

% Calculates the total means and stds from each image's.
samplemean = (samples' * means) / sum(samples);
%samples:45x1, means:45x5, samples' es la transpuesta: 1x45, así queda 1x5
samplevar = (samples' * vars) / (sum(samples) - 1);
samplestd = sqrt(samplevar);

% Saves in "processed" in matlab format.
save(processedfilename, 'featurematrix', 'samplemean', 'samplestd', '-MAT');