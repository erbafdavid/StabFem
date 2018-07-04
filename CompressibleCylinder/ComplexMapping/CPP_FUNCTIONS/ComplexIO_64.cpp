#include  <iostream>
#include  <cfloat>
using namespace std;
#include "error.hpp"
#include "AFunction.hpp"
#include "rgraph.hpp"
#include "MatriceCreuse_tpl.hpp"
#include "RNM.hpp"
#include "fem.hpp"
#include "FESpace.hpp" 
#include "MeshPoint.hpp"
#include "AFunction_ext.hpp" // Extension of "AFunction.hpp" to deal with more than 3 parameters function
using namespace Fem2D;

//function to swap between Endian formats
void *SwapEndian(void* Addr, const int Nb) {
	static char Swapped[16];
	switch (Nb) {
		case 2:	Swapped[0]=*((char*)Addr+1);
				Swapped[1]=*((char*)Addr  );
				break;
		case 3:	// As far as I know, 3 is used only with RGB images
				Swapped[0]=*((char*)Addr+2);
				Swapped[1]=*((char*)Addr+1);
				Swapped[2]=*((char*)Addr  );
				break;
		case 4:	Swapped[0]=*((char*)Addr+3);
				Swapped[1]=*((char*)Addr+2);
				Swapped[2]=*((char*)Addr+1);
				Swapped[3]=*((char*)Addr  );
				break;
		case 8:	Swapped[0]=*((char*)Addr+7);
				Swapped[1]=*((char*)Addr+6);
				Swapped[2]=*((char*)Addr+5);
				Swapped[3]=*((char*)Addr+4);
				Swapped[4]=*((char*)Addr+3);
				Swapped[5]=*((char*)Addr+2);
				Swapped[6]=*((char*)Addr+1);
				Swapped[7]=*((char*)Addr  );
				break;
		case 16:Swapped[0]=*((char*)Addr+15);
				Swapped[1]=*((char*)Addr+14);
				Swapped[2]=*((char*)Addr+13);
				Swapped[3]=*((char*)Addr+12);
				Swapped[4]=*((char*)Addr+11);
				Swapped[5]=*((char*)Addr+10);
				Swapped[6]=*((char*)Addr+9);
				Swapped[7]=*((char*)Addr+8);
				Swapped[8]=*((char*)Addr+7);
				Swapped[9]=*((char*)Addr+6);
				Swapped[10]=*((char*)Addr+5);
				Swapped[11]=*((char*)Addr+4);
				Swapped[12]=*((char*)Addr+3);
				Swapped[13]=*((char*)Addr+2);
				Swapped[14]=*((char*)Addr+1);
				Swapped[15]=*((char*)Addr  );
				break;
	}
	return (void*)Swapped;
}

#define SWAP_LONG(Var)   Var = *(int*)          SwapEndian((void*)&Var, sizeof(int))

#define SWAP_DOUBLE(Var) Var = *(double*)        SwapEndian((void*)&Var, sizeof(double))

#define L_ENDIAN 0
#define B_ENDIAN 1

//funzione per scoprire in l'endianess del sistema
int endian() {
	int i=1;
	char *p=(char *)&i;

	if (p[0]==1)
		return L_ENDIAN;
	else
		return B_ENDIAN;
}
int ENDIANESS=endian();



 
double terminenotocomplex(const KN_<Complex> & f,long int *const & tipo, string *const & nome)   

{
  std::ofstream outfile (nome->data(),ios_base::binary);

int tipo1=*tipo;
//SWAP_LONG(tipo1);
  outfile.write ((char*) &tipo1, sizeof(int));//scrive la flag che identifica il sistema
 
  int nn = f.n; // get number of nodes
int dim=nn;
//bendian swap
//SWAP_LONG(dim);
//outfile.write ((char*) &dim, sizeof(long int));//write the dimension of the vector
 KN<double> fr(dim),fi(dim);
 C2RR(dim,f,fr,fi);
 double ftemp ;
  
  for(int i=0; i<nn; i++) {

    ftemp = fr[i] ;
    // bendian
    //SWAP_DOUBLE(ftemp);
    // swap bits di outfile
   
    outfile.write ((char*) &ftemp, sizeof(double));
    ftemp = fi[i] ;
    // bendian
    //SWAP_DOUBLE(ftemp);
    // swap bits di outfile
    outfile.write ((char*) &ftemp, sizeof(double));
  }

  outfile.close();

  return 0.0;  // dummy return value.
}


 
double SaveVecComplexPETSc(const KN_<Complex> & f, string *const & nome)   

