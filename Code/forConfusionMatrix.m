function [TP,TN,FP,FN] = forConfusionMatrix(A,B)
% A is the trusted matrix
% B is the result matrix
TP=0;
TN=0;
FP=0;
FN=0;
[m,n] = size(A);
for i=1:m
    for j=1:n
        if((A(i,j)==1)&&(B(i,j)==1))
            TP=TP+1;
        elseif((A(i,j)==0)&&(B(i,j)==0))
            TN=TN+1;
        elseif((A(i,j)==0)&&(B(i,j)==1))
            FP=FP+1;
        else
            FN=FN+1;
        end
    end
end
end