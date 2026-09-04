function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm1989Chaudhuri(image)


timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
image = double(image); %image: 584x565x3 double u=256 [0,255]

I = uint8(image); %I: 584x565x3 uint8 u=256 [0,255]
% nos quedamos con el canal verde:
I = I(:,:,2); %I: 584x565 uint8 u=229 [0,229], pero es sobre [0,255]
% nos quedamos con los valores que son >= a 50
I = double(I).*double(I>=50); %I: 584x565 double u=180 [0,229], pero es sobre [0,255]
% escalamos imagen, pasamos de [0,255] a [0,1]
I = double(I)/255; %I: 584x565 double u=180  [0,0.8980], pero es sobre [0,1]

%Preproceso consistente en la aplicación de un filtro media 5x5
H = fspecial('average',5); % devuelve un filtro promediador h (=0.0400) de tamaño 5 (matriz 5x5)
Ifil = filter2(H,I); % applies a finite impulse response filter to I according to coefficients in a matrix H.
%Ifil: 584x565 double u=9280 [0,0.8524]. ¿Es sobre [0,1]? Quizás sí, pero no importa. Al final se escala dividiendo por el máximo.

%Calculamos la convolución con la máscara definida por Chaudhuri de la imagen preprocesada
sig = 2;
L = 9;
serie = -3*sig:1:3*sig; %= -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 double 1x13
mask = repmat(-exp(-(serie.^2)./(2*(sig^2))),L,1); %mask: 9x13 double u=7 [-1,-0.0111], cada columna con un valor, cada fila simétrica e igual
maskm = mean(reshape(mask,size(mask,1)*size(mask,2),1)); %= -0.3852
mask = mask-maskm; %mask: 9x13 double u=7 [-0.6148,0.3741]
%orlamos la máscara con ceros
mask = [zeros(size(mask,1),4),mask,zeros(size(mask,1),4)]; % añade 4 zeros a izquierda y derecha de mask: 9x21 double u=8 [-0.6148,0.3741]
mask = [zeros(6,size(mask,2));mask;zeros(6,size(mask,2))]; % añade 6 zeros arriba y abajo de mask: 21x21 double u=8 [-0.6148,0.3741]

for i=1:12
    Iconv(:,:,i) = filter2(imrotate(mask,15*i,'crop'),Ifil);
end %Iconv: 584x565x12 double u=2871739 [-4.2044,3.7031]

res = max(Iconv,[],3); %res: 584x565 double u=240657 [-0.7436,3.7031]
%desplazamos el mínimo a 0 y escalamos dividiendo por el máximo
greyRes = (res-min(min(res)))/(max(max(res))-min(min(res))); %result: 584x565 double u=240165 [0,1]

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;
        
T = graythresh(greyRes); %=0.4196
bwRes = imbinarize(greyRes,T); %bwRes: 584x565 logical u=2 {0,1}

elapsedBW = toc(timerElapsed);

end