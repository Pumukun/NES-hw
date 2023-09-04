.segment "HEADER"
    .byte "NES"     ;identification string
    .byte $1A       
    .byte $02       ;amount of RPG ROM in 16K units
    .byte $01       ;amount of CHR ROM in 8K units
    .byte $00       ;mapper and mirroring
    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"
VAR:    .RES 1      ;reverses 1 byte of memory

.segment "STARTUP"

RESET:
    SEI         ;disables interrupts
    CLD         ;turns off decimal mode

    LDX #%1000000       ;disable sound IRQ
    STX $4017
    LDX #$00
    STX $4010       ;disable PCM

    ;initialize the stack register
    LDX #$FF
    TXS         ;transfer X to the stack

    ;clear PPU registers
    LDX #$00
    STX $2000
    STX $2001

    ;WAIT FOR VBLANK
:
    BIT $2002
    BPL :-

    ;CLEAR 2K MEMORY
    TXA
CLEARMEMORY:    ;$0000 - &07FF
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    
    LDA #$FF
    STA $0200, X
    LDA #$00

    INX
    CPX #$00
    BNE CLEARMEMORY

    ;WAIT FOR VBLANK
:
    BIT $2002
    BPL :-

    ;SETTING SPRITE RANGE
    LDA #$02
    STA $4014

    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
LOADPALLETES:
    LDA PALETTEDATA, X
    STA $2007
    INX
    CPX #$20
    BNE LOADPALLETES


    LDX #$00
LOADSPRITES:
    LDA SPRITEDATA, X
    STA $0200, X
    INX
    CPX #$28    ;16bytes (4 bytes per sprite)
    BNE LOADSPRITES

;ENABLE INTERRUPTS
    CLI

    LDA #%10010000
    STA $2000

    LDA #%00011110      ;show sprites
    STA $2001

    INFLOOP:
        JMP INFLOOP

NMI:
    LDA #$02
    STA $4014

    RTI

PALETTEDATA:
	.byte $00, $0F, $00, $10, 	$00, $0A, $15, $01, 	$00, $29, $28, $27, 	$00, $34, $24, $14 	;background palettes
	.byte $31, $0F, $15, $30, 	$00, $0F, $11, $30, 	$00, $0F, $30, $27, 	$00, $3C, $2C, $1C 	;sprite palettes

SPRITEDATA:
    .byte $40, $3D, $00, $40 ;H
	.byte $40, $3E, $00, $48 ;E
	.byte $40, $B4, $00, $50 ;L
	.byte $40, $B4, $00, $58 ;L
    .byte $40, $47, $00, $60 ;O

    .byte $48, $9B, $00, $40 ;W 
    .byte $48, $47, $00, $48 ;O
    .byte $48, $31, $00, $50 ;R
    .byte $48, $B4, $00, $58 ;L
    .byte $48, $93, $00, $60 ;D

.segment "VECTORS"
    .word NMI
    .word RESET

.segment "CHARS"
    .incbin "rom.chr"
