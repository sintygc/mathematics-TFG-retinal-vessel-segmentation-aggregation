function [TP,TN,FP,FN] = sumConfusionMatrix(A,B)
% A is the trusted matrix
% B is the result matrix
TP = sum((A(:)==1)&(B(:)==1));
TN = sum((A(:)==0)&(B(:)==0));
FP = sum((A(:)==0)&(B(:)==1));
FN = sum((A(:)==1)&(B(:)==0));
end