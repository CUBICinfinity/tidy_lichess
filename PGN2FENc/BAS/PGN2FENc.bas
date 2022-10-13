CLS

RANDOMIZE TIMER
SCREEN _NEWIMAGE(600, 350, 13)

LOCATE 1, 1: INPUT "PGN filename (without extension)"; PGNname$
PGNname$ = PGNname$ + ".pgn"

'PGN to EPD:
LOCATE 4, 1: PRINT "Step 1 / 9"
LOCATE 5, 1: PRINT "Using pgn-extract-17-19 by David J. Barnes"
PGNEX$ = "pgn-extract-17-19 -Wepd " + PGNname$ + " --output EPD.txt"
SHELL PGNEX$ '"pgn-extract-17-19 -Wepd PGN.txt --output EPD.txt"

t1 = TIMER

'EPD to EPDclean:

LOCATE 7, 1: PRINT "Step 2 / 9"
OPEN "EPD.txt" FOR INPUT AS #1
lines = 0
DO WHILE NOT EOF(1)
    LINE INPUT #1, l$
    lines = lines + 1
    LOCATE 8, 1: PRINT "Counting intermediate EPD lines (around 5 x lines in PGN):"; lines
LOOP
CLOSE #1

LOCATE 10, 1: PRINT "Step 3 / 9"
DIM EPDclean$(lines)
OPEN "EPD.txt" FOR INPUT AS #1
i = 1
DO WHILE NOT EOF(1)
    LINE INPUT #1, EPDclean$(i)
    i = i + 1
    LOCATE 11, 1: PRINT INT(i / lines * 100); "%"
LOOP
CLOSE #1
lines = i - 1


LOCATE 13, 1: PRINT "Step 4 / 9"
i = 1
j = 1
90:
IF EPDclean$(i) = "" THEN i = i + 1
EPDclean$(j) = EPDclean$(i)
IF i >= lines - 1 THEN GOTO 100
i = i + 1
j = j + 1
LOCATE 14, 1: PRINT INT(i / lines * 100); "%"
GOTO 90
100:
LOCATE 14, 1: PRINT 100; "%"
lines = j

LOCATE 16, 1: PRINT "Step 5 / 9"
FOR i = 1 TO lines
    j = 0
    110:
    j = j + 1
    IF MID$(EPDclean$(i), j, 4) = " c0 " THEN EPDclean$(i) = MID$(EPDclean$(i), 1, j): GOTO 120
    GOTO 110
    120:
    LOCATE 17, 1: PRINT INT(i / lines * 100); "%"
NEXT i

'EPDclean to FENL:

LOCATE 19, 1: PRINT "Step 6 / 9"
OPEN PGNname$ FOR INPUT AS #1
LPGN = 0
DO WHILE NOT EOF(1)
    INPUT #1, l$
    LPGN = LPGN + 1
    LOCATE 20, 1: PRINT "Counting PGN lines (including empty lines):"; LPGN
LOOP
CLOSE #1

LOCATE 22, 1: PRINT "Step 7 / 9"
DIM PGN$(LPGN)
OPEN PGNname$ FOR INPUT AS #1
FOR i = 1 TO LPGN
    INPUT #1, PGN$(i)
    LOCATE 23, 1: PRINT INT(i / LPGN * 100); "%"
NEXT i
CLOSE #1

LOCATE 25, 1: PRINT "Step 8 / 9"
DIM FEN$(lines)
k = 0
hmovsi = -1
FOR i = 1 TO lines
    IF MID$(EPDclean$(i), 1, 43) = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR" THEN k = k + 1: hmovsi = i
    movs$ = STR$(INT((i - hmovsi) / 2) + 1)
    FEN$(i) = EPDclean$(i) + movs$
    LOCATE 26, 1: PRINT INT(i / lines * 100); "%"
NEXT i
Partidas = k

KILL "EPD.txt"

LOCATE 28, 1: PRINT "Step 9 / 9"
OPEN "FEN.txt" FOR OUTPUT AS #1
FOR i = 1 TO lines
    WRITE #1, FEN$(i)
    LOCATE 29, 1: PRINT INT(i / lines * 100); "%"
NEXT i
CLOSE #1

t2 = TIMER
LOCATE 32, 1: PRINT Partidas; "Games parsed from PGN to FEN (no 50 moves rule data) in"; INT(t2 - t1); "seconds"



