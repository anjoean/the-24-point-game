DATAS SEGMENT
    PLAYTIME DB 9		;用户输入的时间,最大为9分钟 
    INFO1 DB 0AH,0DH,'Please enter the time FROM 1~9(minutes):','$' 
    INFO2 DB 0AH,0DH,'please enter your answer:',0AH,0DH,'$'
	TIMEUP DB 0AH,0DH,'Time is up!','$'
	
	STATE DB 01H		;游戏状态，01代表还有时间，00代表时间到了
	CONTINUE EQU 01H	;游戏继续状态
	
	ANSWER1 DB ?		;不用看这个，只是测试用的
	TIMESTART DB 0	;游戏开始时间
DATAS ENDS

STACKS SEGMENT STACK 'STACK';此处输入堆栈段代码
	DB 100 DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
MAIN PROC
    MOV AX,DATAS
    MOV DS,AX
    
INPUTTIME:
    LEA DX,INFO1	;提示输入时间
    MOV AH,09H
    INT 21H
    
    MOV AH,01H
    INT 21H
    SUB AL,'0'
    
    CMP AL,PLAYTIME		
    JG INPUTTIME		;大于最大时间则重新输入
    MOV PLAYTIME,AL		
    
    MOV AH,2CH			;获取系统时钟
	INT 21H
	MOV TIMESTART,CL	;保存分钟数，作为开始时间
	
GAMELOOP:
	LEA DX,INFO2	;提示游戏开始，用户输入答案
	MOV AH,09H
	INT 21H

INPUT:	
	MOV AH,01H
	INT 21H
	MOV ANSWER1,AL
	
	CALL CHECKTIME
	CMP STATE,CONTINUE			;进入计算结果前，应再次判断是否超时
	
	;此处编写调用计算结果的子模块
	
	
	CALL CHECKTIME
	CMP STATE,CONTINUE			;游戏是否在继续状态
	JE INPUT					;若在“继续”状态，则跳转到输			
	
GAMEEND:
    LEA DX,TIMEUP			;提示用户超时
	MOV AH,09H
	INT 21H
	
    MOV AH,4CH
    INT 21H
    RET
MAIN ENDP

CHECKTIME PROC 
		PUSH AX
		PUSH CX
	
		MOV AH,2CH				;获取系统时钟
		INT 21H
		
		SUB CL,TIMESTART		;做差，表示目前已经花费的时间
		XOR AX,AX
		MOV AL,CL
		MOV CL,60
		DIV CL					;除60后余数放AH
		MOV CL,PLAYTIME
		CMP AH,CL			
		JL CHECKEND				;若仍在时间范围内，则结束判断
		MOV STATE,00H			;时间已大于设定时间，置游戏状态为时间结束状态
		
CHECKEND:
		POP CX
		POP AX
		RET
CHECKTIME ENDP		
		
CODES ENDS
    END MAIN
