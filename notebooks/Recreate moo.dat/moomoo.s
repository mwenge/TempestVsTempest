; ===========================================================================
.include "jaguar.inc"
.include "syn6.inc"

                jmp     (INIT_SOUND).l
                jmp     (NT_VBL).L
                jmp     (PT_MOD_I).l
                jmp     (START_MOD).L
                jmp     (STOP_MOD).L
                jmp     (PLAYFX2).L
                jmp     (CHANGE_VOL).l
                jmp     (SET_VOLUME).l
                jmp     (NOFADE).L
                jmp     (FADEUP).L
                jmp     (FADEDOWN).L
                jmp     (ENABLE_FX).L
                jmp     (DISABLE_FX).l
                jmp     (DISABLE_FX).l
                jmp     (DISABLE_FX).l
                jmp     (CHANGEFX).l

intmask:        dc.w 0

return_early:
                rts

update_interrupt:
                move.w  d0,-(sp)
                bset    #3,(intmask).l
                clr.w   d0
                move.b  (intmask).l,d0
                move.w  d0,($F000E0).l
                move.w  (sp)+,d0
                rts

copyright_info:dc.b 'Copyright (1993) Imagitec Design, Inc '
; ---------------------------------------------------------------------------
; INITDSP:
; ---------------------------------------------------------------------------
INITDSP:
                movem.l d0-d7/a0-a6,-(sp)
                move.l  #0,(D_CTRL).l
                move.l  #0,(D_FLAGS).l
                movea.l #DSPORG,a1
                movea.l #$5ED4,a0
                move.l  a0,d0
                move.l  #$6238,d1
                sub.l   d0,d1
                lsr.l   #2,d1

COPYLOOP:
                move.l  (a0)+,(a1)+
                dbf     d1,COPYLOOP
                movea.l #TABLESTA,a0
                jsr     (MAKESAMV).l
                jsr     (MAKESAMV).l
                jsr     (MAKESAMV).l
                jsr     (MAKESAMV).l
                jsr     (MAKESAMV).l
                jsr     (MAKESAMV).l
                move.l  #$1B,(SCLK).l
                move.l  #$15,(SMODE).l
                move.l  #DSPORG,(D_PC).l
                move.l  #1,(D_CTRL).l
                movem.l (sp)+,d0-d7/a0-a6
                rts


MAKESAMV:
                move.l  #$FFFFFFFC,(a0)+ 
                move.l  #$4000,(a0)+
                clr.l   d0
                move.l  d0,(a0)+
                move.l  d0,(a0)+
                move.l  d0,(a0)+
                move.l  d0,(a0)+
                move.l  d0,(a0)+
                move.l  d0,(a0)+
                rts

aImagitecDesign:dc.b 'Imagitec Design,Inc ',$BD,' 1993 written by Trev'
; ---------------------------------------------------------------------------
; INIT_SOUND
; ---------------------------------------------------------------------------
INIT_SOUND:
                movem.l d0-d7/a0-a6,-(sp)

loc_FE:                                 
                bsr.w   INITDSP
                bsr.w   initpit2
                move.l  #$FFFFFFFF,(FXONLY).l 
                movem.l (sp)+,d0-d7/a0-a6
                rts
; ---------------------------------------------------------------------------
; PT_MOD_I:
; ---------------------------------------------------------------------------
PT_MOD_I:
                movem.l d1-d7/a0-a6,-(sp)
                bsr.w   init_mod
                lea     (localdata).l,a6
                move.l  #2,dword_1DF0-localdata(a6)
                movem.l (sp)+,d1-d7/a0-a6
                rts
; ---------------------------------------------------------------------------
; initpit1:
; ---------------------------------------------------------------------------
initpit1:
                move.l  #$1AC,d0
                lsl.l   #8,d0
                move.l  #$321,d1
                moveq   #$6C,d2 ; 'l'
                lea     (snd_tabl).l,a0

ip_l2:                                
                move.l  d0,d3
                divu.w  d2,d3
                andi.l  #$FFFF,d3
                mulu.w  #$1C,d3
                divu.w  #$2B,d3 ; '+'
                andi.l  #$FFFF,d3
                move.w  d3,(a0)+
                addq.l  #1,d2
                dbf     d1,ip_l2
                rts

; ---------------------------------------------------------------------------
; initpit2:
; ---------------------------------------------------------------------------
initpit2:
                move.l  #$EF74,d0
                move.l  #$321,d1
                moveq   #$6C,d2 ; 'l'
                move.l  #$8000,d4
                lea     (snd_tabl).l,a0

ipi2:                                
                move.l  d0,d3
                divu.w  d2,d3
                swap    d3
                add.l   d4,d3
                swap    d3
                andi.l  #$FFFF,d3
                move.w  d3,(a0)+
                addq.l  #1,d2
                dbf     d1,ipi2
                rts

; ---------------------------------------------------------------------------
; NT_VBL:
; ---------------------------------------------------------------------------
NT_VBL:
                movem.l d0-d2/d7-a4,-(sp)
                bsr.w   ntplay
                lea     ntvars(pc),a3
                pea     (a3)
                lea     $210(a3),a3
                lea     snd_tabl(pc),a1
                lea     channel1(pc),a0
                movea.l #TABLESTA,a4
                moveq   #3,d7
                lea     localdata(pc),a2
                pea     (a2)

loc_1C6:                                
                moveq   #0,d0
                move.w  $18(a3),d0
                beq.s   loc_1DC
                subi.w  #$6C,d0 ; 'l'
                lsl.w   #1,d0
                move.w  (a1,d0.w),d0
                move.l  d0,$C(a4)

loc_1DC:                                
                clr.l   d0
                move.w  $1A(a3),d0
                lsr.w   #1,d0
                move.w  d0,2(a2)
                move.l  (a2),4(a4)
                move.l  0(a0),d1
                blt.s   loc_25C
                move.l  #$FFFFFFFF,0(a0)
                move.w  #0,(a2)
                move.l  (a2),4(a4)
                move.l  #$FFFFFFFC,(a4)
                move.l  d1,$10(a4)
                tst.l   d1
                beq.s   loc_25C
                move.l  4(a0),d0
                lsr.l   #8,d0
                move.l  d0,8(a4)
                moveq   #0,d2
                move.w  $10(a3),d2
                lsl.l   #8,d2
                lsl.l   #1,d2
                move.l  d2,$14(a4)
                move.l  $C(a3),d0
                cmp.l   d1,d0
                bne.s   loc_238
                cmp.l   #$200,d2
                beq.s   loc_244

loc_238:                                
                move.l  d0,$1C(a4)
                move.w  #$8000,(a2)
                move.l  (a2),4(a4)

loc_244:                                
                move.l  $C(a4),d0
                neg.l   d0
                move.l  d0,$18(a4)
                move.l  #0,$18(a4)
                move.l  #$1C,(a4)

loc_25C:                                
                                        
                lea     $20(a4),a4
                addq.l  #8,a0
                lea     $34(a3),a3
                addq.l  #4,a2
                dbf     d7,loc_1C6
                movea.l (sp)+,a2
                movea.l (sp)+,a3
                tst.w   $14(a2)
                beq.s   loc_2AA
                moveq   #0,d1
                move.w  $20E(a3),d1
                move.l  $1E(a2),d0
                add.l   $10(a2),d1
                cmp.l   d0,d1
                ble.s   loc_292
                move.l  d0,d1
                move.w  #0,$14(a2)
                bra.s   loc_2A6

loc_292:                                
                cmp.l   #0,d1
                bge.s   loc_2A6
                move.l  #0,d1
                move.w  #0,$14(a2)

loc_2A6:                                
                                        
                move.w  d1,$20E(a3)

loc_2AA:                                
                movem.l (sp)+,d0-d2/d7-a4
                rts
; ---------------------------------------------------------------------------
; PLAYFX2:
; ---------------------------------------------------------------------------
PLAYFX2:
                movem.l d1-d7/a2-a6,-(sp)
                tst.w   d1
                bne.s   loc_2BC
                move.w  0(a0),d1

loc_2BC:                                
                movea.l #0,a3
                lea     localdata(pc),a2
                tst.b   FXENA-localdata(a2)
                beq.w   loc_398
                tst.b   $27(a2)
                beq.s   loc_2E2
                moveq   #1,d6
                movea.l #TABLESTA+$80,a4
                lea     $30(a2),a2
                bra.s   loc_2EE

loc_2E2:                                
                moveq   #5,d6
                movea.l #TABLESTA,a4
                lea     $28(a2),a2

loc_2EE:                                
                pea     (a4)
                pea     (a2)
                move.w  d6,d7

loc_2F4:                                
                cmpi.l  #$FFFFFFFC,(a4)
                bne.s   loc_300
                move.w  #$FFFF,(a2)

loc_300:                                
                lea     $20(a4),a4
                addq.l  #2,a2
                dbf     d7,loc_2F4
                lea     localdata(pc),a6
                movea.l (sp)+,a5
                movea.l (sp)+,a2
                movea.l #0,a3
                movea.l a3,a4
                move.w  d1,d5
                move.w  d6,d7

loc_31E:                                
                cmp.w   (a5),d5
                blt.s   loc_328
                movea.l a2,a4
                movea.l a5,a3
                move.w  (a5),d5

loc_328:                                
                addq.l  #2,a5
                lea     $20(a2),a2
                dbf     d7,loc_31E
                cmpa.l  #0,a4
                beq.s   loc_398
                move.w  d1,(a3)
                move.l  #$FFFFFFFC,(a4)
                move.l  4(a0),$10(a4)
                move.l  8(a0),8(a4)
                move.l  $C(a0),$1C(a4)
                move.l  #0,$18(a4)
                tst.w   d2
                bne.s   loc_364
                move.l  $1A(a6),d2

loc_364:                                
                ext.l   d2
                lsl.l   #6,d2
                move.l  $10(a0),$14(a4)
                beq.s   loc_374
                bset    #$1F,d2

loc_374:                                
                move.l  d2,4(a4)
                tst.l   d3
                bne.s   loc_380
                move.w  2(a0),d3

loc_380:                                
                mulu.w  #$1C,d3
                divu.w  #$2B,d3 ; '+'
                andi.l  #$FFFF,d3
                move.l  d3,$C(a4)
                move.l  #$1C,(a4)

loc_398:                                
                                        
                move.l  a3,d0
                beq.s   loc_3AA
                lea     localdata(pc),a2
                lea     dword_1E08-localdata(a2),a2
                sub.l   a2,d0
                lsr.w   #1,d0
                addq.w  #1,d0

loc_3AA:                                
                movem.l (sp)+,d1-d7/a2-a6
                rts
; ---------------------------------------------------------------------------
; CHANGEFX:
; ---------------------------------------------------------------------------
CHANGEFX:
                movem.l d4-d7/a0-a6,-(sp)
                subq.w  #1,d1
                lsl.w   #5,d1
                movea.l #TABLESTA,a0
                btst    #0,d0
                beq.s   loc_3CE
                move.l  #$FFFFFFFC,(a0,d1.w)
                bra.s   loc_424

loc_3CE:                                
                btst    #1,d0
                beq.s   loc_3E0
                move.l  4(a0,d1.w),d4
                bclr    #$1F,d4
                move.l  d4,4(a0,d1.w)

loc_3E0:                                
                btst    #2,d0
                beq.s   loc_402
                move.l  4(a0,d1.w),d4
                asl.w   #7,d2
                add.w   d2,d4
                bvc.s   loc_3F6
                move.w  #$7FFF,d4
                bra.s   loc_3FC

loc_3F6:                                
                bpl.s   loc_3FC
                move.w  #0,d4

loc_3FC:                                
                                        
                move.w  d4,d2
                move.l  d4,4(a0,d1.w)

loc_402:                                
                btst    #3,d0
                beq.s   loc_424
                move.l  $C(a0,d1.w),d4
                ext.l   d3
                add.l   d3,d4
                bvc.s   loc_41A
                move.l  #$7FFFFFFF,d4
                bra.s   loc_41E

loc_41A:                                
                bpl.s   loc_41E
                moveq   #0,d4

loc_41E:                                
                                        
                move.l  d4,d3
                move.l  d4,$C(a0,d1.w)

loc_424:                                
                                        
                movem.l (sp)+,d4-d7/a0-a6
                rts
; ---------------------------------------------------------------------------
; CHANGE_VOL:
; ---------------------------------------------------------------------------
CHANGE_VOL:
                movem.l d1-d2/a0-a1,-(sp)
                lea     localdata(pc),a0
                tst.w   d1
                beq.s   loc_43C
                lea     $1A(a0),a1
                bra.s   loc_440

loc_43C:                                
                lea     $1E(a0),a1

loc_440:                                
                move.l  (a1),d2
                ext.l   d0
                tst.l   d0
                bpl.s   loc_45A
                add.l   d0,d2
                cmp.l   #0,d2
                bge.s   loc_46A
                move.l  #0,d2
                bra.s   loc_46A

loc_45A:                                
                add.l   d0,d2
                cmp.l   #$FF,d2
                ble.s   loc_46A
                move.l  #$FF,d2

loc_46A:                                
                                        
                move.w  #1,$14(a0)
                move.l  d2,(a1)
                tst.w   d1
                bne.s   loc_47E
                lea     ntvars(pc),a0
                move.w  d2,word_120C-ntvars(a0)

loc_47E:                                
                move.l  d2,d0
                movem.l (sp)+,d1-d2/a0-a1
                rts

; ---------------------------------------------------------------------------
; SET_VOLUME:
; ---------------------------------------------------------------------------
SET_VOLUME:
                movem.l d1-d2/a0-a1,-(sp)
                lea     localdata(pc),a0
                tst.w   d1
                beq.s   loc_498
                lea     $1A(a0),a1
                bra.s   loc_49C

loc_498:                                
                lea     $1E(a0),a1

loc_49C:                                
                move.l  d0,d2
                cmp.l   #0,d2
                bge.s   loc_4AE
                move.l  #0,d2
                bra.s   loc_4BC

loc_4AE:                                
                cmp.l   #$FF,d2
                ble.s   loc_4BC
                move.l  #$FF,d2

loc_4BC:                                
                                        
                move.w  #1,$14(a0)
                move.l  d2,(a1)
                tst.w   d1
                bne.s   loc_4D0
                lea     ntvars(pc),a0
                move.w  d2,word_120C-ntvars(a0)

loc_4D0:                                
                move.l  d2,d0
                movem.l (sp)+,d1-d2/a0-a1
                rts

; ---------------------------------------------------------------------------
; NOFADE:
; ---------------------------------------------------------------------------
NOFADE:
                movem.l d0/a0,-(sp)
                lea     localdata(pc),a0
                move.l  MUSVOL-localdata(a0),d0
                lea     ntvars(pc),a0
                move.w  d0,word_120C-ntvars(a0)
                movem.l (sp)+,d0/a0
                rts

; ---------------------------------------------------------------------------
; FADEUP:
; ---------------------------------------------------------------------------
FADEUP:
                move.l  a0,-(sp)
                lea     localdata(pc),a0
                move.l  #2,dword_1DF0-localdata(a0)
                move.w  #1,$14(a0)
                movea.l (sp)+,a0
                rts

; ---------------------------------------------------------------------------
; FADEDOWN:
; ---------------------------------------------------------------------------
FADEDOWN:
                move.l  a0,-(sp)
                lea     localdata(pc),a0
                move.l  #$FFFFFFFE,dword_1DF0-localdata(a0)
                move.w  #1,$14(a0)
                movea.l (sp)+,a0
                rts

