#all depths and velocities are positive
GLOBAL
  mis_timeout 17:00:00              # sec or min:sec or hr:min:sec 
  bottom_time 12:00:00           # sec or min:sec or hr:min:sec 
  max_depth 8600                      # positive meters
  enable_battery_abort 1            # (0) no (1) yes
  battery_cutoff 20                 # percent capacity
  enable_ctd_abort 1                # (0) no (1) yes
  latitude 19.75                       #latitude in decimal degrees
ENDGLOBAL


BOTTLE
  number 1
  trigger DEPTH
  value 8500
  state UP
ENDBOTTLE

BOTTLE
  number 2
  trigger DEPTH
  value 8500
  state UP
ENDBOTTLE
  
BOTTLE
  number 3
  trigger DEPTH
  value 8300
  state UP
ENDBOTTLE
  
BOTTLE
  number 4
  trigger DEPTH
  value 8300
  state UP
ENDBOTTLE
  
BOTTLE
  number 5
  trigger DEPTH
  value 8200
  state UP
ENDBOTTLE
  
BOTTLE
  number 6
  trigger DEPTH
  value 8100
  state UP
ENDBOTTLE

BOTTLE
  number 7
  trigger DEPTH
  value 8000
  state UP
ENDBOTTLE

BOTTLE
  number 8
  trigger DEPTH
  value 7500
  state UP
ENDBOTTLE

BOTTLE
  number 9
  trigger DEPTH
  value 7000
  state UP
ENDBOTTLE

BOTTLE
  number 10
  trigger DEPTH
  value 6000
  state UP
ENDBOTTLE

BOTTLE 
  number 13
  trigger DEPTH
  value 5000
  state UP
ENDBOTTLE

BOTTLE
  number 14
  trigger DEPTH
  value 4500
  state UP
ENDBOTTLE

BOTTLE
  number 15
  trigger DEPTH
  value 4000
  state UP
ENDBOTTLE

BOTTLE
  number 16
  trigger DEPTH
  value 3500
  state UP
ENDBOTTLE

BOTTLE
  number 17
  trigger DEPTH
  value 3000
  state UP
ENDBOTTLE

BOTTLE
  number 18
  trigger DEPTH
  value 2000
  state UP
ENDBOTTLE

BOTTLE
  number 19
  trigger DEPTH
  value 1000
  state UP
ENDBOTTLE

BOTTLE
  number 20
  trigger OXYGEN
  value MAX
  state UP
  range [MIDDLE,BOTTOM]
ENDBOTTLE

BOTTLE
  number 21
  trigger OXYGEN
  value MAX
  state UP
  range [SURFACE,MIDDLE]
ENDBOTTLE

BOTTLE
  number 22
  trigger DEPTH
  value 500
  state UP
ENDBOTTLE

BOTTLE
  number 101
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE

BOTTLE
  number 102
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE
