// Example C++ function USCITA MATRICE IN BINARIO"
// ------------------------------------------------------------------------
 
#include  <iostream>
#include  <cfloat>
using namespace std;
#include "error.hpp"
#include "AFunction.hpp"
#include "rgraph.hpp"
#include "RNM.hpp"
#include "MatriceCreuse_tpl.hpp"
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

int endian() {
	int i=1;
	char *p=(char *)&i;

	if (p[0]==1)
		return L_ENDIAN;
	else
		return B_ENDIAN;
}
int ENDIANESS=endian();

double SaveMATwithDirComplex(long int *const &n,long int *const &m,KN<long int> *const & I,KN<long int> *const & J,const KN_<Complex> & A, string *const & nome, KN<double> *const & SEL)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
    -vettore sel (reale) che individua i nodi in cui imporre la condizione di Dirichlet
   */
  int nn = A.n; // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  KN<double> Ar(dim),Ai(dim);
  C2RR(dim,A,Ar,Ai);
  //cout<<Ar<<endl;
  //cout<<Ai<<endl;
  int *i2 = NULL;
  int *j2 = NULL;
  double *c2 = NULL;
  double *c2c = NULL;
  int count1=0;  
  for(int i=0; i<nn; i++) 
    {
      if (*(SEL[0]+ *(I[0]+i))==1)
	{
	  if(*(I[0]+i)==*(J[0]+i))
	    { //Se è un termine sulla diagonale 
	      i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	      j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	      c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	      c2c = (double*) realloc (c2c, (count1+1) * sizeof(double));
	      i2[count1]=*(I[0]+i);
	      j2[count1]=*(J[0]+i);
	      c2[count1]=1;
	      c2c[count1]=0;
	      count1++;
	    } 
	} 
      else
	{
	  i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	  j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	  c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	  c2c = (double*) realloc (c2c, (count1+1) * sizeof(double));
	  i2[count1]=*(I[0]+i);
	  j2[count1]=*(J[0]+i);
	  c2[count1]=Ar[i];
	  c2c[count1]=Ai[i];
	  count1++;
	}
    }
  nn=count1;  
  int i1[ntemp]; 
  
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=i2[cont];
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i1[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=nn;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  int jtemp;
  double dtemp ;
  
  for(int i=0; i<NN; i++) 
    { 
      itemp = i1[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      jtemp = j2[i] ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      dtemp = c2[i] ;
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      dtemp=c2c[i];
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
    }
  //cout<<"A scritto"<<endl;
  outfile.close();
  free(i2);
  free(j2);
  free(c2);
  free(c2c);
  
  return 0.0;  // dummy return value.
}


double SaveMATZeroRowsComplex(long int *const &n,long int *const &m,KN<long int> *const & I,KN<long int> *const & J,const KN_<Complex> & A, string *const & nome, KN<double> *const & SEL)   
{  
  std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
    -vettore sel che individua i nodi in cui imporre la condizione di Dirichlet
    
    Le righe con sel=1 sono annullate
    
  */
  int nn = A.n; // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  KN<double> Ar(dim),Ai(dim);
  C2RR(dim,A,Ar,Ai);
  //cout<<Ar<<endl;
  //cout<<Ai<<endl;
  int *i2 = NULL;
  int *j2 = NULL;
  double *c2 = NULL;
  double *c2c = NULL;
  int count1=0;
  
  for(int i=0; i<nn; i++) 
    {
      if (*(SEL[0]+ *(I[0]+i))==0)	
	{
	  i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	  j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	  c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	  c2c = (double*) realloc (c2c, (count1+1) * sizeof(double));
	  i2[count1]=*(I[0]+i);
	  j2[count1]=*(J[0]+i);
	  c2[count1]=Ar[i];
	  c2c[count1]=Ai[i];
	  count1++;
	}
    }
  nn=count1;  
  
  int i1[ntemp]; 
  
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=i2[cont];
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i1[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=nn;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  int jtemp;
  double dtemp ;
  
  for(int i=0; i<NN; i++) 
    { 
      itemp = i1[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      jtemp = j2[i] ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      dtemp = c2[i] ;
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      dtemp=c2c[i];
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
    }
  //cout<<"A scritto"<<endl;
  outfile.close();
  free(i2);
  free(j2);
  free(c2);
  free(c2c);
  return 0.0;  // dummy return value.
}

double SaveMATComplex(long int *const &n,long int *const &m,KN<long int> *const & I,KN<long int> *const & J,const KN_<Complex> & A, string *const & nome)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
  */
  int nn = A.n; // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  KN<double> Ar(dim),Ai(dim);
  C2RR(dim,A,Ar,Ai);
  //cout<<Ar<<endl;
  //cout<<Ai<<endl;
  int i2[ntemp];
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=*(I[0]+cont);
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i2[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=dim;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  
  int jtemp;
  double dtemp ;
   
  for(int i=0; i<NN; i++) 
    { 
      itemp = i2[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<dim; i++) 
    {
      jtemp = *(J[0]+i) ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	// swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<dim; i++) 
    {
      dtemp = Ar[i] ;
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      dtemp=Ai[i];
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
    }
  //cout<<"A scritto"<<endl;
  outfile.close();
  
  return 0.0;  // dummy return value.
}





double SaveMATwithDir(long int *const &n,long int *const &m,KN<long int> *const & I,KN<long int> *const & J, KN<double> *const & A, string *const & nome, KN<double> *const & SEL,long int *const & complex)   
{
   std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
    -vettore sel che individua i nodi in cui imporre la condizione di Dirichlet
    -complex per salvare la matrice per PETSc compilato con scalar=complex    
   */
   int nn = A->N(); // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  int *i2 = NULL;
  int *j2 = NULL;
  double *c2 = NULL;
  int count1=0;  
  for(int i=0; i<nn; i++) 
    {
      if (*(SEL[0]+ *(I[0]+i))==1)
	{
	  if(*(I[0]+i)==*(J[0]+i))
	    { //Se è un termine sulla diagonale 
	      i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	      j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	      c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	      i2[count1]=*(I[0]+i);
	      j2[count1]=*(J[0]+i);
	      c2[count1]=1;
	      count1++;
	    } 
	} 
      else
	{
	  i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	  j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	  c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	  i2[count1]=*(I[0]+i);
	  j2[count1]=*(J[0]+i);
	  c2[count1]=*(A[0]+i);
	  count1++;
	}
    }
  nn=count1;  
  int i1[ntemp]; 
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=i2[cont];
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i1[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=nn;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  int jtemp;
  double dtemp ;
  for(int i=0; i<NN; i++) 
    { 
      itemp = i1[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      jtemp = j2[i] ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      dtemp = c2[i] ;
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      if(*complex==1)
	{ dtemp=0.;
	  if (ENDIANESS==0)
	    {// bendian
	      SWAP_DOUBLE(dtemp);
	      // swap bits di outfile
	    }
	  outfile.write ((char*) &dtemp, sizeof(double));
	}
      
    }
  //cout<<"A scritto"<<endl;
  outfile.close();
  free(i2);
  free(j2);
  free(c2);

  
  return 0.0;  // dummy return value.
}
 




double SaveMATZeroRows(long int *const &n,long int *const &m,KN<long int> *const & I,KN<long int> *const & J, KN<double> *const & A, string *const & nome, KN<double> *const & SEL,long int *const & complex)   
{

  std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
    -vettore sel che individua i nodi in cui imporre la condizione di Dirichlet
    Le righe con sel=1 sono annullate
    
  */
  int nn = A->N(); // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  
  //cout<<Ar<<endl;
  //cout<<Ai<<endl;
  int *i2 = NULL;
  int *j2 = NULL;
  double *c2 = NULL;
  int count1=0;
  
  for(int i=0; i<nn; i++) 
    {
      if (*(SEL[0]+ *(I[0]+i))==0)	
	{
	  i2 = (int*) realloc (i2, (count1+1) * sizeof(int));
	  j2 = (int*) realloc (j2, (count1+1) * sizeof(int));
	  c2 = (double*) realloc (c2, (count1+1) * sizeof(double));
	  i2[count1]=*(I[0]+i);
	  j2[count1]=*(J[0]+i);
	  c2[count1]=*(A[0]+i);
	  count1++;
	}
    }
  nn=count1;  
  
  int i1[ntemp]; 
  
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=i2[cont];
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i1[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=nn;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  int jtemp;
  double dtemp ;
  
  for(int i=0; i<NN; i++) 
    { 
      itemp = i1[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      jtemp = j2[i] ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<nn; i++) 
    {
      dtemp = c2[i] ;
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      if(*complex==1)
	{ dtemp=0.;
	  if (ENDIANESS==0)
	    {// bendian
	      SWAP_DOUBLE(dtemp);
	      // swap bits di outfile
	    }
	  outfile.write ((char*) &dtemp, sizeof(double));
	}
      
    }
  //cout<<"A scritto"<<endl;
  outfile.close();
  free(i2);
  free(j2);
  free(c2);
  return 0.0;  // dummy return value.
  
}

double SaveMAT(long int *const &n, long int *const &m,KN<long int> *const & I,KN<long int> *const & J, KN<double> *const & A, string *const & nome,long int *const & complex)   
{
  std::ofstream outfile (nome->data(),ios_base::binary);
  /*
    Questa funzione salva matrici in formato CRS
    
    input
    -dimensione della matrice n e m
    -vettori i j e a che definiscono la matrice in freefem
  */
  int nn = A->N(); // get number of nodes 
  //cout<<"n="<<nn<<endl;  
  int ntemp=*n;
  int mtemp=*m;
  int dim=nn;
  //cout<<Ar<<endl;
  //cout<<Ai<<endl;
  int* i2=new int[ntemp];
  int k,nind;
  int cont;
  cont=0;
  bool go=true;
  for(int i=0; i<ntemp; i++) 
    { 
      //      cout<<"i: "<<i<<endl;
      nind=0;
      go=true;
      while (go)
	{
	  //cout<<"cont "<<cont<<endl;
	  k=*(I[0]+cont);
	  //cout<<"k: "<<k<<endl;
	  if (i==k)
	    {
	      nind++;
	      if(cont<(dim-1))
		{
		  cont++;
		}
	      else
		{
		  go=false;
		}
	    }
	  else
	    {
	      go=false;      
	    }
	}
      i2[i]=nind;
      //cout<<"i2[i] "<<nind<<endl;
    }
  //cout<<"fatto"<<endl;
  int nnz=dim;
  int NN=ntemp;
  int codice=1211216;
  if (ENDIANESS==0) 
    {
      //bendian
      SWAP_LONG(ntemp);
      SWAP_LONG(mtemp);
      SWAP_LONG(nnz);
      SWAP_LONG(codice);
      //swap
    }
  outfile.write ((char*) &codice, sizeof(int));//integer that identifies the matrix for PETSC
  outfile.write ((char*) &ntemp, sizeof(int));//write size of matrix and number of non-zero elements
  outfile.write ((char*) &mtemp, sizeof(int));
  outfile.write ((char*) &nnz, sizeof(int));// n m nnz
  //cout<<"Header scritto"<<endl;
  int itemp ;
  
  int jtemp;
  double dtemp ;
  
  for(int i=0; i<NN; i++) 
    { 
      itemp = i2[i];
      if (ENDIANESS==0)   
	SWAP_LONG(itemp);
      outfile.write ((char*) &itemp, sizeof(int));// write vector I      
    }
  //cout<<"I scritto"<<endl;
  for(int i=0; i<dim; i++) 
    {
      jtemp = *(J[0]+i) ; //write J
      if (ENDIANESS==0)
	{  // bendian
	  SWAP_LONG(jtemp);
	// swap bits di outfile
	}
      outfile.write ((char*) &jtemp, sizeof(int));
    }
  //cout<<"J scritto"<<endl;
  for(int i=0; i<dim; i++) 
    {
      dtemp = *(A[0]+i);
      if (ENDIANESS==0)
	{// bendian
	  SWAP_DOUBLE(dtemp);
	  // swap bits di outfile
	}
      outfile.write ((char*) &dtemp, sizeof(double));
      if(*complex==1)
	{ dtemp=0.;
	  if (ENDIANESS==0)
	    {// bendian
	      SWAP_DOUBLE(dtemp);
	      // swap bits di outfile
	    }
	  outfile.write ((char*) &dtemp, sizeof(double));
	}      
    }
  delete[] i2;
  //cout<<"A scritto"<<endl;
  outfile.close();
  
  return 0.0;  // dummy return value. 
}

//   add the function name to the freefem++ table 
class Init { public:
  Init();
};
Init init;
Init::Init(){
  // Add function with 4 arguments
  Global.Add("SaveMATwithDirComplex","(",new OneOperator7_<double,long int*,long int*,  KN<long int>*, KN<long int>*,KN_<Complex>, string*,KN<double>* >(SaveMATwithDirComplex));  
  Global.Add("SaveMATZeroRowsComplex","(",new OneOperator7_<double,long int*,long int*,  KN<long int>*, KN<long int>*,KN_<Complex>, string*,KN<double>* >(SaveMATZeroRowsComplex));  
  Global.Add("SaveMATComplex","(",new OneOperator6_<double,long int*,long int*,  KN<long int>*, KN<long int>*,KN_<Complex>, string* >(SaveMATComplex));  
  Global.Add("SaveMAT","(",new OneOperator7_<double, long int*,long int*, KN<long int>*, KN<long int>*,KN<double>*, string*,long int* >(SaveMAT));
  Global.Add("SaveMATwithDir","(",new OneOperator8_<double,long int*,long int*,  KN<long int>*, KN<long int>*,KN<double>*, string*,KN<double>*,long int* >(SaveMATwithDir));  
  
  Global.Add("SaveMATZeroRows","(",new OneOperator8_<double,long int*,long int*,  KN<long int>*, KN<long int>*,KN<double>*, string*,KN<double>*,long int* >(SaveMATZeroRows));  
  //Global.Add("terminenoto","(",new OneOperator3_<double,  KN<double>*, long int*, string* >(terminenoto)); 
  //Global.Add("terminenoto","(",new OneOperator2_<double,  KN<double>*, string* >(terminenoto)); 
  // Global.Add("soluzione","(",new OneOperator2_<double,KN<double>*, string* >(soluzione));
}



