//---------Written By Shi Liyu 2018.12.31
//		Connections:
//			Segement Enable:P0.0-P0.7;
//			Segement Control:P2.0-P2.7
//			LED Control:P1.0-P1.5
//			N-S:P1.0-GREEN1,P1.1-YELLOW1,P1.2-RED1
//			E-W:P1.3-GREEN2,P1.4-YELLOW2.P1.5-RED2 

//��������
		REDTIME	EQU 30H
		GREENTIME EQU 31H
//�������
		ORG 0000H
		LJMP MAIN
		ORG 000BH
		LJMP COUNTTIME ;��ʱ��0�ж�
		ORG 0003H
		LJMP CHANMODE ;�ⲿ�ж�0
//������
		ORG 0100H
MAIN:
;1.�������
;2.��ʼ����ʱ��0���ⲿ�ж�
		MOV TMOD,#01H	   	;���÷�ʽ1
		MOV TH0,#0ECH	   	;��ʱ5ms�Ķ�ʱ����
		MOV TL0,#76H
		SETB TR0		   	;������ʱ��
		SETB ET0		   	;����ʱ���ж�
		SETB EX0			;�����ⲿ�ж�
		SETB IT0			;�½��ش�����ʽ
		SETB EA			   	;����CPU�ж�
;3.���������ֵ
		MOV R0,#0
		MOV REDTIME,#25		;�����ʼ25s
		MOV GREENTIME,#20	;�̵���ʼ20s
		MOV P0,#0FFH		;�����ȫ����
		MOV P2,#00H			;���������ÿ�ζ�����
		MOV P1,#00H			;ÿ����������ܶ�����

		MOV R1,GREENTIME		;R1����ʵʱ�仯���ϱ�ʱ��
		MOV R2,REDTIME	;R2����ʵʱ�仯�Ķ���ʱ��

		SETB P1.0			;��ʼ״̬���ϱ��̵���
		SETB P1.5			;��ʼ״̬�����������
		MOV R3,#1			;��¼���еĽ׶�
		MOV R4,#0			;��¼�����λѡ�ź�	
		MOV R5,#0			;��¼�̵���˸����
		MOV R7,#0			;��¼����ģʽ0Ϊ�������У�1Ϊ����ģʽ	
;4.��ʼLED��SEG��ʼ����ʱ����
LOOP:	CJNE R7,#1,WORK		;����ģʽ�ж�
		LCALL SETMODE		;R7=1,���������ģʽ
		JMP LOOP			;����ģʽ�жϵ�ѭ��

WORK:	CJNE R0,#200,LOOP	;����ģʽ
		MOV R0,#0			;R0=200��Ϊ1s���е���ʱʱ��ı仯
		DEC R1
		DEC R2
		LCALL TWINKGREEN	;�̵���˸�ӳ����ж��̵��Ƿ���˸���Ƿ�ִ����˸��
		LCALL  STAGECHAN	;���еĽ׶ε��жϣ���һ���׶εĵ���ʱ���֮�����¸�ֵ
		JMP LOOP

//-----��ʱ��0�ж����ڶ�ʱ-----
		ORG 0300H
COUNTTIME:
		MOV TH0,#0ECH
		MOV TL0,#76H		;��ʱ����װ	
		CJNE R7,#0,STEPR0	
		INC R0				;R0��¼�ж�ִ�еĴ�����ÿִ��һ�μ�1
STEPR0:	INC R4				;R4ΪƬѡ�ź�
		CJNE R4,#8,TODISP
		MOV R4,#0
TODISP:	LCALL DISPSEG		;��������ܵ�Ƭѡ�źŽ�����ʾ
DONTIME:RETI

//-----�ⲿ�ж�0������ģʽ�ı�-----
		ORG 0400H
CHANMODE:
		INC R7
		CJNE R7,#2,REINIT
		MOV R7,#0

REINIT:	MOV R2,#0			 ;��־λ���㣬һ�д�ͷ��ʼ
		MOV R3,#1			
		MOV R4,#0				
		MOV R5,#0
		MOV R1,GREENTIME
		MOV R2,REDTIME
		MOV P1,#00H
		SETB P1.0
		SETB P1.5
DONSTOP:RETI

//-----�ӳ���-----------------------------------
;0 ����ģʽ
SETMODE:								
CHECKEY:JB P3.3,CKEYDO
		LCALL DELAY50
		LCALL DELAY50  ;��ʱ������
WTKUP:	JB P3.3,FINUP
		JMP WTKUP	   ;�ȴ���������
FINUP:	LCALL INCTIME  ;��ɰ�����һ�ζ���֮���������������
		JMP DONSET

CKEYDO:	JB P3.4,DONSET
		LCALL DELAY50
		LCALL DELAY50  ;��ʱ����
WTKUP2:	JB P3.4,FINDON ;�ȴ���������
		JMP WTKUP2	   ; ��ɰ�����һ�ζ���֮����������ļ���
FINDON:	LCALL DECTIME
DONSET:	
		MOV R1,GREENTIME
		MOV R2,REDTIME 
		RET

;0.1����ģʽʱ���
INCTIME:MOV A,GREENTIME
		CJNE A,#90,INCON  ;����̵�ʱ��Ϊ90s(���95s)
		JMP DONINC
