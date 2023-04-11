# lander_localization
Particle filter localization of a full ocean depth autonomous surveyor.

## Background

<img align="right" width="35%" src="/lander.jpg">

The Deep Autonomous Profiler (DAP, also known as ‘lander’) is a rigid body oceanographic instrument that
surveys the entire water column by taking in-situ measurements. Deployment consists of dropping the lander off
the side of a research vessel (R/V) and allowing it to free fall (with the help of 300lbs of weight) to the bottom
of the ocean. The lander rests on the seafloor for a pre-determined duration before detaching from the weights
and floating upwards to the surface. During descent, resting at the bottom, and ascent, the lander samples the
water column using a CTD-rosette (conductivity, temperature, and depth sensor). The lander has no self-
propulsion, depends on buoyancy for operation, and is subject to environmental effects (namely ocean currents).
Upon surfacing, the lander’s satellite beacons email GPS coordinates to topside operations.

## Problem

The lander operates fully autonomously, leaving the topside operators with deficient information regarding the
lander’s exact location. This poses an issue when the lander surfaces; collision between an ascending lander and
the research vessel’s hull would cause damage to both systems. This is trivially solved by driving the R/V far
away from the lander’s positions, however, time is of the essence when at sea which makes this option
expensive.

## Approach

Topside can ping the lander with an acoustic ranging system, providing range measurements from the ship to
the lander. The R/V traverses locally during deployment and maintains a stream of GPS coordinates.
Additionally, a constant descent/bottom/ascent velocity of the lander (z direction) can be estimated based on
buoyancy calculations. It is proposed to use a particle filter to localize the lander during deployment to provide
an accurate in-situ position estimate. Post processed lander depth data and surface position GPS beacon pings
can be used to ground truth the particle filter solution.

## Mathematical Formulation



### Coordinate System

* Z is positive going down. Z = 0m at the ocean surface.

### Knowns

* Approximate ocean depth (from ship sonar systems).
* Sound speed profile.
* Occasional range measurements (distance) from topside to lander during operation.
* GPS coordinates of ship during operation.

### States

The states of interest are as follows: [X Y Z U V W BottomTime Mode]
* XYZ position = in xyz dimension
* UVW velocity = in xyz dimension
* BottomTime = starts counting when particles in mode [bottom 1], otherwise set to null
* Mode = mutually exclusive operation states [descent 0], [bottom 1], [ascent 2], [surface 3]

### Particle Initialization

* X = X_surface_dropoff + position_std_dev
* Y = Y_surface_dropoff + position_std_dev
* Z = 5;
* U = 0 + velocity_std_dev
* V = 0 + velocity_std_dev
* W = avg_descent_veloc + descent_std_dev
* Mode = [descent 0]
* BottomTime = null

### Particle Updates

* X += U*dt
* Y += V*dt
* Z += W*dt
* U += noise
* V += noise
* W += noise, but will have conditional statements based on mode
* Mode = changes based on probabilities set for certain conditions occurring (e.g. if depth = 10000,
probably on the bottom)
* BottomTime += dt [if mode = ‘ascent’ 1], else += 0

### Weights and Particle Culling

* Take a measurement, Rm = range from topside to lander (purely a distance w/ no direction)
* Correct range based on sound profile, still call it Rm
* Calculate expected range between topside and particles
* R = sqrt[ Z^2 + (X^2 – ship_x)^2 + (Y^2 – ship_y)^2 ]
* Probabilistically compare Rm and R and assign confidence value
* Kill particles that are of low confidence
* Spawn new particles on top of the most confident particles and allow noise to drift them

## Acknowledgements
Researchers that contributed to this codebase include: Jake Bonney, Phil Parisi, and Dave Casagrande. Thanks to François Beauducel for the lat/lon UTM matlab conversion function and to the creators of the gsw toolbox for ocean acoustics.

François Beauducel (2023). LL2UTM and UTM2LL (https://www.mathworks.com/matlabcentral/fileexchange/45699-ll2utm-and-utm2ll), MATLAB Central File Exchange. Retrieved April 11, 2023.

Copyright (c) 2011, SCOR/IAPSO WG127 (Scientific Committee on Oceanic Research/ International Association for the Physical Sciences of the Oceans, Working Group 127).