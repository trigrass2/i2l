\XPL.XPL
\XPLV4D MAY 80

\	COPYRIGHT P.J.R.BOYLE. 1977,78,79,80

\THESE ARE THE REQUIRED MACHINE LANGUAGE FUNCTIONS:
'CODE'
ABS=0,		REM=2,		RESERVE=3,	SWAP=4,
CHIN=7,		CHOUT=8,	SKIP=9,		NUMOUT=11,
TEXT=12,	OPENI=13,	OPENO=14,	CLOSE=15,
ABORT=16;


\RESERVED WORD HASHES\
'DEFINE'
ADRSYM=25797,	BEGSYM=26057,	CASEYM=25046,	CODSYM=28615,
DEFSYM=26058,	DOSYM=28516,	ELSEYM=27864,	ENDSYM=28361,
FALSYM=25042,	FORSYM=28632,	FPRSYM=28888,
GESYM=25959,	GETSYM=26075,	IFSYM=26217,	INTSYM=28381,
OWNSYM=30685,	LESYM=25964,	LOOPYM=28635,	NOTSYM=28642,
OFSYM=26223,	PROCYM=29407,	REPSYM=26082,	RETSYM=26086,
THENYM=26841,	TRUSYM=29417,	UNTSYM=28393,	WHILYM=26848,
QUITYM=30170,	EXTNYM=30937,	EXITYM=30926,

\OTHER CONSTANTS
	SYMAX=250,	\MAX NUMBER OF SYMBOLS
	EOFSYM=26,	\CTRL-Z
	EMPTY=$FF,	\NULL POINTER

\ASCII CHARACTERS
SPACH=32,	LFCH=10,	RETCH=13,
FFCH=12,	TABCH=9;

\CODES FOR IDENTIFIER TYPES FOR IDTYP
'DEFINE' UNDEF,		\UNDEFINED
	INTVAR,		\INTEGER VARIABLE
	ADDVAR,		\ADDRESS VARIABLE
	FPRNAM,		\FOREWARD PROCEDURE
	PROCNAM,	\NORMAL PROCEDURE
	OPTPROC,	\OPTIMIZED PROC.
	EXTPROC,	\EXTERNAL PROC.
	INTPROC,	\INTRINSIC PROC.
	OWNVAR,		\OWN VARIABLE
	CONNAM;		\CONSTANT NAME

\CODES FOR ATOM TYPES FOR ATYPE
'DEFINE' SPECIAL,	\RESERVED WORDS, FUNNY CHARS ETC.
	IDENTIFIER,	\AN IDENTIFIER
	CONSTANT;	\A CONSTANT

'OWN'	SRCDEV,	\SOURCE INPUT DEVICE NUMBER
	LSTDEV,	\LISTING DEVICE NUMBER
	BINDEV; \BINARY OUTPUT DEVICE

'INTEGER'\INTEGER VARIABLES FOR ACTUAL PROCESSING
	CHAR,	\CURRENT CHARACTER BUFFER. MOST OF THE TIME
		\IT CONTAINS THE TERMINATOR OF THE CURRENT ATOM
	CC,	\INDEX TO CURRENT CHARACTER IN THE INPUT LINE
	LL,	\LENGTH OF THE CURRENT INPUT LINE
	STRFLG,	\BOOLEAN- STRING FLAG
	CASEIN,	\BOOLEAN- CASE SWITCH
	ALPHA,	\BOOLEAN- CURRENT CHAR IS ALPHABETIC
	NUMBER,	\BOOLEAN- CURRENT CHAR IS NUMERIC
	ALFNUM,	\BOOLEAN- ALPHA OR NUMBER
	ATOM,	\PRESENT ATOM DESCRIPTOR
		\CONTAINS RESERVED WORD HASH OR THE ASCII FOR
		\A SPECIAL CHARACTER. 0 IF THE ATOM IS A
		\CONSTANT OR IDENTIFIER
	ATYPE,	\PRESENT ATOM TYPE DESCRIPTOR
	IDTYP,	\PRESENT IDENTIFIER TYPE DESCRIPTOR
	LEV,	\LEVEL OF CURRENT IDENTIFIER
	VAL,	\VALUE OR ADDRESS OF CURRENT IDENTIFIER
	IATOM,	\VALUE OF CURRENT CONSTANT
	SYMNUM,	\NUMBER IN SYMTAB OF CURRENT IDENT
	NOSYM,	\NUMBER OF SYMBOLS IN SYMBOL TABLE
	LEVEL,	\LEVEL OF CURRENT PROCEDURE
	T,	\GENERAL TEMPORARY
	PC,	\THE RELATIVE PROGRAM COUNTER
	DX,	\HEAP SPACE REQUIREMENT COUNTER
	FIXCNT,	\COUNT OF THE NUMBER OF OUTSTANDING QUITS
	OLDPC,	\SAVE SPACE FOR PC
	OPROC,	\FLAG SHOWS OPTIMIZED PROC
	STKLOD,	\THE NUMBER OF PENDING STACK VALUES
	SSTK,	\SEE LOOP STATEMENT
	HASH;	\CURRENT IDENTIFIER HASH

'ADDRESS'
	IDNAM,	\CURRENT IDENTIFIER NAME
	LINE,	\SOURCE INPUT LINE BUFFER
	SYMBOL,	\SYMBOL TABLE
	SYMTYP,	\SYMBOL TYPE DESCRIPTORS
	SYMLEV,	\SYMBOL LEVELS
	SYMPNT,	\SYMBOL LIST LINKAGE POINTERS
	BOX;	\HASH BOXES (SYMBOL LIST HEADERS)

\INTEGER ARRAYS:
'INTEGER'
	SYMVAL,	\SYMBOL VALUES OR ADDRESSES
	FIXES;	\QUIT FIXES STILL OUTSTANDING


'PROCEDURE'ERROR(STRING);
'INTEGER' STRING;


    'PROCEDURE'ERRMES(DEV);
    'INTEGER'DEV;
    'BEGIN'
    SKIP(DEV);
    TEXT(DEV,"***** I^'M LOST: ");
    TEXT(DEV,STRING);
    TEXT(DEV," *****");
    SKIP(DEV);
    'FOR'T:=0,LL'DO'CHOUT(DEV,LINE(T));
    SKIP(DEV);
    'FOR'T:=0,CC-3'DO'
    'IF'LINE(T)#TABCH'THEN'CHOUT(DEV,SPACH)
    'ELSE'CHOUT(DEV,TABCH);
    CHOUT(DEV,^^);
    SKIP(DEV);
    'END';

