################################################################################
# Basic Truss Example 
# Reference : https://opensees.berkeley.edu/wiki/index.php/Basic_Truss_Example
# Units: kip, inch
################################################################################

################################################################################
# SET UP OF WORKSPACE
################################################################################

    wipe

    

# Define model builder
# http://opensees.berkeley.edu/wiki/index.php/Model_command
#   model BasicBuilder -ndm $ndm <-ndf $ndf>
    model basic -ndm 2 -ndf 3; #ndm: spatial dimension; ndf: DoF per node
                       #2 dimensions, 3 DOF per node


################################################################################
# GLOBAL GEOMETRY
################################################################################

#Set paramter for overall geometry
    set width   360
    set height  144
    
# Create nodes
# ------------
# Create nodes & add to Domain - command: node nodeId xCrd yCrd
#   node    tag     Xcoord  Ycoord
    node    1       0.0     0.0         
    node    2       $width  0.0           
    node    3       0.0     $height  
    node    4       $width  $height  

################################################################################
# RESTRAINTS
################################################################################

#fix $nodeTag (ndf $constrValues [horizontal;vertical;rotation])   
    fix     1       1 1 1
    fix     2       1 1 1
    
################################################################################
# MATERIALS
################################################################################

# Define materials for nonlinear columns 

# Core Concrete
# Concrete                      tag     fc'     ec0     f'cu        ecu
   uniaxialMaterial Concrete01  1       -6.0    -0.004  -5.0        -0.014

# Concrete cover
# Concrete                      tag     fc'     ec0     f'cu        ecu
   uniaxialMaterial Concrete02  2       -5.0    -0.002  0.0        -0.006

# Reinforcing Steel
# Steel                         tag     fy     E0       b
   uniaxialMaterial Steel01     3       60.0   3000.0   0.01   

################################################################################
# CROSS SECTION 
################################################################################

# set some parameters for cross section 
    set colWidth    15
    set colDepth    24

    set cover       1.5

    set As     0.60;    #area of no.7 bar

# some variables derived from the parameters
    set y1 [expr $colWidth/2.0]
    set z1 [expr $colDepth/2.0]

    section Fiber 1{
        # Create concrete core fiber
        # patch rect (for rectangular)  $materalTag $numberOfSubDivisionY $numberOfSubDivisionZ $yI $zI $yJ $zJ
        patch rect 1 10 1 [expr $cover-$y1] [expr $cover-$z1] [expr $y1-$cover] [expr $z1-$cover]

        #Create the concrete cover fibers (top, bottom, left, right)
        # patch rect (for rectangular)  $materalTag $numberOfSubDivisionY $numberOfSubDivisionZ $yI $zI $yJ $zJ
        patch rect 2 10 1  [expr -$y1] [expr $z1-$cover] $y1 $z1
        patch rect 2 10 1  [expr -$y1] [expr -$z1] $y1 [expr $cover-$z1]
        patch rect 2  2 1  [expr -$y1] [expr $cover-$z1] [expr $cover-$y1] [expr $z1-$cover]
        patch rect 2  2 1  [expr $y1-$cover] [expr $cover-$z1] $y1 [expr $z1-$cover]

        #Create the reinforcingf fibers (left, middle, right)
        # Layer straight/circ $materialTag $numFiber $areaFiber $yStart $zStart $yEnd $zEnd
        layer straight 3 3 $As [expr $y1-$cover] [expr $z1-$cover] [expr $y1-$cover][expr $cover-$z1]
        layer straight 3 2 $As 0.0 [expr $z1-$cover] 0.0 [expr $cover-$z1]
        layer straight 3 3 $As [expr $cover-$y1] [expr $z1-$cover] [expr $cover-$y1][expr $cover-$z1]
    }

################################################################################
# ELEMENT 
################################################################################ 

# Define column element 
    # Geometry of column elements 
        geomTransf Linear 1

# Set variables for element assignment
    # Number of integration points along length of element
        set np 5
        
    # Element type 
        set  eleType forceBeamColumn; #forceBeamColumn or dispBeamColumn will work

# Assign column element 
        #                   tag ndI ndJ nsecs   secTag  transfTag 
        element $eleType    1   1   3   $np     1       1
        element $eleType    2   2   4   $np     1       1

# Define beam element 
        # Geometry of beam element
        geomTransf Linear 2 

# Assign beam element 
        #                           tag ndI ndJ Area    EMod    Iz  transfTag
        element ElasticBeamColumn   3   3   4   360     4030    8640    2


################################################################################
# LOADS DEFINITION
################################################################################ 

# Set a parameter for the axial load
    set P 180;      #10% of the axial capacity of the column

# create a Linear TimeSeries with a tag of 1
    timeSeries Linear 1
    
    pattern Plain 1 1 {
    
       # Create the nodal load - command: load nodeID xForce yForce zMoment 
       load 3 0.0   [expr -$P]  0.0
       load 4 0.0   [expr -$P]  0.0

       # FYI : load $nodeTag (ndf $LoadValues) ndf is number of DOF input above
       # ndf = 3; input will be xForce yForce zMoment 
       # ndf = 6; input - xForce yForce zForce xMoment yMoment zMoment
    }

################################################################################
# START ANALYSIS
################################################################################ 

initialize

puts "#### RC Frame Gravity Analysis ####"

################################################################################
# ANALYSIS OPTION
################################################################################ 

# Create the system of equation
system BandGeneral

# Create the DOF numberer, the reverse Cuthill-McKee algorithm
numberer RCM

# Create the constraint handler, a Plain handler is used as homo constraints
constraints Transformation

# Create the convergence test, the norm of the residual with a tolerance of 
# 1e-12 and a max number of iterations of 10
test NormDispIncr 1.0e-12  10 3
 

# Create the integration scheme, the LoadControl scheme using steps of 0.1
integrator LoadControl 0.1

# Create the solution algorithm, a Linear algorithm is created
algorithm Newton

# create the analysis object 
analysis Static 

################################################################################
# PERFORM THE ANALYSIS
################################################################################ 

# This command is used to perform the analysis : analyze numOfSteps
    analyze 10

################################################################################
# OUTPUT SPECIFICATION
################################################################################    

#no recorder is set up for this model 

# Node Recorder "Reactions":    fileName    <nodeTag>    dof    respType 
# create a Recorder object for the nodal displacements at node 4


# Create a recorder for element forces, one in global and the other local system


################################################################################
# PRINT-OUT TO TERMINAL 
################################################################################    

# print out the state of node 3 and 4
#print node 3 4

# print out the state of element 1
#print ele 1


puts "node 4 displacement: [nodeDisp 4]"