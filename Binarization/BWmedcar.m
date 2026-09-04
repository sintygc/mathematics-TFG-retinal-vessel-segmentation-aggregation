function [result,umbrals] = BWmedcar(image,a,b)

%image: 584x565 uint8 u=256 [0,255]
% gM = uint8(255*gM);
[~, or] = phasecong(double(image) / 255);
NMS = nonmaxsup(double(image) / 255, or , 1.5); %binaria en {0,1}
NMS255 = uint8(255 * NMS); %binaria en {0,255}
[result,umbrals] = histmedcar(NMS255, a, b, 5);

end