#all depths and velocities are positive
GLOBAL
  mis_timeout 02:00:00              # sec or min:sec or hr:min:sec 
  bottom_time 00:01:00           # sec or min:sec or hr:min:sec 
  max_depth 250                      # positive meters
  enable_battery_abort 1            # (0) no (1) yes
  battery_cutoff 20                 # percent capacity
  enable_ctd_abort 1                # (0) no (1) yes
  latitude 18.5                       #latitude in decimal degrees
ENDGLOBAL


BOTTLE
  number -1
  trigger DEPTH
  value LAUNCH
  state LAUNCH
ENDBOTTLE


