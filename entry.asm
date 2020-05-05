;         MIT License
;  Copyright (c) 2020 Yuuki Wesp
;
;     Leibniz formula for π
#{
    ~label 'step' 0x9
    ~label 'float_mode' 0x18
    ~label 'trace' 0x11
    ~label 'maxStep' 0x0
    ~label 'term' 0x1
    ~label 'write' 0x5
    ~label 'pi' 0x2
    ~label 'temp1' 0x3
    ~label 'temp2' 0x4
}
.ldx &(![~trace])      <| $(0x0)
.ldx &(![~float_mode]) <| $(0x1)  ; force set float mode 
.ldi &(![~maxStep])    <| $(0xC3) ; 195 step for recalculation
.ldi &(![~step]) <| $(0x0) ; var step = 0;
.orb &(0x1)
.val @float_t(0.0) ; load into stack 0.0 and set value to ~pi variable
.pull &(![~pi]) 
.orb &(0x1)
.val @float_t(-1.0)
.pull &(![~temp1])
.ref.t &(0xA) ; set start point for cycle
.ldx &(![~float_mode]) <| $(0x0) ; need call inc without float mode
.inc &(![~step]) ; step count ++
.ldx &(![~float_mode]) <| $(0x1)
.inc &(0x1)
.dup &(0x1) &(0x5)
.inc &(0x5)
.pow &(0x5) &(![~temp1]) &(0x5)
.dup &(0x1) &(0x6)
.orb &(0x1)
.val @float_t(2.0)
.pull &(![~temp2])
.mul &(0x6) &(![~temp2]) &(0x6)
.dec &(0x6)
.div &(![~temp2]) &(0x5) &(0x6)
.swap &(![~temp2]) &(0x8)
.ckft &(0x8) ; if result is not infinity
.add &(![~pi]) &(![~pi]) &(0x8)
.jump.g &(0xA) ~- &(![~maxStep]) &(![~step]) ; if (step < maxStep) goto start point
.orb &(0x1)
.val @float_t(4.0) ; load multiplier
.pull &(0x1)
.mul &(![~pi]) &(![~pi]) &(0x1) ;  pi = (raw_pi * 4)
.mva &(![~term]) &(![~write]) <| $(0xA) ; print \n
.mvx &(![~term]) &(![~write]) |> &(![~pi]) ; print result from 0x2 cell