'BEGIN'\ERROR
ERRMES(LSTDEV);
'IF'LSTDEV#0'THEN'ERRMES(0);
CLOSE(LSTDEV);
ABORT;
'END';\ERROR

'PROCEDURE'INCH;


    'PROCEDURE'INCHX;
    'BEGIN'
    'IF'CHAR#EOFSYM'THEN'CHAR:=CHIN(SRCDEV)
    'ELSE''IF'STRFLG'THEN'ERROR("UNTERMINATED STRING");
    'IF'CHAR=^^'THEN'
	'BEGIN'
	CHOUT(LSTDEV,CHAR);
	CHAR:=CHIN(SRCDEV)!128;
	'END';
    'END';


    'PROCEDURE'PUTX;
    'IF'(CHAR#RETCH)'THEN'
    	['IF'CHAR#LFCH'THEN'CHOUT(LSTDEV,CHAR&127);INCHX];

'BEGIN'\INCH
\TAKE OUT LINE FEEDS, FORM FEEDS AND COMMENTS
INCHX;
'IF'STRFLG'THEN'['IF'CHAR=^"'THEN'STRFLG:='FALSE']
'ELSE'	'BEGIN'
	'WHILE'(CHAR=LFCH)!(CHAR=FFCH)'DO'PUTX;
	'IF'CHAR=^\'THEN'
		'BEGIN'
		\IGNORE COMMENTS
		'REPEAT'PUTX'UNTIL'(CHAR=^\)!(CHAR=RETCH);
		PUTX;
		'END';
	'IF'CHAR=^"'THEN'STRFLG:='TRUE';
	'END'
'END'\INCH\;

'PROCEDURE'GETCH;
'BEGIN'\GETCH
'IF' CC>LL 'THEN'
	'BEGIN'
	SKIP(LSTDEV);
	LL:=0;
	CC:=0;
	INCH;
	'WHILE'(CHAR#RETCH)&(CHAR#EOFSYM)
	'DO'
		'BEGIN'
		LINE(LL):=CHAR;
		CHOUT(LSTDEV,CHAR&127);
		INCH;
		LL:=LL+1;
		'IF'LL>79'THEN'ERROR("LINE TOO LONG");
		'END';
	LINE(LL):=CHAR;
	'END';
CHAR:=LINE(CC);
CC:=CC+1;
'IF'CHAR=\SINGLE QUOTE\39'THEN'
	'BEGIN'
	CASEIN:='NOT'CASEIN;
	CHAR:=^ ;
	'END';
\SWITCH CASE IF CASEIN IS 'TRUE'\
'IF'CASEIN&(CHAR>=^A)&(CHAR<=^Z)
	'THEN'CHAR:=CHAR+32;
ALPHA:=((CHAR>=^A)&(CHAR<=^Z)) ! 
    ((CHAR>=\LOWER CASE A\97)&(CHAR<=\LOWER CASE Z\122));
NUMBER:=(CHAR>=^0)&(CHAR<=^9);
ALFNUM:=ALPHA!NUMBER;
'END'\GETCH\;

'PROCEDURE'RATOM;
'INTEGER'LEN;



'BEGIN'\READ IN AN ATOM\
'WHILE'
   (CHAR=SPACH)!(CHAR=RETCH)!(CHAR=TABCH)
'DO'GETCH;
'CASE''OF'
(CHAR>=\LOW A\97)&(CHAR<=\LOW Z\122):
	'BEGIN'
        \RESERVED WORD\
        ATOM:=CHAR;
        GETCH;
        ATOM:=ATOM+SWAP(CHAR);
	GETCH;
	'IF'ALPHA'THEN'ATOM:=ATOM+CHAR;
        'WHILE'ALPHA'DO'GETCH;
        ATYPE:=SPECIAL;
        'END';

ALPHA:
	'BEGIN'
        \IDENTIFIER\
        LEN:=0;HASH:=0;
        'WHILE'ALFNUM'DO'
        	'BEGIN'
		'IF'CHAR>=\LOW A\97'THEN'ERROR("LOWER CASE?");
		'IF'LEN<6'THEN'
			'BEGIN'
			IDNAM(LEN):=CHAR;
			HASH:=HASH+CHAR;
			LEN:=LEN+1;
			'END';
		GETCH;
		'END';
	'FOR'LEN:=LEN,5'DO'
		'BEGIN'
		IDNAM(LEN):=^ ;
		HASH:=HASH+^ ;
		'END';
	ATYPE:=IDENTIFIER;
	ATOM:=0;
        HASH:=HASH&63;
        'END';

NUMBER:
	'BEGIN'
        \CONSTANT\
        IATOM:=0;
        'WHILE'NUMBER'DO'
        [IATOM:=IATOM*10+CHAR-^0;GETCH];
        ATYPE:=CONSTANT;
        ATOM:=0;
        'END';

CHAR=^$:
	'BEGIN'\HEXADECIMAL CONSTANT
        GETCH;
        IATOM:=0;
        'LOOP''BEGIN'
		'IF'CHAR>=^0 & CHAR<=^9'THEN'
		        IATOM:=IATOM*16+CHAR-^0
	        'ELSE''IF'CHAR>=^A & CHAR<=^F'THEN'
		        IATOM:=IATOM*16+CHAR-^A+10
		'ELSE''QUIT';
		GETCH;
		'END';
	ATYPE:=CONSTANT;
        ATOM:=0;
        'END'

'ELSE'
	'BEGIN'
        \SPECIAL CHARACTER\
        'IF'LINE(CC)=^='THEN'
        'CASE'CHAR'OF'
		^::[GETCH;ATOM:=GETSYM];
		^>:[GETCH;ATOM:=GESYM];
		^<:[GETCH;ATOM:=LESYM]
		'ELSE'ATOM:=CHAR
	'ELSE'ATOM:=CHAR;
        ATYPE:=SPECIAL;
        GETCH;
        'END';
'END'\OF RATOM\;

'PROCEDURE'HEXB(I);
'INTEGER'I;


    'PROCEDURE'PHEX(I);
    'INTEGER'I;
    'BEGIN'
    'IF'I<=9'THEN'I:=I+^0'ELSE'I:=I+^7;
    CHOUT(BINDEV,I);
    'END';

'BEGIN'\HEXB
PHEX((I&$FF)/16);
PHEX(REM(0));
'END';\HEXB


'PROCEDURE'HEXW(I);
'INTEGER'I;
[HEXB(SWAP(I));HEXB(I)];


'PROCEDURE'FIX(I);
'INTEGER'I,J;
'BEGIN'\FIX FORWARD REFRENCES\
SKIP(BINDEV);
'IF'PC#OLDPC'THEN'
	'BEGIN'
	CHOUT(BINDEV,^;);HEXW(PC);
	OLDPC:=PC;
	SKIP(BINDEV);
	'END';
CHOUT(BINDEV,^^);
HEXW(I+1);
'END'\FIX\;

'PROCEDURE'GEN(OP,LEV,VAL,CL);
'INTEGER'OP,LEV,VAL,CL;
'BEGIN'\GEN\
\THE ENCODING OF THE CLASS, CL IS A 4 BIT BINARY CODE...
\0:=OP CODE ONLY, 1 BYTE
\2:=OP WITH ONE BYTE VALUE
\3:=OP WITH VALUE, 3 BYTES
\7:=OP WITH ADDRESS, 3 BYTES
\10:=OP WITH LEVEL AND ONE BYTE OFFSET (IN VAL)
\15:=OP WITH LEVEL AND ADDRESS, 4 BYTES
'IF'PC#OLDPC'THEN'[SKIP(BINDEV);CHOUT(BINDEV,^;);HEXW(PC)];
'IF'(OP=1)&(LEV=0)'THEN'
	'BEGIN'
	\MAGIC OPCODE
	HEXB(VAL/2!128);\SHORT GLOBAL LOAD
	PC:=PC+1;
	'END'
'ELSE'	'BEGIN'
	\NOT SPECIAL
	HEXB(OP);PC:=PC+1;
	'IF'CL&8'THEN'[HEXB(LEV);PC:=PC+1];
	'IF'CL&4'THEN'
		'BEGIN'
		CHOUT(BINDEV,^*);
		HEXW(VAL);
		PC:=PC+2;
		'END'
	'ELSE'
		'BEGIN'
		'IF'CL&2'THEN'[HEXB(VAL);PC:=PC+1];
		'IF'CL&1'THEN'[HEXB(SWAP(VAL));PC:=PC+1];
		'END';
	'END';
OLDPC:=PC;
'END'\GEN\;

'PROCEDURE'LOOKUP;
'INTEGER'I,K,PNTR;
'BEGIN'\LOOKUP
PNTR:=BOX(HASH);
'LOOP'
	'BEGIN'
	'IF'PNTR=EMPTY'THEN'[IDTYP:=UNDEF;'QUIT'];
	I:=0;
	K:=PNTR;
	'WHILE'(IDNAM(I)=SYMBOL(K))&(I<6)
		'DO'[I:=I+1;K:=K+SYMAX];
	'IF'I=6'THEN'
		'BEGIN'
		IDTYP:=SYMTYP(PNTR);
		VAL:=SYMVAL(PNTR);
		LEV:=SYMLEV(PNTR);
		SYMNUM:=PNTR;
		'QUIT';
		'END';
	PNTR:=SYMPNT(PNTR);
	'END';
'END';\LOOKUP


'PROCEDURE'INSERT(STYP,SLEV,SVAL);
'INTEGER'STYP,SLEV,SVAL,I,K;
'BEGIN'\INSERT\
LOOKUP;
'IF'(IDTYP#UNDEF)&(LEV=LEVEL)'THEN'ERROR("SYMBOL CONFLICTS");
'IF'NOSYM>=SYMAX'THEN'ERROR("TOO MANY SYMBOLS");
K:=NOSYM;
'FOR'I:=0,5'DO'
	'BEGIN'
	SYMBOL(K):=IDNAM(I);
	K:=K+SYMAX;
	'END';
SYMLEV(NOSYM):=SLEV;
SYMVAL(NOSYM):=SVAL;
SYMTYP(NOSYM):=STYP;
SYMPNT(NOSYM):=BOX(HASH);
BOX(HASH):=NOSYM;
NOSYM:=NOSYM+1;
'END'\INSERT\;


'PROCEDURE'GETCON;
'INTEGER'SIGN,I,SLEV,STYP,SVAL,SNUM;
'BEGIN'
SIGN:=1;
'IF'ATOM=^-'THEN'[SIGN:=-1;RATOM];
'IF'ATYPE=CONSTANT'THEN'I:=IATOM
'ELSE''IF'ATYPE=IDENTIFIER'THEN'
	'BEGIN'
	SLEV:=LEV;
	STYP:=IDTYP;
	SVAL:=VAL;
	SNUM:=SYMNUM;
        LOOKUP;
        'IF'IDTYP=CONNAM'THEN'I:=VAL
        'ELSE'ERROR("BAD CONSTANT");
	LEV:=SLEV;
	IDTYP:=STYP;
	VAL:=SVAL;
	SYMNUM:=SNUM;
	ATYPE:=CONSTANT;
        'END'
'ELSE'ERROR("BAD CONSTANT");
IATOM:=I*SIGN;
'END';

'FPROC'BOOLEXP;


'PROCEDURE'PROCAL;
'INTEGER'SVAL,SLEV,ACNT;

'BEGIN'\PROCAL
'CASE'IDTYP'OF'
OPTPROC:
	'BEGIN'
	GEN(\JSR\38,0,VAL,7);
	RATOM;
	'IF'ATOM=^('THEN'ERROR("ILLEGAL CALL");
	'END';

EXTPROC:
    'BEGIN'
    \EXTERNAL CALL\
    SVAL:=VAL;
    RATOM;
    ACNT:=0;
    'IF'ATOM=^('THEN'
	'BEGIN'
	'REPEAT'[RATOM;BOOLEXP;ACNT:=ACNT+1]
	'UNTIL'ATOM#^,;
	'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	RATOM;
	'END';
    GEN(\ECL\41,0,SVAL,3);
    'END';


INTPROC:
    'BEGIN'
    \INTRINSIC CALL\
    SVAL:=VAL;
    RATOM;
    'IF'ATOM=^('THEN'
	'BEGIN'
	'REPEAT'[RATOM;BOOLEXP]
	'UNTIL'ATOM#^,;
	'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	RATOM;
	'END';
    GEN(\CML\12,0,SVAL,2);
    'END'

'ELSE'
	'BEGIN'
        \PROCEDURE CALL\
        SVAL:=VAL;
        SLEV:=LEV+2;
        RATOM;
        ACNT:=0;
    'IF'ATOM=^('THEN'
	'BEGIN'
	ACNT:=0;
	'REPEAT'[RATOM;BOOLEXP;ACNT:=ACNT+2]
	'UNTIL'ATOM#^,;
	'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	RATOM;
	'END';
    'IF'ACNT>0'THEN'GEN(\ARG\10,0,ACNT-1,2);
    GEN(\CAL\5,SLEV,SVAL,15);
    'END';
'END';

'PROCEDURE'BOOLEXP;
'INTEGER'OP,P1,P2;


    'PROCEDURE'EXPRESSION;
    'INTEGER'OP;


	'PROCEDURE'FACTOR;
	'INTEGER'SVAL,SLEV,SPC,SCHAR;


	    'PROCEDURE'STRCON;
	    'INTEGER'SPC,SCHAR;
	    'BEGIN'
	    SPC:=PC;
	    SKIP(BINDEV);CHOUT(BINDEV,^;);HEXW(PC);
	    'WHILE'CHAR#^"'DO'
		'BEGIN'
		HEXB(CHAR&127);
		PC:=PC+1;
		SCHAR:=CHAR;
		GETCH;
		'END';
	    SKIP(BINDEV);CHOUT(BINDEV,^;);HEXW(PC-1);
	    HEXB(SCHAR!128);
	    GETCH;
	    'RETURN'SPC;
	    'END';

	    'PROCEDURE'ARYCON;
	    'INTEGER'THISEL,NEXTEL,PNTR,SPC,I,INDIRECT;
	    'DEFINE'NULL=$FFFF;
	    'BEGIN'
	    PNTR:=RESERVE(6);
	    THISEL:=PNTR;
	    THISEL(0):=NULL;
	    'REPEAT'
		'BEGIN'
		RATOM;
		INDIRECT:='TRUE';
		'CASE'ATOM'OF'
		    ^[:I:=ARYCON;
		    ^":I:=STRCON
		    'ELSE'
			'BEGIN'
			INDIRECT:='FALSE';
			GETCON;
			I:=IATOM;
		        'END';
		NEXTEL:=RESERVE(6);
	        THISEL(1):=I;
	        THISEL(2):=INDIRECT;
	        THISEL(0):=NEXTEL;
	        NEXTEL(0):=NULL;
	        THISEL:=NEXTEL;
	        RATOM;
	        'END'
	    'UNTIL'ATOM#^,;
	    'IF'ATOM#^]'THEN'ERROR("PAREN MISMATCH");
	    SPC:=PC;
	    SKIP(BINDEV);CHOUT(BINDEV,^;);HEXW(PC);
	    'WHILE'PNTR(0)#NULL'DO'
	    	'BEGIN'\DUMP LIST
	        I:=PNTR(1);
	        'IF'PNTR(2)'THEN'[CHOUT(BINDEV,^*);HEXW(I)]
	        'ELSE'[HEXB(I);HEXB(SWAP(I))];
	        PC:=PC+2;
	        PNTR:=PNTR(0);
	        'END';
	    'RETURN'SPC;
	    'END';

	'BEGIN'\FACTOR\
        'CASE'ATYPE'OF'
	SPECIAL:
	    'BEGIN'\DOSPEC
	    'CASE'ATOM'OF'
	    ^(:
	        'BEGIN'
	        \PARENTHESIZED EXPRESSION\
	        RATOM;
	        BOOLEXP;
	        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	        'END';
	    ^":
	        'BEGIN'
	        \STRING CONSTANT\
	        SVAL:=PC;
	        GEN(\JMP\7,0,0,7);
	        SPC:=STRCON;
	        FIX(SVAL);
	        GEN(\IMM\11,0,SPC,7);
	        'END';
	    ^[:
	        'BEGIN'
	        \ARRAY CONSTANT\
	        SVAL:=PC;
	        GEN(\JMP\7,0,0,7);
	        SPC:=ARYCON;
	        FIX(SVAL);
	        GEN(\IMM\11,0,SPC,7);
	        'END';
	    ADRSYM:
	        'BEGIN'
	        RATOM;
	        'IF'ATYPE#IDENTIFIER'THEN'ERROR("BAD OPERAND");
	        LOOKUP;
	        'IF'(IDTYP=INTVAR)!(IDTYP=ADDVAR)
	        'THEN'GEN(\ADR\33,LEV,VAL,10)
	        'ELSE''IF'IDTYP=OWNVAR'THEN'GEN(\IMM\11,0,VAL,7)
	        'ELSE'ERROR("BAD SYMBOL");
	        'END';
	    TRUSYM:
		GEN(\IMS\36,0,$FF,2);
	    FALSYM:
		GEN(\IMS\36,0,0,2)
	    'ELSE'
		'IF'ATOM>128'THEN'
			GEN(\IMS\36,0,ATOM&127,2)
	        'ELSE'ERROR("IN EXPRESSION?");
	    RATOM;
	    'END';\DOSPEC

	CONSTANT:
	    'BEGIN'
	    \LITERAL INTEGER CONSTANT\
	    'IF'(IATOM#$8000)&(ABS(IATOM)<128)'THEN'GEN(\IMS\36,0,IATOM,2)
	    'ELSE'GEN(\IMM\11,0,IATOM,3);
	    RATOM;
	    'END'
	'ELSE'
	    'BEGIN'\IDENTIFIER\
	    LOOKUP;
	    'IF'IDTYP>=FPRNAM & IDTYP<=INTPROC'THEN'
		'BEGIN'\PROCEDURE CALL
		'IF'IDTYP=OPTPROC'THEN'ERROR("ILLEGAL CALL");
	        SVAL:=IDTYP;
	        PROCAL;
		'IF'SVAL<=OPTPROC'THEN'GEN(\LOD\1,0,0,10);
	        'END'
	    'ELSE''CASE'IDTYP'OF'
		UNDEF:ERROR("UNKNOWN HERE");
	        INTVAR:
		    'BEGIN'\INTEGER VARIABLE\
		    GEN(\LOD\1,LEV,VAL,10);
		    RATOM;
		    'IF'ATOM=^('THEN'
			'BEGIN'\IT IS INDEXED
		        'REPEAT''BEGIN'
				RATOM;
			        BOOLEXP;\INDEXES
			        GEN(\DBI\32,0,0,0);
			        'END'
			'UNTIL'ATOM#^,;
		        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
		        RATOM;
		        'END';
		    'END';

	        ADDVAR:
		    'BEGIN'\ADDRESS VARIABLE\
		    RATOM;
		    'IF'ATOM#^('THEN'GEN(\LOD\1,LEV,VAL,10)
		    'ELSE'
			'BEGIN'\ARRAY ELEMENT REFRENCE\
		        SLEV:=LEV;
		        SVAL:=VAL;
		        RATOM;
		        EXPRESSION;\INDEX\
		        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
		        GEN(\LDX\2,SLEV,SVAL,10);
		        RATOM;
		        'END';
		    'END';

	        OWNVAR:
		    'BEGIN'
		    GEN(\LDA\35,0,VAL,7);
		    RATOM;
		    'IF'ATOM=^('THEN'
			'BEGIN'
		        'REPEAT''BEGIN'
		        	RATOM;
			        BOOLEXP;
			        GEN(\DBI\32,0,0,0);
			        'END'
			'UNTIL'ATOM#^,;
		        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
		        RATOM;
		        'END';
		    'END';

	        CONNAM:
		    'BEGIN'\CONSTANT
		    'IF'ABS(VAL)<128'THEN'GEN(\IMS\36,0,VAL,2)
		    'ELSE'GEN(\IMM\11,0,VAL,3);
		    RATOM;
		    'END'

		'ELSE'ERROR("BAD SYMBOL");
	    'END'\IDENTIFIER\;
        'END'\FACT\;

	'PROCEDURE'TERM;
        'INTEGER'OP;
        'BEGIN'\TERM\
        FACTOR;
        'WHILE'(ATOM=^*)!(ATOM=^/)'DO'
		'BEGIN'
	        OP:=ATOM;
	        RATOM;
	        FACTOR;
	        'IF'OP=^*'THEN'GEN(\MUY\15,0,0,0)
	        'ELSE'GEN(\DIV\16,0,0,0);
	        'END';
	'END'\TERM\;

    'BEGIN'\EXPRESS\
    'WHILE'ATOM=^+'DO'RATOM;
    'IF'ATOM=^-'THEN'
	[RATOM;EXPRESSION;GEN(\NEG\17,0,0,0)]
    'ELSE'TERM;
    'WHILE'(ATOM=^+)!(ATOM=^-)'DO'
	'BEGIN'
	OP:=ATOM;
	RATOM;
	TERM;
	'IF'OP=^+'THEN'GEN(\ADD\13,0,0,0)
	'ELSE'GEN(\SUB\14,0,0,0);
	'END';
    'END'\EXPRES\;


    'PROCEDURE'LOGEXP;
    'INTEGER'OP;
    'BEGIN'\LOGEXP\
    EXPRESSION;
    'IF'(ATOM=^=)!(ATOM=^#)!(ATOM=^>)!
    (ATOM=^<)!(ATOM=GESYM)!(ATOM=LESYM)
	'THEN'	'BEGIN'
		OP:=ATOM;
	        RATOM;
	        EXPRESSION;
	        'CASE'OP'OF'
			^=:GEN(\EQ\18,0,0,0);
		        ^#:GEN(\NE\19,0,0,0);
		        ^>:GEN(\GT\21,0,0,0);
		        ^<:GEN(\LT\23,0,0,0);
		        GESYM:GEN(\GE\20,0,0,0)
		        'ELSE'GEN(\LE\22,0,0,0);
		'END';
    'END'\LOGEXP\;

    'PROCEDURE'CONDEXP;
    'BEGIN'
    RATOM;
    BOOLEXP;\THE CONDITION
    P1:=PC;
    GEN(\JPC\8,0,0,7);
    'IF'ATOM#THENYM'THEN'ERROR("WHERES THE THEN?");
    RATOM;
    BOOLEXP;\TRUE CASE
    'IF'ATOM#ELSEYM'THEN'ERROR("WHERES THE ELSE?");
    P2:=PC;
    GEN(\JMP\7,0,0,7);
    FIX(P1);
    RATOM;
    BOOLEXP;\FALSE CASE
    FIX(P2);	
    'END';

'BEGIN'\BOOLEXP\
'IF'ATOM=IFSYM'THEN'CONDEXP
'ELSE''IF'ATOM=NOTSYM'THEN'
	[RATOM;BOOLEXP;GEN(\NOT\28,0,0,0)]
'ELSE'LOGEXP;
'WHILE'(ATOM=^!)!(ATOM=^&)'DO'
	'BEGIN'
	OP:=ATOM;
	RATOM;
	LOGEXP;
	'IF'OP=^!'THEN'GEN(\OR\26,0,0,0)
	'ELSE'GEN(\AND\27,0,0,0);
	'END';
'END'\BOOLEXP\;

'FPROC'STAMNT;


'PROCEDURE'ASSIGN;
'INTEGER'SVAL,SLEV,OP,SPC;
'DEFINE'INTSTOR,BYTIND,INTIND;\TYPE OF STORE
'BEGIN'\ASSIGN
\INCLUDES PROC CALLS\
'IF'ATYPE#IDENTIFIER'THEN'ERROR("WHAT IS THIS?");
LOOKUP;
'IF'IDTYP=UNDEF'THEN'ERROR("UNKNOWN HERE");
'IF'IDTYP>=FPRNAM & IDTYP<=INTPROC'THEN'PROCAL
'ELSE''BEGIN'\TRUE ASSIGN\
	SLEV:=LEV;
	SVAL:=VAL;
	'CASE'IDTYP'OF'
	INTVAR:
	    'BEGIN'
	    RATOM;
	    'IF'ATOM=^('THEN'
		'BEGIN'\INDEXED INTEGER
	        GEN(\LOD\1,SLEV,SVAL,10);
	        RATOM;\EAT THE PAREN
	        BOOLEXP;\FIRST INDEX
	        'WHILE'ATOM=^,'DO'
		    'BEGIN'
		    GEN(\DBI\32,0,0,0);
		    RATOM;\THE COMMA
		    BOOLEXP;\NEXT INDEX
		    'END';
		GEN(\DBA\30,0,0,0);
	        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	        \WE HAVE ITS ADDRESS ON STACK
	        OP:=INTIND;
	        RATOM;\MOVE TO THE :=
	        'END'
	    'ELSE'OP:=INTSTOR;\STORE INTO VARIABLE\
	    'END';

	ADDVAR:
            'BEGIN'\STORE TO BYTE\
	    RATOM;
	    'IF'ATOM=^('THEN'
	        'BEGIN'
	        OP:=BYTIND;
	        RATOM;
	        BOOLEXP;
	        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	        RATOM;
	        'END'
	    'ELSE'OP:=INTSTOR;
	    'END'\BYTE STORE\;

        OWNVAR:
           'BEGIN'
	   RATOM;
	   OP:=INTIND;
	   'IF'ATOM=^('THEN'
	       'BEGIN'
	       GEN(\LDA\35,0,SVAL,7);
	       RATOM;\PAST PAREN
	       BOOLEXP;
	       'WHILE'ATOM=^,'DO'
	           'BEGIN'
		   GEN(\DBI\32,0,0,0);
		   RATOM;\THE COMMA
		   BOOLEXP;\NEXT INDEX
		   'END';
		GEN(\DBA\30,0,0,0);
	        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
	        RATOM;\TO THE :=
	        'END'
	    'ELSE'GEN(\IMM\11,0,SVAL,7);
	    'END'

        'ELSE'ERROR("WHAT ASSIGNMENT?");

	'IF'ATOM#GETSYM'THEN'ERROR("IN ASSIGNMENT");
	RATOM;
	BOOLEXP;
	'CASE'OP'OF'
		INTSTOR:GEN(\STO\3,SLEV,SVAL,10);
		BYTIND:GEN(\STX\4,SLEV,SVAL,10)
		'ELSE'GEN(\STD\31,0,0,0);
	'END'\TRUE ASSIGN\;
'END'\PROC ASSIGN\;

'PROCEDURE'STAMNT;
'INTEGER'P2,P3,SFIXS,SLEV,SVAL,T;



	'PROCEDURE'CASER(TYPE);
        'INTEGER'TYPE,SPC1,SPC2;
        'BEGIN'
        BOOLEXP;
        SPC1:=PC;
        GEN(TYPE,0,0,7);
        'IF'ATOM#^:'THEN'ERROR("IN CASE");
        RATOM;
        STAMNT;
        SPC2:=PC;
        GEN(\JMP\7,0,0,7);
        FIX(SPC1);
        'WHILE'ATOM=^;'DO'
        	'BEGIN'
	        RATOM;
	        BOOLEXP;
	        SPC1:=PC;
	        GEN(TYPE,0,0,7);
	        'IF'ATOM#^:'THEN'ERROR(" IN CASE");
	        RATOM;
	        STAMNT;
		FIX(SPC2);
	        SPC2:=PC;
	        GEN(\JMP\7,0,0,7);
	        FIX(SPC1);
	        'END';
	'IF'ATOM#ELSEYM'THEN'ERROR(" IN CASE");
	RATOM;
        STAMNT;
	FIX(SPC2);
	'END';\CASER

    'PROCEDURE'BLKSMT;
    'BEGIN'\BLOCK STATEMENT\
    'REPEAT'[RATOM;STAMNT]'UNTIL'ATOM#^;;
    'IF'ATOM=EOFSYM'THEN'ERROR("UNTERMINATED BLOCK");
    'IF'(ATOM#ENDSYM)&(ATOM#^])'THEN'ERROR(" IN BLOCK");
    RATOM;
    'END';

'BEGIN'\STAMNT\
'CASE'ATOM'OF'
BEGSYM:	BLKSMT;
^[:	BLKSMT;
QUITYM:
    'BEGIN'
    'IF'FIXCNT>9'THEN'ERROR("TOO MANY QUITS");
    'FOR'T:=SSTK,STKLOD-1'DO'GEN(\DRP\40,0,0,0);
    FIXES(FIXCNT):=PC;
    FIXCNT:=FIXCNT+1;
    GEN(\JMP\7,0,0,7);
    RATOM;
    'END';
REPSYM:
    'BEGIN'
    P2:=PC;
    'REPEAT'[RATOM;STAMNT]'UNTIL'ATOM#^;;
    'IF'ATOM#UNTSYM'THEN'ERROR(" IN REPEAT");
    RATOM;
    BOOLEXP;
    GEN(\JPC\8,0,P2,7);
    'END';
IFSYM: 
    'BEGIN'
    \IF STATEMENT\
    RATOM;
    BOOLEXP;
    P3:=PC;
    GEN(\JPC\8,0,0,7);
    'IF'ATOM#THENYM'THEN'ERROR(" IN IF");
    RATOM;
    STAMNT;
    'IF'ATOM=ELSEYM'THEN'
	'BEGIN'
	P2:=PC;
	GEN(\JMP\7,0,0,7);
	FIX(P3);
	P3:=P2;
	RATOM;
	STAMNT;
	'END';
    FIX(P3);
    'END';
WHILYM:
    'BEGIN'
    \WHILE STATEMENT\
    RATOM;
    P2:=PC;
    BOOLEXP;
    P3:=PC;
    GEN(\JPC\8,0,0,7);
    'IF'ATOM#DOSYM'THEN'ERROR(" IN WHILE");
    RATOM;
    STAMNT;
    GEN(\JMP\7,0,P2,7);
    FIX(P3);
    'END';
RETSYM:
    'BEGIN'\RETURN STATEMENT
    RATOM;
    'FOR'T:=0,STKLOD-1'DO'GEN(\DRP\40,0,0,0);
    'IF'(ATOM#ELSEYM)&(ATOM#^;)&(ATOM#UNTSYM)&
    (ATOM#^])&(ATOM#ENDSYM)'THEN'
	'BEGIN'
	BOOLEXP;
	GEN(\STO\3,0,0,10);
	'END';
    GEN('IF'OPROC'THEN'\RTS\39'ELSE'\RET\6,0,0,0);
    'END';
LOOPYM:
    'BEGIN'
    \LOOP STATEMENT\
    SFIXS:=FIXCNT;
    SSTK:=STKLOD;
    RATOM;
    P2:=PC;
    STAMNT;
    GEN(\JMP\7,0,P2,7);
    'WHILE'FIXCNT>SFIXS'DO'
	'BEGIN'
	FIXCNT:=FIXCNT-1;
	FIX(FIXES(FIXCNT));
	'END';
    'END';
FORSYM:
    'BEGIN'
    \FOR STATEMENT\
    RATOM;
    'IF'ATYPE#IDENTIFIER'THEN'ERROR("NO VARIABLE?");
    LOOKUP;
    'IF'IDTYP#INTVAR'THEN'ERROR("BAD VARIABLE");
    SLEV:=LEV;
    SVAL:=VAL;
    RATOM;
    'IF'ATOM#GETSYM'THEN'ERROR("BAD ASSIGNMENT");
    RATOM;
    BOOLEXP;
    GEN(\STO\3,SLEV,SVAL,10);
    'IF'ATOM#^,'THEN'ERROR(" IN FOR");
    RATOM;
    BOOLEXP;
    'IF'ATOM#DOSYM'THEN'ERROR(" IN FOR");
    GEN(\LOD\1,SLEV,SVAL,10);
    P2:=PC;
    GEN(\FOR\24,0,0,7);
    RATOM;
    STKLOD:=STKLOD+1;
    STAMNT;
    STKLOD:=STKLOD-1;
    GEN(\INC\25,SLEV,SVAL,10);
    GEN(\JMP\7,0,P2,7);
    FIX(P2);
    'END';
CASEYM:
   'BEGIN'\CASSMT
   RATOM;
   'IF'ATOM=OFSYM'THEN'
	'BEGIN'
	RATOM;
	CASER(\JPC\8);
	'END'
    'ELSE'
	'BEGIN'
	BOOLEXP;
	'IF'ATOM#OFSYM'THEN'ERROR(" IN CASE");
	RATOM;
	STKLOD:=STKLOD+1;
	CASER(\CJP\37);
	GEN(\DRP\40,0,0,0);
	STKLOD:=STKLOD-1;
	'END';
    'END';
EXITYM:
    'BEGIN'
    GEN(\EXT\0,0,0,0);
    RATOM;
    'END';
ELSEYM:\NULL STATEMENT\;
^;:    \NULL STATEMENT\;
^]:    \NULL STATEMENT\;
UNTSYM:\NULL STATEMENT\;
ENDSYM:\NULL STATEMENT\;
EOFSYM:ERROR("UNTERMINATED PROGRAM")
'ELSE' ASSIGN;
'END'\STATEMENT\;


'PROCEDURE'PROGRAM;
'INTEGER'P1,TEMAT,REFCNT;


    'PROCEDURE'FPRDEF;
    'BEGIN'
    'REPEAT'
	'BEGIN'
	INSERT(FPRNAM,LEVEL,PC);
	GEN(\JMP\7,0,0,7);
	REFCNT:=REFCNT+1;
	RATOM;
	'IF'ATOM=^,'THEN'RATOM;
	'END'
    'UNTIL'ATYPE#IDENTIFIER;
    'END';\FPRDEF

    'PROCEDURE'PRODEF;
    'INTEGER'P2,CDX,HASH,I,K,STYP,SSNO;
    'BEGIN'
    \PROCEDURE DECLARATION\
    LOOKUP;
    'IF'IDTYP=FPRNAM 'THEN'
	'BEGIN'\FIX FORWARD PROCEDURE
	'IF'LEVEL#LEV'THEN'ERROR("WRONG LEVEL");
	FIX(VAL);
	SYMVAL(SYMNUM):=PC;
	SYMTYP(SYMNUM):=PROCNAM;
	REFCNT:=REFCNT-1;
	OPROC:='FALSE';
	'END'
    'ELSE'
	'BEGIN'
	SSNO:=NOSYM;
	INSERT(PROCNAM,LEVEL,PC);
	OPROC:='TRUE';
	'END';
    LEVEL:=LEVEL+2;
    'IF'LEVEL>14'THEN'ERROR("PROCEDURES NESTED TOO DEEP");
    P2:=NOSYM;
    CDX:=DX;
    \NOW EAT THE ARGUMENT LIST AS A COMMENT
    'WHILE'ATOM#^;'DO'RATOM;
    RATOM;
    PROGRAM;
    'IF'OPROC'THEN'SYMTYP(SSNO):=OPTPROC;
    DX:=CDX;
    \NOW RESTORE SYMBOL TABLE TO PREVIOUS LEVEL
    'WHILE'NOSYM>P2'DO'
	'BEGIN'
	NOSYM:=NOSYM-1;
	HASH:=0;
	K:=NOSYM;
	'FOR'I:=0,5'DO'[HASH:=HASH+SYMBOL(K);K:=K+SYMAX];
	BOX(HASH&63):=SYMPNT(NOSYM);
	STYP:=SYMTYP(NOSYM);
	'IF'STYP=FPRNAM'THEN'ERROR("UNRESOLVED SYMBOL");
	'END';
    LEVEL:=LEVEL-2;
    'END'\PROCEDURE DEFINITION\;

    'PROCEDURE'CONDEF;
    'INTEGER'COUNTER;
    'BEGIN'\DEFINE CONSTANT NAMES\
    COUNTER:=0;
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	RATOM;
	'IF'ATOM#^='THEN'
		'BEGIN'
		INSERT(CONNAM,0,COUNTER);
		COUNTER:=COUNTER+1;
		'END'
	'ELSE'	'BEGIN'
		RATOM;
		GETCON;
		INSERT(CONNAM,0,IATOM);
		RATOM;
		'END';
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN DEFINE");
    RATOM;
    'END'\CONSTANT DEFINITION\;


    'PROCEDURE'CODDEF;
    'BEGIN'
    \DEFINE INTERNAL INTRINSIC NAMES\
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	RATOM;
	'IF'ATOM#^='THEN'ERROR("NO EQUALS?");
	RATOM;
	GETCON;
	'IF'(IATOM<0)!(IATOM>63)
		'THEN'ERROR("BAD NUMBER");
	INSERT(INTPROC,0,IATOM+64);
	RATOM;
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN CODE");
    RATOM;
    'END'\INTRINSIC DEFINITION\;

    'PROCEDURE'EXTDEF;
    'BEGIN'
    \DEFINE EXTERNAL INTRINSIC NAMES\
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	RATOM;
	'IF'ATOM#^='THEN'ERROR("NO EQUALS?");
	RATOM;
	GETCON;
	INSERT(EXTPROC,0,IATOM);
	RATOM;
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN EXTERNALS");
    RATOM;
    'END'\FUNCTION NAME DEFINITION\;


    'PROCEDURE'INTDEF;
    'BEGIN'
    \DEFINE INTEGER VARIABLES\
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	INSERT(INTVAR,LEVEL,DX);
	DX:=DX+2;
	RATOM;
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN INT DECLARATION");
    RATOM;
    'END'\INTEGER DEFINITION\;


    'PROCEDURE'ADRDEF;
    'BEGIN'
    \DEFINE ADDRESS VARIABLES\
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	INSERT(ADDVAR,LEVEL,DX);
	DX:=DX+2;
	RATOM;
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN ADR DECLARATION");
    RATOM;
    'END'\ADDRESS DEFINITION\;

    'PROCEDURE'OWNDEF;
    'INTEGER'K,N,TPC,I;


	'PROCEDURE'OWNARRAY;
        'BEGIN'
        CHOUT(BINDEV,^*);
        HEXW(PC+2);
        PC:=PC+2;
        K:=1;
        RATOM;\PAST THE PAREN
	GETCON;
        N:=IATOM;\FIRST DIMEN
        RATOM;
        'WHILE'ATOM=^,'DO'
		'BEGIN'
	        SKIP(BINDEV);
	        RATOM;\PAST THE COMMA
		GETCON;
	        TPC:=PC+K*N*2;
	        'FOR'I:=1,K*N'DO'
			'BEGIN'
		        CHOUT(BINDEV,^*);
		        HEXW(TPC);
		        PC:=PC+2;
		        TPC:=TPC+IATOM*2;
		        'END';
		K:=K*N;
	        N:=IATOM;
	        RATOM;\PAST THIS DIMEN
	        'END';
	PC:=PC+K*N*2;\THE ACTUAL SPACE
        'IF'ATOM#^)'THEN'ERROR("PAREN MISMATCH");
        RATOM;
        'END';

    'BEGIN'
    \DEFINE OWN VARIABLES\
    'WHILE'ATYPE=IDENTIFIER'DO'
	'BEGIN'
	INSERT(OWNVAR,0,PC);
	RATOM;
	SKIP(BINDEV);
	'IF'ATOM=^('THEN'OWNARRAY
	'ELSE'[HEXW(0);PC:=PC+2];
	'IF'ATOM=^,'THEN'RATOM;
	'END';
    'IF'ATOM#^;'THEN'ERROR(" IN OWN DECLARATION");
    RATOM;
    'END'\OWN DEFINITION\;

'BEGIN'\PROC PROGRAM\
'IF'LEVEL=0'THEN'DX:=2'ELSE'DX:=0;
P1:=PC;
REFCNT:=0;
SSTK:=STKLOD;
GEN(\JMP\7,0,0,7);
'LOOP'	'CASE'ATOM'OF'
	CODSYM:[RATOM;CODDEF];
	EXTNYM:[RATOM;EXTDEF];
	INTSYM:[RATOM;INTDEF];
	ADRSYM:[RATOM;ADRDEF];
	OWNSYM:[RATOM;OWNDEF];
	DEFSYM:[RATOM;CONDEF]
	'ELSE''QUIT';
'WHILE'ATOM=PROCYM ! ATOM=FPRSYM 'DO'
	'BEGIN'
	TEMAT:=ATOM;
	RATOM;
	'IF'ATYPE#IDENTIFIER'THEN'ERROR("BAD NAME");
	'IF'TEMAT=PROCYM'THEN'PRODEF'ELSE'FPRDEF;
	'IF'ATOM#^;'THEN'ERROR(" IN PROC DECLARATION");
	RATOM;
	'END';
'IF'PC=P1+3'THEN'PC:=P1'ELSE'FIX(P1);
'IF'DX#0'THEN'[GEN(\SPI\9,0,DX,2);OPROC:='FALSE'];
STAMNT;
GEN('IF'OPROC'THEN'\RTS\39'ELSE'\RET\6,0,0,0);
'IF'FIXCNT#0'THEN'ERROR("UNRESOLVED QUITS");
'IF'ATOM#^;'THEN'ERROR("UNRESOLVED STATEMENT");
'IF'REFCNT>0'THEN'ERROR("UNRESOLVED FORWARD PROCEDURE");
'END'\PROGRAM\;

'BEGIN'\MAIN PROGRAM\

\INITIALISE IO DEVICES
OPENI(0);OPENO(0);
SKIP(0);
TEXT(0,"XPL0 V4D - MAY 1980");

\RESERVE ARRAYS\
LINE:=RESERVE(80);
IDNAM:=RESERVE(6);
SYMBOL:=RESERVE(6*SYMAX);
SYMTYP:=RESERVE(SYMAX);
SYMVAL:=RESERVE(2*SYMAX);
SYMLEV:=RESERVE(SYMAX);
SYMPNT:=RESERVE(SYMAX);
BOX:=RESERVE(64);
FIXES:=RESERVE(20);

'LOOP'
	'BEGIN'
	SKIP(0);TEXT(0,"BINARY:");
	CHOUT(0,'IF'BINDEV=3'THEN'^Y'ELSE'^N);
	SKIP(0);TEXT(0,"LISTING:");
	CHOUT(0,'IF'LSTDEV=0'THEN'^Y'ELSE'^N);
	SKIP(0);TEXT(0,"OK?");
	OPENI(0);
	'IF'CHIN(0)#^N'THEN''QUIT';
	SKIP(0);TEXT(0,"BINARY?");
	OPENI(0);
	BINDEV:='IF'CHIN(0)=^Y'THEN'3'ELSE'7;
	TEXT(0,"LISTING?");
	OPENI(0);
	LSTDEV:='IF'CHIN(0)=^Y'THEN'0'ELSE'7;
	'END';
SRCDEV:=3;
OPENO(BINDEV);
OPENO(LSTDEV);
OPENI(SRCDEV);

\PRESET SOME THINGS\
CHAR:=RETCH;		CASEIN:='FALSE';	CC:=1;
LL:=0;			STRFLG:='FALSE';	PC:=0;
LEVEL:=0;		NOSYM:=0;		FIXCNT:=0;
STKLOD:=0;		OLDPC:=$FFFF;

GETCH;
RATOM;
\ZERO THE SYMBOL TABLE
'FOR'T:=0,5'DO'IDNAM(T):=^ ;
'FOR'T:=0,63'DO'BOX(T):=EMPTY;

OPROC:='FALSE';
PROGRAM;

'WHILE'NOSYM>0'DO'
	[NOSYM:=NOSYM-1;
	'IF'SYMTYP(NOSYM)=FPRNAM'THEN'ERROR("UNRESOLVED SYMBOL")];
'IF'ATOM=^;'THEN'RATOM;
'IF'ATOM#EOFSYM'THEN'ERROR("TOO MANY ENDS");

SKIP(0);
TEXT(0,"PROGRAM LENGTH: ");
NUMOUT(0,PC+1);
SKIP(0);
CLOSE(LSTDEV);
CHOUT(BINDEV,^$);
CLOSE(BINDEV);

'END';\OF MAIN
