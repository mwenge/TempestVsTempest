
dcb.l 2,0
.org $0000

        ; Clear the first 256 bytes of the object.
        lea     $100000,a6
        movea.l a6,a1
        move.l  #255,d0
xxxa:   clr.l   (a1)+
        dbf     d0,xxxa
 
    stop #$2700

