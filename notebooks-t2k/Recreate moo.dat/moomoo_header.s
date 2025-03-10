; Header for moomoo.s
;.org $4040
.include "jaguar.inc"

init_sound    EQU $000041ba
nt_vbl        EQU $0000425e
pt_mod_init   EQU $000041d6
start_mod     EQU $000045e2
stop_mod      EQU $00004606
playfx2       EQU $00004370
change_volume EQU $000044ea
set_volume    EQU $00004546
nofade        EQU $00004598
fadeup        EQU $000045b2
fadedown      EQU $000045ca
enable_fx     EQU $0000464e
disable_fx    EQU $00004660
resume_dsp    EQU $00004470

INIT_SOUND:
                jmp     (init_sound).l
NT_VBL:
                jmp     (nt_vbl).l
PT_MOD_INIT:
                jmp     (pt_mod_init).l
START_MOD:
                jmp     (start_mod).l
STOP_MOD:
                jmp     (stop_mod).l
PLAYFX2:
                jmp     (playfx2).l
CHANGE_VOLUME:
                jmp     (change_volume).l
SET_VOLUME:
                jmp     (set_volume).l
NOFADE:
                jmp     (nofade).l
FADEUP:
                jmp     (fadeup).l
FADEDOWN:
                jmp     (fadedown).l
ENABLE_FX:
                jmp     (enable_fx).l
DISABLE_FX:
                jmp     (disable_fx).l
CHANGEFX:
                jmp     (disable_fx).l
HALT_DSP:
                jmp     (disable_fx).l
RESUME_DSP:
                jmp     (resume_dsp).l
intmask:        dc.b 0

; Address 0x40A2
return_early:
                rts

; Address 0x40A4
update_interrupt:
                move.w  d0,-(sp)
                bset    #3,(intmask).l
                clr.w   d0
                move.b  (intmask).l,d0
                move.w  d0,(INT1).l ; RW CPU Interrupt Control Register
                move.w  (sp)+,d0
                rts
