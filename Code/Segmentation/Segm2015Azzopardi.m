function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2015Azzopardi( image, thresh )
%AngiographyComparison2015AzzopardiDrive Returns the segmentation of the DRIVE
%images obtained with the 2015Azzopardi method. (with respect to GT1).
%

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
image = double(image); %image: 584x565x3 double u=256 [0,255]

% Create Segmentations:
%   Symmetric filter params
symmfilter = struct();
symmfilter.sigma     = 2.4;
symmfilter.len       = 8;
symmfilter.sigma0    = 3;
symmfilter.alpha     = 0.7;
%   Asymmetric filter params
asymmfilter = struct();
asymmfilter.sigma     = 1.8;
asymmfilter.len       = 22;
asymmfilter.sigma0    = 2;
asymmfilter.alpha     = 0.1;
%   DRIVE -> preprocessthresh = 0.5, thresh = 37
%   STARE -> preprocessthresh = 0.5, thresh = 40
%   CHASE_DB1 -> preprocessthresh = 0.1, thresh = 38
greyRes = BCOSFIRE(image/255, symmfilter, asymmfilter, 0.5);
%result: 584x565 double u=220266 [0,255]

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
        
bwRes = (greyRes > thresh); %bwRes: 584x565 logical u=2 {0,1}

elapsedBW = toc(timerElapsed);

end