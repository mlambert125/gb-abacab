; ---------------------------------------------------------------------------------------------------------------------
;
;   Simple ABACAB display demo
;
; ---------------------------------------------------------------------------------------------------------------------
INCLUDE "./src/hardware.inc"

; *********************************************************************************************************************
;   Constants
; *********************************************************************************************************************
; Tile Constants
DEF TILE_BLANK EQU $00
DEF TILE_A EQU $01
DEF TILE_B EQU $02
DEF TILE_C EQU $03

; Row/Col offsets for the tilemap (add to the base address of the tilemap to get the address of a specific tile)
DEF ROW_OFFSET EQU $20
DEF COL_OFFSET EQU $01

; Pallette Constants
DEF PAL_DEFAULT EQU %11100100



; *********************************************************************************************************************
;   Header / Initialization
; *********************************************************************************************************************
SECTION "Header", ROM0[$100]
	jp EntryPoint  ; Jump past this header block to the actual "game"
	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Disable audio
	ld a, 0         ; 0 = off, 80 = on
	ld [rNR52], a   ; rNR52 is the audio control register 

WaitVBlank:
	ld a, [rLY]      ; rLY is the current scanline
	cp SCRN_Y        ; compare current to the last scanline 
	jp c, WaitVBlank ; if the comparison set the carry flag, then the comparison failed, so we're not in VBlank yet

	; Turn the LCD off
	ld a, LCDCF_OFF 
	ld [rLCDC], a   ; rLCDC is the LCD control register
    
CopyTiles:
	; Copy the tile data to VRAM
	ld de, Tiles
	ld hl, _VRAM9000
	ld bc, TilesEnd - Tiles
CopyTilesLoop:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTilesLoop

ClearTilemap:
    ld hl, _SCRN0  ; Start of tilemap
    ld bc, 1024 ; Countdown from 1024 to 0
ClearTilemapLoop:
    ld a, 0     ; Load 0 into A (have to do this because ldi doesn't accept immediate values)
    ld [hli], a ; Write 0 to the tilemap VRAM and increment hl to point to the next tile VRAM location
    dec bc      ; decrement the countdown
    ld a, b     ; load the high byte of bc into A
    or a, c     ; logical OR the high byte with the low byte. If the result is 0, then bc is 0
    jp nz, ClearTilemapLoop ; Loop if we aren't at zero yet on the count down

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a

	; During the first (blank) frame, initialize pallette 
    ; Display intensity for each pallette color
	ld a, PAL_DEFAULT 
	ld [rBGP], a

    ; Set wFrameCount variable to 0
    ld a, 0
    ld [wFrameCount], a


    
; *********************************************************************************************************************
;   Main Loop
; *********************************************************************************************************************
Main:
WaitForNonVBlankLoop:
    ; Wait until it's *not* VBlank to get on a new cycle
    ld a, [rLY] ; rLY is the current scanline
    cp SCRN_Y   ; compare current to the last non-vblank scanline
    jp nc, WaitForNonVBlankLoop
WaitVBlankMainLoop:
    ; Wait until it *is* VBlank
	ld a, [rLY]
	cp SCRN_Y  
	jp c, WaitVBlankMainLoop

UpdateState:
    ld a, [wFrameCount]

ShowA1:
    ; Jump to next if not on frame 0 (if we're here, register A holds the frame count)
    cp 0
    jp nz, ShowB1

    ; Put TILE_A at position row 8, column 7 
    ld a, TILE_A 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 7)], a
    jp IncrementFrameCount

ShowB1:
    ; Jump to next if not on frame 16 (if we're here, register A holds the frame count)
    cp 16  
    jp nz, ShowA2

    ; Put TILE_B at position row 8, column 8
    ld a, TILE_B 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 8)], a
    jp IncrementFrameCount

ShowA2:
    ; Jump to next if not on frame 32 (if we're here, register A holds the frame count)
    cp 32 
    jp nz, ShowC

    ; Put TILE_A at position row 8, column 9
    ld a, TILE_A 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 9)], a
    jp IncrementFrameCount

ShowC:
    ; Jump to next if not on frame 48 (if we're here, register A holds the frame count)
    cp 48 
    jp nz, ShowA3

    ; Put TILE_C at position row 8, column 10
    ld a, TILE_C 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 10)], a
    jp IncrementFrameCount

ShowA3:
    ; Jump to next if not on frame 64 (if we're here, register A holds the frame count)
    cp 64
    jp nz, ShowB2

    ; Put TILE_A at position row 8, column 11
    ld a, TILE_A 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 11)], a
    jp IncrementFrameCount

ShowB2:
    ; Jump to next if not on frame 80 (if we're here, register A holds the frame count)
    cp 80
    jp nz, IncrementFrameCount 

    ; Put TILE_B at position row 8, column 11
    ld a, TILE_B 
    ld [_SCRN0 + (ROW_OFFSET * 8) + (COL_OFFSET * 12)], a
    jp IncrementFrameCount

IncrementFrameCount:
    ld a, [wFrameCount]
    inc a
    ld [wFrameCount], a

EndOfMain:
	jp Main 

; *********************************************************************************************************************
;  Variables 
; *********************************************************************************************************************
Section "Variables", WRAM0[$C000]
    wFrameCount: db     ; Rolling frame count (0-255)

; *********************************************************************************************************************
;   Static Data
; *********************************************************************************************************************
SECTION "Data", ROM0
Tiles:
    ; Empty tile
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000

    ; Leter A
	dw `00000000
	dw `00333300
	dw `00300300
	dw `03300330
	dw `03000030
	dw `03333330
	dw `03000030
	dw `03000030

    ; Letter B
	dw `00000000
	dw `03333000
	dw `03000300
	dw `03000300
	dw `03333330
	dw `03000030
	dw `03000030
	dw `03333330

    ; Letter C
	dw `00000000
	dw `00333300
	dw `03300330
	dw `03000000
	dw `03000000
	dw `03000000
	dw `03300330
	dw `00333300
TilesEnd:

