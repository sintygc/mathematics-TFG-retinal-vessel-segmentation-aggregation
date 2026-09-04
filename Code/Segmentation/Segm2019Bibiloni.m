function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2019Bibiloni( image )
% function [ finalEstimation ] = SegmentationMethod2019Bibiloni( originalRGBImage, databaseName, mask )
%SEGMENTATIONMETHOD. Main Segmentation method to extract vessels from
%retinal eye-fundus images.
%
%   Usage:
%  [ finalEstimation ] = SegmentationMethod( originalRGBImage ) -
%       Using a RGB image, it generates the segmentation according to the
%       step-by-step procedure shown in the source code.
%  [ finalEstimation ] = SegmentationMethod( originalRGBImage, databaseName) -
%       It also specifies the parameters that will be used by specifying
%       which database the sample belongs to (STARE or DRIVE). By dafault,
%       the parameters of the DRIVE database are used.
%  [ finalEstimation ] = SegmentationMethod( originalRGBImage, databaseName, mask ) -
%       It also specifies the mask of the image, which will be used instead
%       of the estimated mask.
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


% Add auxiliar matlab functions to Matlab Path.
% newFolderInPath = [ fileparts(mfilename('fullpath')), filesep, 'src', filesep ];
% addpath( newFolderInPath );


% By default, the parameters used for the DRIVE databases will be selected.


 %%%%%%%%%%%%%%%%%%%%%%%
 % PARAMETER SELECTION %
 %%%%%%%%%%%%%%%%%%%%%%%

topHatStructuringElement = CreateStructuringElement( 'flat', 7);
topHatTNorm = @(x, y) MayorTorrensTNorm(x, y, 0.7);
topHatRImpl = @(x, y) RImplicationOfMayorTorrens(x, y, 0.7);
dilationStructuringElement = CreateStructuringElement('gaussian', 3);
dilationTNorm = @ProductTNorm;    % Element-wise product
equalizationFactor =  0.6126;

% topHatStructuringElement = CreateStructuringElement( 'flat', 5);
% topHatTNorm = @(x, y) MayorTorrensTNorm(x, y, 0.7);
% topHatRImpl = @(x, y) RImplicationOfMayorTorrens(x, y, 0.7);
% dilationStructuringElement = CreateStructuringElement('flat', 3);
% dilationTNorm = @ProductTNorm;    % Element-wise product


 %%%%%%%%%%
 % METHOD %
 %%%%%%%%%%
%image: 584x565x3 uint8 u=256 [0,255]

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
image=double(image);
%   STEP: Selection of Green Channel.
%       The green channel is selected, and the image is normalized to the
%       interval [0, 1] for further processing.
greenChannel = double(image(:,:,2))/255.0; %greenChannel: 584x565 double u=229 [0,0.8980]


%   STEP: Equalization to improve contrast.
%       A monotonic transformations from [0,1] to [0,1] is applied.
equalizationStep = greenChannel.^equalizationFactor; %equalizationStep: 584x565 double u=229 [0,0.9362]


%   STEP: Top Hat by Closing.
%       The filtered image is processed with a top hat by closing to
%       extract black and thin objects.
topHatOpeningStep = FuzzyTopHatByClosing( ...
    equalizationStep, ...
    topHatStructuringElement, ...
    topHatTNorm, ...
    topHatRImpl ); %topHatOpneingStep: 584x565 double u=2855 [0,0.3459]

%   STEP: Mask estimation and removal.
%       The mask is estimated from the RGB image if it is not supplied.
%       Afterwards, it is slightly reduced with an erosion operation so it
%       includes its border. All false positives found in this region are
%       removed.
mask = EstimateMaskEyeFundus( image ); %mask: 584x565 double u=2 {0,1}
normalizedMask = zeros(size(mask));
normalizedMask(mask == max(mask(:))) = 1;
maskImplication = @RImplicationOfProductTNorm;
erodedMask = FuzzyErosion(...
    normalizedMask, ...
    CreateStructuringElement('gaussian', 10), ...
    maskImplication); %erodedMask: 584x565 double u=1 {1}
borderRemovingStep = topHatOpeningStep .* erodedMask; %== topHatOpeningStep


%   STEP: Filtering to remove isolated points.
%       Each point will be assigned the minimum between its original value
%       and the value of the highest neighbour pixel.
filterStructuringElement = CreateStructuringElement('flat', 3);
filterStructuringElement( ceil( size(filterStructuringElement)/2 ) ) = 0;
filteringConjunction = @ProductTNorm;   % Element-wise product
filteringStep1 = FuzzyDilation( ...
    borderRemovingStep, ...
    filterStructuringElement, ...
    filteringConjunction );
filteringStep2 = min(borderRemovingStep, filteringStep1); %filteringStep2: 584x565 double u=2855 [0,0.3459]


%   STEP: Normalization into the interval [0, 1].
%       Stretch the values of the image so that all values are within the
%       selected range.
if max( filteringStep2(:) ) == min( filteringStep2(:) )
    % All values are the same, so a zero value is assigned to all of them.
    normalizationStep = zeros( size(filteringStep2) );
else
    normalizationStep = filteringStep2 - min( filteringStep2(:) );
    normalizationStep = normalizationStep / max( normalizationStep(:) );
end %normalizationStep: 584x565 double u=2855 [0,1]


%   STEP: Dilation.
%       A dilation is applied to compensate the shrinking effect of the top
%       hat transformation.
dilationStep = FuzzyDilation( ...
    normalizationStep, ...
    dilationStructuringElement, ...
    dilationTNorm ); %dilationStep: 584x565 double u=5951 [0,1]

greyRes = dilationStep;

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
    
hystersisLowerBound = 0.12;
hystersisUpperBound = 0.24;

%   STEP: Hysteresis to binarize the image.
%       Finally, the image is binarized (so each pixel will be either
%       positive or negative) with a hysteresis operation. This operation
%       returns all connected components above or equal to a lower bound, 
%       which have at least one pixel above or equal to upper bound.
thresholdingStep = Hysteresis( greyRes, hystersisLowerBound, hystersisUpperBound );

bwRes = thresholdingStep;

elapsedBW = toc(timerElapsed);

end


 %%%%%%%%%%%%%%%%%%%%%%
 % AUXILIAR FUNCTIONS %
 %%%%%%%%%%%%%%%%%%%%%%


function [ r ] = ProductTNorm( x, y )
r = x.*y;
end

function r = RImplicationOfProductTNorm(x, y)
r = y./x;
r(x <= y) = 1;
end


function [ r ] = MayorTorrensTNorm( x, y, lambda )
rAux = min(x, y);
r = max(x + y - lambda, 0);
r(x > lambda) = rAux(x > lambda);
r(y > lambda) = rAux(y > lambda);
end

function r = RImplicationOfMayorTorrens(x, y, lambda)
r = ones( size(x) );
idLargerX = (x >= lambda) & (y < x);
idSmallerX = (x < lambda) & (y < x);

r(idLargerX) = y(idLargerX);
r(idSmallerX) = lambda - x(idSmallerX) + y(idSmallerX);
end

