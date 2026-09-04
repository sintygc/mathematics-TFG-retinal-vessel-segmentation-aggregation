function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2008SoaresKNN( path,imnum,samples )

timerElapsed = tic;

featurefilename   = [path '\Features\' sprintf('im%02d',imnum) '-features.mat'];
processedfilename     = [path '\Features-processed\training-processed-' num2str(samples) '.mat'];
normalizeflag = 1;
k=50;

classgray = knnclassify(featurefilename, processedfilename, k, normalizeflag);

greyRes = classgray;

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
        
% The segmentation.
bwRes = greyRes > 0.5;

elapsedBW = toc(timerElapsed);

end
