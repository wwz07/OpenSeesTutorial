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
    model BasicBuilder -ndm 2 -ndf 3; #ndm: spatial dimension; ndf: DoF per node
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
    node    2       $width  0
    node    3       0.0     $height
    node    4       $width  $height

################################################################################
# RESTRAINTS
################################################################################

#fix $nodeTag (ndf $constrValues [horizontal;vertical;rotation])   
    fix     1       1 1 1;
    fix     2       1 1 1;
    
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
    set colDepth   24

    set cover       1.5

    set As     0.60;    #area of no.7 bar

$ some variables derived from the parameters
    set y1 [expr $colWidth/2.0]
    set x1 [expr $colDepth/2.0]

################################################################################
# LOADS DEFINITION
################################################################################ 

# create a Linear TimeSeries with a tag of 1
timeSeries Linear 1

pattern Plain 1 1 {
	
   # Create the nodal load - command: load nodeID xForce yForce
   load 4 100 -50
}

################################################################################
# START ANALYSIS
################################################################################ 

initialize

puts "#### BASIC TRUSS EXAMPLE : NODAL LOAD ANALYSIS ####"

################################################################################
# ANALYSIS OPTION
################################################################################ 

# Create the system of equation
system FullGeneral

# Create the DOF numberer, the reverse Cuthill-McKee algorithm
numberer RCM

# Create the constraint handler, a Plain handler is used as homo constraints
constraints Plain


# Create the integration scheme, the LoadControl scheme using steps of 1.0
integrator LoadControl 1.0

# Create the solution algorithm, a Linear algorithm is created
algorithm Linear

# create the analysis object 
analysis Static 

################################################################################
# PERFORM THE ANALYSIS
################################################################################ 

# This command is used to perform the analysis : analyze numOfSteps
    analyze 1

################################################################################
# OUTPUT SPECIFICATION
################################################################################    

# Node Recorder "Reactions":    fileName    <nodeTag>    dof    respType 
# create a Recorder object for the nodal displacements at node 4
recorder Node -file node.out -time -node 4 -dof 1 2 disp
recorder Node -file node.out -time -node 1 -dof 1 2 reaction
recorder Node -file node.out -time -node 2 -dof 1 2 reaction
recorder Node -file node.out -time -node 3 -dof 1 2 reaction

# Create a recorder for element forces, one in global and the other local system
recorder Element -file eleGlobal.out -time -ele 1 2 3 forces
recorder Element -file eleLocal.out -time -ele 1 2 3  basicForces

################################################################################
# PRINT-OUT TO TERMINAL 
################################################################################    

puts "node 4 displacement: [nodeDisp 4]"
print -node 1 2 3 4
print -ele
