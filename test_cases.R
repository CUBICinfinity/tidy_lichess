fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "")

# rook disambiguation
{
fen_move("k4r2/8/8/8/8/K4R2/8/5r2 b - - 0 1", "Rf5") ==
  "k7/8/8/5r2/8/K4R2/8/5r2 w - - 1 2"
fen_move("k4r2/8/1r6/8/8/K4R2/8/8 b - - 0 1", "Rff6") ==
  "k7/8/1r3r2/8/8/K4R2/8/8 w - - 1 2"
fen_move("k4r2/8/1r4r1/8/8/K7/8/5r2 b - - 0 1", "Rbf6") ==
  "k4r2/8/5rr1/8/8/K7/8/5r2 w - - 1 2"
fen_move("k4r2/8/1r4r1/8/8/K7/8/5r2 b - - 0 1", "Rgf6") ==
  "k4r2/8/1r3r2/8/8/K7/8/5r2 w - - 1 2"
fen_move("k4r2/8/1r1r2r1/8/5r2/K7/8/5r2 b - - 0 1", "Rdf6") ==
  "k4r2/8/1r3rr1/8/5r2/K7/8/5r2 w - - 1 2"
fen_move("k4r2/8/1r1r2r1/8/5r2/K7/8/5r2 b - - 0 1", "R4f6") ==
  "k4r2/8/1r1r1rr1/8/8/K7/8/5r2 w - - 1 2"
fen_move("k4r2/8/1r1r2r1/8/5r2/K7/8/5r2 b - - 0 1", "R8f6") ==
  "k7/8/1r1r1rr1/8/5r2/K7/8/5r2 w - - 1 2"

fen_move("k4r2/5p2/8/8/8/K7/8/5r2 b - - 0 1", "Rf5") ==
  "k4r2/5p2/8/5r2/8/K7/8/8 w - - 1 2"
fen_move("k4r2/5p2/8/2r5/8/K7/8/5r2 b - - 0 1", "Rff5") ==
  "k4r2/5p2/8/2r2r2/8/K7/8/8 w - - 1 2"
}

# Queen
{
  fen_move("k7/5q2/4q3/8/8/8/q3q3/7K b - - 0 1", "Q6c4") ==
    "k7/5q2/8/8/2q5/8/q3q3/7K w - - 1 2"
  fen_move("k7/5q2/4q3/8/8/8/q3q3/7K b - - 0 1", "Qe2c4") ==
    "k7/5q2/4q3/8/2q5/8/q7/7K w - - 1 2"
  fen_move("k7/5q2/4q3/8/8/8/q3q3/7K b - - 0 1", "Qac4") ==
    "k7/5q2/4q3/8/2q5/8/4q3/7K w - - 1 2"
  
  fen_move("k7/5q2/4q3/8/8/1p1p4/q3q3/7K b - - 0 1", "Qc4") ==
    "k7/5q2/8/8/2q5/1p1p4/q3q3/7K w - - 1 2"
  fen_move("k7/5q2/4q3/3p4/8/1p6/q3q3/7K b - - 0 1", "Qc4") ==
    "k7/5q2/4q3/3p4/2q5/1p6/q7/7K w - - 1 2"
  fen_move("k7/5q2/4q3/8/8/1p6/q3q3/7K b - - 0 1", "Q6c4") ==
    "k7/5q2/8/8/2q5/1p6/q3q3/7K w - - 1 2"
  fen_move("k7/5q2/4q3/8/8/1p6/q3q3/7K b - - 0 1", "Q2c4") ==
    "k7/5q2/4q3/8/2q5/1p6/q7/7K w - - 1 2"
  fen_move("k7/5q2/4q3/8/8/3p4/q3q3/7K b - - 0 1", "Qec4") ==
    "k7/5q2/8/8/2q5/3p4/q3q3/7K w - - 1 2"
  fen_move("k7/5q2/4q3/3p4/8/3p4/q3q3/7K b - - 0 1", "Qc4") ==
    "k7/5q2/4q3/3p4/2q5/3p4/4q3/7K w - - 1 2"
}

