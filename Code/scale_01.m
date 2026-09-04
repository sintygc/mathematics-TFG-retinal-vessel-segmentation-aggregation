function image = scale_01(image)
%si image es uint8, los valores de image serán {0,1}
image = (image-min(image(:)))/(max(image(:))-min(image(:)));
end
