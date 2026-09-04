function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2005Zapater(image,th,T)
%Este algoritmo sólo funciona con imágenes en que los vasos están representados
%con niveles bajos de gris (son negros)

%Creamos las aperturas de la imagen original mediante elementos estructurantes
%lineales de longitud 15 pixels centrados en el origen y con 15º de rotación de
%cada uno respecto al anterior

%En este caso deberíamos utilizar como tamaño del elemento estructurante el diámetro

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
% image = double(image);
I= rgb2gray(image); %I: 584x565 double u=224 [0,223] 
% invierte valores 
In=255-double(I); %In: 584x565 double u=224 [32,255]

for k=1:21
    t=k+4;
    Imax=[];
    Ino=[];
    Sop=[];
    ss=[];
    Ssum=[];
    Slapo1=[];
    S1=[];
    S1c=[];
    Imin=[];
    S2=[];
    Sr1=[];
    Sres1=[];
    
    %fila central de 1's
    L1=[zeros(floor(t/2),t);ones(1,t);zeros(floor(t/2),t)]; %L1: 5x5 double {0,1} ...
    for i=1:12
        L2=imrotate(L1,15*i,'crop'); %L2: ... 5x5 double {0,1}
        L=mmimg2se(L2); %L: ... 1x5 double {1}
        Ino(:,:,i)=mmopen(In,L); %Ino: ... 584x565x12 double u=224 [32,255]
    end %...
    %Tomamos el máximo de dichas aperturas
    Imax=max(Ino,[],3); %Imax: 584x565 double u=224 [32,255] ...

    %Realizamos una reconstrucción (o una apertura) geodésica del máximo
    %OJO: en el libro pone que el marcador es In: Sop=mminfrec(In,Imax);
    %y aquí hemos puesto a Imax: Imax=marker image e In=conditioning image
    Sop=mminfrec(Imax,In); %Sop: 584x565 double u=224 [32,255] ...
    
    %Suma de top-hats (reduce el ruido blanco y mejora el contraste de todas las partes lineales)
    for i=1:12
        ss(:,:,i)=double(Sop)-double(Ino(:,:,i));
    end %ss: 584x565x12 double u=46 [0,54]
    Ssum=sum(ss,3); %Ssum: 584x565 double u=237 [0,279] ...
    
    %LAPLACIANO DEL GAUSSIANO
    flap=fspecial('log',7,7/4);
    lap=filter2(flap,Ssum);

    %Alternating filter

    %Cálculo de las aperturas de la imagen obtenida con el Laplaciano
    for i=1:12
        L2=imrotate(L1,15*i,'crop');
        L=mmimg2se(L2);
        Slapo1(:,:,i)=mmopen(lap,L);
    end
    %Cálculo del máximo de las aperturas
    Imax=max(Slapo1,[],3);

    %Reconstrucción (o apertura geodésica del máximo)
    S1=mminfrec(Imax,lap);
   
    %Cálculo del cierre de la imagen resultado de la apertura geodésica mediante
    %los doce elementos estructurantes lineales
    for i=1:12
        L2=imrotate(L1,15*i,'crop');
        L=mmimg2se(L2);
        S1c(:,:,i)=mmclose(S1,L);
    end
    %Mínimo de los cierres
    Imin=min(S1c,[],3);
    
    %Cierre geodésico del mínimo
    S2=mmsuprec(S1,Imin);
    
    %Doble apertura en la imagen resultante del cierre
    %L1=[zeros(t,2*t);ones(1,2*t);zeros(t,2*t)];
    for i=1:12
        L2=imrotate(L1,15*i,'crop');
        L=mmimg2se(L2);
        Sr1(:,:,i)=mmopen(mmopen(S2,L),L);
    end
    %Máximo de las aperturas
    Sres1=max(Sr1,[],3);
    gR = 1-(Sres1-min(min(Sres1)))/(max(max(Sres1))-min(min(Sres1)));
    
    ima(:,:,k)=gR>=table2array(th(k,'th'));
    %   ima(:,:,k)=(double(Sres1)-double(min(min(Sres1))))/(double(max(max(Sres1)))-double(min(min(Sres1))));
    %Suma de las imágenes obtenidas con cada uno de los elementos estructurantes utilizados
end

resultado=sum(ima,3); %resultado: 584x565 double u=5729 [0,8318]
greyRes = resultado/max(max(resultado)); %result: 584x565 double u=5729 [0,1]

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;

bwRes = greyRes>=T;

elapsedBW = toc(timerElapsed);

end