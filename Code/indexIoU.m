function res = indexIoU(TP,TN,FP,FN)

res = TP/(TP+FN+FP);

end