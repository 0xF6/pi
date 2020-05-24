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

;;
; vm.trace = true;
; var maxStep = 4;
; var temp1 = 18;
; maxStep *= temp1;
;
; vm.floatMode = true;
; var step = 0;
; var pi = 0.0f;
; temp1 = -1.0f;
;;
.sig @init(void) -> void
    .ldx &(![~trace])      <| $(0x0)
    .ldi &(![~maxStep])    <| $(0x4) ; 195 step for recalculation
    .ldx &(![~temp1])      <| $(0x12)
    .mul &(![~maxStep])    <| &(![~maxStep]) &(![~temp1])

    ; force set float mode 
    .ldx &(![~float_mode]) <| $(0x1)  
    .ldi &(![~step]) <| $(0x0) 
    .orb &(0x1)
    .val @float_t(0.0) 
    .pull &(![~pi]) 
    .orb &(0x1)
    .val @float_t(-1.0)
    .pull &(![~temp1])
.ret

;;
; vm.floatMode = false;
; step++;
; vm.floatMode = true;
;; 
.sig @inc(void) -> void
    .ldx &(![~float_mode]) <| $(0x0) ; need call inc without float mode
    .inc &(![~step]) ; step count ++
    .ldx &(![~float_mode]) <| $(0x1)
.ret

;;
; label1:
;   inc();
;   vm.cells[0x1]++;
;   vm.cells[0x1] = vm.cells[0x5];
;   vm.cells[0x5]++
;   vm.cells[0x5] = pow(temp1, vm.cells[0x5])
;   vm.cells[0x1] = vm.cells[0x6];
;   var temp2 = 2.0;
;   vm.cells[0x6] *= temp2;
;   vm.cells[0x6]--;
;   temp2 = vm.cells[0x5] / vm.cells[0x6];
;   swap(temp2, vm.cells[0x8])
;   if(!float.IsFinity(vm.cells[0x8] as float))
;       shutdownVM();
;   pi += vm.cells[0x8];
;   if(maxStep < step)
;       goto label1;
;;
.sig @calculate(void) -> void
    .ref.t &(0xA) ; set start point for cycle
    .call.i !{inc()}
    .inc &(0x1)
    .dup &(0x1) &(0x5)
    .inc &(0x5)
    .pow &(0x5) <| &(![~temp1]) &(0x5)
    .dup &(0x1) &(0x6)
    .orb &(0x1)
    .val @float_t(2.0)
    .pull &(![~temp2])
    .mul &(0x6) <| &(![~temp2]) &(0x6)
    .dec &(0x6)
    .div &(![~temp2]) <| &(0x5) &(0x6)
    .swap &(![~temp2]) &(0x8)
    .ckft &(0x8) ; if result is not infinity
    .add &(![~pi]) <| &(![~pi]) &(0x8)
    .mvx &(![~term]) &(![~write]) |> &(![~pi])
    .jump.g &(0xA) ~- &(![~maxStep]) &(![~step]) ; if (step < maxStep) goto start point
.ret


.call.i !{init()}
.call.i !{calculate()}


;.neq &(0x11) <| &(![~maxStep]) &(![~step])
;.jump.x &(0xA) ~- &(0x11)
.orb &(0x1)
.val @float_t(4.0) ; load multiplier
.pull &(0x1)
.mul &(![~pi]) <| &(![~pi]) &(0x1) ;  pi = (raw_pi * 4)
.mva &(![~term]) &(![~write]) <| $(0xA) ; print \n
.mvx &(![~term]) &(![~write]) |> &(![~pi]) ; print result from 0x2 cell
.halt