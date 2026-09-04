function elapsed = saveMethod(imName,imPath,method,pathwrite)
% 
% 
meth = str2func(method);
timerElapsed = tic;
im = meth(imread( [imPath '\' imName] ));
elapsed = toc(timerElapsed);
if contains(imName,'Grey')
    imwrite( scale_01(im) , [pathwrite '\' insertBefore(imName,'Grey',[method '-'])] )
else
    imwrite( scale_01(im) , [pathwrite '\' replace(imName,'Original',method)] )
end