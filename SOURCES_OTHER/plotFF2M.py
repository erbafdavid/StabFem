from SFGraphics import SF_Graphics
import argparse

# TODO: ADD options to save and organise the script of FreeFEM to plot in VTK 
# and ff2m if you order to and to select the plotting option
# Select to do a single plot of few plots (we could extend this file to a class
# and select few members of the class)

# Instantiate the parser

parser = argparse.ArgumentParser(description='App to plot eigenmodes',
                                 prefix_chars='@')

# Required positional argument
parser.add_argument('path', type=str,
                    help='The path of the file to be plotted')

# Optional positional argument
parser.add_argument('file', type=str, nargs='?',
                    help='The name of the file')

# Optional argument
parser.add_argument('@@type_format', type=str,
                    help='The name of the format of the file to be represented')

# Optional argument
parser.add_argument('@@type_plot', type=str,
                    help='The name of the plot to be done, line, contour')

# Optional argument
parser.add_argument('@@opt_field', type=str,
                    help='The name of the field to be plotted')

# Optional argument
parser.add_argument('@@opt_field2', type=str,
                    help='The name of the field 2 to be plotted')

parser.add_argument('@@twoFields', type=str,
                    help='Either plot a single field or two fields shown symmetric' \
                    'with respect to y axis')

parser.add_argument('@@opt_typeField', type=str,
                    help='Select the variable to be represented')

parser.add_argument('@@opt_typeField2', type=str,
                    help='Select the variable to be represented')


# Optional argument
parser.add_argument('@@type_complex', type=str,
                    help='The name of complex field, real or imag')

parser.add_argument('@@xlim', type=str,
                    help='The x-limit of the plot')

parser.add_argument('@@ylim', type=str,
                    help='The y-limit of the plot')

parser.add_argument('@@title', type=str,
                    help='The title of the plot')

parser.add_argument('@@yloc', type=list,
                    help='The location of the plot')

# Optional argument
parser.add_argument('@@cmap', type=str,
                    help='The colormap option of the plot: viridis, plasma'+
                    'inferno,cool,hot, RdYlBlu, Spectral, jet, rainbow')
# Optional argument
parser.add_argument('@@mirror', type=str,
                    help='For symmetric solutions, the other half is mirrored')

parser.add_argument('@@name', type=str,
                    help='The name of the file to be saved the plot')

parser.add_argument('@@saveOption', type=str,
                    help='The option to save the plot in a pdf file')


# Parsing arguments
args = parser.parse_args()

filename = args.path+args.file
options = {}

try:
    options['TypePlot'] = args.type_plot
except:
    options['TypePlot'] = 'contour'
    print("No option TypePlot selected")
    
try:
    formatPlot = args.type_format
except:
    print("No format selected FF2M by default")
    formatPlot = 'ff2m'
    
try:
    options['TypeField'] = args.opt_typeField
except:
    print("No option TypeField selected")
    
try:
    if(args.twoFields == '1'):
        options['twoFields'] = True
    else:
        options['twoFields'] = False
except:
    print("No option twoFields selected")
    

try:
    options['Field'] = args.opt_field
except:
    print("No option field selected")
    
try:
    options['complex'] = args.type_complex
except:
    print("No option complex selected")
    
try:
    inputvalue = args.xlim
    inputlist = list(inputvalue.split(','))
    inputlist = [float(x) for x in inputlist]
    options['xlim'] = inputlist
except:
    print("No option xlim selected")
    
try:
    inputvalue = args.ylim
    inputlist = list(inputvalue.split(','))
    inputlist = [float(x) for x in inputlist]
    options['ylim'] = inputlist
except:
    print("No option ylim selected")
    
try:
    options['name'] = args.name
except:
    print("No option name selected")    
        
try:
    options['title'] = args.title
except:
    print("No option ylim selected")
    
try:
    options['cmap'] = args.cmap
except:
    print("No option cmap selected")

try:
    if(args.saveOption == '1'):
        options['saveOption'] = True
    else:
        options['saveOption'] = False
except:
    print("No option saveOption selected")
    
try:
    if(args.mirror == '1'):
        options['mirror'] = True
    else:
        options['mirror'] = False
except:
    print("No option twoFields selected")

try:
    options['yloc'] = args.yloc
except:
    print("No option yloc selected")   

plot = SF_Graphics(formatPlot)
plot.FF2MReader(filename, **options)
if(options['twoFields'] == True):
    try:
        options['TypeField'] = args.opt_typeField2
    except:
        print("No option TypeField selected")
    try:
        options['Field'] = args.opt_field2
    except:
        print("No option field selected")
    plot.FF2MReader(filename, **options)
plot.PlotPlt(**options)