; ---------------------------------------------------------------------------
; START_MOD:
; ---------------------------------------------------------------------------
START_MOD:
                move.l  a4,-(sp)
                move.l  #0,(FXONLY).l 
                jsr     (update_interrupt).l 
                lea     localdata(pc),a4
                st      MUSENA-localdata(a4)
                move.w  #1,$14(a4)
                movea.l (sp)+,a4
                rts

; ---------------------------------------------------------------------------
; STOP_MOD:
; ---------------------------------------------------------------------------
STOP_MOD:
                movem.l d7/a3-a4,-(sp)
                jsr     (return_early).l 
                lea     localdata(pc),a4
                sf      MUSENA-localdata(a4)
                lea     $28(a4),a3
                movea.l #TABLESTA,a4
                moveq   #3,d7

loc_564:                                
                move.l  #$FFFFFFFC,(a4)
                move.l  #0,4(a4)
                move.w  #$FFFF,(a3)+
                lea     $20(a4),a4
                dbf     d7,loc_564
                move.l  #$FFFFFFFF,(FXONLY).l 
                movem.l (sp)+,d7/a3-a4
                rts

; ---------------------------------------------------------------------------
; ENABLE_FX:
; ---------------------------------------------------------------------------
ENABLE_FX:
                movem.l a6,-(sp)
                lea     localdata(pc),a6
                st      FXENA-localdata(a6)
                movem.l (sp)+,a6
                rts

; ---------------------------------------------------------------------------
; DISABLE_FX:
; ---------------------------------------------------------------------------
DISABLE_FX:
                movem.l d7/a6,-(sp)
                lea     localdata(pc),a6
                sf      FXENA-localdata(a6)
                tst.b   $27(a6)
                beq.s   loc_5B6
                moveq   #5,d7
                bra.s   loc_5B8

loc_5B6:                                
                moveq   #1,d7

loc_5B8:                                
                movea.l #TABLESTA,a6
                lea     $A0(a6),a6

loc_5C2:                                
                move.l  #$FFFFFFFC,(a6)
                move.l  #0,4(a6)
                lea     -$20(a6),a6
                dbf     d7,loc_5C2
                movem.l (sp)+,d7/a6
                rts

; ---------------------------------------------------------------------------
; GETSAMNO:
; ---------------------------------------------------------------------------
GETSAMNO:
                movem.l d1/a0-a2,-(sp)
                lea     sampleno(pc),a1
                lea     (a1,d0.w),a1
                move.b  (a1),d1
                lea     ntvars(pc),a0
                lea     word_120E-ntvars(a0),a0
                mulu.w  #$34,d0 ; '4'
                lea     $32(a0,d0.w),a2
                move.b  (a2),d0
                move.b  d0,(a1)
                move.b  1(a2),d1
                bne.s   loc_608
                moveq   #$FFFFFFFF,d0

loc_608:                                
                clr.b   1(a2)
                movem.l (sp)+,d1/a0-a2
                rts

; ---------------------------------------------------------------------------
; HALTDSP:
; ---------------------------------------------------------------------------
HALTDSP:
                movem.l d0/d7/a1/a4,-(sp)
                lea     localdata(pc),a1
                move.w  d0,d7
                andi.w  #$F,d7
                cmp.w   #$F,d7
                bne.s   loc_62C
                jsr     (return_early).l 

loc_62C:                                
                not.l   d0
                move.l  d0,(CHANFLAG).l 
                movem.l (sp)+,d0/d7/a1/a4
                rts

; ---------------------------------------------------------------------------
; RESUME_DSP:
; ---------------------------------------------------------------------------
RESUME_DSP:
                movem.l d7/a1/a4,-(sp)
                lea     localdata(pc),a1
                moveq   #0,d7
                not.l   d7
                move.l  d7,(CHANFLAG).l 
                tst.b   $27(a1)
                beq.s   loc_658
                jsr     (update_interrupt).l 

loc_658:                                
                movem.l (sp)+,d7/a1/a4
                rts

aCopyright1993I_0:dc.b 'Copyright (1993) Imagitec Design, Inc '

; ---------------------------------------------------------------------------
; RESUME_DSP:
; ---------------------------------------------------------------------------
init_mod:
                bsr.s   init_song
                bsr.w   init_sample
                rts

; ---------------------------------------------------------------------------
; init_song:                                
; ---------------------------------------------------------------------------
init_song:                                
                lea     ntvars(pc),a5
                move.l  a0,dword_100E-ntvars(a5)
                move.w  #$1D8,d0
                move.w  #$258,d1
                cmpi.l  #$4D2E4B2E,$438(a0)
                bne.s   loc_6AE
                move.w  #$3B8,d0
                move.w  #$43C,d1

loc_6AE:                                
                lea     (a0,d0.w),a1
                lea     (a0,d1.w),a2
                move.l  a1,$14(a5)
                move.l  a2,$18(a5)
                moveq   #0,d0
                move.b  (a1),d0
                lsl.l   #8,d0
                lsl.l   #2,d0
                add.l   a2,d0
                move.l  d0,8(a5)
                clr.l   $C(a5)
                adda.w  #$14,a0
                move.b  -2(a1),0(a5)
                moveq   #$7F,d0
                moveq   #0,d1

loc_6DE:                                
                cmp.b   (a1)+,d1
                bge.s   loc_6E6
                move.b  -1(a1),d1

loc_6E6:                                
                dbf     d0,loc_6DE
                move.b  #6,2(a5)
                move.b  #0,1(a5)
                move.b  #0,3(a5)
                moveq   #7,d0
                lea     channel1(pc),a6

loc_702:                                
                clr.l   (a6)+
                dbf     d0,loc_702
                moveq   #$33,d0 ; '3'
                lea     $210(a5),a6

loc_70E:                                
                clr.l   (a6)+
                dbf     d0,loc_70E
                lea     $244(a5),a6
                move.w  #8,$20(a6)
                lea     $278(a5),a6
                move.w  #$10,$20(a6)
                lea     $2AC(a5),a6
                move.w  #$18,$20(a6)
                lea     $1C(a5),a5
                lea     dword_814(pc),a6
                moveq   #$1E,d0

loc_73C:                                
                move.l  a6,(a5)+
                move.w  #1,(a5)+
                move.l  a6,(a5)+
                move.w  #2,(a5)+
                clr.l   (a5)+
                dbf     d0,loc_73C
                lea     dword_7E0(pc),a5
                movem.l d0-d7/a0-a4,(a5)
                rts


; ===========================================================================
; init_sample:
; ===========================================================================
init_sample:
                lea     dword_7E0(pc),a5
                movem.l (a5),d0-d7/a0-a4
                lea     ntvars(pc),a5
                addq.w  #1,d1
                lsl.l   #8,d1
                lsl.l   #2,d1
                lea     (a2,d1.l),a2
                lea     $1C(a5),a3
                move.l  $14(a5),d0
                sub.l   a0,d0
                subq.l  #2,d0
                divu.w  #$1E,d0
                subq.w  #1,d0

loc_780:                                
                moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d3
                move.w  $16(a0),d1
                move.w  $1C(a0),d3
                move.w  $1A(a0),d2
                bne.s   loc_79C
                add.l   d1,d1
                add.l   d3,d3
                move.l  d1,d4
                bra.s   loc_7B8

loc_79C:                                
                move.l  d2,d4
                add.l   d3,d4
                cmp.l   d1,d4
                bgt.s   loc_7A6
                add.l   d2,d2