INCON:	ADD A,#5
		MOV GREENTIME,A
		MOV A,REDTIME
		ADD A,#5
		MOV REDTIME,A
		MOV R1,GREENTIME
		MOV R2,REDTIME
DONINC: 
		MOV R1,GREENTIME
		MOV R2,REDTIME 
		RET
;0.2����ģʽʱ���			
DECTIME:MOV A,GREENTIME
		CJNE A,#10,DECON  ;����̵�ʱ��Ϊ10s(���15s)
		JMP DONDEC
DECON:	SUBB A,#5
		MOV GREENTIME,A
		MOV A,REDTIME
		SUBB A,#5
		MOV REDTIME,A
		MOV R1,GREENTIME
		MOV R2,REDTIME
DONDEC:	RET
;DELAY50MS�ӳ���50ms��
DELAY50:MOV R6,#200
H2:		MOV R0,#125
H1:		DJNZ R0,H1
		DJNZ R6,H2
		RET
;1.�̵���˸�ӳ���
TWINKGREEN:
		CJNE R3,#1,TOTAG3
		CJNE R1,#3,DONTWINK
WT1:	CJNE R0,#100,WT1
		MOV R0,#0
		CPL P1.0
		INC R5
		CJNE R5,#2,WT1
		MOV R5,#0
		DEC R1
		DEC R2
		CJNE R1,#0,WT1
		JMP DONTWINK		

TOTAG3:	CJNE R3,#3,DONTWINK
		CJNE R2,#3,DONTWINK
WT2:	CJNE R0,#100,WT2
		MOV R0,#0
		CPL P1.3
		INC R5
		CJNE R5,#2,WT2
		MOV R5,#0
		DEC R1
		DEC R2
		CJNE R2,#0,WT2
DONTWINK:RET
;2.���н׶ε��ж��뵹��ʱ���¸�ֵ�ӳ���
STAGECHAN:		
		CJNE R1,#0,COMR2	;��鶫���ϱ��ĵ���ʱ�Ƿ�Ϊ0���������н׶�
		JMP INCR3
COMR2:	CJNE R2,#0,DONESTAGE;����Ϊ0��û�н׶εı仯
INCR3:	INC R3

		CJNE R3,#5,STAGE1
		MOV R3,#1

STAGE1:	CJNE R3,#2,STAGE2
		MOV R1,#5
		CPL P1.0		   	;�ϱ��̵��𣬻Ƶ���
		CPL P1.1

STAGE2:	CJNE R3,#3,STAGE3
		MOV R1,REDTIME
		MOV R2,GREENTIME
		CPL P1.1
		CPL P1.2			;�ϱ��Ƶ�������
		CPL P1.5			;����������̵���
		CPL P1.3
STAGE3:	CJNE R3,#4,STAGE4
		MOV R2,#5
		CPL P1.3
		CPL P1.4			;�����̵��𣬻Ƶ���
STAGE4:	CJNE R3,#1,DONESTAGE
		MOV R1,GREENTIME
		MOV R2,REDTIME
		CPL P1.4
		CPL P1.5			;�����Ƶ����̵���
		CPL P1.0   			;�ϱ�������̵���
		CPL P1.2
		CPL P
DONESTAGE:RET	
;3.�������ʾ�ӳ���
DISPSEG:
		MOV A,R4
		MOV DPTR,#SEGCON
		MOVC A,@A+DPTR
		MOV P0,A			;�����ʹ��		

		CJNE R4,#0,SEG1		;�ж�����һλ�������
		MOV A,R1			;����ǵ�һ�������������Ϊ�ϱ���ʾ
		MOV B,#10			
		DIV AB
		MOV DPTR,#NUM;*********************************
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ��ʮλ

SEG1: 	CJNE R4,#1,SEG2
		MOV A,R1
		MOV B,#10
		DIV AB
		MOV A,B
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ����λ

SEG2:	CJNE R4,#2,SEG3
		MOV A,R2
		MOV B,#10
		DIV AB
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ��ʮλ

SEG3:	CJNE R4,#3,SEG4
		MOV A,R2
		MOV B,#10
		DIV AB
		MOV A,B
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ����λ

SEG4:	CJNE R4,#4,SEG5
		MOV A,R1
		MOV B,#10
		DIV AB
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ��ʮλ

SEG5: 	CJNE R4,#5,SEG6
		MOV A,R1
		MOV B,#10
		DIV AB
		MOV A,B
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			;��ʾ�ϸ�λ

SEG6:	CJNE R4,#6,SEG7
		MOV A,R2
		MOV B,#10
		DIV AB
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			 ;��ʾ��ʮλ

SEG7:	CJNE R4,#7,FINDISP
		MOV A,R2
		MOV B,#10
		DIV AB
		MOV A,B
		MOV DPTR,#NUM
		MOVC A,@A+DPTR
		MOV P2,A			 ;��ʾ����λ
FINDISP:RET					 ;������ʾ�����򷵻�
	;���飺NUM�����������ʾ���֣�SEGCON���������ʹ���źţ�����ܵ͵�ƽ����
NUM: DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
SEGCON: DB 0FEH,0FDH,0FBH,0F7H,0EFH,0DFH,0BFH,07FH
		END
