function [maskRes, elapsedMask] = Mask2002Heneghan(image)

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
I= double(image); %I: 584x565x3 double u=256 [0,255] 
%nos quedamos con el canal verde
I=I(:,:,2); %I: 584x565 double u=229 [0,229]
%invierte escala de grises
In=255-double(I); %In: 584x565 double u=229 [26,255]

%Construir tambien aquí la mascara (para tapar agujeros utilizar mmclohole)
%crea la máscara (la parte que no es ojo en negro)
mask=I>44; %mask: 584x565 logical {0,1}
% tapa agujeros de la máscara
maskRes=mmclohole(mask); %mask: 584x565 double {0,1}

elapsedMask = toc(timerElapsed);

end