loc_7A6:                                
                add.l   d1,d1
                add.l   d3,d3
                move.l  d2,d4
                add.l   d3,d4
                cmp.l   d1,d4
                ble.s   loc_7B8
                move.l  d1,d3
                sub.l   d2,d3
                move.l  d1,d4

loc_7B8:                                
                                        ; init_sample+58↑j
                move.l  a2,(a3)+
                lsr.l   #1,d3
                lsr.l   #1,d4
                move.w  d4,(a3)+
                move.l  a2,(a3)
                add.l   d2,(a3)+
                move.w  d3,(a3)+
                moveq   #0,d2
                move.b  $18(a0),d2
                move.w  d2,(a3)+
                move.b  $19(a0),d2
                move.w  d2,(a3)+
                adda.l  d1,a2
                lea     $1E(a0),a0
                dbf     d0,loc_780
                rts

; ---------------------------------------------------------------------------
dword_7E0:      dcb.l $D,0              
                                        ; init_sample↑o
dword_814:      dcb.l 4,0               

; ===========================================================================
; ntplay:
; ===========================================================================
ntplay:
                movem.l d0-d7/a0-a6,-(sp)
                lea     ntvars(pc),a5
                lea     byte_FFF-ntvars(a5),a0
                lea     loc_B16(pc),a1
                move.b  (a0)+,d0
                addq.b  #1,d0
                cmp.b   (a0),d0
                blt.s   loc_862
                clr.b   -(a0)
                bsr.w   asys_ntn_8ee
                lea     $790(a5),a0
                tst.b   (a0)+
                beq.s   loc_850
                move.b  -(a0),1(a0)
                clr.b   (a0)+

loc_850:                                
                tst.b   (a0)
                beq.s   loc_860
                subq.b  #1,(a0)
                beq.s   loc_860
                subi.l  #$10,$C(a5)

loc_860:                                
                                        ; ntplay+32↑j
                bra.s   loc_864

loc_862:                                
                move.b  d0,-(a0)

loc_864:                                
                lea     $210(a5),a0
                bsr.w   asys_ntp_a9c
                lea     $244(a5),a0
                bsr.w   asys_ntp_a9c
                lea     $278(a5),a0
                bsr.w   asys_ntp_a9c
                lea     $2AC(a5),a0
                bsr.w   asys_ntp_a9c
                tst.b   5(a5)
                beq.s   loc_89E
                sf      5(a5)
                moveq   #0,d0
                move.b  6(a5),d0
                lsl.w   #4,d0
                move.l  d0,$C(a5)
                clr.w   6(a5)

loc_89E:                                
                cmpi.l  #$400,$C(a5)
                blt.s   loc_8E2

loc_8A8:                                
                moveq   #0,d0
                move.b  6(a5),d0
                lsl.w   #4,d0
                move.l  d0,$C(a5)
                move.b  3(a5),d0
                addq.b  #1,d0
                cmp.b   0(a5),d0
                blt.s   loc_8C2
                clr.b   d0

loc_8C2:                                
                move.b  d0,3(a5)
                movea.l $14(a5),a0
                move.b  (a0,d0.w),d0
                lsl.l   #8,d0
                lsl.l   #2,d0
                add.l   $18(a5),d0
                move.l  d0,8(a5)
                sf      6(a5)
                sf      7(a5)

loc_8E2:                                
                tst.b   7(a5)
                bne.s   loc_8A8
                movem.l (sp)+,d0-d7/a0-a6
                rts

; ===========================================================================
; asys_ntn_8ee:
; ===========================================================================
asys_ntn_8ee:
                tst.b   $791(a5)
                beq.s   loc_8FE
                addi.l  #$10,$C(a5)
                rts
; ---------------------------------------------------------------------------

loc_8FE:                                
                movea.l 8(a5),a0
                adda.l  $C(a5),a0
                addi.l  #$10,$C(a5)
                lea     $210(a5),a1
                lea     channel1(pc),a2
                bsr.s   asys_ntg_93c
                lea     $244(a5),a1
                lea     channel2(pc),a2
                bsr.s   asys_ntg_93c
                lea     $278(a5),a1
                lea     channel3(pc),a2
                bsr.s   asys_ntg_93c
                lea     $2AC(a5),a1
                lea     channel4(pc),a2
                bsr.s   asys_ntg_93c
                lea     word_B06(pc),a1
                rts

; ===========================================================================
; asys_ntg_93c:
; ===========================================================================
asys_ntg_93c:
                move.l  (a0)+,d0
                move.l  d0,0(a1)
                move.w  d0,d1
                swap    d0
                move.w  d0,d2
                andi.w  #$F000,d1
                andi.w  #$F000,d2
                lsr.w   #4,d1
                or.w    d2,d1
                beq.s   loc_988
                subq.w  #1,d1
                lsr.w   #4,d1
                andi.w  #$1F0,d1
                st      $33(a1)
                lsr.w   #4,d1
                move.b  d1,$32(a1)
                lsl.w   #4,d1
                lea     6(a1),a3
                lea     $1C(a5),a4
                adda.w  d1,a4
                move.l  (a4)+,(a3)+
                move.l  (a4)+,(a3)+
                move.l  (a4)+,(a3)+
                move.w  (a4)+,(a3)+
                move.w  (a4),2(a3)
                movea.l $C(a1),a3
                move.l  a3,$2A(a1)

loc_988:                                
                andi.w  #$FFF,d0
                beq.w   locret_A94
                move.b  2(a1),d1
                andi.w  #$F,d1
                cmp.b   #3,d1
                beq.w   asys_ntg_a4a
                cmp.b   #5,d1
                beq.w   asys_ntg_a4a
                cmp.b   #9,d1
                bne.s   loc_9D8
                moveq   #0,d1
                move.b  3(a1),d1
                beq.s   loc_9BA
                move.b  d1,$23(a1)

loc_9BA:                                
                move.b  $23(a1),d1
                lsl.w   #7,d1
                cmp.w   $A(a1),d1
                bge.s   loc_9D2
                sub.w   d1,$A(a1)
                add.w   d1,d1
                add.l   d1,6(a1)
                bra.s   loc_9D8
; ---------------------------------------------------------------------------

loc_9D2:                                
                move.w  #1,$A(a1)

loc_9D8:                                
                                        ; asys_ntg_93c+94↑j
                move.l  d0,d1
                swap    d1
                andi.w  #$FF0,d1
                cmp.w   #$E50,d1
                bne.s   loc_9F4
                moveq   #0,d2
                move.b  3(a1),d2
                andi.w  #$F,d2
                move.w  d2,$12(a1)

loc_9F4:                                
                move.w  $12(a1),d2
                beq.s   loc_A14
                lea     $310(a5),a3
                moveq   #$24,d2 ; '$'

loc_A00:                                
                cmp.w   (a3)+,d0
                bcc.s   loc_A08
                dbf     d2,loc_A00

loc_A08:                                
                move.w  $12(a1),d2
                mulu.w  #$48,d2 ; 'H'
                move.w  -2(a3,d2.w),d0

loc_A14:                                
                move.w  d0,$14(a1)
                cmp.w   #$ED0,d1
                beq.w   locret_A94
                btst    #2,$22(a1)
                bne.s   loc_A2C
                clr.b   $25(a1)

loc_A2C:                                
                btst    #6,$22(a1)
                bne.s   loc_A38
                clr.b   $25(a1)

loc_A38:                                
                move.l  6(a1),0(a2)
                move.w  $A(a1),4(a2)
                asl     4(a2)
                rts
; ---------------------------------------------------------------------------
; asys_ntg_a4a:                                
; ---------------------------------------------------------------------------
asys_ntg_a4a:                                
                move.w  $12(a1),d1
                mulu.w  #$48,d1 ; 'H'
                lea     $310(a5),a3
                adda.l  d1,a3
                moveq   #0,d1

