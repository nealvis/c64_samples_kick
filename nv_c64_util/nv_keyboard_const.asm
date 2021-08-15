
#importonce

// For all the colX_tables below when there is no reasonable 
// value to poke to the screen (or when i haven't looked up
// the right value yet) for the corresponding key, 
// the table byte will be $40 which is just a grid pattern
.const NV_KEY_UNINITIALIZED = $A0
.const NV_KEY_A = $01
.const NV_KEY_B = $02
.const NV_KEY_C = $03
.const NV_KEY_D = $04
.const NV_KEY_E = $05
.const NV_KEY_F = $06
.const NV_KEY_G = $07
.const NV_KEY_H = $08
.const NV_KEY_I = $09
.const NV_KEY_J = $0A
.const NV_KEY_K = $0B
.const NV_KEY_L = $0C
.const NV_KEY_M = $0D
.const NV_KEY_N = $0E
.const NV_KEY_O = $0F
.const NV_KEY_P = $10
.const NV_KEY_Q = $11
.const NV_KEY_R = $12
.const NV_KEY_S = $13
.const NV_KEY_T = $14
.const NV_KEY_U = $15
.const NV_KEY_V = $16
.const NV_KEY_W = $17
.const NV_KEY_X = $18
.const NV_KEY_Y = $19
.const NV_KEY_Z = $1A

.const NV_KEY_0 = $30
.const NV_KEY_1 = $31
.const NV_KEY_2 = $32
.const NV_KEY_3 = $33
.const NV_KEY_4 = $34
.const NV_KEY_5 = $35
.const NV_KEY_6 = $36
.const NV_KEY_7 = $37
.const NV_KEY_8 = $38
.const NV_KEY_9 = $39

.const NV_KEY_COMMA = $2C
.const NV_KEY_PERIOD = $2E
.const NV_KEY_SPACE = $20   
.const NV_KEY_NO_KEY = $40  // Special value for no key
.const NOKEY = NV_KEY_NO_KEY
