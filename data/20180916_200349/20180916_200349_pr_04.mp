#all depths and velocities are positive
GLOBAL
  mis_timeout 16:00:00              # sec or min:sec or hr:min:sec 
  bottom_time 13:20:00           # sec or min:sec or hr:min:sec 
  max_depth 6200                      # positive meters
  enable_battery_abort 1            # (0) no (1) yes
  battery_cutoff 20                 # percent capacity
  enable_ctd_abort 1                # (0) no (1) yes
  latitude 19.5                       #latitude in decimal degrees
ENDGLOBAL


BOTTLE
  number 1
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE

BOTTLE
  number 2
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE
  
BOTTLE
  number 3
  trigger DEPTH
  value BOTTOM
  state BOTTOM
ENDBOTTLE
  
BOTTLE
  number 4
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 5:00
ENDBOTTLE
  
BOTTLE
  number 5
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 15:00
ENDBOTTLE
  
BOTTLE
  number 6
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 30:00
ENDBOTTLE

BOTTLE
  number 7
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 1:00:00
ENDBOTTLE

BOTTLE
  number 8
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 2:00:00
ENDBOTTLE

BOTTLE
  number 9
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 5:00:00
ENDBOTTLE

BOTTLE
  number 10
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 7:00:00
ENDBOTTLE

BOTTLE 
  number 13
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 7:00:00
ENDBOTTLE

BOTTLE
  number 14
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 10:00:00
ENDBOTTLE

BOTTLE
  number 15
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 10:00:00
ENDBOTTLE

BOTTLE
  number 16
  trigger DEPTH
  value BOTTOM
  state BOTTOM
  delay 13:00:00
ENDBOTTLE

BOTTLE
  number 17
  trigger DEPTH
  value 6500
  state UP
ENDBOTTLE

BOTTLE
  number 18
  trigger DEPTH
  value 6500
  state UP
ENDBOTTLE

BOTTLE
  number 19
  trigger DEPTH
  value 5500
  state UP
ENDBOTTLE

BOTTLE
  number 20
  trigger DEPTH
  value 5500
  state UP
ENDBOTTLE

BOTTLE
  number 21
  trigger DEPTH
  value 5000
  state UP
ENDBOTTLE

BOTTLE
  number 22
  trigger DEPTH
  value 5000
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
