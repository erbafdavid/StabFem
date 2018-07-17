
#include  <iostream>
#include  <cfloat>
using namespace std;
#include "error.hpp"
#include "AFunction.hpp"
#include "rgraph.hpp"
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



 
double FF2Stru(KN<long int> *const & vers,KN<long int> *const & nxny,KN<double> *const & grid,KN<double> *const & fields, string *const & nome)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  //IMPORTANTE: IN SCRITTURA SI USA LASCIA UNA SPAZIO vuoto di 4 bytes (la variabile tempint) come in FORTRAN (per uniformare con nek5000 e la classe matlab per leggere i file)


  // Grid parameters  
  int nx=*(nxny[0]+0);
  int ny=*(nxny[0]+1);
  double x0=*(grid[0]+0);
  double x1=*(grid[0]+1);
  double y0=*(grid[0]+2);
  double y1=*(grid[0]+3);
  //=======================================================================
  
  double xtemp,ytemp;
  int vtemp; 
  int tempint=28; //4*7 
  double ftemp ;
  int dim = fields->N(); // get number of nodes
  
  //write vers
  outfile.write ((char*) &tempint, sizeof(int));
  for (int i=0;i<7;i++)
    { 
      vtemp=*(vers[0]+i);
      outfile.write ((char*) &vtemp, sizeof(int));
    }
  outfile.write ((char*) &tempint, sizeof(int));

  // se vers(0)=1 scrive anche la griglia   
  vtemp=*(vers[0]);
  if (vtemp==1)
    {
      outfile.write ((char*) &tempint, sizeof(int));
      outfile.write ((char*) &nx, sizeof(int));
      outfile.write ((char*) &ny, sizeof(int));
      outfile.write ((char*) &tempint, sizeof(int));
      
      outfile.write ((char*) &tempint, sizeof(int));
      for (int i=1;i<=nx;i++)
	{
	  xtemp=x0 + (x1-x0)/(nx-1)*(i-1);
	  outfile.write ((char*) &xtemp, sizeof(double));
	}
      outfile.write ((char*) &tempint, sizeof(int));
      outfile.write ((char*) &tempint, sizeof(int));
      for (int i=1;i<=ny;i++)
	{
	  ytemp=y0 + (y1-y0)/(ny-1)*(i-1);
	  outfile.write ((char*) &ytemp, sizeof(double));
	}
      outfile.write ((char*) &tempint, sizeof(int));
    }
  
  //dimensioni dei campi
    int dimfield=nx*ny;
    /*outfile.write ((char*) &tempint, sizeof(int));
  outfile.write ((char*) &dimfield, sizeof(int));
  outfile.write ((char*) &tempint, sizeof(int));
  */
  //si scrivono i campi

  int ncycle=dim/dimfield;
  int cont;
  for(int j=0;j<ncycle;j++)
    {
      cont=j*dimfield;
      outfile.write ((char*) &tempint, sizeof(int));
      for( int i=0; i<dimfield; i++) 
	{
    	  ftemp = *(fields[0]+i+cont);
	  outfile.write ((char*) &ftemp, sizeof(double));
	}
      outfile.write ((char*) &tempint, sizeof(int));
    }
      outfile.close();
      return 0.0;  // dummy return value.
    }
  

double SaveVec(KN<double> *const & f, string *const & nome)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  // To access value at node i of vector N, do as follow: *(N[0]+i)
  // Explanation (C++ for dummies as I am ;-):
  //   N         is an alias to the KN object.
  //   N[0]      is a pointer to the first element of the vector.
  //   N[0]+i    is a pointer to the ith element of the vector.
  //   *(N[0]+i) is the value of the ith element of the vector.
 
   int nn = f->N(); // get number of nodes
   int dim=nn;
   outfile.write ((char*) &dim, sizeof(int));//write the dimension of the vector
   double ftemp ;
   for( int i=0; i<nn; i++) { 
     ftemp = *(f[0]+i) ;
     outfile.write ((char*) &ftemp, sizeof(double));
   }
   outfile.close();
  return 0.0;  // dummy return value.
}


 
double LoadVec(KN<double> *const & ww, string *const & nome)   
{
  std::ifstream infile (nome->data(),ios_base::binary);
  int dim;
  infile.read((char *) &dim, sizeof(int));
  double dtemp;
  for(int i=0; i<dim; i++)
   {
   infile.read((char *) &dtemp, sizeof(double));
    *(ww[0]+i)=dtemp ;
    }
  return 0.0;  // dummy return value.
}
 