{
  std::ofstream outfile (nome->data(),ios_base::binary);

int cod=1211214;
 if (ENDIANESS==0)
   SWAP_LONG(cod);
 outfile.write ((char*) &cod, sizeof(int));//scrive il codice che identifica il vettore in PETSC
 
 int nn = f.n; // get number of nodes
 int dim=nn;
 //bendian swap
 if (ENDIANESS==0)
   SWAP_LONG(nn);
 outfile.write ((char*) &nn, sizeof(int));//write the dimension of the vector
 KN<double> fr(dim),fi(dim);
 C2RR(dim,f,fr,fi);
 double ftemp ;
 for(int i=0; i<dim; i++) 
   {
     ftemp = fr[i] ;
     // bendian
     if (ENDIANESS==0)
       SWAP_DOUBLE(ftemp);
     // swap bits di outfile
     outfile.write ((char*) &ftemp, sizeof(double));
     ftemp = fi[i] ;
     // bendian
     if (ENDIANESS==0)
       SWAP_DOUBLE(ftemp);
     // swap bits di outfile
     outfile.write ((char*) &ftemp, sizeof(double));
   }
 outfile.close();
 return 0.0;  // dummy return value.
}

  
double LoadVecComplexPETSc(const KN_<Complex> & ww, string *const & nome)   
{
  std::ifstream infile (nome->data(),ios_base::binary);
  // Remarque:
  // It might prove usefull to have a look in the cpp file where KN is defined: src/femlib/RNM.hpp
  //
  // To access value at node i of vector N, do as follow: *(N[0]+i)
  // Explanation (C++ for dummies as I am ;-):
  //   N         is an alias to the KN object.
  //   N[0]      is a pointer to the first element of the vector.
  //   N[0]+i    is a pointer to the ith element of the vector.
  //   *(N[0]+i) is the value of the ith element of the vector.
  //
  int codice;
  int dim;
  infile.read((char *) &codice, sizeof(int));
  if (ENDIANESS==0)
    SWAP_LONG(codice);
    infile.read((char *) &dim, sizeof(int));
  if (ENDIANESS==0)
    SWAP_LONG(dim);
  
  double dtemp;
  KN<double> wwi(dim),wwr(dim);
  for(int i=0; i<dim; i++) 
    {
      infile.read((char *) &dtemp, sizeof(double));
      if (ENDIANESS==0)
	{// lendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di infile    
	}
      wwr[i]=dtemp ;
      infile.read((char *) &dtemp, sizeof(double));
      if (ENDIANESS==0)
	{// lendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di infile    
	}
      wwi[i]=dtemp ;
    }
  RR2C(dim,wwr,wwi,ww);
  return 0.0;  // dummy return value.
}

 
double SaveVecComplex(const KN_<Complex> & f, string *const & nome)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  int nn =f.n; // get number of nodes  
  KN<double> fr(nn),fi(nn);
  C2RR(nn,f,fr,fi);
  int dim=nn;  
  outfile.write ((char*) &dim, sizeof(int));//write the dimension of the vector
  double ftemp ;
  for(int i=0; i<nn; i++) 
    {
      ftemp = fr[i] ;
      outfile.write ((char*) &ftemp, sizeof(double));
      ftemp = fi[i] ;
      outfile.write ((char*) &ftemp, sizeof(double));
    }
  outfile.close();
  return 0.0;  // dummy return value.
}

 
double LoadVecComplex(const KN_<Complex> & ww, string *const & nome)   
{
  std::ifstream infile (nome->data(),ios_base::binary);
  int dim;
  infile.read((char *) &dim, sizeof(int));
  double dtemp;
  KN<double> wwr(dim),wwi(dim);
  for(long int i=0; i<dim; i++)
   {
   infile.read((char *) &dtemp, sizeof(double));
    wwr[i]=dtemp ;
    infile.read((char *) &dtemp, sizeof(double));
    wwi[i]=dtemp;
   }
  RR2C(dim,wwr,wwi,ww);
  return 0.0;  // dummy return value.
}

 

//   add the function name to the freefem++ table 
class Init { public:
  Init();
};	
Init init;
Init::Init(){	
  Global.Add("LoadVecComplex","(",new OneOperator2_<double,  KN_<Complex>, string* >(LoadVecComplex)); 
  Global.Add("SaveVecComplex","(",new OneOperator2_<double,KN_<Complex>, string* >(SaveVecComplex));
Global.Add("SaveVecComplexPETSc","(",new OneOperator2_<double,KN_<Complex>, string* >(SaveVecComplexPETSc));
  Global.Add("terminenotocomplex","(",new OneOperator3_<double,  KN_<Complex>, long int*, string* >(terminenotocomplex)); 
  Global.Add("LoadVecComplexPETSc","(",new OneOperator2_<double,KN_<Complex>, string* >(LoadVecComplexPETSc));
 


}

