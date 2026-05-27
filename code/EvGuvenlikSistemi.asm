        LIST P=16F628A
        INCLUDE "P16F628A.INC"

        __CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF & _LVP_OFF & _CP_OFF


;-------------------------------------------------
; S1 Ana kapi sensörü        -> RB4
; S2 Pencere sensörü         -> RB5
; S3 Havalandirma sensörü    -> RB6
; S4 Balkon kapisi sensörü   -> RB7
;
; Siren                      -> RA0
; Kapi biber gazi sistemi    -> RA1
; Pencere biber gazi sistemi -> RA2
;-------------------------------------------------

        CBLOCK h'20'
        W_TEMP
        STATUS_TEMP
        ENDC

        ORG h'000'
        GOTO BASLA

        ORG h'004'
        GOTO KESME_PROG

;-------------------------------------------------
; Ana program
;-------------------------------------------------
BASLA
        ; PORTA dijital cikis olarak kullanilacagi icin
        ; analog karsilastiricilar kapatilir.
        MOVLW h'07'
        MOVWF CMCON

        ; Port ayarlari
        BSF STATUS, RP0

        MOVLW b'11110000'
        MOVWF TRISB          ; RB4-RB7 giris

        MOVLW b'00000000'
        MOVWF TRISA          ; RA0-RA2 cikis

        BCF STATUS, RP0

        CLRF PORTA           ; Baslangicta siren ve gaz sistemleri kapali
        CLRF PORTB

        MOVF PORTB, W        ; RB4-RB7 ilk okuma

        BCF INTCON, RBIF     ; RBIF bayragi temizlenir
        BSF INTCON, RBIE     ; PORTB RB4-RB7 lojik seviye degisiklik kesmesi aktif
        BSF INTCON, GIE      ; Genel kesmeler aktif

ANA_DONGU
        GOTO ANA_DONGU

;-------------------------------------------------
; Kesme alt programi
;-------------------------------------------------
KESME_PROG
        ; W ve STATUS saklanir
        MOVWF W_TEMP
        SWAPF STATUS, W
        MOVWF STATUS_TEMP

        ; Bank 0'a gecilir
        BCF STATUS, RP0
        BCF STATUS, RP1

        ; RB4-RB7 kesmesinde once PORTB okunmalidir
        MOVF PORTB, W

        ; Sadece RB4-RB7 kontrol edilir
        ANDLW b'11110000'

        ; Sonuc 0 degilse en az bir sensor aktiftir
        BTFSS STATUS, Z
        GOTO ALARM_AC

ALARM_KAPAT
        CLRF PORTA
        GOTO KESME_BITIR

ALARM_AC
        MOVLW b'00000111'    ; RA0, RA1, RA2 aktif
        MOVWF PORTA

KESME_BITIR
        BCF INTCON, RBIF     ; RBIF bayragi temizlenir

        ; W ve STATUS geri yuklenir
        SWAPF STATUS_TEMP, W
        MOVWF STATUS
        SWAPF W_TEMP, F
        SWAPF W_TEMP, W

        RETFIE

        END


