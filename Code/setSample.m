function setSample(pathread,pathwrite)

% Es guarden totes les imatges que s'empren com a Bases de Dades en format .png:
% - Original
% - GroundTruth
% - GroundTruthMasks
% S'especifiquen a ScriptExtras les rutes d'on es prenen les dades i on es guarden.

if ~exist([pathwrite '\Original'], 'dir')
    mkdir([pathwrite '\Original'])
end
if ~exist([pathwrite '\GroundTruth'], 'dir')
    mkdir([pathwrite '\GroundTruth'])
end
if ~exist([pathwrite '\GroundTruthMask'], 'dir')
    mkdir([pathwrite '\GroundTruthMask'])
end

pathO1 = [pathread '\EyeFundus - DRIVE\Dataset\Originals\test'];
pathO2 = [pathread '\EyeFundus - DRIVE\Dataset\Originals\training'];
pathO3 = [pathread '\EyeFundus - STARE\Dataset\Originals'];
pathGT1 = [pathread '\EyeFundus - DRIVE\Dataset\Ground Truth - Vessel Segmentation 1\test'];
pathGT2 = [pathread '\EyeFundus - DRIVE\Dataset\Ground Truth - Vessel Segmentation 1\training'];
pathGT3 = [pathread '\EyeFundus - STARE\Dataset\Ground Truth - Vessel Segmentation - Adam Hoover'];
pathGTM1 = [pathread '\EyeFundus - DRIVE\Dataset\Ground Truth - Mask\test'];
pathGTM2 = [pathread '\EyeFundus - DRIVE\Dataset\Ground Truth - Mask\training'];

for i=1:20
    imwrite( imread([pathO1 '\' sprintf('%02d_test.tif',i)]), ...
        [pathwrite '\Original\' sprintf('im%02d_Original.png',i)] )
    imwrite( imread([pathGT1 '\' sprintf('%02d_manual1.gif',i)]), ...
        [pathwrite '\GroundTruth\' sprintf('im%02d_GroundTruth.png',i)] )
    imwrite( imread([pathGTM1 '\' sprintf('%02d_test_mask.gif',i)]), ...
        [pathwrite '\GroundTruthMask\' sprintf('im%02d_GroundTruthMask.png',i)] )
end
for i=21:40
    imwrite( imread([pathO2 '\' sprintf('%02d_training.tif',i)]), ...
        [pathwrite '\Original\' sprintf('im%02d_Original.png',i)] )
    imwrite( imread([pathGT2 '\' sprintf('%02d_manual1.gif',i)]), ...
        [pathwrite '\GroundTruth\' sprintf('im%02d_GroundTruth.png',i)] )
    imwrite( imread([pathGTM2 '\' sprintf('%02d_training_mask.gif',i)]), ...
        [pathwrite '\GroundTruthMask\' sprintf('im%02d_GroundTruthMask.png',i)] )
end
namesGT3 = { dir(fullfile(pathGT3,'*.ppm')).name };
for i=1:20
        imwrite( imread([pathO3 '\' erase(namesGT3{i},'.ah')]), ...
                 [pathwrite '\Original\' sprintf('im%02d_Original.png',i+40)] )
        imwrite( imread([pathGT3 '\' namesGT3{i}]), ...
                 [pathwrite '\GroundTruth\' sprintf('im%02d_GroundTruth.png',i+40)] )
end
