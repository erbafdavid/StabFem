#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Library for VTK and ff2m graphics with python libraries such as matplotlib
"""

import vtk
from vtk.util.numpy_support import vtk_to_numpy
import numpy as np
from scipy.interpolate import griddata
from matplotlib.patches import Circle,Rectangle # To add a circle patch
import matplotlib.pyplot as plt
import matplotlib as mpl
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import matplotlib.ticker as ticker
from cycler import cycler 
import scipy.io as spio

class SF_Graphics: 
    
    # Atributes of the class SF_Graphics
    nFields = 0 # number of fields
    npFields = []
    npIntFields = []
    # Members
    def __init__(self, IOType, ):
        self.IOType = IOType
        return
        
    def VTKReader(self, fileName,**kwargs):
        # Reading kwargs
        fieldName = kwargs.get('Field','pr')
        coord = kwargs.get('Coord','S')
        npts = kwargs.get('npts', 1000)
        # Reading fileName
        reader = vtk.vtkUnstructuredGridReader()
        reader.SetFileName(fileName)
        reader.Update()
        self.reader = reader
        iField = self.nFields # Field of the list in the class
        self.__VTKGetField(fieldName) # Get the field fieldName
        self.__VTKGetNodes() # Get the nodes of the mesh (x,y,z)
        self.__VTKGetCoordinate(coord,iField)
        self.__SFInterpolation(npts,iField)
        return
    
    def FF2MReader(self, fileName, **kwargs):
        mat = spio.loadmat(fileName, squeeze_me=True, struct_as_record=False)
        self.mat = mat
        self.FF2MGetVariable(**kwargs)
       
    
    def FF2MGetVariable(self, **kwargs):
        TypeField = kwargs.get('TypeField','em')
        fieldName = kwargs.get('Field','T1')
        ff2mElement = kwargs.get('ff2mElement',0)
        npts = kwargs.get('npts', 1000)
        reader = self.mat[TypeField]
        if(type(reader) == np.ndarray):
            reader = reader[ff2mElement]
        self.reader = reader
        iField = self.nFields # Field of the list in the class
        self.__FF2MGetField(fieldName, **kwargs) # Get the field fieldName
        self.__FF2MGetNodes()  # Get the nodes of the mesh (x,y)
        self.__SFInterpolation(npts,iField)
        
    def __FF2MGetNodes(self):
        self.x = self.reader.mesh.points[0]
        self.y = self.reader.mesh.points[1]

    def __VTKGetNodes(self):
        nodes_vtk_array= self.reader.GetOutput().GetPoints().GetData()
        nodes_nummpy_array = vtk_to_numpy(nodes_vtk_array)
        x,y,z= nodes_nummpy_array[:,0] , nodes_nummpy_array[:,1] ,\
               nodes_nummpy_array[:,2]
        self.x = x
        self.y = y
        self.z = z
        return
    
    def __VTKGetField(self, fieldName):
        
        Field = self.reader.fieldName
        FieldNP = vtk_to_numpy(Field)
        self.npFields.append(FieldNP)
        self.nFields += 1
        return
    
    def __FF2MGetField(self, fieldName, **kwargs):
        complexType = kwargs.get('complex','real')
        Field = getattr(self.reader, fieldName)
        if(complexType == 'real'):
            Field = np.real(Field)
        else:
            Field = np.imag(Field)
        self.npFields.append(Field)
        self.nFields += 1
        return
    
    def __VTKGetCoordinate(self, coord, iField):
        # Selec the coordinate of the field if it is a vector or select a scalar
        try:
            if(coord == 'S'):
                fieldtype = 0
            elif(coord=='X'):
                fieldtype=1
                component = 0
            elif(coord=='Y'):
                fieldtype=1
                component = 1
            elif(coord=='Z'):
                fieldtype=1
                component = 2
            else:
                exit(0)
        except:
            fieldtype = 0
            
        if (fieldtype == 0):
            self.npFields[iField] = self.npFields[iField][:]
        else:
            self.npFields[iField] = self.npFields[iField][:,component]
        return
    
    def __SFInterpolation(self,npts,iField):
        self.npts = npts 
        xmin, xmax = min(self.x), max(self.x)
        ymin, ymax = min(self.y), max(self.y)
        # define grid
        xi = np.linspace(xmin, xmax, npts)
        yi = np.linspace(ymin, ymax, npts)
        FieldInt = griddata((self.x, self.y), self.npFields[iField], \
                            (xi[None,:], yi[:,None]), method='cubic')
        self.npIntFields.append(FieldInt)
        self.xi = xi
        self.yi = yi
        return

    def __Styleplt(self, **kwargs):
        default_cycler = cycler('color', ['k','k','k','k']) \
                         + cycler('linestyle', ['-','--',':','-.'])
        plt.rc('text', usetex=True)
        mpl.rcParams['font.size'] = 30
        mpl.rcParams['axes.formatter.limits'] = -5,5
        plt.rc('font', family='serif')
        plt.rc('xtick', labelsize='x-small')
        plt.rc('ytick', labelsize='x-small')
        plt.rc('lines', color='r')
        plt.rc('lines', linewidth=3)
        plt.rc('axes', prop_cycle=default_cycler)
        return
    
    def PlotPlt (self, **kwargs):
        # Read dictionary with kwargs
        fieldName = kwargs.get('Field','pr')
        TypePlot = kwargs.get('TypePlot','contour')
        iField = -1 # Field of the list in the class
        self.__Styleplt(**kwargs)
        if (TypePlot == 'contour'):
            self.__PlotContour(fieldName,iField,**kwargs)
        elif(TypePlot == 'line'):
            self.__PlotLine(iField,**kwargs)
        
        plt.show()
        return
    
    def __PlotContour(self, fieldName, iField, **kwargs):
        # Reading input parameters
        xlim = kwargs.get('xlim',[-5.0,30.0])
        ylim = kwargs.get('ylim',[-5.0,5.0])
        nLevels = kwargs.get('nLevelsFill',100)
        BoxCM = kwargs.get('BoxCM',False)
        BoxCMOrig = kwargs.get('BoxCMOrig',[0,0])
        BoxCMUpperCor = kwargs.get('BoxCMUpperCor',[40,16])
        levelsFilled = kwargs.get('LevelsFilled', None)
        levelsFilled2 = kwargs.get('LevelsFilled2', None)
        contourLevels = kwargs.get('CLevels', None)
        mirror = kwargs.get('mirror', False)
        csMap = kwargs.get('cmap', None)
        twoFields = kwargs.get('twoFields',False)
        saveOption = kwargs.get('saveOption', False)
        name = kwargs.get('name', 'plot')

        # Plotting
        fig, ax1 = plt.subplots(1, 1)
        
        if 'title' in kwargs:
            title = kwargs.get('title')
            if(title != 'None'):
                ax1.set_title(title, fontsize = 'large', y = 1.02)
        else:
            ax1.set_title(r' $\hat'+'{'+fieldName+'}'+'(x,y)$',\
                          fontsize = 'large', y = 1.02)
        ax1.set_aspect('equal')
        def mymft(x, pos):
            return '{0:.5f}'.format(x)
        # Contour plot
       
        if(twoFields == False):
            yi = [self.yi]
            xi = [self.xi]
            Field = [self.npIntFields[iField]]
            nFields = 1
            CS = [0]
            cbaxes1 = inset_axes(ax1, width="30%", height="5%", loc='upper center')
            position = [cbaxes1]
        elif(twoFields == True):
            nFields = 2
            Cond1 = np.array(np.where(self.yi>=0))[0,:]
            Cond2 = np.array(np.where(self.yi<0))[0,:]
            yi = [self.yi[Cond1], self.yi[Cond2]]
            xi = [self.xi, self.xi]
            Field = [self.npIntFields[iField][Cond1,:],
                     self.npIntFields[iField-1][Cond2,:]]
            cbaxes1 = inset_axes(ax1, width="30%", height="5%", loc='upper center') 
            cbaxes2 = inset_axes(ax1, width="30%", height="5%", 
                                 loc='lower center', borderpad=1)
            position = [cbaxes1, cbaxes2]
            CS = [0,0];
        levelsFilled = [levelsFilled, levelsFilled2]
        for i in range(nFields):
            if(type(levelsFilled[i]) != np.ndarray):
                CSnp = np.linspace(np.min(Field[i]), 
                                   np.max(Field[i]), nLevels)
            else:
                CSnp = np.linspace(levelsFilled[i][0], 
                                   levelsFilled[i][1], nLevels)
            CS[i] = ax1.contourf(xi[i],yi[i],Field[i],
                              levels=CSnp,cmap=csMap,extend="both")
            if(contourLevels != None):
                ax1.contour(xi[i],yi[i],Field[i],
                            levels=contourLevels, colors='w',
                            linewidths=2,linestyles='dashed',alpha=0.8)
        
            plt.colorbar(CS[i], cax=position[i], cmap=csMap, orientation='horizontal',
                         format=ticker.FuncFormatter(mymft),
                         ticks=[np.min(CSnp),
                                 np.max(CSnp)],
                         extend='both') 
            # This is the fix for the white lines between contour levels
            for c in CS[i].collections:
                c.set_edgecolor("face")
        # Axial symmetry with respect y-axis
        if(mirror == True):
            CS[0] = ax1.contourf(self.xi,-self.yi,self.npIntFields[iField], 
                              levels=CSnp,cmap=csMap,extend="both")
            if(contourLevels != None):
                ax1.contour(self.xi,-self.yi,self.npIntFields[iField], 
                            levels=contourLevels, colors='w',
                            linewidths=2,linestyles='dashed',alpha=0.8)
        if(twoFields == True):
            ax1.plot([np.min(self.xi), np.max(self.xi)], [0, 0], '-k')
        circ = Circle((0, 0), 1, facecolor='w', edgecolor='w', lw=5)
        
        if(BoxCM == True):
            rect = Rectangle((BoxCMOrig[0], BoxCMOrig[1]), BoxCMUpperCor[0], 
                             BoxCMUpperCor[1], fill=None, alpha=1)
            ax1.add_patch(rect)
        ax1.add_patch(circ)
        ax1.set_xlim(xlim)
        ax1.set_ylim(ylim)
        if (saveOption == True):
            fig.set_size_inches(12, 20)
            fig.savefig(name+'.pdf', bbox_inches='tight', dpi=500)
        # Add color bar
        return
    
        
    def __PlotLine(self, iField, **kwargs):
        # Reading input parameters
        if 'xLoc' in kwargs:
            fig, ax1 = plt.subplots(1, 1)
            xLoc = kwargs.get('xLoc', [0])
            ylim = kwargs.get('ylim',[-5.0,5.0])
            xmin, xmax = min(self.x), max(self.x)
            if 'title' in kwargs:
                title = kwargs.get('title')
                ax1.set_title(title, fontsize = 'large', y = 1.02)
            for xloc in xLoc:
                iLoc = int((xloc - xmin)/(xmax-xmin))*self.npts
                nFiles = kwargs.get('nFiles', 1)
                lineLabels = kwargs.get('lineLabels', nFiles*[None])
                for i in range(0,nFiles):
                    iField = self.nFields - i - 1
                    plt.plot(self.yi, self.npIntFields[iField][:,iLoc],
                             label=lineLabels[i])
            if 'xlim' in kwargs:
                xlim = kwargs.get('ylim',[-5.0,5.0])
                ax1.set_ylim(ylim)
        else:
            fig, ax1 = plt.subplots(1, 1)
            yLoc = kwargs.get('yLoc', [0])
            self.yLoc = yLoc
            
            ymin, ymax = min(self.y), max(self.y)
            for yloc in yLoc:
                iLoc = int ((yloc - ymin)/(ymax-ymin)*self.npts)
                nFiles = kwargs.get('nFiles', 1)
                lineLabels = kwargs.get('lineLabels', nFiles*[None])
                for i in range(0,nFiles):
                    iField = self.nFields - i - 1
                    plt.plot(self.xi, self.npIntFields[iField][iLoc,:],
                             label=lineLabels[i])
            if 'xlim' in kwargs:
                xlim = kwargs.get('xlim',[-5.0,30.0])
                ax1.set_xlim(xlim)
            ax1.legend(loc='upper right')
            
        # Plotting
        return

    def __errorfill(self, x, y, yerr, color=None, alpha_fill=0.3, ax=None):
        ax = ax if ax is not None else plt.gca()
        if np.isscalar(yerr) or len(yerr) == len(y):
            ymin = y - yerr
            ymax = y + yerr
        elif len(yerr) == 2:
            ymin, ymax = yerr
        ax.plot(x, y, color='k')
        ax.fill_between(x, ymax, ymin, color='k', alpha=alpha_fill)
        return   
    
    def plotComp(self,x,y1,y2,**kwargs):
        self.__Styleplt(**kwargs)
        fig, axs = plt.subplots(nrows=1, ncols=1, sharey=True)
        ax = axs
        # Reading input parameters
        if 'title' in kwargs:
            title = kwargs.get('title')
            ax.set_title(title)
        lineLabels = kwargs.get('lineLabels', None)
        yerr = np.abs(y2-y1)
        self.__errorfill(x, y1, yerr, ax=ax)
        ax.scatter(x, y1, c="k", alpha=0.5, marker='x',
                    label=lineLabels)
        ax.scatter(x, y2, c="k", alpha=0.5, marker='o',
                    label=lineLabels)
        if 'xLabel' in kwargs:
            xLabel = kwargs.get('xLabel')
            ax.set_xlabel(xLabel)
        if 'yLabel' in kwargs:
            yLabel = kwargs.get('yLabel')
            ax.set_ylabel(yLabel)
        if 'xlim' in kwargs:
            xlim = kwargs.get('xlim',[-5.0,30.0])
            ax.set_xlim(xlim)
        if 'ylim' in kwargs:
            ylim = kwargs.get('ylim',[-5.0,5.0])
            ax.set_xlim(ylim)
        ax.legend()
        plt.show()
        return


        
        