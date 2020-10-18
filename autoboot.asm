; TO BE COMPILED WITH SJASMPLUS

            org         $2000                       
            output      BETADISK.SYS
            ; --- ESXDOS FUNCTIONS
            define      M_GETSETDRV   $89
            define      F_OPEN        $9a
            define      F_CLOSE       $9b
            define      F_READ        $9d
            define      F_WRITE       $9e
            ; --- FILE OPEN MODES
            define      FA_READ       1
            define      FA_CREATE_AL  12

            ; --- AUTOEXEC.BIN data
            define      LOAD_ADDRESS      32768 ; Address where to load AUTOEXEC.BIN file
            define      LOAD_SIZE         32768 ; Size of the AUTOEXEC.BIN file (if size if larger than file, file is loaded anyway)
            define      START_ADDRESS     32768 ; Start address to run the game


; ---------------------- MAIN -------------------------------------------

Start       ; --- Place the stack at a proper place and change to IM1
            DI
            LD SP, LOAD_ADDRESS

            ; --- Set default disk    
            XOR A
            RST $08
            DB M_GETSETDRV
            JR C, Error

            ; Clears the RAM by setting all values from $4000 to $FFFF to 0
ClearRAM    XOR A
            LD HL, $4000
            LD (HL), A
            LD DE, $4001
            LD BC, $FFFF-$4000-1
            LDIR
            ; --- Enable interrupts in IM1 mode
            IM 1
            EI

            ; --- Load code file
LoadCode    LD IX, LOAD_ADDRESS
            LD HL, FileName
            LD DE, LOAD_SIZE
            CALL LoadFile        
            JR C, Error

            ; This code just makes sure the stack is clean, cause every CALL to LoadFile is storing a value in the stack different than zero
            LD HL, 0
            PUSH HL
            POP HL
            ; --- Jump to entry address for the game, but passing trough 1FFAh so ESXDOS ROM is paged out (and back to normal Spectrum ROM)
            LD HL, START_ADDRESS
            JP 1FFBh
 

      

; ---------------------- FUNCTIONS -------------------------------------------

; Error: at this moment in case of error we just freeze the Spectrum
Error       DI 
            HALT


; LoadFile: loads a file or part of a file at a given address
; Parameters    HL: points to zero terminated string  (file name)
;               IX: Load Address 
;               DE: Bytes to load, if file is shorter, it will be loaded anyway
; Output        Carry flag set of error. HL, DE, BC, IX, A and F are modified
LoadFile    LD B, FA_READ   
            RST $08
            DB F_OPEN      ;Open file
            RET C
      ; --- Load AUTOEXEC.BIN
            LD (fileHandle),A
            PUSH IX
            POP HL
            PUSH DE
            POP  BC
            RST $08
            DB F_READ      ; read file
            RET C
      ; --- Close file      
            LD A,(fileHandle)
            RST $08
            DB F_CLOSE     ; close file
            RET


; ---------------------- DATA -------------------------------------------
fileHandle  DB 0
FileName    DB 'AUTOEXEC.BIN', 0
