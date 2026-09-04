function config = drivestareconfig()

%both
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


%DRIVE-test
%names
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
config.classifier = 'gmm';
config.classifier = 'knn';
config.imagedir =   [rootdir filesep 'drive_images' filesep];
config.k = 50;
config.leaveoneout = 0;
config.leaveoneoutnames = {names{1:20}};
config.mixed = 1;
config.otherapertures = 1;
config.testname = 'drive_gmm';
config.testnames = {names{1:20}};
config.trainingsamples = 1000000;
config.trainingsamples = 1000;
config.trainnames = {names{21:40}};
config.windownames = {names{1:20}};


%STARE
%names
ind = [1,2,3,4,5,44,77,81,82,139,162,163,235,236,239,240,255,291,319,324];
for i=1:length(ind)
    names{i}.original = sprintf('im%04d.ppm',ind(i)); 
    names{i}.manual1 = sprintf('im%04d.ah.ppm',ind(i));
    names{i}.manual2 = sprintf('im%04d.vk.ppm',ind(i));
    names{i}.aperture = sprintf('im%04d.ap.ppm',ind(i));
end
config.classifier = 'lmse';
config.classifier = 'gmm';
config.imagedir =   [rootdir filesep 'stare_images' filesep];
config.leaveoneout = 1;
config.leaveoneoutnames = names;
config.lineardir     = [rootdir filesep 'linear' filesep];
config.mixed = 0;
config.otherapertures = 0;
config.testname = 'stare_lmse';
config.testname = 'stare_gmm';
config.testnames = {names{6:end}};
config.trainingsamples = 1000000;
config.trainnames = {names{1:5}};
config.windownames = names;


end







