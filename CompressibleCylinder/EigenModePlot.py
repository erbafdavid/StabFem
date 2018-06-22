import vtk
from vtk.util.numpy_support import vtk_to_numpy
from numpy import zeros
import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import griddata
from matplotlib.patches import Circle # To add a circle patch
import argparse

# TODO: ADD options to save and organise the script of FreeFEM to plot in VTK 
# and ff2m if you order to and to select the plotting option
# Select to do a single plot of few plots (we could extend this file to a class
# and select few members of the class)

# Instantiate the parser
parser = argparse.ArgumentParser(description='App to plot eigenmodes')

# Required positional argument
parser.add_argument('path', type=str,
                    help='The path of the file to be plotted')

# Optional positional argument
parser.add_argument('file', type=str, nargs='?',
                    help='The name of the file')

# Optional argument
parser.add_argument('--opt_field', type=str,
                    help='The name of the field to be plotted')

parser.add_argument('--opt_typeField', type=str,
                    help='Please select the type of field, (S) Scalar'+
                    ' or vector, in that case select the component (X), (Y), (Z)')

# Parsing arguments
args = parser.parse_args()

	
filename = args.path+args.file

try:
    fieldi = args.opt_field+'i'
    fieldr = args.opt_field+'r'
    fieldname = args.opt_field
    print ("Fields {0} and {1} are chosen".format(fieldi,fieldr))
except:
    fieldi = 'ui'
    fieldr = 'ur'
    fieldname = 'u'
    print("Default fields chosen u_i, u_r")
    
try:
    if(args.opt_typeField == 'S'):
        fieldtype = 0
    elif(args.opt_typeField=='X'):
        fieldtype=1
        component = 0
    elif(args.opt_typeField=='Y'):
        fieldtype=1
        component = 1
    elif(args.opt_typeField=='Z'):
        fieldtype=1
        component = 2
    else:
        exit(0)
except:
    fieldtype = 0
    print("Option S by default, if you want to select and option"+
          "type --opt_typeField. Type -h for help.")
reader = vtk.vtkUnstructuredGridReader()
reader.SetFileName(filename)
reader.Update()

# Get the coordinates of nodes in the mesh
nodes_vtk_array= reader.GetOutput().GetPoints().GetData()

#Read the fields you need
FieldImagVTK = reader.GetOutput().GetPointData().GetArray(fieldi)
FieldRealVTK = reader.GetOutput().GetPointData().GetArray(fieldr)

#Get the coordinates of the nodes and their temperatures
nodes_nummpy_array = vtk_to_numpy(nodes_vtk_array)
x,y,z= nodes_nummpy_array[:,0] , nodes_nummpy_array[:,1] , nodes_nummpy_array[:,2]

# Transform the fields into numpy
FieldImagNP = vtk_to_numpy(FieldImagVTK)
FieldRealNP = vtk_to_numpy(FieldRealVTK)

if (fieldtype == 0):
    FieldImag = FieldImagNP[:]
    FieldReal = FieldRealNP[:]
else:
    FieldImag = FieldImagNP[:,component]
    FieldReal = FieldRealNP[:,component]
#veliY = veliNP[:,1]
#velrY = velrNP[:,1]

#Draw contours
npts = 2000
xmin, xmax = min(x), max(x)
ymin, ymax = min(y), max(y)

# define grid
xi = np.linspace(xmin, xmax, npts)
yi = np.linspace(ymin, ymax, npts)
# grid the data
FieldImagD = griddata((x, y), FieldImag, (xi[None,:], yi[:,None]), method='cubic')
#veliYintD = griddata((x, y), veliY, (xi[None,:], yi[:,None]), method='cubic')  
FieldRealD = griddata((x, y), FieldReal, (xi[None,:], yi[:,None]), method='cubic')
#velrYintD = griddata((x, y), velrY, (xi[None,:], yi[:,None]), method='cubic')  

NormDX = np.sqrt(FieldRealD**2+FieldImagD**2)
#NormAX = np.sqrt(veliXint**2+velrXint**2)
#NormDY = np.sqrt(veliYintD**2+velrYintD**2)
#NormAY = np.sqrt(veliYint**2+velrYint**2)
#StructuralS = np.sqrt(NormDX**2+NormDY**2)*np.sqrt(NormAX**2+NormAY**2)

fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
ax1.set_title(r' Imaginary $\hat'+'{'+fieldname+'}'+'(x,y)$', fontsize = 'medium')
ax2.set_title(r'Real $\hat'+'{'+fieldname+'}'+'(x,y)$', fontsize = 'medium')
ax1.set_aspect('equal')
ax2.set_aspect('equal')
CSiL = np.linspace(np.min(FieldRealD), np.max(FieldRealD), 30)
CSrL = np.linspace(np.min(FieldRealD), np.max(FieldRealD), 30)
## CONTOUR: draws the boundaries of the isosurfaces
CSi = ax1.contourf(xi,yi,FieldImagD, levels=CSiL)
CSr = ax2.contourf(xi,yi,FieldRealD, levels=CSrL) 
circ1 = Circle((0, 0), 1, facecolor='w', edgecolor='w', lw=5)
circ2 = Circle((0, 0), 1, facecolor='w', edgecolor='w', lw=5)
ax1.add_patch(circ1)
ax2.add_patch(circ2)
## CONTOUR ANNOTATION: puts a value label
#plt.clabel(CS, inline=1,inline_spacing= 3, fontsize=12, colors='k', use_clabeltext=1)
ax1.set_xlim(-2.0, 70.0)
ax1.set_ylim(-5, 5)
ax2.set_xlim(-2.0, 70.0)
ax2.set_ylim(-5, 5)
plt.colorbar(CSi,ax=ax1) 
plt.colorbar(CSr,ax=ax2) 
plt.show() 
