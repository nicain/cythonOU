#  cythonOU.pyx 
#  Created by nicain on 5/17/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.

################################################################################
# Preamble: 
################################################################################

# Import floating point division from python 3.0
from __future__ import division

# Import necessary python packages:
import random, uuid
import numpy as np
from math import ceil
cimport numpy as np
cimport cython

# Compile-time type initialization for numpy arrays:
ctypedef np.float_t DTYPE_t	

################################################################################
# Useful C++ functions:
################################################################################

# Wrapper for the RNG:
cdef extern from "MersenneTwister.h":
	ctypedef struct c_MTRand "MTRand":
		double randNorm( double mean, double stddev)
		void seed( unsigned long bigSeed[])

# External math wrapper functions that might be needed:
cdef extern from "math.h":
	float sqrt(float sqrtMe)
	float abs(float absMe)		# Unused in this file, but can't hurt!
	


################################################################################
# OU Process simulator:
################################################################################
@cython.boundscheck(False)
def OUProcess(
			float mu,			# Steady-state mean
			float var,			# Steady-state variance
			float tau,			# Time-constant
			float tMax,			# End time of sim
			float dt,			# Time-step
			float tMin = 0,		# Beginning time of sim
			float XIC = 0):		# Initial condition

	################################################################################
	# Initializations:
	################################################################################	

	# Simple C initializations
	cdef int i						# Array index
	cdef float tau_recip = 1/tau	# Reciprocal of tau,
	cdef int arrayLength = ceil(tMax/dt)			# Compute array length
	
	# RNG initializations:
	cdef unsigned long mySeed[624]		# Seed array for the RNG, length 624
	cdef c_MTRand myTwister				# RNG object construction
	
	# numpy array initializations:
	DTYPE = np.float					# Initialize a data-type for the array
	cdef np.ndarray[DTYPE_t, ndim=1] X = np.zeros(arrayLength, dtype=DTYPE) # 1D array of floats 
	cdef np.ndarray[DTYPE_t, ndim=1] t = np.zeros(arrayLength, dtype=DTYPE) # 1D array of floats
	
	# Initialization of random number generator:
	myUUID = uuid.uuid4()
	random.seed(myUUID.int)
	for i in range(624): mySeed[i] = random.randint(0,2**30) 				
	myTwister.seed(mySeed)

	################################################################################
	# Simulation:
	################################################################################

	# Set up initial conditions:
	t[0] = 0
	t[0] = tMin
	X[0] = XIC

	# Time loop, nice and fast!:
	for i in range(1,arrayLength):
		t[i] = t[i-1]+dt
		X[i] = X[i-1] + dt*(mu - X[i-1])*tau_recip + sqrt(2*var*dt*tau_recip)*myTwister.randNorm(0,1)				

	return t, X