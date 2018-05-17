cd CPP_FUNCTIONS
rm -f *.so
rm -f *.c
rm -fr *dylib.dSYM 
rm -f *dylib 
ff-c++ BinaryIO_64.cpp  
ff-c++ ComplexIO_64.cpp
ff-c++ IO_PETSc_64.
ff-c++ iovtk.cpp
cd ../
