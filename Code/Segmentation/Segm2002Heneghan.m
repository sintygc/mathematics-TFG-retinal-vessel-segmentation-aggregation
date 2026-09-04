function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2002Heneghan(image,M)

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
I= double(image); %I: 584x565x3 double u=256 [0,255] 
%nos quedamos con el canal verde
I=I(:,:,2); %I: 584x565 double u=229 [0,229]
%invierte escala de grises
In=255-double(I); %In: 584x565 double u=229 [26,255]

%Construir tambien aquí la mascara (para tapar agujeros utilizar mmclohole)
%crea la máscara (la parte que no es ojo en negro)
mask=I>M; %mask: 584x565 logical {0,1}
% tapa agujeros de la máscara
mask=mmclohole(mask); %mask: 584x565 double {0,1}

%aplica la máscara sobre la imagen invertida
In=double(In).*double(mask); %In: 584x565 double u=179 [0,204]

% 3.3.1. Initial morphological filtering

%Aperturas con elemento estructurante lineal
for i=1:12 % 12 aperturas
    L=strel('line', 17,(i-1)*15); % crea un elemento estructurante
    Iop(:,:,i)=imopen(In,L); % hace la apertura con L
end

%max en la dirección z
Iops=max(Iop,[],3); %Iops: 584x565 double u=158 [0,183]
%Reconstruccion
%inf-reconstruction of In from the marker Iops
Ic=mminfrec(double(Iops),In); %Ic: 584x565 double u=158 [0,183]
%min en la dirección z
Ib=min(Iop,[],3); %Ib: 584x565 double u=142 [0,168]
%max-min
Iv=double(Ic)-double(Ib); %Iv: 584x565 double u=96 [0,165]

% 3.3.2. Second derivative properties of the vasculature

H=fspecial('gaussian',[1 7],1.75); %filtro paso bajo gaussiano: 1x7
H=H/max(H);
G=fspecial('log',[1 7],1.75); %filtro laplaciano-gaussiano: 1x7
G=G/(min(G));
%Convolucion
for i=1:12 % 12 convoluciones
    Hr=imrotate(H,(i-1)*15);
    Gr=imrotate(G,90+((i-1)*15));
    con1=conv2(Iv,Hr,'same');
    res(:,:,i)=conv2(con1,Gr,'same'); % tiene valores + y - muy grandes
end
%max en la dirección z
Idiff=max(res,[],3); %Idiff: 584x565 double u=229597 [0,1.4694e+03]
%se queda los valores positivos (esta imagen no cambia, pero la 1a de STARE sí: min=-1.8481)
Idiff=Idiff.*(Idiff>0); %Idiff: 584x565 double u=229597 [0,1.4694e+03]

% 3.3.3. Final morphological filtering

for i=1:12 % 12 aperturas
    L=strel('line', 17,(i-1)*15); % crea un elemento estructurante
    Ilk(:,:,i)=imopen(Idiff,L); % hace la apertura con L
end
%max en la dirección z
Ilkk=max(Ilk,[],3); %Ilkk: 584x565 double u=142037 [0,845.3461]
%inf-reconstruction of Idiff from the marker Ilkk
Il=mminfrec(Ilkk,Idiff); %Il: 584x565 double u=183080 [0,845.3461]
for i=1:12 % 12 cierres
    L=strel('line', 17,(i-1)*15); % crea un elemento estructurante
    Ifk(:,:,i)=imclose(Il,L); % hace el cierre con L
end
%min en la dirección z
Ifkk=min(Ifk,[],3); %Ifkk: 584x565 double u=95365 [0,845.3461]
%sup-reconstruction of Il from the marker Ifkk
If=mmsuprec(Ifkk,Il); %If: 584x565 double u=118657 [0,845.3461]

%reescala a [0,1]
greyRes=double(If)/double(max(max(If))); %result: 584x565 double u=118555 [0,1]

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;

%Thresholding
If1=greyRes;

low=25;
high=40;

Ilow=im2bw(If1,low/255);
Ihigh=im2bw(If1,high/255);

Im=mminfrec(Ihigh,Ilow);

Iml=bwlabel(Im);
Im_a=mmblob(Iml,'area');
Imfin=Im_a>170;

bwRes=Imfin;

elapsedBW = toc(timerElapsed);

end