
## Problem with Ubuntu and solution proposed by Romain Casta


Lors de l’exécution de la commande système :
``
system( ’FreeFem++ /PRODCOM/Ubuntu16.04/freefem/3.51/gcc-5.4-mpich_3.2/share/freefem++/3.51-3/examples++/demo.edp’)
``
dans Matlab 2017. On a le retour :
``
FreeFem++ : /PRODCOM/MATLAB/matlabr2017a/sys/os/glnxa64/libstdc++.so.6 : version `GLIBCXX_3.4.21’ not found (required by FreeFem++)
``

alors que les choses se passent correctement en exécutant la commande sans passer par matlab.

Cela vient du fait que Matlab préfère aller chercher les librairies dans son répertoire /PRODCOM/MATLAB/matlabr2017a/sys/os/glnxa64 à la place de chercher dans les répertoires systèmes.

Dans ce cas-ci on a créé un lien symbolique dans le répertoire Matlab vers la librairie système /usr/lib/x86_64-linux-gnu/libstdc++.so.6 . Cela a permis de résoudre le problème.

On aurait pu aussi surcharger la variable LD_PRELOAD, en l’incluant dans le wrapper /PRODCOM/bin/matlab

