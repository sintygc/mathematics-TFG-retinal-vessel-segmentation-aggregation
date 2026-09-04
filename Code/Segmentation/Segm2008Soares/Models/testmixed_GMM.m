function testmixed()
% testmixed(config)
%
% Creates results training with a set of images and segmenting a
% different set. All the configuration parameters and image names
% should be informed in "config".
%
% See also: testleaveoneout, testwindow, stareconfig, driveconfig.

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

installdir = 'C:\Users\sinty\OneDrive - Universitat de les Illes Balears\TFG_Sinty_Garau\Code\Angiography\AngiographyFunctions\2006Soares';
rootdir = installdir;
covariancetype = 'full';
% config.createstats = 1;
featuredir   = [rootdir filesep 'features' filesep];
labelleddir  = [rootdir filesep 'features-labelled' filesep];
modeldir     = [rootdir filesep 'models' filesep];
morletscales = [2 3 4 5];
ngaussians = 20;
normalizeflag = 1;
paderosionsize = 5;
processeddir = [rootdir filesep 'features-processed' filesep];
resultdir = [rootdir filesep 'results' filesep];

%driveconfig
% names
for i=1:20
    names{i}.original = sprintf('%02d_test.tif',i); %original
    names{i}.manual1 = sprintf('%02d_manual1.gif',i); %GT1
    names{i}.manual2 = sprintf('%02d_manual2.gif',i); %GT2
    names{i}.aperture = sprintf('%02d_test_mask.gif',i); %mask
end
for i=21:40
    names{i}.original = sprintf('%02d_training.tif',i);
    names{i}.manual1 = sprintf('%02d_manual1.gif',i);
    names{i}.aperture = sprintf('%02d_training_mask.gif',i);
end
% imagedir =   [rootdir filesep 'drive_images' filesep];
testname = 'mixed_drive_gmm';
testnames = {names{1:20}};
trainingsamples = 1000000;
trainnames = {names{21:40}};





% % The stats generation module.
% addpath([installdir filesep 'src' filesep 'stats']);
% % The gaussian mixture model module.
% addpath([installdir filesep 'src' filesep 'gmm']);
% % The linear classifier module.
% addpath([installdir filesep 'src' filesep 'lmse']);
% % The knn classifier module.
% addpath([installdir filesep 'src' filesep 'knn']);
% % The skeletonization module.
% addpath([installdir filesep 'src' filesep 'skel']);
% % The feature manipulation module.
% addpath([installdir filesep 'src' filesep 'ftrs']);
% % The html module.
% addpath([installdir filesep 'src' filesep 'html']);
% 
% % Directory with images.
% addpath(imagedir);

% Creates features for all images.
imagenames = {trainnames{:} testnames{:}}; %size(imagenames, 2) = 40
%names of all the images: 
%.original, .manual1, .aperture for trains (21-40 -> 1-20)
%.original, .manual1, .manual2, .aperture for tests (1-20 -> 21-40)

for ind = 1:size(imagenames, 2) %for every original image in drive 1-40
  imfilename = imagenames{ind}.original; %original's name with extension
  shortname = imfilename(1:(end-4)); %original's name without extension
  img = imread(imfilename); %read original image
  featurefilename = [featuredir shortname '-features.mat']; %set features' .mat name
  
  %creates features [mask,description,features] and saves them in ...\features
  disp('Creating features file.');
  createfeaturescolored(img, morletscales,paderosionsize, featurefilename);
  %featurefilename is the outputfilename
end

% 'description' is the same for every image:
% 'Inverted green channel'
% 'Morlet a = 2, k0y = 3, eps = 4'
% 'Morlet a = 3, k0y = 3, eps = 4'
% 'Morlet a = 4, k0y = 3, eps = 4'
% 'Morlet a = 5, k0y = 3, eps = 4'
  
% Creates all labelled files for training images.
labelledfilenames = []; %list of features-labelled .mat's names
for i = 1:size(trainnames, 2) %for every original image in drive train 21-40
  imfilename = trainnames{i}.original; %original's name with extension
  shortname = imfilename(1:(end-4)); %original's name without extension
  labelledfilename = [labelleddir shortname '-labelled.mat']; %set features-labelled's name
  featurefilename = [featuredir shortname '-features.mat']; %set features' name
  manualname = trainnames{i}.manual1; %GT1's name with extension
    
  %creates features [mask,description,featurematrix] and saves them in \features-labelled
  disp('Creating labelled file');
  createlabelled(featurefilename, manualname, labelledfilename);
  %uses load(featurefilename)
  %labelledfilename is the outputfilename
  
  labelledfilenames = strvcat(labelledfilenames, labelledfilename);
end

% Creating name for training (processed) file.
train1 = trainnames{1}.original; %first train original's name with extension
shorttrain1 = train1(1:(end-4)); %first train original's name without extension
train2 = trainnames{end}.original; %last train original's name with extension
shorttrain2 = train2(1:(end-4)); %last train original's name without extension
train = [shorttrain1 '-' shorttrain2]; %"21_training-40_training"

% Creating the processed samples file from the labelled samples files.
processedfilename = [processeddir train '-processed-' num2str(trainingsamples) '.mat'];
%features-processed's name: "21_training-40_training-processed-1000000.mat"
%creates features [featurematrix,description,samplemean,samplestd] and saves them in \features-processed
disp('Creating processed file');
createprocessed(labelledfilenames, processedfilename, trainingsamples);
%uses load(labelledfilenames)
%processedfilename is the outputfilename


