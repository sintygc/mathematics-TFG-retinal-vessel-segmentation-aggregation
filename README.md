# Estudi de mètodes de segmentació automàtica de vasos sanguinis de la retina i la seva agregació

**Autor:** Sinty Garau Chen 
**Tutors:** Marc Munar Covas, Manuel González Hidalgo
**Universitat:** Universitat de les Illes Balears (UIB)
**Titulació:** Grau de Matemàtiques
**Any acadèmic:** 2025-2026

---

## Descripció
Aquest repositori conté l'entorn de treball i el codi font desenvolupat per a l'experimentació del Treball Final de Grau (TFG). El projecte s'enfoca en l'estudi, implementació i avaluació de mètodes automàtics de segmentació de vasos sanguinis en angiografies retinals (utilitzant les bases de dades DRIVE i STARE), així com en la millora dels resultats individuals mitjançant l'aplicació de diferents funcions d'agregació.

A més del codi d'execució, s'inclouen les imatges de referència, els fitxers de dades exhaustius en format Excel amb totes les mètriques d'avaluació calculades i una mostra representativa de les imatges segmentades resultants.

## Estructura
- `Code/`:
- `Images/`:
- `Results/`:
- `Tests/`:
- TFG_EPS0041_Memòria_Sinty_Garau_Chen.pdf: Memòria del TFG.

## Requisits
- MATLAB (paquets: Image Processing Toolbox, Signal Processing Toolbox, Statistics and Machine Learning Toolbox).
- R, RStudio
- Git LFS

## Execució

## Resum de la memòria

Aquest Treball Final de Grau s'emmarca en el camp del processament d'imatges mèdiques i s'enfoca en la segmentació automàtica de vasos sanguinis en angiografies de la retina, una etapa fonamental en el procés de diagnòstic d'anomalies i patologies oculars. L'objectiu principal és avaluar l'eficiència de diversos mètodes de segmentació existents comparant els resultats amb el criteri d'experts oftalmòlegs, així com determinar si la combinació d'aquests mètodes mitjançant funcions d'agregació permet millorar els resultats individuals.

Per a la fase experimental, es disposa d'un conjunt d'angiografies retinals a color procedents de bases de dades públiques: 40 imatges de DRIVE i 20 de STARE. S'analitzen 11 mètodes de segmentació, extraient de cada un la segmentació en escala de grisos i la segmentació binària (vasos blancs sobre fons negre). A més, per tal d'avaluar els mètodes de forma independent a la seva binarització d'origen, es binaritza cada segmentació en escala de grisos amb tres mètodes diferents: Otsu, Otsu adaptatiu i Medina-Carnicer. A continuació, s'apliquen funcions d'agregació sobre la totalitat de les segmentacions en escala de grisos i sobre subconjunts seleccionats mitjançant contrastos d'hipòtesis dos a dos per descartar els mètodes de menor rendiment en mètriques d'avaluació seleccionades. Finalment, es tornen a aplicar les tres binaritzacions per acabar de comparar tots els processos considerats i determinar quina configuració ofereix la millor aproximació a les segmentacions de referència.

L'anàlisi estadística realitzada permet concloure que el procés de segmentació òptim inclou una combinació de mètodes de segmentació, confirmant que l'ús de funcions d'agregació supera el rendiment de qualsevol mètode individual considerat. Així mateix, l'estudi posa en relleu la sensibilitat dels resultats respecte a la tria de paràmetres i procediments, obrint la porta a futures ampliacions del conjunt de dades i de les tècniques avaluades.
