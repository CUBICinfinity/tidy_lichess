Paraná (Argentina)
March 9th,2015.

This program allows you to create a continuos string of fen chess lines from given .pgn file that could have more than one game.
In fact was tested successfully with Korchnoi.pgn downloaded from http://www.pgnmentor.com/files.html that have 4565 games.
PGN2FENc was programming in QB64.
Is slow program. Its transform pgn files of x KB to a fen.txt file at a velocity of around 7KB/sec. 
To make the fen strings from Korchnoi.pgn (4565 games in 3GB), it needs 8 minutes in my Phenom 955.


Install:
-Unrar PGN2FENc.rar in any folder you want.

Usage:
-Put your pgn file in the same folder.
-Doubleclick on PGN2FENc.exe
-Introduce the name (without the extension) of the pgn file from wich you want to create the FEN string.
-Go for a cup of coffee if the pgn is large.
-You have the fen´s strings in FEN.txt


More:
-The main program is PGN2FENc.exe that needs pgn-extract-17-19.exe from David J. Barnes to run.
-pgn-extract-17-19.exe, free distribution ( http://www.cs.kent.ac.uk/people/staff/djb/pgn-extract/ ), is adjointed here.
-You need to have in the same folder the .pgn file you want to use to make the fen strings.
-The result is FEN.txt file having lines like this:

"4k3/R4p2/K1p1p1p1/2Pp2P1/3P1P2/1r2P3/8/8 w - -  52"
"4k3/1R3p2/K1p1p1p1/2Pp2P1/3P1P2/1r2P3/8/8 b - -  52"
"4k3/1R3p2/K1p1p1p1/2Pp2P1/3P1P2/4r3/8/8 w - -  53"
"4k3/1R3p2/1Kp1p1p1/2Pp2P1/3P1P2/4r3/8/8 b - -  53"
"4k3/1R3p2/1Kp1p1p1/2Pp2P1/3PrP2/8/8/8 w - -  54"
"4k3/1R3p2/2K1p1p1/2Pp2P1/3PrP2/8/8/8 b - -  54"
"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -  1"
"rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR b KQkq c3  1"
"rnbqkb1r/pppppppp/5n2/8/2P5/8/PP1PPPPP/RNBQKBNR w KQkq -  2"
"rnbqkb1r/pppppppp/5n2/8/2P5/6P1/PP1PPP1P/RNBQKBNR b KQkq -  2"
"rnbqkb1r/pp1ppppp/5n2/2p5/2P5/6P1/PP1PPP1P/RNBQKBNR w KQkq c6  3"


-As example to test PGN2FENc, you have here Adamspic.pgn, that is a cut from Adams.pgn downloaded from: http://www.pgnmentor.com/files.html
-In the BAS folder you have the ( QB64http://www.qb64.net/ ) code used to make PGN2FENc.


-If anyone knows how to make a faster program to do the same, you are welcome.


-PGN2FEN2 is open sourcecode and free distribution and usage program.

Luis Babboni.