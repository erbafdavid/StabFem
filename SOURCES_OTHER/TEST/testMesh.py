from SFGraphics import SF_Graphics
import numpy as np
import scipy.io as spio
import matplotlib.pyplot as plt

#mat = spio.loadmat(fileName,
#                  squeeze_me=True, struct_as_record=False)
#
#matS = spio.loadmat('/home/jsagg/Videos/StabFem/CASES_DEVELOPMENT/CompressibleCylinder/Sponge/Sensitivity.mat',
#                   squeeze_me=True, struct_as_record=False)

plot = SF_Graphics('ff2m')
options = {
           'Field':'ux1',
           'TypeField':'emZ',
           'ff2mElement': 394,
           'complex':'imag',
           'title':r'$u(x,y)$',
           'mirror':False,
           'cmap':None,
        	   'nLevelsFill':100,
        	   'LevelsFilled':None,
        	   'CLevels':None,
           'xlim':[0.5,80],
           'ylim':[-30,30],
           'nFiles': 1,
           'yLoc':[0]}
fileName = '/home/jsagg/StabFem/CASES_DEVELOPMENT/CompressibleCylinder/ComplexMapping/TestReflectedCM.mat'
plot.FF2MReader(fileName, **options)
options['TypeField'] = 'emP1'
plot.FF2MReader(fileName, **options)
options['TypeField'] = 'emP2'
plot.FF2MReader(fileName, **options)
options['TypeField'] = 'emP3'
plot.FF2MReader(fileName, **options)
options['TypeField'] = 'emP35'
plot.FF2MReader(fileName, **options)
options['TypeField'] = 'emP4'
plot.FF2MReader(fileName, **options)
plot.PlotPlt(**options)
Llim = 100
ULim = 1000
#
ax1 = plt.subplot(211)
plt.plot(plot.xi[Llim:ULim], -plot.npIntFields[-4][500,Llim:ULim], label=r'$\gamma_c = 0.2$')
plt.setp(ax1.get_xticklabels(), visible=False)
plt.text(1.02, 0.5, r'$\gamma_c = 0.2$', {'color': 'black', 'fontsize': 50},
         horizontalalignment='left',
         verticalalignment='center',
         rotation=90,
         clip_on=False,
         transform=plt.gca().transAxes)

ax2 = plt.subplot(212, sharex=ax1)
plt.plot(plot.xi[Llim:ULim], -plot.npIntFields[-3][500,Llim:ULim], label=r'$\gamma_c = 0.3$')
plt.setp(ax2.get_xticklabels(), visible=True)
plt.xlim(0.5,400)
plt.text(1.02, 0.5, r'$\gamma_c = 0.3$', {'color': 'black', 'fontsize': 50},
         horizontalalignment='left',
         verticalalignment='center',
         rotation=90,
         clip_on=False,
         transform=plt.gca().transAxes)
plt.show()




#
##plt.yticks(np.arange(-0.0005, 0.00075, step=0.000125))
#plt.grid()
#plt.plot(plot.xi[500:], plot.npIntFields[-1][500,500:])
#
#plt.xticks(np.arange(0, 150, step=10))
##plt.yticks(np.arange(-0.0005, 0.00075, step=0.000125))
#plt.grid()
#plt.xlim(0.5,200)
#Normalization = np.max(-plot.npIntFields[-3][500,:])/np.max(plot.npIntFields[-4][500,:])
#plot.npIntFields[-4][500,:] = Normalization*plot.npIntFields[-4][500,:]
##plt.plot(plot.xi, -plot.npIntFields[-5][500,:])
#plt.xticks(np.arange(0, 125, step=25))


#y1 = np.zeros(10)
#y2 = np.zeros(10)
#for i in range(7):
#	y1[i] = np.real(mat['em_L'][i].lambdaVarBF) + np.real(mat['em_L'][i].lambdaVarMa)
#	y2[i] = np.real(matS['em_L'][i].lambdaVarBF) + np.real(matS['em_L'][i].lambdaVarMa)
#for i in range(8,11):
#	y1[i-1] = np.real(mat['em_L'][i].lambdaVarBF) + np.real(mat['em_L'][i].lambdaVarMa)
#	y2[i-1] = np.real(matS['em_L'][i].lambdaVarBF) + np.real(matS['em_L'][i].lambdaVarMa)
#x = np.linspace(0.1,0.6,10)
#plot.plotComp(x,y1,y2)
