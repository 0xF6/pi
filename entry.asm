.ldx &(0x11) <| $(0x1)
.ldx &(0x18) <| $(0x1)
.ldi &(0x00) <| $(0xC8)

.nop
.orb &(0x1)
.val @float_t(0.0)
.pull &(0x2)
.orb &(0x1)
.val @float_t(-1.0)
.pull &(0x3)

.ref.t &(0xA)

.inc &(0x1)

.dup &(0x1) &(0x5)
.inc &(0x5)
.pow &(0x5) &(0x3) &(0x4)

.dup &(0x1) &(0x6)
.ldx &(0x4) <| $(0x2)
.mul &(0x6) &(0x4) &(0x6)
.dec &(0x6)

.div &(0x4) &(0x5) &(0x6)
.swap &(0x4) &(0x9)
.ckft &(0x9)

.jump.u &(0xA) ~- &(0x0) &(0x1)

.prune
.locals init #(
    [0x0] u32
)
;.page &(0x9)
.call.i !{sys->write(u32)}
.halt
