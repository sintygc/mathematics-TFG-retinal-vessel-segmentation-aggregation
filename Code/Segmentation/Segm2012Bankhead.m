function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2012Bankhead(image)

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
rgbOriginal = double(image)/255; %rgbOriginal: 584x565x3 double u=256 [0,1]
    
%     processor = ARIA_generate_test_processor('DRIVE');
vessel_data = Vessel_Data();
vessel_data.im_orig = rgbOriginal;
vessel_data.im = rgbOriginal(:,:,2); %vessel_data.im: 584x565 double u=229 [0,0.8980]

% If there isn't a mask there already, choose whether to apply one
[args, cancelled] = mask_choose(vessel_data, struct('mask_option', 'create', 'mask_dark_threshold', 0.2), 0);
%vessel_data.bw_mask: 584x565 logical {0,1}        

% Segment the image using the isotropic undecimated wavelet transform
[args, cancelled, elapsedGrey, timerElapsed] = seg_iuwt(vessel_data, struct(), 0, timerElapsed);
greyRes = vessel_data.grey; %vessel_data.grey: 584x565 double u=329879 [-0.1630,0.1981]
bwRes = vessel_data.bw;

elapsedBW = toc(timerElapsed);

end