loc_A5A:                                
                cmp.w   (a3,d1.w),d0
                bcc.s   loc_A6A
                addq.w  #2,d1
                cmp.w   #$48,d1 ; 'H'
                bcs.s   loc_A5A
                moveq   #$46,d1 ; 'F'

loc_A6A:                                
                move.w  $12(a1),d0
                andi.b  #8,d0
                beq.s   loc_A7A
                tst.w   d1
                beq.s   loc_A7A
                subq.w  #2,d1

loc_A7A:                                
                                        ; asys_ntg_93c+13A↑j
                move.w  (a3,d1.w),d0
                move.w  d0,$1C(a1)
                clr.b   $1E(a1)
                cmp.w   $14(a1),d0
                beq.s   loc_A96
                bgt.s   locret_A94
                move.b  #1,$1E(a1)

locret_A94:                             
                                        ; asys_ntg_93c+E0↑j ...
                rts
; ---------------------------------------------------------------------------

loc_A96:                                
                clr.w   $1C(a1)
                rts


; ===========================================================================
; asys_ntp_a9c:                                
; ===========================================================================
asys_ntp_a9c:                                
                move.l  a1,-(sp)
                movem.l a0-a1,-(sp)
                bsr.w   asys_ntE
                movem.l (sp)+,a0-a1
                lea     $14(a0),a2
                move.l  (a2)+,(a2)
                moveq   #0,d0
                move.w  2(a0),d0
                andi.w  #$FFF,d0
                beq.s   loc_AD6
                move.l  d0,d1
                andi.w  #$FF,d1
                lsr.w   #8,d0
                tst.b   (a1,d0.w)
                beq.s   loc_AD6
                add.w   d0,d0
                lea     word_AE6(pc),a1
                adda.w  (a1,d0.w),a1
                jsr     (a1)

loc_AD6:                                
                                        ; asys_ntp_a9c+2C↑j
                move.w  $20E(a5),d0
                mulu.w  $1A(a0),d0
                move.w  d0,$1A(a0)
                movea.l (sp)+,a1
                rts

; ---------------------------------------------------------------------------
word_AE6:       dc.w $40                
                dc.l $9800B4, $D0014E, $1E401F4, $20402A8, $2AA02D2, $3000310
                dc.l $3220344
                dc.b 4, $E8
word_B06:       dc.w 0                  
                dc.l 0
                dc.l 1, $10101
; ---------------------------------------------------------------------------
                btst    d0,d1

loc_B16:                                
                btst    d0,d1
                btst    d0,d1
                btst    d0,d1
                btst    d0,d1
                ; Not sure what these instructions are.
                ; Some variant of ori.b #1,d0 ?
                dc.l $00000100
                dc.l $00000100
                moveq   #0,d0
                move.b  1(a5),d0
                divs.w  #3,d0
                swap    d0
                cmp.w   #0,d0
                beq.s   loc_B4C
                cmp.w   #2,d0
                beq.s   loc_B44
                move.l  d1,d0
                lsr.b   #4,d0
                bra.s   loc_B52
; ---------------------------------------------------------------------------

loc_B44:                                
                move.l  d1,d0
                andi.b  #$F,d0
                bra.s   loc_B52
; ---------------------------------------------------------------------------

loc_B4C:                                
                move.w  $14(a0),d2
                bra.s   loc_B78
; ---------------------------------------------------------------------------

loc_B52:                                
                                        
                add.w   d0,d0
                move.w  $12(a0),d1
                mulu.w  #$48,d1 ; 'H'
                lea     $310(a5),a1
                adda.l  d1,a1
                move.w  $14(a0),d1
                moveq   #$24,d7 ; '$'

loc_B68:                                
                move.w  (a1,d0.w),d2
                cmp.w   (a1),d1
                bcc.s   loc_B78
                addq.l  #2,a1
                dbf     d7,loc_B68
                rts
; ---------------------------------------------------------------------------

loc_B78:                                
                                        
                move.w  d2,$18(a0)
                rts
; ---------------------------------------------------------------------------
sub_4C3E:
                sub.w   d1,$14(a0)
                cmpi.w  #$71,$14(a0) ; 'q'
                bge.s   loc_B90
                move.w  #$71,$14(a0) ; 'q'

loc_B90:                                
                move.w  $14(a0),d0
                move.w  d0,$18(a0)
                rts
; ---------------------------------------------------------------------------
sub_4C5A:
                add.w   d1,$14(a0)
                cmpi.w  #$358,$14(a0)
                ble.s   loc_BAC
                move.w  #$358,$14(a0)

loc_BAC:                                
                move.w  $14(a0),d0
                move.w  d0,$18(a0)
                rts
; ---------------------------------------------------------------------------
                tst.w   d1
                beq.s   asys_ntc_bc2
                move.b  d1,$1F(a0)
                clr.b   3(a0)

; ===========================================================================
; asys_ntc_bc2:                                
; ===========================================================================
asys_ntc_bc2:                                
                                        
                move.w  $1C(a0),d2
                bne.s   loc_BCA
                rts

loc_BCA:                                
                moveq   #0,d0
                move.b  $1F(a0),d0
                tst.b   $1E(a0)
                beq.s   loc_BEA
                sub.w   d0,$14(a0)
                cmp.w   $14(a0),d2
                blt.s   loc_BFC
                move.w  d2,$14(a0)
                clr.w   $1C(a0)
                bra.s   loc_BFC

loc_BEA:                                
                add.w   d0,$14(a0)
                cmp.w   $14(a0),d2
                bgt.s   loc_BFC
                move.w  d2,$14(a0)
                clr.w   $1C(a0)

loc_BFC:                                
                                        ; asys_ntc_bc2+26↑j ...
                move.w  $14(a0),d0
                move.b  $28(a0),d1
                andi.b  #$F,d1
                beq.s   loc_C2E
                move.w  $12(a0),d1
                mulu.w  #$48,d1 ; 'H'
                lea     $310(a5),a1
                adda.l  d1,a1
                moveq   #0,d1

loc_C1A:                                
                cmp.w   (a1,d1.w),d0
                bcc.s   loc_C2A
                addq.w  #2,d1
                cmp.w   #$48,d1 ; 'H'
                bcs.s   loc_C1A
                moveq   #$46,d1 ; 'F'

loc_C2A:                                
                move.w  (a1,d1.w),d0

loc_C2E:                                
                move.w  d0,$18(a0)
                rts

; ---------------------------------------------------------------------------
loc_FF26:
                tst.w   d1
                beq.s   asys_ntc_c5c
                move.b  $24(a0),d2
                andi.b  #$F,d1
                beq.s   loc_C48
                andi.b  #$F0,d2
                or.b    d1,d2

loc_C48:                                
                move.b  3(a0),d1
                andi.b  #$F0,d1
                beq.s   loc_C58
                andi.b  #$F,d2
                or.w    d1,d2

loc_C58:                                
                move.b  d2,$24(a0)

; ===========================================================================
; asys_ntc_c5c:                                
; ===========================================================================
asys_ntc_c5c:                                
                                        
                lea     $2F0(a5),a1
                move.b  $25(a0),d0
                lsr.w   #2,d0
                andi.w  #$1F,d0
                moveq   #0,d1
                move.b  $22(a0),d1
                andi.b  #3,d1
                beq.s   loc_C96
                lsl.b   #3,d0
                cmp.b   #1,d1
                beq.s   loc_C84
                move.b  #$FF,d1
                bra.s   loc_C9A

loc_C84:                                
                tst.b   $25(a0)
                bpl.s   loc_C92
                move.b  #$FF,d1
                sub.b   d0,d1
                bra.s   loc_C9A

loc_C92:                                
                move.b  d0,d1
                bra.s   loc_C9A

loc_C96:                                
                move.b  (a1,d0.w),d1

