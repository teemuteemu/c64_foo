*       = $0801
        .word (+), 10  ;pointer, line number
        .null $9e, format("%d", start) ;will be sys 2061
+	.word 0          ;basic line end

*       = $1000

voice1FreqH = $d400
voice1FreqL = $d401
voice1Ctrl = $d404
voice1EnvAD = $d405
voice1EnvSR = $d406

masterCtrl = $D418

freq .word $0430
freqH = $f0
freqL = $f1
adenv .byte $02
srenv .byte $00
tickcounter =$fa
speed = #50 ; wait for 50 * 1/50 sec

start:
  lda <freq
  sta freqL
  lda >freq
  sta freqH

; clear all sid registers to 0
  ldx #$00
  lda #$00
  sta tickcounter
clearsidloop: ; SID registers start at $d400
  sta $d400, x
  inx
  cpx #$29 ; and there are 29 of them
  bne clearsidloop

  ; set master volume and turn filter off
  lda #%00001111
  sta masterCtrl

  sei

mainloop:
  lda #$fb
loop:
  cmp $d012 
  bne loop

  inc tickcounter
  lda tickcounter
  cmp speed
  bne mainloopend

  lda #0
  sta tickcounter

  jsr playnote

mainloopend:
  lda #$fb
syncloop:
  cmp $d012 
  beq syncloop
  jmp mainloop

playnote:
  inc $d020

  ; reset gatebit/waveform
  lda #%00000000
  sta voice1Ctrl

  ; freq voice 1
  lda freqL
  sta voice1FreqL
  lda freqH
  sta voice1FreqH

  ; adsr voice 1
  lda adenv
  sta voice1EnvAD
  lda srenv
  sta voice1EnvSR

  ; voice 1 ctrl
  lda #%00010001
  sta voice1Ctrl

  dec freqL

  rts
