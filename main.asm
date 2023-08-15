; =========================================================================      
; Project:       
; File:          main.asm
; Description:   
;                 
; Author:        
; Version:       
; Date:         
; =========================================================================
;--------------- File Include ---------------------------------------------
;--------------------------------------------------------------------------
#include		NY8A054E.H						; The Header File for NY8A054E

;--------------- Variable Definition --------------------------------------
;--------------------------------------------------------------------------
		R_Data_G			EQU		0X20
		R_Data_R			EQU		0X21
		R_Data_B			EQU		0X22
		R_Cnt				EQU		0X23
		R_Cnt1				EQU		0X24
		R_Data_G_Buff		EQU		0X25
		R_Data_R_Buff		EQU		0X26
		R_Data_B_Buff		EQU		0X27
		R_GRB_Gear			EQU		0X28
;--------------- Constant Definition --------------------------------------
;--------------------------------------------------------------------------
		C_Colour_Max	    EQU			0xFF			; Example
		C_Colour_Min		EQU			0


;--------------- Vector Definition ----------------------------------------
;--------------------------------------------------------------------------
		ORG		0x000		
		lgoto	V_Main                
		
		ORG		0x008
		lgoto	V_INT
		
;--------------- Code Start -----------------------------------------------
;--------------------------------------------------------------------------
        ORG		0x010         
V_Main:
		; Power ON initial - User program area 
		; ...
		; ...
		bsr		porta,2
		nop
		nop
		clrwdt
		;nop
		;nop
    	movia	0
    	iost	IOSTA
    	movia	0xff
 		movar	R_Data_G_Buff
		movar	R_Data_R_Buff
		movar	R_Data_B_Buff 
		clrr	R_GRB_Gear
		lcall	F_GRB_Init
L_GRB_Loop:   	
		lcall	F_RES_SIGN
L_OUTPUT_LOOP:
		clrwdt	
		movr	R_Data_B_Buff,0
		movar	R_Data_B
		movr	R_Data_R_Buff,0
		movar	R_Data_R
		movr	R_Data_G_Buff,0
		movar	R_Data_G
		lcall	F_LED_OUTPUT_GRB
		
		decrsz	R_Cnt,1
		lgoto	L_OUTPUT_LOOP
		lcall	F_GRB_Init
		
		movia	L_Gear_Switch&0xff
		addar	R_GRB_Gear,0
		
		movia	L_Gear_Switch>>8
		btrsc	status,0
		addia	1
		sfun	TBHP
		movia	L_Gear_Switch&0xff
		addar	R_GRB_Gear,0		
		gotoa
L_Gear_Switch:	
		lgoto	L_Gear_1
		lgoto	L_Gear_2
		lgoto	L_Gear_3
		lgoto	L_Gear_4
		lgoto	L_Gear_5
		lgoto	L_Gear_6
		lgoto	L_Gear_7
	L_Gear_1:
		decr	R_Data_B_Buff,1
		decrsz	R_Data_G_Buff,1
		lgoto	L_GRB_Loop
		;R:255  G:255  B:255->R:255  G:0  B:0
		lgoto	L_Gear_Init
	L_Gear_2:
		incr	R_Data_G_Buff,1
		movia	C_Colour_Max
		cmpar	R_Data_G_Buff
		btrss	status,2
		lgoto	L_GRB_Loop
		;R:255  G:0  B:0->R:255  G:255  B:0
		lgoto	L_Gear_Init
	L_Gear_3:
		decrsz	R_Data_R_Buff,1
		lgoto	L_GRB_Loop
		;R:255  G:255  B:0->R:0  G:255  B:0		
		lgoto	L_Gear_Init
	L_Gear_4:
		incr	R_Data_B_Buff,1
		movia	C_Colour_Max
		cmpar	R_Data_B_Buff
		btrss	status,2
		lgoto	L_GRB_Loop
		;R:0    G:255  B:0->R:0  G:255  B:255		
		lgoto	L_Gear_Init
	L_Gear_5:
		decrsz	R_Data_G_Buff,1
		lgoto	L_GRB_Loop
		;R:0    G:255  B:255->R:0  G:0  B:255		
		lgoto	L_Gear_Init
	L_Gear_6:
		incr	R_Data_R_Buff,1
		movia	C_Colour_Max
		cmpar	R_Data_R_Buff
		btrss	status,2
		lgoto	L_GRB_Loop
		;R:0    G:0  B:255->R:255  G:0  B:255
		lgoto	L_Gear_Init
	L_Gear_7:
		incr	R_Data_G_Buff,1
		movia	C_Colour_Max
		cmpar	R_Data_G_Buff
		btrss	status,2
		lgoto	L_GRB_Loop
		;R:255    G:0  B:255->R:255  G:255  B:255
		
L_Gear_Init:
		incr	R_GRB_Gear,1
		movia	7
		cmpar	R_GRB_Gear
		btrss	status,2
		lgoto	L_GRB_Loop
		clrr	R_GRB_Gear
		
		lgoto	L_GRB_Loop
;L_MainLoop:                                    
;        clrwdt								; Clear WatchDog
		; Main Loop Service -  User program area
		; ...
		; ...
;       lgoto   L_MainLoop
        
;----------------------------        
F_RES_SIGN:
    	bcr		porta,2
    	clrr	R_Data_G	
    	movia	75
    	movar	R_Data_R
L_Low_Delay:
		clrwdt	
		incrsz	R_Data_G,1
		lgoto	L_Low_Delay	
		decrsz	R_Data_R,1
		lgoto	L_Low_Delay
		ret        
;----------------------------        
F_LED_OUTPUT_GRB:
		;200ns指令周期
		clrwdt
L_Output_GRB_DATA:		
		rlr		R_Data_B,1
		rlr		R_Data_R,1
		rlr		R_Data_G,1
		btrsc	status,0
		lgoto	L_Output_1
L_Output_0:		
		;--------------------1
		bsr		porta,2
		nop
		bcr		porta,2
		lgoto	L_Bit_Cnt_Calculate
L_Output_1:
		;---------------------24
		bsr		porta,2
		nop
		nop
		nop
		bcr		porta,2
L_Bit_Cnt_Calculate:
		decrsz	R_Cnt1,1
		lgoto	L_Output_GRB_DATA
		clrr	R_Data_G
		clrr	R_Data_R
		clrr	R_Data_B
		movia	24
		movar	R_Cnt1
		ret
 
 F_GRB_Init:
		movia	30
		movar	R_Cnt
		movia	24
		movar	R_Cnt1
		clrr	R_Data_G
		clrr	R_Data_R
		clrr	R_Data_B
 		ret
;--------------- Interrupt Service Routine --------------------------------
;--------------------------------------------------------------------------
V_INT:
		; Interrupt Service - User program area
		; ...
		; ...
		; Clear Interrupt Flag
		retie								; Return from interrupt and enable interrupt globally
	
end											; End of Code
		