loc_C9A:                                
                                        ; asys_ntc_c5c+34↑j ...
                move.b  $24(a0),d0
                andi.w  #$F,d0
                mulu.w  d0,d1
                lsr.w   #7,d1
                move.w  $14(a0),d0
                tst.b   $25(a0)
                bmi.s   loc_CB4
                add.w   d1,d0
                bra.s   loc_CB6

loc_CB4:                                
                sub.w   d1,d0

loc_CB6:                                
                move.w  d0,$18(a0)
                move.b  $24(a0),d0
                lsr.w   #2,d0
                andi.w  #$3C,d0 ; '<'
                add.b   d0,$25(a0)
                rts

; ---------------------------------------------------------------------------
; asys_ntc_cca:
; ---------------------------------------------------------------------------
asys_ntc_cca:
                bsr.w   asys_ntc_bc2
                moveq   #0,d1
                move.b  3(a0),d1
                bsr.w   asys_ntc_db8
                rts
; ---------------------------------------------------------------------------
; asys_ntc_cda:
; ---------------------------------------------------------------------------
asys_ntc_cda:
                bsr.w   asys_ntc_c5c
                moveq   #0,d1
                move.b  3(a0),d1
                bsr.w   asys_ntc_db8
                rts
; ---------------------------------------------------------------------------
; asys_ntc_cea:
; ---------------------------------------------------------------------------
asys_ntc_cea:
                tst.w   d1
                beq.s   loc_D12
                move.b  $24(a0),d2
                andi.b  #$F,d1
                beq.s   loc_CFE
                andi.b  #$F0,d2
                or.b    d1,d2

loc_CFE:                                
                move.b  3(a0),d1
                andi.b  #$F0,d1
                beq.s   loc_D0E
                andi.b  #$F,d2
                or.w    d1,d2

loc_D0E:                                
                move.b  d2,$24(a0)

loc_D12:                                
                lea     $2F0(a5),a1
                move.b  $25(a0),d0
                lsr.w   #2,d0
                andi.w  #$1F,d0
                moveq   #0,d1
                move.b  $22(a0),d1
                lsr.b   #4,d1
                andi.b  #3,d1
                beq.s   loc_D4E
                lsl.b   #3,d0
                cmp.b   #1,d1
                beq.s   loc_D3C
                move.b  #$FF,d1
                bra.s   loc_D52

loc_D3C:                                
                tst.b   $25(a0)
                bpl.s   loc_D4A
                move.b  #$FF,d1
                sub.b   d0,d1
                bra.s   loc_D52

loc_D4A:                                
                move.b  d0,d1
                bra.s   loc_D52

loc_D4E:                                
                move.b  (a1,d0.w),d1

loc_D52:                                
                                        
                move.b  $24(a0),d0
                andi.w  #$F,d0
                mulu.w  d0,d1
                lsr.w   #6,d1
                move.w  $16(a0),d0
                tst.b   $25(a0)
                bmi.s   loc_D6C
                add.w   d1,d0
                bra.s   loc_D6E

loc_D6C:                                
                sub.w   d1,d0

loc_D6E:                                
                bpl.s   loc_D72
                moveq   #0,d0

loc_D72:                                
                cmp.w   #$40,d0 ; '@'
                ble.s   loc_D7A
                moveq   #$40,d0 ; '@'

loc_D7A:                                
                move.w  d0,$1A(a0)
                move.b  $24(a0),d0
                lsr.w   #2,d0
                andi.w  #$3C,d0 ; '<'
                add.b   d0,$25(a0)
                rts
; ---------------------------------------------------------------------------
                rts
; ---------------------------------------------------------------------------
                tst.w   d1
                beq.s   loc_D98
                move.b  d1,$23(a0)

loc_D98:                                
                move.b  $23(a0),d1
                lsl.w   #7,d1
                cmp.w   $A(a0),d1
                bge.s   loc_DB0
                sub.w   d0,$A(a0)
                add.w   d0,d0
                add.l   d0,6(a0)
                rts

loc_DB0:                                
                move.w  #1,$A(a0)
                rts

; ===========================================================================
; asys_ntc_db8:                                
; ===========================================================================
asys_ntc_db8:                                
                                        
                move.w  $16(a0),d3
                move.w  d1,d2
                lsr.w   #4,d1
                andi.w  #$F,d1
                beq.s   loc_DD2
                add.w   d1,d3
                cmp.w   #$40,d3 ; '@'
                ble.s   loc_DDC
                moveq   #$40,d3 ; '@'
                bra.s   loc_DDC

loc_DD2:                                
                andi.w  #$F,d2
                sub.w   d2,d3
                bpl.s   loc_DDC
                moveq   #0,d3

loc_DDC:                                
                                        ; asys_ntc_db8+18↑j ...
                move.w  d3,$16(a0)
                move.w  d3,$1A(a0)
                rts

; ---------------------------------------------------------------------------
; asys_ntc_de6:
; ---------------------------------------------------------------------------
asys_ntc_de6:
                subq.w  #1,d1
                move.b  d1,3(a5)
                clr.b   6(a5)
                st      7(a5)
                rts
; ---------------------------------------------------------------------------
; asys_ntc_df6:
; ---------------------------------------------------------------------------
asys_ntc_df6:
                cmp.w   #$40,d1 ; '@'
                ble.s   loc_DFE
                moveq   #$40,d1 ; '@'

loc_DFE:                                
                move.w  d1,$16(a0)
                move.w  d1,$1A(a0)
                rts
; ---------------------------------------------------------------------------
; asys_ntc_e08:
; ---------------------------------------------------------------------------
asys_ntc_e08:
                clr.b   6(a5)
                st      7(a5)
                move.l  d1,d2
                lsr.b   #4,d1
                mulu.w  #$A,d1
                andi.b  #$F,d2
                add.b   d2,d1
                cmp.b   #$3F,d1 ; '?'
                bhi.s   locret_E28
                move.b  d1,6(a5)

locret_E28:                             
                rts
; ---------------------------------------------------------------------------
; asys_ntc_e2a:
; ---------------------------------------------------------------------------
asys_ntc_e2a:
                move.w  d1,d2
                andi.w  #$F,d1
                lsr.w   #4,d2
                add.w   d2,d2
                lea     dword_E40(pc),a1
                adda.w  (a1,d2.w),a1
                jsr     (a1)
                rts

dword_E40:
byte_4F00:      dc.b 0, $20, 0, $22, 0, $2E, 0, $3A, 0, $46, 0, $52, 0
                dc.b $58, 0, $90, 0, $9E, 0, $A0, 0, $DE, 0, $EC, 0, $F8
                dc.b 1, 8, 1, $1A, 1, $2E, $4E, $75

                tst.b   1(a5)
                bne.s   locret_4F2C
                bsr.w   sub_4C3E

locret_4F2C:                            ; CODE XREF: ROM:00004F26↑j
                rts
; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_4F38
                bsr.w   sub_4C5A

locret_4F38:                            ; CODE XREF: ROM:00004F32↑j
                rts
; ---------------------------------------------------------------------------
                andi.b  #$F0,$28(a0)
                or.b    d1,$28(a0)
                rts
; ---------------------------------------------------------------------------
                andi.b  #$F0,$22(a0)
                or.b    d1,$22(a0)
                rts
; ---------------------------------------------------------------------------
                move.b  d1,$12(a0)
                rts
; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_4F8E
                tst.w   d1
                beq.s   loc_4F82
                tst.b   $26(a0)
                beq.s   loc_4F7C
                subq.b  #1,$26(a0)
                beq.s   locret_4F8E

loc_4F6E:                               ; CODE XREF: ROM:00004F80↓j
                move.b  $27(a0),d0
                move.b  d0,6(a5)
                st      5(a5)
                rts
; ---------------------------------------------------------------------------

