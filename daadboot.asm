; TO BE COMPILED WITH SJASMPLUS

            org         $2000                       
            output      BETADISK.SYS
            ; --- ESXDOS FUNCTIONS
            define      M_GETSETDRV   $89
            define      F_OPEN        $9a
            define      F_CLOSE       $9b
            define      F_READ        $9d
            define      F_CHDIR       $a9
            ; --- FILE OPEN MODES
            define      FA_READ       1
            define      FA_CREATE_AL  12


; ---------------------- MAIN -------------------------------------------

Start       ; --- Place the stack at a proper place and change to IM1
            DI
            LD SP, $6000


            ; Clears the RAM by setting all values from $4000 to $FFFF to 0
ClearRAM    XOR A
            LD HL, $4000
            LD (HL), A
            LD DE, $4001
            LD BC, $FFFF-$4000-1
            LDIR


            ; --- Load DDB file
            LD IX, $8400
            LD HL, DDBFile
            LD DE, $8000            ; In excess, just to be sure it is full loaded
            CALL LoadFile        
            JR C, Error


            ; --- Load VAR, system variables
            LD IX, $5C00
            LD HL, VARFile
            LD DE, 256
            CALL LoadFile        
            JR C, Error

            ; --- Load code file
            LD IX, $6000
            LD HL, InterpreterFile
            LD DE, $8000            ; In excess, just to be sure it is full loaded
            CALL LoadFile        
            JR C, Error


            ; --- Load SDG
            LD IX, $F7D7
            LD HL, SDGFile
            LD DE, $2000            ; In excess, just to be sure it is full loaded
            CALL LoadFile        
            JR C, Error

            ; --- Load CHR, which is loaded over the SDG file, at the point where the charset is for ZX Spectrum
            LD IX, $F7E4
            LD HL, CHRFile
            LD DE, 2048             ; In excess, just to be sure it is full loaded
            CALL LoadFile        
            OR A                    ; CHR file may be absent, ignore if it fails and clear carry flag

            ; -- This code just makes sure the stack is clean, cause every CALL to LoadFile is storing a value in the stack different than zero
            LD HL, 0
            PUSH HL
            POP HL
            
            ; --- Enable interrupts in IM1 mode
            IM 1
            EI
            
            ; -- DAAD Expects the following registers to have these values
            LD SP, $5FE8
            LD IY, $5C3A
            
            ; --- Jump to entry address for the game, but passing trough 1FFBh so ESXDOS ROM is paged out (and back to normal Spectrum ROM)
            LD HL, $6000
            JP 1FFBh          ; Contains JP (HL)
 

      

; ---------------------- FUNCTIONS -------------------------------------------

; Error: at this moment in case of error we just freeze the Spectrum
Error       DI 
            HALT

; LoadFile: loads a file or part of a file at a given address
; Parameters    HL: points to zero terminated string  (file name)
;               IX: Load Address 
;               DE: Bytes to load, if file is shorter, it will be loaded anyway
; Output        Carry flag set of error. HL, DE, BC, IX, A and F are modified
LoadFile    XOR A
            RST $08
            DB M_GETSETDRV ; Set drive
            RET C

            LD B, FA_READ   
            RST $08
            DB F_OPEN      ;Open file
            RET C

            LD (fileHandle),A
            PUSH IX
            POP HL
            PUSH DE
            POP  BC
            RST $08
            DB F_READ      ; read file
            RET C

            LD A,(fileHandle)
            RST $08
            DB F_CLOSE     ; close file
            RET


; ---------------------- DATA -------------------------------------------
fileHandle         DB 0
DDBFile            DB 'DAAD.DDB', 0
CHRFile            DB 'DAAD.CHR', 0
SDGFile            DB 'DAAD.SDG', 0
InterpreterFile    DB 'DAAD.BIN', 0
VARFile            DB 'DAAD.VAR', 0
