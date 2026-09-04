function gmmcreatemodel(processedfilename, modelfilename, kvessel, krest, type)
% gmmcreatemodel(processedfilename, modelfilename, kvessel, krest, type)
%
% Creates the gaussian mixture models using labelled samples in
% "processedfilename". Saves results in "modelfilename". The model
% will probably have "kvessel" gaussians representing vessel pixel
% samples and "krest" gaussians representin "non-vessels". "type"
% specifies the type of covariance matrix for the gaussians.
%
% See also: createprocessed, gmmmodel.

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

T = load(processedfilename);

% description = T.description;

samplemean = T.samplemean;

samplestd = T.samplestd;

% "vessels" indicates vessel pixels in featurematrix.
vessels = (T.featurematrix(:, 1) == 1);
%de los píxeles cogidos aleatoriamente en processed, coger las filas que son vasos

% Matrix with vessel samples.
vesselmatrix = T.featurematrix(vessels, 2:end); %coge el valor de las 5 imágenes donde los píxeles son vasos en la GT
% Matrix with non-vessel samples.
restmatrix = T.featurematrix(~vessels, 2:end); %el resto

% Number of vessel and non-vessel samples.
nvessel = size(vesselmatrix, 1); %total de píxeles de vaso cogidos en processed, todos los de cada imagen
%cada imagen = ceil(nvessel * ceil(nsamples / nfiles)/rows))
%nvessel = # de píxeles que son vaso en GT, nsamples= 1000 o 1000000, nfiles=45, rows = # de píxeles que son ojo en 'mask'
%por tanto depende de cada imagen
nrest = size(restmatrix, 1); %total del resto de que son NO vasos
ntotal = nvessel + nrest; %total

% Creating the mixture model for the vessels.
[vesselgaussians, vesselQ] = gmmmodel(vesselmatrix, kvessel, type);

% Creating the mixture model for non-vessels.
[restgaussians, restQ] = gmmmodel(restmatrix, krest, type);

% Priors.
vesselprior = nvessel / ntotal; %proporción de píxeles cogidos de vaso
restprior = nrest / ntotal; %proporción de píxeles cogidos de NO vaso

vesselit = size(vesselQ, 2);
restit = size(restQ, 2);

% Saves some info on parameters.
info = strvcat([' File used for training: ' processedfilename],...
               [' kvessel = ' num2str(kvessel)],...
               [' krest = ' num2str(krest)],...
               [' Iterations for vessels: ' num2str(vesselit)],...
               [' Iterations for rest: ' num2str(restit)],...
               [' Covariance matrix type: ' type]);

% Saves in "modelfilename" in matlab format.
save(modelfilename, 'info', 'vesselprior', ...
     'vesselgaussians', 'vesselQ', 'restprior', 'restgaussians', ...
     'restQ', 'samplemean', 'samplestd', '-MAT');