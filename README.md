# tidy_lichess - Alpha 1.0.0
Analyze your lichess games
---

The most useful feature of this repo is the `fen_move` function, which gets the 
next FEN position in chess, given the current FEN position and the algebraic 
move.  
https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation  
https://en.wikipedia.org/wiki/Algebraic_notation_(chess)

`fen_move` supports a number of variants, namely,  
Standard (Including From Position)  
Crazyhouse  
Antichess (Following the rules of lichess.org and chess.com)  
Chess960  
Three-check  
King of the Hill  
Horde  
Racing Kings  

Many other variants, including Atomic Chess, Duck Chess, ones with more or less 
than two players, and ones with boards in any shape other than 8x8 are not 
supported. There is a possibility that I will add support for some other 
variants in the future, but it is not something you should wait for. Instead,
you should start your own branch to add anything you like.