% Creates the classifier.
% Gaussian model paremeters
modelfilename = [modeldir train '-' covariancetype '-' ...
                 num2str(ngaussians) '.mat'];
% "...\models\21_training-40_training-full-20.mat"

% Creating the gaussian mixture model from the processed labelled
% samples file.

%creates features [featurematrix,description,samplemean,samplestd] 
%and saves them in \models
disp('Creating gaussian mixture models');
gmmcreatemodel(processedfilename, modelfilename, ngaussians, ...
               ngaussians, covariancetype);
%uses load(processedfilename)
%modelfilename is the outputfilename
  

classifierfilename = modelfilename;





fprintf('End of learning and beginning of new classification.\n');


% Creating directory for results.
ignore = mkdir(resultdir, testname);
resultdir = [resultdir testname filesep];

for j = 1:size(testnames, 2)
  imagename = testnames{j};
  
  imfilename = testnames{j}.original;
  shortname = imfilename(1:(end-4));
  
  outputdir = [resultdir shortname filesep];
  ignore = mkdir(resultdir, shortname);

  featurefilename = [featuredir shortname '-features.mat'];
  mixed_test(outputdir, imagename, featurefilename, processedfilename, ...
             classifierfilename, driveconfig);
end

% % Creates stats and puts them on a web page.
% if (config.createstats)
%   createstats(resultdir, testnames, driveconfig);
%   createstatspage(resultdir, testnames);
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mixed_test(outputdir, imagename, featurefilename, ...
                    processedfilename, classifierfilename, driveconfig)
% Performs the test for the image specified in "imagename" using the
% classifier "classifierfilename". A web page is produced with the
% results in "outputdir".

imfilename = imagename.original;

img = imread(imfilename);
shortname = imfilename(1:(end-4));

% Creates the posterior probabilities image by pixel classification.

[vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
    gmmlikelihoods(featurefilename, classifierfilename, ...
                   normalizeflag);
  
vesselprob = vessellikelihoods * vesselprior;
restprob = restlikelihoods * restprior;
  
% Posterior probabilities.
classgray = (vesselprob) ./ (restprob + vesselprob);
classgray((vesselprob + restprob) == 0) = 0;
  
% The segmentation.
class = classgray > 0.5;
  
classgray(classgray < 0) = 0;
classgrayeval = (((classgray - 0.5).^3 / (0.5)^3) + 1) / 2;


% Extracts the skeleton from the segmentation.
[skel, final] = skeleton(class, 0, img);

% Creates the page and images.
fp = htopen([outputdir 'index.html'], ['Retina Image Processing ' ...
                    'for ' imfilename]);
htwtext(fp,['<h2> Retina Image Processing for ' imfilename '</h2>']); 

if (~isempty(classifierfilename))
  C = load(classifierfilename);
  
  % Info on classifier.
  htwtext(fp, 'About the classifier used: ');
  htwtext(fp, transpose(C.info));
  htwtext(fp, '<br>Features used:<br>');
  htwtext(fp, transpose(C.description));

    handle = figure('visible', 'off');
    
    htwtext(fp, '<h4>Log-likelihood of vessel samples during EM</h4>');
    htwtext(fp, '<img src="vesselq.jpg" width = 25%>'); 
    plot(C.vesselQ);
    print(handle, '-djpeg', [outputdir filesep 'vesselq.jpg']);

    htwtext(fp, '<h4>Log-likelihood of rest samples during EM</h4>');
    htwtext(fp, '<img src="restq.jpg" width = 25%>'); 
    plot(C.restQ);
    print(handle, '-djpeg', [outputdir filesep 'restq.jpg']);
    
  clear C;
end

% Original image.
htwpar(fp);htwhr(fp); htwpar(fp);
httitle='Original image';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, img, [shortname '.jpg'], 4);

% Posterior probabilities and transform to be evaluated by ROC.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Posterior probabilities image and its transform';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, classgray, [shortname '-class-gray.png'], 4);
htwimage(fp, outputdir, classgrayeval, [shortname '-class-gray-eval.png'], 4);

% Automatic segmentation.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Automatic segmentation';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, class, [shortname '-class.png'], 4);

if (isfield(imagename, 'manual1'))
  manskel = imread(imagename.manual1);
  manskel = manskel > 128;
  
  % Manual segmentation.
  htwpar(fp); htwhr(fp); htwpar(fp);
  httitle='Manual segmentation';
  htwtext(fp, ['<h2>' httitle '</h2>']);
  htwimage(fp, outputdir, manskel, [shortname '-manual-class.png'], 4);
end

% Automatic skeleton.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Automatic skeleton';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, skel, [shortname '-class-skeleton.png'], 4);

if (isfield(imagename, 'manual1'))
  % Manual skeleton.
  htwpar(fp); htwhr(fp); htwpar(fp);
  httitle='Manual skeleton';
  htwtext(fp, ['<h2>' httitle '</h2>']);
  htwimage(fp, outputdir, bwmorph(manskel, 'skel', Inf),...
                [shortname '-manual-skeleton.png'], 4);
end

% Skeleton superposed on image.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Skeleton of segmentation produced by classifier with image';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, final, [shortname '-class-final.jpg'], 4);

htclose(fp);