# normal gameplay
{
fen_move("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", "d4") ==
  "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1"
fen_move("rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1", "b6") ==
  "rnbqkbnr/p1pppppp/1p6/8/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2"
fen_move("rnbqkbnr/p1pppppp/1p6/8/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2", "Nf3") ==
  "rnbqkbnr/p1pppppp/1p6/8/3P4/5N2/PPP1PPPP/RNBQKB1R b KQkq - 1 2"
fen_move("rnbqkbnr/p1pppppp/1p6/8/3P4/5N2/PPP1PPPP/RNBQKB1R b KQkq - 1 2", "Bb7") ==
  "rn1qkbnr/pbpppppp/1p6/8/3P4/5N2/PPP1PPPP/RNBQKB1R w KQkq - 2 3"
fen_move("rn1qkbnr/pbpppppp/1p6/8/3P4/5N2/PPP1PPPP/RNBQKB1R w KQkq - 2 3", "Nc3") ==
  "rn1qkbnr/pbpppppp/1p6/8/3P4/2N2N2/PPP1PPPP/R1BQKB1R b KQkq - 3 3"
fen_move("rn1qkbnr/pbpppppp/1p6/8/3P4/2N2N2/PPP1PPPP/R1BQKB1R b KQkq - 3 3", "Nf6") ==
  "rn1qkb1r/pbpppppp/1p3n2/8/3P4/2N2N2/PPP1PPPP/R1BQKB1R w KQkq - 4 4"
fen_move("rn1qkb1r/pbpppppp/1p3n2/8/3P4/2N2N2/PPP1PPPP/R1BQKB1R w KQkq - 4 4", "Bf4") ==
  "rn1qkb1r/pbpppppp/1p3n2/8/3P1B2/2N2N2/PPP1PPPP/R2QKB1R b KQkq - 5 4"
fen_move("rn1qkb1r/pbpppppp/1p3n2/8/3P1B2/2N2N2/PPP1PPPP/R2QKB1R b KQkq - 5 4", "d5") ==
  "rn1qkb1r/pbp1pppp/1p3n2/3p4/3P1B2/2N2N2/PPP1PPPP/R2QKB1R w KQkq - 0 5"
fen_move("rn1qkb1r/pbp1pppp/1p3n2/3p4/3P1B2/2N2N2/PPP1PPPP/R2QKB1R w KQkq - 0 5", "e3") == 
  "rn1qkb1r/pbp1pppp/1p3n2/3p4/3P1B2/2N1PN2/PPP2PPP/R2QKB1R b KQkq - 0 5"
fen_move("rn1qkb1r/pbp1pppp/1p3n2/3p4/3P1B2/2N1PN2/PPP2PPP/R2QKB1R b KQkq - 0 5", "e6") ==
  "rn1qkb1r/pbp2ppp/1p2pn2/3p4/3P1B2/2N1PN2/PPP2PPP/R2QKB1R w KQkq - 0 6"
fen_move("rn1qkb1r/pbp2ppp/1p2pn2/3p4/3P1B2/2N1PN2/PPP2PPP/R2QKB1R w KQkq - 0 6", "Bd3") ==
  "rn1qkb1r/pbp2ppp/1p2pn2/3p4/3P1B2/2NBPN2/PPP2PPP/R2QK2R b KQkq - 1 6"
fen_move("rn1qkb1r/pbp2ppp/1p2pn2/3p4/3P1B2/2NBPN2/PPP2PPP/R2QK2R b KQkq - 1 6", "Bb4") ==
  "rn1qk2r/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPP2PPP/R2QK2R w KQkq - 2 7"
fen_move("rn1qk2r/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPP2PPP/R2QK2R w KQkq - 2 7", "Qd2") ==
  "rn1qk2r/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/R3K2R b KQkq - 3 7"
fen_move("rn1qk2r/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/R3K2R b KQkq - 3 7", "O-O") ==
  "rn1q1rk1/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/R3K2R w KQ - 4 8"
fen_move("rn1q1rk1/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/R3K2R w KQ - 4 8", "O-O-O") ==
  "rn1q1rk1/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/2KR3R b - - 5 8"
fen_move("rn1q1rk1/pbp2ppp/1p2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/2KR3R b - - 5 8", "Na6") ==
  "r2q1rk1/pbp2ppp/np2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/2KR3R w - - 6 9"
fen_move("r2q1rk1/pbp2ppp/np2pn2/3p4/1b1P1B2/2NBPN2/PPPQ1PPP/2KR3R w - - 6 9", "a3") ==
  "r2q1rk1/pbp2ppp/np2pn2/3p4/1b1P1B2/P1NBPN2/1PPQ1PPP/2KR3R b - - 0 9"
fen_move("r2q1rk1/pbp2ppp/np2pn2/3p4/1b1P1B2/P1NBPN2/1PPQ1PPP/2KR3R b - - 0 9", "Ba5") ==
  "r2q1rk1/pbp2ppp/np2pn2/b2p4/3P1B2/P1NBPN2/1PPQ1PPP/2KR3R w - - 1 10"
fen_move("r2q1rk1/pbp2ppp/np2pn2/b2p4/3P1B2/P1NBPN2/1PPQ1PPP/2KR3R w - - 1 10", "Ng5") ==
  "r2q1rk1/pbp2ppp/np2pn2/b2p2N1/3P1B2/P1NBP3/1PPQ1PPP/2KR3R b - - 2 10"
fen_move("r2q1rk1/pbp2ppp/np2pn2/b2p2N1/3P1B2/P1NBP3/1PPQ1PPP/2KR3R b - - 2 10", "g6") ==
  "r2q1rk1/pbp2p1p/np2pnp1/b2p2N1/3P1B2/P1NBP3/1PPQ1PPP/2KR3R w - - 0 11"
fen_move("r2q1rk1/pbp2p1p/np2pnp1/b2p2N1/3P1B2/P1NBP3/1PPQ1PPP/2KR3R w - - 0 11", "b4") ==
  "r2q1rk1/pbp2p1p/np2pnp1/b2p2N1/1P1P1B2/P1NBP3/2PQ1PPP/2KR3R b - - 0 11"
fen_move("r2q1rk1/pbp2p1p/np2pnp1/b2p2N1/1P1P1B2/P1NBP3/2PQ1PPP/2KR3R b - - 0 11", "Bxb4") ==
  "r2q1rk1/pbp2p1p/np2pnp1/3p2N1/1b1P1B2/P1NBP3/2PQ1PPP/2KR3R w - - 0 12"
fen_move("r2q1rk1/pbp2p1p/np2pnp1/3p2N1/1b1P1B2/P1NBP3/2PQ1PPP/2KR3R w - - 0 12", "axb4") ==
  "r2q1rk1/pbp2p1p/np2pnp1/3p2N1/1P1P1B2/2NBP3/2PQ1PPP/2KR3R b - - 0 12"
fen_move("r2q1rk1/pbp2p1p/np2pnp1/3p2N1/1P1P1B2/2NBP3/2PQ1PPP/2KR3R b - - 0 12", "Nxb4") == 
  "r2q1rk1/pbp2p1p/1p2pnp1/3p2N1/1n1P1B2/2NBP3/2PQ1PPP/2KR3R w - - 0 13"
fen_move("r2q1rk1/pbp2p1p/1p2pnp1/3p2N1/1n1P1B2/2NBP3/2PQ1PPP/2KR3R w - - 0 13", "Nb5") ==
  "r2q1rk1/pbp2p1p/1p2pnp1/1N1p2N1/1n1P1B2/3BP3/2PQ1PPP/2KR3R b - - 1 13"
fen_move("r2q1rk1/pbp2p1p/1p2pnp1/1N1p2N1/1n1P1B2/3BP3/2PQ1PPP/2KR3R b - - 1 13", "Nxd3+") ==
  "r2q1rk1/pbp2p1p/1p2pnp1/1N1p2N1/3P1B2/3nP3/2PQ1PPP/2KR3R w - - 0 14"
fen_move("r2q1rk1/pbp2p1p/1p2pnp1/1N1p2N1/3P1B2/3nP3/2PQ1PPP/2KR3R w - - 0 14", "Qxd3") ==
  "r2q1rk1/pbp2p1p/1p2pnp1/1N1p2N1/3P1B2/3QP3/2P2PPP/2KR3R b - - 0 14"
}