loc_4F7C:                               ; CODE XREF: ROM:00004F66↑j
                move.b  d1,$26(a0)
                bra.s   loc_4F6E
; ---------------------------------------------------------------------------

loc_4F82:                               ; CODE XREF: ROM:00004F60↑j
                move.l  $C(a5),d1
                lsr.w   #4,d1
                subq.b  #1,d1
                move.b  d1,$27(a0)

locret_4F8E:                            ; CODE XREF: ROM:00004F5C↑j
                                        ; ROM:00004F6C↑j
                rts
; ---------------------------------------------------------------------------
                lsl.b   #4,d1
                andi.b  #$F,$22(a0)
                or.b    d1,$22(a0)
                rts
; ---------------------------------------------------------------------------
                rts
; ---------------------------------------------------------------------------
                tst.w   d1
                beq.s   locret_4FDC
                moveq   #0,d2
                move.b  1(a5),d2
                bne.s   loc_4FBC
                move.w  0(a0),d2
                andi.w  #$FFF,d2
                bne.s   locret_4FDC
                moveq   #0,d2
                move.b  1(a5),d2

loc_4FBC:                               ; CODE XREF: ROM:00004FAA↑j
                divu.w  d1,d2
                swap    d2
                tst.w   d2
                bne.s   locret_4FDC

; =============== S U B R O U T I N E =======================================


sub_4FC4:                               ; CODE XREF: ROM:00005014↓p
                move.w  $20(a0),d1
                lea     channel1(pc),a6
                move.l  6(a0),(a6,d1.w)
                move.w  $A(a0),4(a6,d1.w)
                asl     4(a6,d1.w)

locret_4FDC:                            ; CODE XREF: ROM:00004FA2↑j
                                        ; ROM:00004FB4↑j ...
                rts
; End of function sub_4FC4

; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_4FEA
                lsl.b   #4,d1
                bsr.w   asys_ntc_db8

locret_4FEA:                            ; CODE XREF: ROM:00004FE2↑j
                rts
; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_4FF6
                bsr.w   asys_ntc_db8

locret_4FF6:                            ; CODE XREF: ROM:00004FF0↑j
                rts
; ---------------------------------------------------------------------------
                cmp.b   1(a5),d1
                bne.s   locret_5006
                clr.w   $16(a0)
                clr.w   $1A(a0)

locret_5006:                            ; CODE XREF: ROM:00004FFC↑j
                rts
; ---------------------------------------------------------------------------
                cmp.b   1(a5),d1
                bne.s   locret_5018
                tst.w   0(a0)
                beq.s   locret_5018
                bsr.w   sub_4FC4

locret_5018:                            ; CODE XREF: ROM:0000500C↑j
                                        ; ROM:00005012↑j
                rts
; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_502C
                tst.b   $791(a5)
                bne.s   locret_502C
                addq.b  #1,d1
                move.b  d1,$790(a5)

locret_502C:                            ; CODE XREF: ROM:0000501E↑j
                                        ; ROM:00005024↑j
                rts
; ---------------------------------------------------------------------------
                tst.b   1(a5)
                bne.s   locret_FCC
                lsl.b   #4,d1
                andi.b  #$F,$28(a0)
                or.b    d1,$28(a0)
                tst.b   d1
                beq.s   locret_FCC

; =============== S U B R O U T I N E =======================================

; ===========================================================================
; asys_ntE:                                
; ===========================================================================
asys_ntE:                                
                moveq   #0,d1
                move.b  $28(a0),d1
                lsr.b   #4,d1
                beq.s   locret_FCC
                lea     $2E0(a5),a1
                move.b  (a1,d1.w),d1
                add.b   d1,$29(a0)
                btst    #7,$29(a0)
                beq.s   locret_FCC
                clr.b   $29(a0)
                move.l  $C(a0),d0
                moveq   #0,d1
                move.w  $10(a0),d1
                add.l   d1,d0
                add.l   d1,d0
                movea.l $2A(a0),a1
                addq.l  #1,a1
                cmpa.l  d0,a1
                bcs.s   loc_FC2
                movea.l $C(a0),a1

loc_FC2:                                
                move.l  a1,$2A(a0)
                moveq   #$FFFFFFFF,d0
                sub.b   (a0),d0
                move.b  d0,(a0)

locret_FCC:                             
                rts

; ---------------------------------------------------------------------------
asys_nt_fce:
                andi.w  #$1F,d1
                beq.s   locret_FDC
                move.b  d1,2(a5)
                clr.b   1(a5)

locret_FDC:                             
                rts
; ---------------------------------------------------------------------------
channel1:       dc.w 0                  
                dc.l 0
                dcb.b 2,0
channel2:       dc.w 0                  
                dc.l 0
                dcb.b 2,0
channel3:       dc.w 0                  
                dc.l 0
                dcb.b 2,0
channel4:       dc.w 0                  
                dc.l 0
                dcb.b 2,0
ntvars:         dc.b 0                  
byte_FFF:       dc.b 0                  
                dcb.l 3,0
                dcb.b 2,0
dword_100E:     dc.l 0                  
.long
                dcb.l $7E,0
word_120C:      dc.w $40                
                                        
