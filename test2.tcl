wipe

initialize

puts "#### RC Frame Gravity Analysis ####"

set width    360
set height   144

# Create nodes
#    tag        X       Y 
node  1       0.0     0.0 
node  2    $width     0.0 
node  3       0.0 $height
node  4    $width $height

puts "node 4 coordinates: [node 4]"