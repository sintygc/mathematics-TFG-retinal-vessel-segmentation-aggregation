function testleaveoneout(config)
% testleaveoneout(config)
%
% Creates html results for leave-one-out tests: training with all
% images except the one being segmented. Uses info in "config" o run
% the tests.
%
% See also: testmixed, testwindow, stareconfig, driveconfig.

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
config.imagetype = 'colored';
config.labelleddir  = [rootdir filesep 'features-labelled' filesep];
config.manualtype = 'segmentation';
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

%stareconfig
% names
ind = [1,2,3,4,5,44,77,81,82,139,162,163,235,236,239,240,255,291,319,324];
for i=1:length(ind)
    names{i}.original = sprintf('im%04d.ppm',ind(i)); 
    names{i}.manual1 = sprintf('im%04d.ah.ppm',ind(i));
    names{i}.manual2 = sprintf('im%04d.vk.ppm',ind(i));
    names{i}.aperture = sprintf('im%04d.ap.ppm',ind(i));
end
config.classifier = 'gmm';
config.imagedir =   [rootdir filesep 'stare_images' filesep];
config.leaveoneout = 1;
config.leaveoneoutnames = names;
config.lineardir     = [rootdir filesep 'linear' filesep];
config.mixed = 0;
config.otherapertures = 0;
config.testname = 'stare_gmm';
config.testnames = {names{6:end}};
config.trainingsamples = 1000000;
config.trainnames = {names{1:5}};
config.windownames = names;



% Should leave-one-out test be done under this configuration?
if (~config.leaveoneout)
  return;
end

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
imagenames = config.leaveoneoutnames;

for i = 1:size(imagenames, 2)
  imfilename = imagenames{i}.original; 
  shortname = imfilename(1:(end-4));
  img = imread(imfilename);
  featurefilename = [config.featuredir shortname '-features.mat'];
  
  disp('Creating features file.');
  switch(config.imagetype)
   case 'angiogram'
    createfeaturesangiogram(img, config.morletscales, ...
                            config.paderosionsize, featurefilename);
   case 'redfree'
    createfeaturesredfree(img, config.morletscales, config.paderosionsize, ...
                          featurefilename);
   case 'colored'
    createfeaturescolored(img, config.morletscales, ...
                          config.paderosionsize, featurefilename);
   otherwise
    disp(['Unknown image type ' config.imagetype]);
    return;
  end
end
  
% Creates all labelled files for all images.
labelledfilenames = [];
for i = 1:size(imagenames, 2)
  imfilename = imagenames{i}.original;
  shortname = imfilename(1:(end-4));
  
  labelledfilename = [config.labelleddir shortname '-labelled.mat'];
  featurefilename = [config.featuredir shortname '-features.mat'];
  manualname = imagenames{i}.manual1;
    
  disp('Creating labelled file');
  switch(config.manualtype)
   case 'segmentation'
    createlabelled(featurefilename, manualname, labelledfilename);
   case 'skeleton'
    createlabelledskeleton(featurefilename, manualname, labelledfilename);
   otherwise
    disp(['Unknown manual image type ' config.manualtype]);
    return;
  end
  
  labelledfilenames = strvcat(labelledfilenames, labelledfilename);
end

% Creating directory for results.
resultdir = config.resultdir;
testname = ['leave_one_out_' config.testname];
ignore = mkdir(resultdir, testname);
resultdir = [resultdir testname filesep];

for j = 1:size(imagenames, 2)
  imagename = imagenames{j};
  
  imfilename = imagename.original;
  shortname = imfilename(1:(end-4));
  
  outputdir = [resultdir shortname filesep];
  ignore = mkdir(resultdir, shortname);

  % Defines the training images by removing the image being tested.
  labelledtrainfilenames = [labelledfilenames(1:j-1, :); ...
                      labelledfilenames(j+1:end, :)];
  
  featurefilename = [config.featuredir shortname '-features.mat'];
  leave_one_out_test(outputdir, imagename, featurefilename, ...
                     labelledtrainfilenames, config);
end

% Creates stats and puts them on a web page.
if (config.createstats)
  createstats(resultdir, imagenames, config);
  createstatspage(resultdir, imagenames);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function leave_one_out_test(outputdir, imagename, featurefilename, ...
                            labelledtrainfilenames, config)
%
% Does the leave one out test for image "imagename", with features
% from "featurefilename" and training with labelled samples in
% "labelledtrainfilenames".

imfilename = imagename.original;

img = imread(imfilename);
shortname = imfilename(1:(end-4));
train = ['all-but-' shortname]

% Creating the processed samples file from the labelled samples files.
trainingsamples = config.trainingsamples;
processedfilename = [config.processeddir train '-processed-' ...
                    num2str(trainingsamples) '.mat'];
disp('Creating processed file');
createprocessed(labelledtrainfilenames, processedfilename, trainingsamples);

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
  
  % Creates the posterior probabilities image by pixel classification.
  [vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
      gmmlikelihoods(featurefilename, modelfilename, config.normalizeflag);
  
  vesselprob = vessellikelihoods * vesselprior;
  restprob = restlikelihoods * restprior;
  
  % Posterior probabilities.
  classgray = (vesselprob) ./ (restprob + vesselprob);
  classgray((vesselprob + restprob) == 0) = 0;
  
  % The segmentation.
  class = classgray > 0.5;
  
  classgray(classgray < 0) = 0;
  classgrayeval = (((classgray - 0.5).^3 / (0.5)^3) + 1) / 2;
  
  classifierfilename = modelfilename;
 case 'lmse'
  disp('Creating linear function.');
  linearfilename = [config.lineardir train '-lmse.mat'];
  lmsecreatelinear(processedfilename, linearfilename);
  [class, classgray] = lmseapply(featurefilename, linearfilename, ...
                                 config.normalizeflag);
  
  classgrayeval = (classgray + 2) / 4;
  classgray = (classgray + 1) / 2;

  classgrayeval(classgrayeval < 0) = 0;
  classgray(classgray < 0) = 0;
    
  classifierfilename = linearfilename;
 case 'knn'
  disp('Classifying with knn.');
  [class, classgray] = knnclassify(featurefilename, processedfilename, ...
                                   config.k, config.normalizeflag);

  classgray(classgray < 0) = 0;
  classgrayeval = (((classgray - 0.5).^3 / (0.5)^3) + 1) / 2;
  
  classifierfilename = [];
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

% Posterior probabilities and transform to be evaluated.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Posterior probabilities image and its transform';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, classgray, [shortname '-class-gray.png'], 4);
htwimage(fp, outputdir, classgrayeval, [shortname '-class-gray-eval.png'], 4);

manskel = imread(imagename.manual1);
manskel = manskel > 128;

% Manual and automatic segmentations.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Manual and automatic segmentations';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, manskel, [shortname '-manual-class.png'], 4);
htwimage(fp, outputdir, class, [shortname '-class.png'], 4);

% Manual and automatic skeletons.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Manual and automatic skeletons';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, bwmorph(manskel, 'skel', Inf),...
              [shortname '-manual-skeleton.png'], 4);
htwimage(fp, outputdir, skel, [shortname '-class-skeleton.png'], 4);

% Skeleton superposed on image.
htwpar(fp); htwhr(fp); htwpar(fp);
httitle='Skeleton of segmentation produced by classifier with image';
htwtext(fp, ['<h2>' httitle '</h2>']);
htwimage(fp, outputdir, final, [shortname '-class-final.jpg'], 4);

htclose(fp);