word_120E:      dc.w 0                  
                dc.l 1
                dcb.l $C,0
                dc.l 2
                dcb.l 6,0
                dc.l 8
                dcb.l 5,0
                dc.l 4
                dcb.l 6,0
                dc.l $10
                dcb.l 5,0
                dc.l 8
                dcb.l 6,0
                dc.l $18
                dcb.l 4,0
                dc.l 5, $607080A, $B0D1013, $161A202B, $40800018, $314A6178
                dc.l $8DA1B4C5, $D4E0EBF4, $FAFDFFFD, $FAF4EBE0, $D4C5B4A1
                dc.l $8D78614A, $31180358, $32802FA, $2D002A6, $280025C
                dc.l $23A021A, $1FC01E0, $1C501AC, $194017D, $1680153
                dc.l $140012E, $11D010D, $FE00F0, $E200D6, $CA00BE, $B400AA
                dc.l $A00097, $8F0087, $7F0078, $710352, $32202F5, $2CB02A2
                dc.l $27D0259, $2370217, $1F901DD, $1C201A9, $191017B
                dc.l $1650151, $13E012C, $11C010C, $FD00EF, $E100D5, $C900BD
                dc.l $B300A9, $9F0096, $8E0086, $7E0077, $71034C, $31C02F0
                dc.l $2C5029E, $2780255, $2330214, $1F601DA, $1BF01A6
                dc.l $18E0178, $163014F, $13C012A, $11A010A, $FB00ED, $E000D3
                dc.l $C700BC, $B100A7, $9E0095, $8D0085, $7D0076, $700346
                dc.l $31702EA, $2C00299, $2740250, $22F0210, $1F201D6
                dc.l $1BC01A3, $18B0175, $160014C, $13A0128, $1180108
                dc.l $F900EB, $DE00D1, $C600BB, $B000A6, $9D0094, $8C0084
                dc.l $7D0076, $6F0340, $31102E5, $2BB0294, $26F024C, $22B020C
                dc.l $1EF01D3, $1B901A0, $1880172, $15E014A, $1380126
                dc.l $1160106, $F700E9, $DC00D0, $C400B9, $AF00A5, $9C0093
                dc.l $8B0083, $7C0075, $6E033A, $30B02E0, $2B6028F, $26B0248
                dc.l $2270208, $1EB01CF, $1B5019D, $1860170, $15B0148
                dc.l $1350124, $1140104, $F500E8, $DB00CE, $C300B8, $AE00A4
                dc.l $9B0092, $8A0082, $7B0074, $6D0334, $30602DA, $2B1028B
                dc.l $2660244, $2230204, $1E701CC, $1B2019A, $183016D
                dc.l $1590145, $1330122, $1120102, $F400E6, $D900CD, $C100B7
                dc.l $AC00A3, $9A0091, $890081, $7A0073, $6D032E, $30002D5
                dc.l $2AC0286, $262023F, $21F0201, $1E401C9, $1AF0197
                dc.l $180016B, $1560143, $1310120, $1100100, $F200E4, $D800CC
                dc.l $C000B5, $AB00A1, $980090, $880080, $790072, $6C038B
                dc.l $3580328, $2FA02D0, $2A60280, $25C023A, $21A01FC
                dc.l $1E001C5, $1AC0194, $17D0168, $1530140, $12E011D
                dc.l $10D00FE, $F000E2, $D600CA, $BE00B4, $AA00A0, $97008F
                dc.l $87007F, $780384, $3520322, $2F502CB, $2A3027C, $2590237
                dc.l $21701F9, $1DD01C2, $1A90191, $17B0165, $151013E
                dc.l $12C011C, $10C00FD, $EE00E1, $D400C8, $BD00B3, $A9009F
                dc.l $96008E, $86007E, $77037E, $34C031C, $2F002C5, $29E0278
                dc.l $2550233, $21401F6, $1DA01BF, $1A6018E, $1780163
                dc.l $14F013C, $12A011A, $10A00FB, $ED00DF, $D300C7, $BC00B1
                dc.l $A7009E, $95008D, $85007D, $760377, $3460317, $2EA02C0
                dc.l $2990274, $250022F, $21001F2, $1D601BC, $1A3018B
                dc.l $1750160, $14C013A, $1280118, $10800F9, $EB00DE, $D100C6
                dc.l $BB00B0, $A6009D, $94008C, $84007D, $760371, $3400311
                dc.l $2E502BB, $294026F, $24C022B, $20C01EE, $1D301B9
                dc.l $1A00188, $172015E, $14A0138, $1260116, $10600F7
                dc.l $E900DC, $D000C4, $B900AF, $A5009C, $93008B, $83007B
                dc.l $75036B, $33A030B, $2E002B6, $28F026B, $2480227, $20801EB
                dc.l $1CF01B5, $19D0186, $170015B, $1480135, $1240114
                dc.l $10400F5, $E800DB, $CE00C3, $B800AE, $A4009B, $92008A
                dc.l $82007B, $740364, $3340306, $2DA02B1, $28B0266, $2440223
                dc.l $20401E7, $1CC01B2, $19A0183, $16D0159, $1450133
                dc.l $1220112, $10200F4, $E600D9, $CD00C1, $B700AC, $A3009A
                dc.l $910089, $81007A, $73035E, $32E0300, $2D502AC, $2860262
                dc.l $23F021F, $20101E4, $1C901AF, $1970180, $16B0156
                dc.l $1430131, $1200110, $10000F2, $E400D8, $CB00C0, $B500AB
                dc.l $A10098, $900088, $800079, $720000
                dcb.b 2,0
snd_tabl:      dc.w 0                  
                                        ; initpit2+14↑o ...
                dcb.l $192,0
sampleno:     dc.l $FFFFFFFF          
localdata:     dcb.l 4,0               
                                        
dword_1DF0:     dc.l 2                  
                                        
                dc.l $10000, 0
                dc.b 0, $C0
MUSVOL:     dc.l $60                
.long
                dc.b 1, 0
FXENA:      dc.b 1                  
                                        
MUSENA:      dc.b 0                  
                                        
dword_1E08:     dcb.l 3,0               
GPUSTART:
                dc.l $9800B022, $F1D000
                dcb.l 2,$E400E400
                dc.l $A53D3C7D, $A7FE395D, $85E089F, $8C20D3C0, $BD3D981F
                dc.l $B01000F1, $93FF9809, $A10000F1, $981BB800, $F19807
                dc.l $B36000F1, $980A0020, $980B, $FF0000, $980D7FFF, $91B9
                dc.l $980CFFFC, $FFFF981C, $B35800F1, $A52E38AE, $BD2EE400
                dc.l $E400980D, $B35800F1, $8B6FA5BC, $A5ED9812, $B0B600F1
                dc.l $798D88F3, $D242341C, $D242E400, $B063B0D3, $B0440073
                dc.l $B0217A64, $9033D554, $37E1D461, $88F3D240, $BDECB0A5
                dc.l $B0E28C13, $C845C882, $8A68C8D3, $6513B082, $25680053
                dc.l $9100014F, $A5ED9812, $B0FE00F1, $798D88F4, $D242343C
                dc.l $D242E400, $B063B0D4, $B0440074, $B0217A84, $9034D554
                dc.l $37E1D461, $88F4D240, $BDECB0A5, $B0E28C14, $C845C882
                dc.l $8A88C8D4, $6514B082, $25680054, $9101014F, $A5ED9812
                dc.l $B14600F1, $798D88F5, $D242345C, $D242E400, $B063B0D5
                dc.l $B0440075, $B0217AA4, $9035D554, $37E1D461, $88F5D240
                dc.l $BDECB0A5, $B0E28C15, $C845C882, $8AA8C8D5, $6515B082
                dc.l $25680055, $9102014F, $A5ED9812, $B18E00F1, $798D88F6
                dc.l $D242347C, $D242E400, $B063B0D6, $B0440076, $B0217AC4
                dc.l $9036D554, $37E1D461, $88F6D240, $BDECB0A5, $B0E28C16
                dc.l $C845C882, $8AC8C8D6, $6516B082, $25680056, $9103014F
                dc.l $A5ED9812, $B1D600F1, $798D88F7, $D242349C, $D242E400
                dc.l $B063B0D7, $B0440077, $B0217AE4, $9037D554, $37E1D461
                dc.l $88F7D240, $BDECB0A5, $B0E28C17, $C845C882, $8AE8C8D7
                dc.l $6517B082, $25680057, $9104014F, $A5ED9812, $B21E00F1
                dc.l $798D88F8, $D24234BC, $D242E400, $B063B0D8, $B0440078
                dc.l $B0217B04, $9038D554, $37E1D461, $88F8D240, $BDECB0A5
                dc.l $B0E28C18, $C845C882, $8B08C8D8, $6518B082, $25680058
                dc.l $91059E70, $C339206, $9E719E90, $92270C34, $92089E91
                dc.l $9EB09229, $C35920A, $9EB19ED0, $922B0C36, $920C9ED1
                dc.l $9EF0922D, $9F119210, $9232A52D, $39CDBD2D, $E400E400
                dc.l $957B6306, $101B6307, $47664407, $C7957B, $6308103B
                dc.l $63094768, $44290109, $957B630A, $105B630B, $476A444B
                dc.l $14B957B, $630C107B, $630D476C, $446D018D, $6D074667
                dc.l $6D096DE7, $46896D0B, $6DE946AB, $6D0D6DEB, $46CD6310
                dc.l $6DED46F0, $63126DF0, $47126DF2, $9806B35C, $F1980A
                dc.l $3FFF0000, $A4C89806, $B30200F1, $7C08D0C1, $E4009806
                dc.l $60000000, $98081FFF, $48E6, $51285168, $51A6520A
                dc.l $524A4C1D, $48E85126, $516651A8, $520A524A, $4C1E9806
                dc.l $B32400F1, $E400D0C0, $E400980A, $3FFF0000, $48EA512A
                dc.l $516A51AA, $520A524A, $4C1D48EA, $512A516A, $51AA520A
                dc.l $524A4C1E, $9534A693, $3DD3BE93, $E400E400, $7C00D7C2
                dc.l $E40097B9, $97DA980E, $A14800F1, $6DF96DFA, $8419841A
                dc.l $BDD9088E, $9812B066, $F1BDDA, $D2408C00
                dcb.l 2,$FFFFFFFF
                dc.l 0
; end of 'ROM'
GPUEND:


                END
