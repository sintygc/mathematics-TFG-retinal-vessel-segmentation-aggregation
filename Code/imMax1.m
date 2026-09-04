function image = imMax1(image)
if max(image(:))>1
    image=image/255;
end