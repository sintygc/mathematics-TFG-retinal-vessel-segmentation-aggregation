function [greyRes, elapsedGrey, bwRes, elapsedBW] = Segm2003Chanwimaluang(image)
% Thitiporn Chanwimaluang
% tchanwim@gmail.com
% Department of Electrical and Computer Engineering
% Oklahoma State University

% This is the main function to perform blood vessel extraction

timerElapsed = tic;
%image: 584x565x3 uint8 u=256 [0,255]
I= double(image); %I: 584x565x3 double u=256  [0,255] 

I = uint8(I); %I: 584x565x3 uint8 u=256 [0,255] 
G(:,:,2) = I(:,:,2); % canal verde de la imagen original
G(:,:,1) = 0;
G(:,:,3) = 0;%imshow(G,[]) %G sale en verde
%canal verde en escala de grises (0.2989*R + 0.5870*G + 0.1140*B)
Y = rgb2gray(G); %Y: 584x565 uint8 u=134 [0,134] 
sa = 2.0;
% imagen en escala de grises, venas en blanco
rt = mim(Y,sa); %result: 584x565 double u=254 [0,255]
greyRes = rt;

elapsedGrey = toc(timerElapsed);
timerElapsed = tic;

%binarization
IG = rgb2gray( uint8(I) );
[M,N] = size(IG);
[tt1,e1,cmtx] = myThreshold(rt);
ms = 45;    
mk = msk(IG,ms);

rt2 = 255*ones(M,N);
for i=1:M
    for j=1:N
        if rt(i,j)>=tt1 & mk(i,j)==255
            rt2(i,j)=0;
        end
    end
end
J = im2bw(rt2); 

J= ~J;
[Label,Num] = bwlabel(J);
Lmtx = zeros(Num+1,1);
for i=1:M
    for j=1:N
        Lmtx(double(Label(i,j))+1) = Lmtx(double(Label(i,j))+1) + 1;
    end
end
sLmtx = sort(Lmtx);
cp = 950;
for i=1:M
    for j=1:N
        if (Lmtx(double(Label(i,j)+1)) > cp) & (Lmtx(double(Label(i,j)+1)) ~= sLmtx(Num+1,1))
            J(i,j) = 0;
        else
            J(i,j) = 1;
        end
    end
end
for i=1:M
    for j=1:N
        if mk(i,j)==0
            J(i,j)=1;
        end
    end
end
J = 1 - J;

bwRes = J;

elapsedBW = toc(timerElapsed);

end