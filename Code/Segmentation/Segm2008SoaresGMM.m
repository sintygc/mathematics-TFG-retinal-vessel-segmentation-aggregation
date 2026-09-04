function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2008SoaresGMM( path,imnum,samples )

timerElapsed = tic;

featurefilename   = [path '\Features\' sprintf('im%02d',imnum) '-features.mat'];
classifierfilename     = [path '\Models\training-full-20-' num2str(samples) '.mat'];
normalizeflag = 1;

[vessellikelihoods, restlikelihoods, vesselprior, restprior] = ...
    gmmlikelihoods(featurefilename, classifierfilename, normalizeflag);

vesselprob = vessellikelihoods * vesselprior;
restprob = restlikelihoods * restprior;

% Posterior probabilities.
classgray = (vesselprob) ./ (restprob + vesselprob);
classgray((vesselprob + restprob) == 0) = 0;

greyRes = classgray;

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
        
% The segmentation.
bwRes = greyRes > 0.5;

elapsedBW = toc(timerElapsed);

end
