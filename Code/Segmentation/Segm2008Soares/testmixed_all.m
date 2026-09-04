function testmixed_all(mainPath,train_idx)

% create features for all images
morletscales = [2 3 4 5];
paderosionsize = 5;
for i=1:60
    imfilename = [mainPath '\Images\Original\im' sprintf('%02d',i) '_Original.png'];
    img = imread(imfilename);
    shortname = sprintf('im%02d',i);
    featurefilename = [mainPath '\Code\Segmentation\Segm2008Soares\Features\' shortname '-features.mat'];
    createfeaturescolored(img,morletscales,paderosionsize,featurefilename)
end

% create labelled files for all training images
labelledfilenames = [];
for i=train_idx
%     imfilename = [mainPath '\Images\Original\im' sprintf('%02d',i) '_Original.png'];
    shortname = sprintf('im%02d',i);
    labelledfilename = [mainPath '\Code\Segmentation\Segm2008Soares\Features-labelled\' shortname '-labelled.mat'];
    featurefilename = [mainPath '\Code\Segmentation\Segm2008Soares\Features\' shortname '-features.mat'];
    manualname = [mainPath '\Images\GroundTruth\im' sprintf('%02d',i) '_GroundTruth.png'];
    createlabelled(featurefilename,manualname,labelledfilename);
    labelledfilenames = strvcat(labelledfilenames, labelledfilename);
end

% create name for processed file
for trainingsamples=[1000 1000000]

    processedfilename = [mainPath '\Code\Segmentation\Segm2008Soares\Features-processed\training-processed-' num2str(trainingsamples) '.mat'];
    timerElapsed = tic;
    createprocessed(labelledfilenames,processedfilename,trainingsamples);
    elapsed = toc(timerElapsed) % 7.4966 , 11.2406

    % create classifiers (model)
    
    % gmm
    ngaussians = 20;
    covariancetype = 'full';
    modelfilename = [mainPath '\Code\Segmentation\Segm2008Soares\Models\training-full-20-' num2str(trainingsamples) '.mat'];
    timerElapsed = tic;
    gmmcreatemodel(processedfilename, modelfilename, ngaussians, ngaussians, covariancetype);
    elapsed = toc(timerElapsed) % 3.3033 , 2.4524e+03

    % knn: nothing to do
    
    % lmse
    linearfilename = [mainPath '\Code\Segmentation\Segm2008Soares\Models\training-lmse-' num2str(trainingsamples) '.mat'];
    timerElapsed = tic;
    lmsecreatelinear(processedfilename, linearfilename);
    elapsed = toc(timerElapsed) % 0.0324 , 1.0173

end



