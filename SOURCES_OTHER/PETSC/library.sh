rm -f *.so
rm -f *.c
rm -fr *dylib.dSYM 
rm -f *dylib 
ff-c++ iovtk.cpp
cp $HOME/Sources/freefem++-3.59/examples++-hpddm/*.so .
cp $HOME/Sources/freefem++-3.59/examples++-hpddm/*.o .

