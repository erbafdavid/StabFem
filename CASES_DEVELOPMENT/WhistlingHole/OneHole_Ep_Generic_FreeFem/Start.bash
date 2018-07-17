cp Params_Conduct_reel.edp Params_Conduct.edp 
FreeFem++ -nw -v 0 ../MeshGuess.edp
echo 10 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
echo 30 | FreeFem++-nw -v 0 ../Newton_Axi_COMPLEX.edp 
FreeFem++-nw -v 0 ../Adapt_COMPLEX.edp
echo 100 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
echo 300 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
FreeFem++-nw -v 0 ../Adapt_COMPLEX.edp
cp Params_Conduct_cplx.edp Params_Conduct.edp 
echo 300 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
echo 1000 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
FreeFem++-nw -v 0 ../Adapt_COMPLEX.edp
echo 1000 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
echo 4 | FreeFem++ -nw -v 0 ../CalcRayConductivity.edp
FreeFem++-nw -v 0 ../Adapt_UVP.edp < UVP_conductivity_Re1000_omega4.txt
echo 1000 | FreeFem++ -nw -v 0 ../Newton_Axi_COMPLEX.edp 
echo " 0.5 10 .1" > FreeFem++-nw -v 0 ../LoopRayConductivity.edp 


