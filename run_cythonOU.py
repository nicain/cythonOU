#
#  run_cythonOU.py 
#  cythonOU
#
#  Created by nicain on 5/18/10.
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#

################################################################################
# Preamble:
################################################################################

# Import necessary packages:
from subprocess import call as call

# Compile cython extension cythonOU.pyx:
call('python setup.py build_ext --inplace', shell=True)

# Import cython extension:
from cythonOU import OUProcess

################################################################################
# Call the main function, as an example:
################################################################################

# Settings
mu = 1
var = 5
tau = .5
tMax = 1
dt = .01

# Call the function:
t, X =  OUProcess(mu, var, tau, tMax, dt)

# Print results:
print t, X