double LoadFlag(long int *const & ww, string *const & nome)   
{
  std::ifstream infile (nome->data(),ios_base::binary);
  int dim;
  infile.read((char *) &dim, sizeof(int));
  *ww=(long int) dim;
  infile.close();
  return 0.0;  // dummy return value.
}


double WriteFlag(long int *const & FLAG,string *const &nome)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  int Flag;
  Flag= *FLAG;   
  outfile.write ((char*) &Flag, sizeof(int));
  outfile.close();
  return 0.0;
}

double SaveVecPETSc(KN<double> *const & f, string *const & nome, long int *const & comp)
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  int cod=1211214;
  if (ENDIANESS==0)
    SWAP_LONG(cod);
  outfile.write ((char*) &cod, sizeof(int));//scrive il codice che identifica il vettore in PETSC
  int nn = f->N(); // get number of nodes
  int dim=nn;
  //bendian swap
  if (ENDIANESS==0)
    SWAP_LONG(nn);
  outfile.write ((char*) &nn, sizeof(int));//write the dimension of the vector
  double ftemp ;
  for(int i=0; i<dim; i++) 
    {
      ftemp = *(f[0]+i);
      // bendian
      if (ENDIANESS==0)
	SWAP_DOUBLE(ftemp);
      // swap bits di outfile
      outfile.write ((char*) &ftemp, sizeof(double));
      if (*comp==1)
	{
	  ftemp=0;
	  if (ENDIANESS==0)
	    SWAP_DOUBLE(ftemp);
	  // swap bits di outfile
	  outfile.write ((char*) &ftemp, sizeof(double));
	}
    }
  outfile.close();
  return 0.0;  // dummy return value.
}

double LoadVecPETSc(KN<double> *const & ww, string *const & nome,long int *const &comp)   
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
  for(int i=0; i<dim; i++) 
    {
      infile.read((char *) &dtemp, sizeof(double));
      if (ENDIANESS==0)
	{// lendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di infile    
	}
      *(ww[0]+i)=dtemp ;
      if (*comp==1)
	{
	  infile.read((char *) &dtemp, sizeof(double));
	}
    }
  infile.close();
  return 0.0;  // dummy return value.
}


//   add the function name to the freefem++ table 
class Init { public:
  Init();
};	
Init init;
Init::Init(){	
		
  Global.Add("LoadVec","(",new OneOperator2_<double,  KN<double>*, string* >(LoadVec)); 
  Global.Add("LoadVecPETSc","(",new OneOperator3_<double,  KN<double>*, string*, long int* >(LoadVecPETSc)); 
  Global.Add("LoadFlag","(",new OneOperator2_<double,  long int*, string* >(LoadFlag)); 
  //  Global.Add("FF2Stru","(",new OneOperator5_<double,  KN<long int>*,KN<long int>*,KN<double>*, KN<double>*,  string* >(FF2Stru)); 
  Global.Add("SaveVec","(",new OneOperator2_<double,KN<double>*, string* >(SaveVec));
  Global.Add("SaveVecPETSc","(",new OneOperator3_<double,KN<double>*, string*,long int* >(SaveVecPETSc));
  Global.Add("WriteFlag","(",new OneOperator2_<double,long int*,string* >(WriteFlag));  
}

