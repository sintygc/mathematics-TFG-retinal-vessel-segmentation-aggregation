function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2008SoaresLMSE( path,imnum,samples )

timerElapsed = tic;

featurefilename   = [path '\Features\' sprintf('im%02d',imnum) '-features.mat'];
classifierfilename     = [path '\Models\training-lmse-' num2str(samples) '.mat'];
normalizeflag = 1;

classgray = lmseapply(featurefilename, classifierfilename, normalizeflag);
    
greyRes = classgray;

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
        
% The segmentation.
bwRes = greyRes > 0;

elapsedBW = toc(timerElapsed);

end
