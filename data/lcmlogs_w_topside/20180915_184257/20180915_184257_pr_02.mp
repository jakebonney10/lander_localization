#all depths and velocities are positive
GLOBAL
  mis_timeout 06:00:00              # sec or min:sec or hr:min:sec 
  bottom_time 00:05:00           # sec or min:sec or hr:min:sec 
  max_depth 4500                      # positive meters
  enable_battery_abort 1            # (0) no (1) yes
  battery_cutoff 20                 # percent capacity
  enable_ctd_abort 1                # (0) no (1) yes
  latitude 18.85                       #latitude in decimal degrees
ENDGLOBAL


BOTTLE
  number 1
  trigger DEPTH
  value RECOVERY
  state RECOVERY
ENDBOTTLE

BOTTLE
  number 2
  trigger DEPTH
  value RECOVERY
  state RECOVERY
ENDBOTTLE
  
BOTTLE
  number 3
  trigger OXYGEN
  value MIN
  state UP
ENDBOTTLE
  
BOTTLE
  number 4
  trigger OXYGEN
  value MIN
  state UP
ENDBOTTLE
  
BOTTLE
  number 5
  trigger TEMPERATURE
  value GRADIENT
  state UP
ENDBOTTLE
  
BOTTLE
  number 6
  trigger TEMPERATURE
  value GRADIENT
  state UP
ENDBOTTLE

BOTTLE
  number 7
  trigger DEPTH
  value 1000
  state UP
ENDBOTTLE

BOTTLE
  number 8
  trigger DEPTH
  value 1000
  state UP
ENDBOTTLE

BOTTLE
  number 9
  trigger DEPTH
  value 1500
  state UP
ENDBOTTLE

BOTTLE
  number 10
  trigger DEPTH
  value 1500
  state UP
ENDBOTTLE

BOTTLE
  number 11
  trigger DEPTH
  value 2000
  state UP
ENDBOTTLE

BOTTLE
  number 12
  trigger DEPTH
  value 2000
  state UP
ENDBOTTLE

BOTTLE 
  number 13
  trigger DEPTH
  value 2500
  state UP
ENDBOTTLE

BOTTLE
  number 14
  trigger DEPTH
  value 2500
  state UP
ENDBOTTLE

BOTTLE
  number 15
  trigger DEPTH
  value 3000
  state UP
ENDBOTTLE

BOTTLE
  number 16
  trigger DEPTH
  value 3000
  state UP
ENDBOTTLE

BOTTLE
  number 17
  trigger DEPTH
  value 3250
  state UP
ENDBOTTLE

BOTTLE
  number 18
  trigger DEPTH
  value 3250
  state UP
ENDBOTTLE

BOTTLE
  number 19
  trigger DEPTH
  value 3500
  state UP
ENDBOTTLE

BOTTLE
  number 20
  trigger DEPTH
  value 3500
  state UP
ENDBOTTLE

BOTTLE
  number 21
  trigger DEPTH
  value 3750
  state UP
ENDBOTTLE

BOTTLE
  number 22
  trigger DEPTH
  value 3750
  state UP
ENDBOTTLE

BOTTLE
  number 23
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE

BOTTLE
  number 24
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE
