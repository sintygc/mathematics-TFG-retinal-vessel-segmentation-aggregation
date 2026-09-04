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

rootdir = installdir;
config.covariancetype = 'full';
config.createstats = 1;
config.featuredir   = [rootdir filesep 'features' filesep];
config.labelleddir  = [rootdir filesep 'features-labelled' filesep];
config.modeldir     = [rootdir filesep 'models' filesep];
config.morletscales = [2 3 4 5];
config.ngaussians = 20;
config.normalizeflag = 1;
config.paderosionsize = 5;
config.processeddir = [rootdir filesep 'features-processed' filesep];
config.resultdir = [rootdir filesep 'results' filesep];
config.secondmanual = 1;
config.window = 1;
config.windowsize = 0.4;

%driveconfig
% names
for i=1:20
    names{i}.original = sprintf('%02d_test.tif',i);
    names{i}.manual1 = sprintf('%02d_manual1.gif',i);
    names{i}.manual2 = sprintf('%02d_manual2.gif',i);
    names{i}.aperture = sprintf('%02d_test_mask.gif',i);
end
for i=21:40
    names{i}.original = sprintf('%02d_training.tif',i);
    names{i}.manual1 = sprintf('%02d_manual1.gif',i);
    names{i}.aperture = sprintf('%02d_training_mask.gif',i);
end
config.classifier = 'knn';
config.imagedir =   [rootdir filesep 'drive_images' filesep];
config.k = 50;
config.leaveoneout = 0;
config.leaveoneoutnames = {names{1:20}};
config.mixed = 1;
config.otherapertures = 1;
config.testname = 'drive_gmm';
config.testnames = {names{1:20}};
config.trainingsamples = 1000;
config.trainnames = {names{21:40}};
config.windownames = {names{1:20}};



% Should mixed test be done under this configuration?
if (~config.mixed)
  return;
end

tic;

% The stats generation module.
addpath([installdir filesep 'src' filesep 'stats']);
% The gaussian mixture model module.
addpath([installdir filesep 'src' filesep 'gmm']);
% The linear classifier module.
addpath([installdir filesep 'src' filesep 'lmse']);
% The knn classifier module.
addpath([installdir filesep 'src' filesep 'knn']);
% The skeletonization module.
addpath([installdir filesep 'src' filesep 'skel']);
% The feature manipulation module.
addpath([installdir filesep 'src' filesep 'ftrs']);
% The html module.
addpath([installdir filesep 'src' filesep 'html']);

% Directory with images.
addpath(config.imagedir);

% Creates features for all images.
imagenames = {config.trainnames{:} config.testnames{:}};

for ind = 1:size(imagenames, 2)
  imfilename = imagenames{ind}.original; 
  shortname = imfilename(1:(end-4));
  img = imread(imfilename);
  featurefilename = [config.featuredir shortname '-features.mat'];
  
  disp('Creating features file.');
  createfeaturescolored(img, config.morletscales, ...
                          config.paderosionsize, featurefilename);
end
  
% Creates all labelled files for training images.
labelledfilenames = [];
for i = 1:size(config.trainnames, 2)
  imfilename = config.trainnames{i}.original;
  shortname = imfilename(1:(end-4));
  
  labelledfilename = [config.labelleddir shortname '-labelled.mat'];
  featurefilename = [config.featuredir shortname '-features.mat'];
  manualname = config.trainnames{i}.manual1;
    
  disp('Creating labelled file');
  createlabelled(featurefilename, manualname, labelledfilename);
  
  labelledfilenames = strvcat(labelledfilenames, labelledfilename);
end

% Creating name for training (processed) file.
train1 = config.trainnames{1}.original;
shorttrain1 = train1(1:(end-4));
train2 = config.trainnames{end}.original;
shorttrain2 = train2(1:(end-4));
train = [shorttrain1 '-' shorttrain2];

% Creating the processed samples file from the labelled samples files.
trainingsamples = config.trainingsamples;
processedfilename = [config.processeddir train '-processed-' ...
                    num2str(trainingsamples) '.mat'];
disp('Creating processed file');
createprocessed(labelledfilenames, processedfilename, trainingsamples);

% Creates the classifier.
switch(config.classifier)
 case 'gmm'
  % Gaussian model paremeters
  ngaussians = config.ngaussians;
  covariancetype = config.covariancetype;
  modelfilename = [config.modeldir train '-' covariancetype '-' ...
                   num2str(ngaussians) '.mat'];

  % Creating the gaussian mixture model from the processed labelled
  % samples file.
  disp('Creating gaussian mixture models');
  gmmcreatemodel(processedfilename, modelfilename, ngaussians, ...
                 ngaussians, covariancetype);
  
  classifierfilename = modelfilename;
 case 'lmse'
  disp('Creating linear function.');
  linearfilename = [config.lineardir shortname '-lmse.mat'];
  lmsecreatelinear(processedfilename, linearfilename);

  classifierfilename = linearfilename;
 case 'knn'
  % Nothing to do.
  
  classifierfilename = [];
 otherwise
  disp(['Unknown classifier type ' config.classifier]);
  return;
end




toc;
fprintf('End of learning and beginning of new classification.\n');
tic;


% Creating directory for results.
resultdir = config.resultdir;
testname = ['mixed_' config.testname];
ignore = mkdir(resultdir, testname);
resultdir = [resultdir testname filesep];

for j = 1:size(config.testnames, 2)
  imagename = config.testnames{j};
  
  imfilename = config.testnames{j}.original;
  shortname = imfilename(1:(end-4));
  
  outputdir = [resultdir shortname filesep];
  ignore = mkdir(resultdir, shortname);

  featurefilename = [config.featuredir shortname '-features.mat'];
  mixed_test(outputdir, imagename, featurefilename, processedfilename, ...
             classifierfilename, config);
end

% Creates stats and puts them on a web page.
if (config.createstats)
  createstats(resultdir, config.testnames, config);
  createstatspage(resultdir, config.testnames);
end


toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mixed_test(outputdir, imagename, featurefilename, ...
                    processedfilename, classifierfilename, config)
% Performs the test for the image specified in "imagename" using the
% classifier "classifierfilename". A web page is produced with the
% results in "outputdir".

imfilename = imagename.original;

img = imread(imfilename);
shortname = imfilename(1:(end-4));

switch(config.classifier)
 case 'gmm'
  % Creates the posterior probabilities image by pixel classification.

  [vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
      gmmlikelihoods(featurefilename, classifierfilename, ...
                     config.normalizeflag);
  
  vesselprob = vessellikelihoods * vesselprior;
  restprob = restlikelihoods * restprior;
  
  % Posterior probabilities.
  classgray = (vesselprob) ./ (restprob + vesselprob);
  classgray((vesselprob + restprob) == 0) = 0;
  
  % The segmentation.
  class = classgray > 0.5;
  
  classgray(classgray < 0) = 0;
  classgrayeval = (((classgray - 0.5).^3 / (0.5)^3) + 1) / 2;
 case 'lmse'
  [class, classgray] = lmseapply(featurefilename, classifierfilename, ...
                                 config.normalizeflag);
  
  classgrayeval = (classgray + 2) / 4;
  classgray = (classgray + 1) / 2;

  classgrayeval(classgrayeval < 0) = 0;
  classgray(classgray < 0) = 0;
 case 'knn'
  disp('Classifying with knn.');
  [class, classgray] = knnclassify(featurefilename, processedfilename, ...
                                   config.k, config.normalizeflag);
 
  classgray(classgray < 0) = 0;
  classgrayeval = (((classgray - 0.5).^3 / (0.5)^3) + 1) / 2;
 otherwise
  disp(['Unknown classifier type ' config.classifier]);
  return;
end

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

  if (strcmp(config.classifier, 'gmm'))
    handle = figure('visible', 'off');
    
    htwtext(fp, '<h4>Log-likelihood of vessel samples during EM</h4>');
    htwtext(fp, '<img src="vesselq.jpg" width = 25%>'); 
    plot(C.vesselQ);
    print(handle, '-djpeg', [outputdir filesep 'vesselq.jpg']);

    htwtext(fp, '<h4>Log-likelihood of rest samples during EM</h4>');
    htwtext(fp, '<img src="restq.jpg" width = 25%>'); 
    plot(C.restQ);
    print(handle, '-djpeg', [outputdir filesep 'restq.jpg']);
  end
    
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


