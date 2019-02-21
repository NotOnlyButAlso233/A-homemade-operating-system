;����ϵͳ���س������ڽ�����ϵͳ���ص��ڴ�
	CYLS    EQU        10        ;����ȡ10������

        ORG        0x7c00            ; �������ڴ��м��ص���ʼ��ַ��0x7c00--0x7cffΪ��������������ڴ棩

; ��������Ǳ�׼FAT12��ʽ����ר�õĴ���

        JMP        entry
        DB        0x90
        DB        "HELLOIPL"        ; freeparam �����������ƿ�����������ַ�����8�ֽڣ�
        DW        512                ; ÿ��������sector���Ĵ�С������Ϊ512�ֽڣ�
        DB        1                ; �أ�cluster���Ĵ�С������Ϊ1��������
        DW        1                ; FAT����ʼλ�ã�һ��ӵ�һ��������ʼ��
        DB        2                ; FAT�ĸ���������Ϊ2��
        DW        224                ; ��Ŀ¼�Ĵ�С��һ�����224�
        DW        2880            ; �ô��̵Ĵ�С��������2880������
        DB        0xf0            ; ���̵����ࣨ������0xf0��
        DW        9                ; FAT�ĳ��ȣ�������9������
        DW        18                ; 1���ŵ���track���м���������������18��
        DW        2                ; ��ͷ����������2��
        DD        0                ; ��ʹ�÷�����������0
        DD        2880            ; ��дһ�δ��̴�С
        DB        0,0,0x29        ; ���岻�����̶�
        DD        0xffffffff        ; �������ǣ�������
        DB        "HELLO-OS   "    ; freeparam ���̵����ƣ�11�ֽڣ�
        DB        "FAT12   "        ; ���̸�ʽ���ƣ�8�ֽڣ�
        RESB    18                ; �ȿճ�18�ֽ�


entry:
        MOV        AX,0            ; ��ʼ���Ĵ���
        MOV        SS,AX
        MOV        SP,0x7c00
        MOV        DS,AX

; ������

        MOV        AX,0x0820
        MOV        ES,AX
        MOV        CH,0            ; ����0
        MOV        DH,0            ; ��ͷ0
        MOV        CL,2            ; ����2
readloop:
        MOV        SI,0            ; ��¼ʧ�ܴ����ļĴ���
retry:
        MOV        AH,0x02            ; AH=0x02 : �������
        MOV        AL,1            ; 1������
        MOV        BX,0
        MOV        DL,0x00            ; A������
        INT        0x13            ; ���ô���BIOS
        JNC        next            ; û����ʱ��ת��next
        ADD        SI,1            ; SI��1
        CMP        SI,5            ; �Ƚ�SI��5
        JAE        error            ; SI >= 5ʱ����ת�� error
        MOV        AH,0x00
        MOV        DL,0x00            ; A������
        INT        0x13            ; ����������
        JMP        retry
next:
        MOV        AX,ES            ; ���ڴ��ַ����0x200��0x200 = 512��
        ADD        AX,0x0020        ; ADD    AX, 512 / 16
        MOV        ES,AX            ; ��Ϊû��ADD ES,0x020 ָ�����������΢�Ƹ���
        ADD        CL,1            ; CL��1
        CMP        CL,18            ; �Ƚ�CL��18
        JBE        readloop        ; ���CL <= 18������ת��readloop
        MOV        CL,1
        ADD        DH,1
        CMP        DH,2
        JB        readloop        ; ���DH < 2������ת��readloop
        MOV        DH,0
        ADD        CH,1
        CMP        CH,CYLS
        JB        readloop        ; ���CH < CYLS������ת��readloop

; �����������ݺ󣬵���0x8200λ�ã���haribote.sys�е�ָ��

        MOV        [0x0ff0],CH        ; ��CYLS��ֵд���ڴ��ַ0x0ff0�С�
        JMP        0xc200

error:
        MOV        SI,msg
putloop:
        MOV        AL,[SI]
        ADD        SI,1            ; ��SI��1
        CMP        AL,0
        JE        fin
        MOV        AH,0x0e            ; ��ʾһ������
        MOV        BX,15            ; ָ���ַ���ɫ
        INT        0x10            ; �����Կ�BIOS
        JMP        putloop
fin:
        HLT                        ; ��CPUֹͣ���ȴ�ָ��
        JMP        fin                ; ����ѭ��
msg:
        DB        0x0a, 0x0a        ; ����2��
        DB        "load error"    ; freeparam
        DB        0x0a            ; ����
        DB        0

        RESB    0x7dfe-$        ; ��д0x00��ֱ��0x001fe

        DB        0x55, 0xaa

ipl10.nas