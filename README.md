# tidy_lichess - 1.0.1
### Analyze your lichess games

---

Lichess.org already offers a nice collection of analysis tools players can use to understand their performance, but with preset limitations.  
This repository provides the basic tools to perform your own research on chess games data with the limitless potential of R.

---

`evaluation.R` includes a customizable `material_score()` for FEN positions.

---

The most advanced feature of this repo is the `fen_move` function, which gets the 
next FEN position in chess, given the current FEN position and the algebraic 
move. Thus, allowing you to recreate every position in the game and save them in tibbles.  
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

Many other variants, including Atomic Chess, Duck Chess, ones with more or less 
than two players, and ones with boards in any shape other than 8x8 are not 
supported. There is a possibility that I will add support for some other 
variants in the future, but it is not something you should wait for. Instead,
you should start your own branch to add anything you like.

---

AnalysisDemo.R is an example script for building an opening performance plot:
![Opening Analysis Plot](ECO_plot.png)
