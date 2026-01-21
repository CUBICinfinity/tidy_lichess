# Execute script
source('fen_move.R')


# These tests are not fully comprehensive, but intend to catch the majority of mistakes.


message('checking en passant support')
# Check enpassant working properly
moves <- c('c5', 'dxc6')
positions <- c('rn1qkbnr/pppb2pp/3pp3/1N1P1p2/3Q4/8/PPP1PPPP/R1B1KBNR b KQkq - 0 5',
 'rn1qkbnr/pp1b2pp/3pp3/1NpP1p2/3Q4/8/PPP1PPPP/R1B1KBNR w KQkq c6 0 6',
 'rn1qkbnr/pp1b2pp/2Ppp3/1N3p2/3Q4/8/PPP1PPPP/R1B1KBNR b KQkq - 0 6')

for (i in 1:length(moves)) {
	if (fen_move(positions[i], moves[i]) != positions[i+1]) {
		message('failed at ', positions[i], ' || ', moves[i], ' : ', fen_move(positions[i], moves[i]))
	}
}



# illegal cases. (contains illegal positions too; not all moves are illegal)
message('checking illegal cases. there should be 13 warnings')
tests <- list(c('8/3k4/8/3K4/6p1/8/8/8 w - - 0 1', 'Ke6+', '8/3k4/4K3/8/6p1/8/8/8 b - - 1 1'), # KvK
c('8/3k4/4K3/8/6p1/8/8/8 b - - 0 1', 'Kxe6', '8/8/4k3/8/6p1/8/8/8 w - - 0 2'), # king capture king
c('7B/8/5k2/8/8/8/8/8 b - - 0 1', 'Kg7', '7B/6k1/8/8/8/8/8/8 w - - 1 2'), # stay in check
c('7B/6k1/8/8/8/8/8/8 w - - 1 2', 'Bxg7', '8/6B1/8/8/8/8/8/8 b - - 0 2'), # capture king
c('7B/8/5k2/8/8/8/8/8 b - - 0 1', 'Kg7', '7B/5k2/8/8/8/8/8/8 w - - 1 2'), # move out of check. move NOT illegal
c('8/8/8/8/1Q1qk1K1/8/8/8 b - - 1 2', 'Qg1+', '8/8/8/8/1Q2k1K1/8/8/6q1 w - - 2 3'), # pinned
c('8/8/8/8/1Q2k1K1/8/8/6q1 w - - 2 3', 'Qe7+', '8/4Q3/8/8/4k1K1/8/8/6q1 b - - 3 3'), # stay in check
c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', 'Ne2', 
'rnbqkbnr/pppppppp/8/8/8/8/PPPPNPPP/RNBQKB1R b KQkq - 1 1'), # occupied
c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', 'Nxe2', 
'rnbqkbnr/pppppppp/8/8/8/8/PPPPNPPP/RNBQKB1R b KQkq - 1 1'), # can't capture self. !!This FEN is ambiguous. Implementation optional and subjective
c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', 'Rh3', 
'rnbqkbnr/pppppppp/8/8/8/7R/PPPPPPPP/RNBQKBN1 b KQkq - 1 1'), # blocked
c('rnbqk2r/pppp1ppp/8/8/8/BP6/P1PPP1PP/RN1QKBNR b KQkq - 2 6', 'O-O', 
'rnbq1rk1/pppp1ppp/8/8/8/BP6/P1PPP1PP/RN1QKBNR w KQ - 3 7'), # castle through check
c('rnbqk2r/pppp1ppp/8/8/8/BP6/P1PPP1PP/RN1QKBNR b KQkq - 2 6', 'Ke7', 
'rnbq3r/ppppkppp/8/8/8/BP6/P1PPP1PP/RN1QKBNR w KQ - 3 7'), # move into check
c('rnbqk2r/ppp2ppp/5n2/3Pp3/1b2P3/2N5/PP1P1PPP/R1BQKBNR[P] w KQkq - 1 5', '@g8',
'rnbqk1Pr/ppp2ppp/5n2/3Pp3/1b2P3/2N5/PP1P1PPP/R1BQKBNR[P] b KQkq - 0 5'), # illegal placement
c('r1b1k2r/p1pq1ppp/2n5/1B2p3/Q3n3/2P5/PP3PPP/R1B1K1NR[PBpppn] w KQkq - 0 10', 'B@h8',
'r1b1k2r/p1pq1ppp/2n5/1B2p3/Q3n3/2P5/PP1N1PPP/R1B1K1NR[PBpppn] b KQkq - 1 10')) # illegal placement

for (test in tests) {
	tryCatch({
		if (fen_move(test[1], test[2]) != test[3]) {
			message('failed at ', test[1], ' || ', test[2], ' : ', fen_move(test[1], test[2]))
		}
	}, error = function(e) {
		message(paste("error at ", test[1], test[2], " : ", e$messgae))
	})
}


message('checking a long standard game')
# Test against a new, long game
# https://lichess.org/eatLiF30
moves <- c('e4','e5','Nf3','Nc6','d4','d6','Bc4','Bg4','d5','Na5','Bd3','Bxf3','Qxf3','c5','Bb5+','Ke7','c3','a6','Be2','b6','Bg5+','f6','Qh3','Qc7','Be3',
'g6','Nd2','Nb7','f4','Kf7','f5','Kg7','Qg3','Be7','h4','Qd8','O-O','Qd7','a4','Qe8','Nc4','Bd8','b4','Bc7','Qh3','Nd8','bxc5','bxc5','Rf2','Ra7','Raf1','Rb7',
'g4','h6','fxg6','Qxg6','Qg2','Nf7','Bd2','Kf8','Ne3','a5','Ba6','Rb3','Nc4','Rb8','Bb5','Qh7','Bd7','Rb3','Bf5','Qg7','Be6','Ke8','Kh2','Qh7','h5','Rb7','Rxf6',
'Nxf6','Rxf6','Ng5','Bxg5','hxg5','Rf7','Qxf7','Bxf7+','Kxf7','Qf3+','Ke7','Qf5','Rf8','Qe6+','Kd8','Nxd6','Bxd6','Qxd6+','Ke8','Qxe5+','Kf7','d6','Kg8','Qxg5+',
'Rg7','Qd5+','Kh8','Kg3','Kh7','e5','Rg5','d7','Rfg8','d8=Q','Rxg4+','Kf2','Rf4+','Ke3','Rxd8','Qxd8','Rg4','e6','Rg1','Kf2','Rh1','e7','Rxh5','e8=Q','Rf5+',
'Ke2','Rf2+','Kxf2','c4','Qh8+','Kg6','Qdf6#')
positions <- c(
'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
'r1bqkbnr/pppp1ppp/2n5/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R b KQkq - 0 3',
'r1bqkbnr/ppp2ppp/2np4/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R w KQkq - 0 4',
'r1bqkbnr/ppp2ppp/2np4/4p3/2BPP3/5N2/PPP2PPP/RNBQK2R b KQkq - 1 4',
'r2qkbnr/ppp2ppp/2np4/4p3/2BPP1b1/5N2/PPP2PPP/RNBQK2R w KQkq - 2 5',
'r2qkbnr/ppp2ppp/2np4/3Pp3/2B1P1b1/5N2/PPP2PPP/RNBQK2R b KQkq - 0 5',
'r2qkbnr/ppp2ppp/3p4/n2Pp3/2B1P1b1/5N2/PPP2PPP/RNBQK2R w KQkq - 1 6',
'r2qkbnr/ppp2ppp/3p4/n2Pp3/4P1b1/3B1N2/PPP2PPP/RNBQK2R b KQkq - 2 6',
'r2qkbnr/ppp2ppp/3p4/n2Pp3/4P3/3B1b2/PPP2PPP/RNBQK2R w KQkq - 0 7',
'r2qkbnr/ppp2ppp/3p4/n2Pp3/4P3/3B1Q2/PPP2PPP/RNB1K2R b KQkq - 0 7',
'r2qkbnr/pp3ppp/3p4/n1pPp3/4P3/3B1Q2/PPP2PPP/RNB1K2R w KQkq c6 0 8',
'r2qkbnr/pp3ppp/3p4/nBpPp3/4P3/5Q2/PPP2PPP/RNB1K2R b KQkq - 1 8',
'r2q1bnr/pp2kppp/3p4/nBpPp3/4P3/5Q2/PPP2PPP/RNB1K2R w KQ - 2 9',
'r2q1bnr/pp2kppp/3p4/nBpPp3/4P3/2P2Q2/PP3PPP/RNB1K2R b KQ - 0 9',
'r2q1bnr/1p2kppp/p2p4/nBpPp3/4P3/2P2Q2/PP3PPP/RNB1K2R w KQ - 0 10',
'r2q1bnr/1p2kppp/p2p4/n1pPp3/4P3/2P2Q2/PP2BPPP/RNB1K2R b KQ - 1 10',
'r2q1bnr/4kppp/pp1p4/n1pPp3/4P3/2P2Q2/PP2BPPP/RNB1K2R w KQ - 0 11',
'r2q1bnr/4kppp/pp1p4/n1pPp1B1/4P3/2P2Q2/PP2BPPP/RN2K2R b KQ - 1 11',
'r2q1bnr/4k1pp/pp1p1p2/n1pPp1B1/4P3/2P2Q2/PP2BPPP/RN2K2R w KQ - 0 12',
'r2q1bnr/4k1pp/pp1p1p2/n1pPp1B1/4P3/2P4Q/PP2BPPP/RN2K2R b KQ - 1 12',
'r4bnr/2q1k1pp/pp1p1p2/n1pPp1B1/4P3/2P4Q/PP2BPPP/RN2K2R w KQ - 2 13',
'r4bnr/2q1k1pp/pp1p1p2/n1pPp3/4P3/2P1B2Q/PP2BPPP/RN2K2R b KQ - 3 13',
'r4bnr/2q1k2p/pp1p1pp1/n1pPp3/4P3/2P1B2Q/PP2BPPP/RN2K2R w KQ - 0 14',
'r4bnr/2q1k2p/pp1p1pp1/n1pPp3/4P3/2P1B2Q/PP1NBPPP/R3K2R b KQ - 1 14',
'r4bnr/1nq1k2p/pp1p1pp1/2pPp3/4P3/2P1B2Q/PP1NBPPP/R3K2R w KQ - 2 15',
'r4bnr/1nq1k2p/pp1p1pp1/2pPp3/4PP2/2P1B2Q/PP1NB1PP/R3K2R b KQ - 0 15',
'r4bnr/1nq2k1p/pp1p1pp1/2pPp3/4PP2/2P1B2Q/PP1NB1PP/R3K2R w KQ - 1 16',
'r4bnr/1nq2k1p/pp1p1pp1/2pPpP2/4P3/2P1B2Q/PP1NB1PP/R3K2R b KQ - 0 16',
'r4bnr/1nq3kp/pp1p1pp1/2pPpP2/4P3/2P1B2Q/PP1NB1PP/R3K2R w KQ - 1 17',
'r4bnr/1nq3kp/pp1p1pp1/2pPpP2/4P3/2P1B1Q1/PP1NB1PP/R3K2R b KQ - 2 17',
'r5nr/1nq1b1kp/pp1p1pp1/2pPpP2/4P3/2P1B1Q1/PP1NB1PP/R3K2R w KQ - 3 18',
'r5nr/1nq1b1kp/pp1p1pp1/2pPpP2/4P2P/2P1B1Q1/PP1NB1P1/R3K2R b KQ - 0 18',
'r2q2nr/1n2b1kp/pp1p1pp1/2pPpP2/4P2P/2P1B1Q1/PP1NB1P1/R3K2R w KQ - 1 19',
'r2q2nr/1n2b1kp/pp1p1pp1/2pPpP2/4P2P/2P1B1Q1/PP1NB1P1/R4RK1 b - - 2 19',
'r5nr/1n1qb1kp/pp1p1pp1/2pPpP2/4P2P/2P1B1Q1/PP1NB1P1/R4RK1 w - - 3 20',
'r5nr/1n1qb1kp/pp1p1pp1/2pPpP2/P3P2P/2P1B1Q1/1P1NB1P1/R4RK1 b - - 0 20',
'r3q1nr/1n2b1kp/pp1p1pp1/2pPpP2/P3P2P/2P1B1Q1/1P1NB1P1/R4RK1 w - - 1 21',
'r3q1nr/1n2b1kp/pp1p1pp1/2pPpP2/P1N1P2P/2P1B1Q1/1P2B1P1/R4RK1 b - - 2 21',
'r2bq1nr/1n4kp/pp1p1pp1/2pPpP2/P1N1P2P/2P1B1Q1/1P2B1P1/R4RK1 w - - 3 22',
'r2bq1nr/1n4kp/pp1p1pp1/2pPpP2/PPN1P2P/2P1B1Q1/4B1P1/R4RK1 b - - 0 22',
'r3q1nr/1nb3kp/pp1p1pp1/2pPpP2/PPN1P2P/2P1B1Q1/4B1P1/R4RK1 w - - 1 23',
'r3q1nr/1nb3kp/pp1p1pp1/2pPpP2/PPN1P2P/2P1B2Q/4B1P1/R4RK1 b - - 2 23',
'r2nq1nr/2b3kp/pp1p1pp1/2pPpP2/PPN1P2P/2P1B2Q/4B1P1/R4RK1 w - - 3 24',
'r2nq1nr/2b3kp/pp1p1pp1/2PPpP2/P1N1P2P/2P1B2Q/4B1P1/R4RK1 b - - 0 24',
'r2nq1nr/2b3kp/p2p1pp1/2pPpP2/P1N1P2P/2P1B2Q/4B1P1/R4RK1 w - - 0 25',
'r2nq1nr/2b3kp/p2p1pp1/2pPpP2/P1N1P2P/2P1B2Q/4BRP1/R5K1 b - - 1 25',
'3nq1nr/r1b3kp/p2p1pp1/2pPpP2/P1N1P2P/2P1B2Q/4BRP1/R5K1 w - - 2 26',
'3nq1nr/r1b3kp/p2p1pp1/2pPpP2/P1N1P2P/2P1B2Q/4BRP1/5RK1 b - - 3 26',
'3nq1nr/1rb3kp/p2p1pp1/2pPpP2/P1N1P2P/2P1B2Q/4BRP1/5RK1 w - - 4 27',
'3nq1nr/1rb3kp/p2p1pp1/2pPpP2/P1N1P1PP/2P1B2Q/4BR2/5RK1 b - - 0 27',
'3nq1nr/1rb3k1/p2p1ppp/2pPpP2/P1N1P1PP/2P1B2Q/4BR2/5RK1 w - - 0 28',
'3nq1nr/1rb3k1/p2p1pPp/2pPp3/P1N1P1PP/2P1B2Q/4BR2/5RK1 b - - 0 28',
'3n2nr/1rb3k1/p2p1pqp/2pPp3/P1N1P1PP/2P1B2Q/4BR2/5RK1 w - - 0 29',
'3n2nr/1rb3k1/p2p1pqp/2pPp3/P1N1P1PP/2P1B3/4BRQ1/5RK1 b - - 1 29',
'6nr/1rb2nk1/p2p1pqp/2pPp3/P1N1P1PP/2P1B3/4BRQ1/5RK1 w - - 2 30',
'6nr/1rb2nk1/p2p1pqp/2pPp3/P1N1P1PP/2P5/3BBRQ1/5RK1 b - - 3 30',
'5knr/1rb2n2/p2p1pqp/2pPp3/P1N1P1PP/2P5/3BBRQ1/5RK1 w - - 4 31',
'5knr/1rb2n2/p2p1pqp/2pPp3/P3P1PP/2P1N3/3BBRQ1/5RK1 b - - 5 31',
'5knr/1rb2n2/3p1pqp/p1pPp3/P3P1PP/2P1N3/3BBRQ1/5RK1 w - - 0 32',
'5knr/1rb2n2/B2p1pqp/p1pPp3/P3P1PP/2P1N3/3B1RQ1/5RK1 b - - 1 32',
'5knr/2b2n2/B2p1pqp/p1pPp3/P3P1PP/1rP1N3/3B1RQ1/5RK1 w - - 2 33',
'5knr/2b2n2/B2p1pqp/p1pPp3/P1N1P1PP/1rP5/3B1RQ1/5RK1 b - - 3 33',
'1r3knr/2b2n2/B2p1pqp/p1pPp3/P1N1P1PP/2P5/3B1RQ1/5RK1 w - - 4 34',
'1r3knr/2b2n2/3p1pqp/pBpPp3/P1N1P1PP/2P5/3B1RQ1/5RK1 b - - 5 34',
'1r3knr/2b2n1q/3p1p1p/pBpPp3/P1N1P1PP/2P5/3B1RQ1/5RK1 w - - 6 35',
'1r3knr/2bB1n1q/3p1p1p/p1pPp3/P1N1P1PP/2P5/3B1RQ1/5RK1 b - - 7 35',
'5knr/2bB1n1q/3p1p1p/p1pPp3/P1N1P1PP/1rP5/3B1RQ1/5RK1 w - - 8 36',
'5knr/2b2n1q/3p1p1p/p1pPpB2/P1N1P1PP/1rP5/3B1RQ1/5RK1 b - - 9 36',
'5knr/2b2nq1/3p1p1p/p1pPpB2/P1N1P1PP/1rP5/3B1RQ1/5RK1 w - - 10 37',
'5knr/2b2nq1/3pBp1p/p1pPp3/P1N1P1PP/1rP5/3B1RQ1/5RK1 b - - 11 37',
'4k1nr/2b2nq1/3pBp1p/p1pPp3/P1N1P1PP/1rP5/3B1RQ1/5RK1 w - - 12 38',
'4k1nr/2b2nq1/3pBp1p/p1pPp3/P1N1P1PP/1rP5/3B1RQK/5R2 b - - 13 38',
'4k1nr/2b2n1q/3pBp1p/p1pPp3/P1N1P1PP/1rP5/3B1RQK/5R2 w - - 14 39',
'4k1nr/2b2n1q/3pBp1p/p1pPp2P/P1N1P1P1/1rP5/3B1RQK/5R2 b - - 0 39',
'4k1nr/1rb2n1q/3pBp1p/p1pPp2P/P1N1P1P1/2P5/3B1RQK/5R2 w - - 1 40',
'4k1nr/1rb2n1q/3pBR1p/p1pPp2P/P1N1P1P1/2P5/3B2QK/5R2 b - - 0 40',
'4k2r/1rb2n1q/3pBn1p/p1pPp2P/P1N1P1P1/2P5/3B2QK/5R2 w - - 0 41',
'4k2r/1rb2n1q/3pBR1p/p1pPp2P/P1N1P1P1/2P5/3B2QK/8 b - - 0 41',
'4k2r/1rb4q/3pBR1p/p1pPp1nP/P1N1P1P1/2P5/3B2QK/8 w - - 1 42',
'4k2r/1rb4q/3pBR1p/p1pPp1BP/P1N1P1P1/2P5/6QK/8 b - - 0 42',
'4k2r/1rb4q/3pBR2/p1pPp1pP/P1N1P1P1/2P5/6QK/8 w - - 0 43',
'4k2r/1rb2R1q/3pB3/p1pPp1pP/P1N1P1P1/2P5/6QK/8 b - - 1 43',
'4k2r/1rb2q2/3pB3/p1pPp1pP/P1N1P1P1/2P5/6QK/8 w - - 0 44',
'4k2r/1rb2B2/3p4/p1pPp1pP/P1N1P1P1/2P5/6QK/8 b - - 0 44',
'7r/1rb2k2/3p4/p1pPp1pP/P1N1P1P1/2P5/6QK/8 w - - 0 45',
'7r/1rb2k2/3p4/p1pPp1pP/P1N1P1P1/2P2Q2/7K/8 b - - 1 45',
'7r/1rb1k3/3p4/p1pPp1pP/P1N1P1P1/2P2Q2/7K/8 w - - 2 46',
'7r/1rb1k3/3p4/p1pPpQpP/P1N1P1P1/2P5/7K/8 b - - 3 46',
'5r2/1rb1k3/3p4/p1pPpQpP/P1N1P1P1/2P5/7K/8 w - - 4 47',
'5r2/1rb1k3/3pQ3/p1pPp1pP/P1N1P1P1/2P5/7K/8 b - - 5 47',
'3k1r2/1rb5/3pQ3/p1pPp1pP/P1N1P1P1/2P5/7K/8 w - - 6 48',
'3k1r2/1rb5/3NQ3/p1pPp1pP/P3P1P1/2P5/7K/8 b - - 0 48',
'3k1r2/1r6/3bQ3/p1pPp1pP/P3P1P1/2P5/7K/8 w - - 0 49',
'3k1r2/1r6/3Q4/p1pPp1pP/P3P1P1/2P5/7K/8 b - - 0 49',
'4kr2/1r6/3Q4/p1pPp1pP/P3P1P1/2P5/7K/8 w - - 1 50',
'4kr2/1r6/8/p1pPQ1pP/P3P1P1/2P5/7K/8 b - - 0 50',
'5r2/1r3k2/8/p1pPQ1pP/P3P1P1/2P5/7K/8 w - - 1 51',
'5r2/1r3k2/3P4/p1p1Q1pP/P3P1P1/2P5/7K/8 b - - 0 51',
'5rk1/1r6/3P4/p1p1Q1pP/P3P1P1/2P5/7K/8 w - - 1 52',
'5rk1/1r6/3P4/p1p3QP/P3P1P1/2P5/7K/8 b - - 0 52',
'5rk1/6r1/3P4/p1p3QP/P3P1P1/2P5/7K/8 w - - 1 53',
'5rk1/6r1/3P4/p1pQ3P/P3P1P1/2P5/7K/8 b - - 2 53',
'5r1k/6r1/3P4/p1pQ3P/P3P1P1/2P5/7K/8 w - - 3 54',
'5r1k/6r1/3P4/p1pQ3P/P3P1P1/2P3K1/8/8 b - - 4 54',
'5r2/6rk/3P4/p1pQ3P/P3P1P1/2P3K1/8/8 w - - 5 55',
'5r2/6rk/3P4/p1pQP2P/P5P1/2P3K1/8/8 b - - 0 55',
'5r2/7k/3P4/p1pQP1rP/P5P1/2P3K1/8/8 w - - 1 56',
'5r2/3P3k/8/p1pQP1rP/P5P1/2P3K1/8/8 b - - 0 56',
'6r1/3P3k/8/p1pQP1rP/P5P1/2P3K1/8/8 w - - 1 57',
'3Q2r1/7k/8/p1pQP1rP/P5P1/2P3K1/8/8 b - - 0 57',
'3Q2r1/7k/8/p1pQP2P/P5r1/2P3K1/8/8 w - - 0 58',
'3Q2r1/7k/8/p1pQP2P/P5r1/2P5/5K2/8 b - - 1 58',
'3Q2r1/7k/8/p1pQP2P/P4r2/2P5/5K2/8 w - - 2 59',
'3Q2r1/7k/8/p1pQP2P/P4r2/2P1K3/8/8 b - - 3 59',
'3r4/7k/8/p1pQP2P/P4r2/2P1K3/8/8 w - - 0 60',
'3Q4/7k/8/p1p1P2P/P4r2/2P1K3/8/8 b - - 0 60',
'3Q4/7k/8/p1p1P2P/P5r1/2P1K3/8/8 w - - 1 61',
'3Q4/7k/4P3/p1p4P/P5r1/2P1K3/8/8 b - - 0 61',
'3Q4/7k/4P3/p1p4P/P7/2P1K3/8/6r1 w - - 1 62',
'3Q4/7k/4P3/p1p4P/P7/2P5/5K2/6r1 b - - 2 62',
'3Q4/7k/4P3/p1p4P/P7/2P5/5K2/7r w - - 3 63',
'3Q4/4P2k/8/p1p4P/P7/2P5/5K2/7r b - - 0 63',
'3Q4/4P2k/8/p1p4r/P7/2P5/5K2/8 w - - 0 64',
'3QQ3/7k/8/p1p4r/P7/2P5/5K2/8 b - - 0 64',
'3QQ3/7k/8/p1p2r2/P7/2P5/5K2/8 w - - 1 65',
'3QQ3/7k/8/p1p2r2/P7/2P5/4K3/8 b - - 2 65',
'3QQ3/7k/8/p1p5/P7/2P5/4Kr2/8 w - - 3 66',
'3QQ3/7k/8/p1p5/P7/2P5/5K2/8 b - - 0 66',
'3QQ3/7k/8/p7/P1p5/2P5/5K2/8 w - - 0 67',
'3Q3Q/7k/8/p7/P1p5/2P5/5K2/8 b - - 1 67',
'3Q3Q/8/6k1/p7/P1p5/2P5/5K2/8 w - - 2 68',
'7Q/8/5Qk1/p7/P1p5/2P5/5K2/8 b - - 3 68')

for (i in 1:length(moves)) {
	if (fen_move(positions[i], moves[i]) != positions[i+1]) {
		message('failed at ', positions[i], ' || ', moves[i], ': ', fen_move(positions[i], moves[i]))
	}
}


# # This will not be implemented yet.
# message('checking a short atomic game')
# # Atomic game
# moves <- c('f4','Nf6','Nf3','e5','fxe5','d5','g3','Bh3','Bxh3',
# 'Qh4','gxh4','Bb4','c3','Bc5','d4','Be7','Ne5','Bh4+','Nxf7#')
# positions <- c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
# 'rnbqkbnr/pppppppp/8/8/5P2/8/PPPPP1PP/RNBQKBNR b KQkq - 0 1',
# 'rnbqkb1r/pppppppp/5n2/8/5P2/8/PPPPP1PP/RNBQKBNR w KQkq - 1 2',
# 'rnbqkb1r/pppppppp/5n2/8/5P2/5N2/PPPPP1PP/RNBQKB1R b KQkq - 2 2',
# 'rnbqkb1r/pppp1ppp/5n2/4p3/5P2/5N2/PPPPP1PP/RNBQKB1R w KQkq - 0 3',
# 'rnbqkb1r/pppppppp/5n2/8/5P2/5N2/PPPPP1PP/RNBQKB1R b KQkq - 2 2',
# 'rnbqkb1r/pppp1ppp/5n2/4p3/5P2/5N2/PPPPP1PP/RNBQKB1R w KQkq - 0 3',
# 'rnbqkb1r/pppp1ppp/8/8/8/5N2/PPPPP1PP/RNBQKB1R b KQkq - 0 3',
# 'rnbqkb1r/ppp2ppp/8/3p4/8/5N2/PPPPP1PP/RNBQKB1R w KQkq - 0 4',
# 'rnbqkb1r/ppp2ppp/8/3p4/8/5NP1/PPPPP2P/RNBQKB1R b KQkq - 0 4',
# 'rn1qkb1r/ppp2ppp/8/3p4/8/5NPb/PPPPP2P/RNBQKB1R w KQkq - 1 5',
# 'rn1qkb1r/ppp2ppp/8/3p4/8/5NP1/PPPPP2P/RNBQK2R b KQkq - 0 5',
# 'rn2kb1r/ppp2ppp/8/3p4/7q/5NP1/PPPPP2P/RNBQK2R w KQkq - 1 6',
# 'rn2kb1r/ppp2ppp/8/3p4/8/5N2/PPPPP2P/RNBQK2R b KQkq - 0 6',
# 'rn2k2r/ppp2ppp/8/3p4/1b6/5N2/PPPPP2P/RNBQK2R w KQkq - 1 7',
# 'rn2k2r/ppp2ppp/8/3p4/1b6/2P2N2/PP1PP2P/RNBQK2R b KQkq - 0 7',
# 'rn2k2r/ppp2ppp/8/2bp4/8/2P2N2/PP1PP2P/RNBQK2R w KQkq - 1 8',
# 'rn2k2r/ppp2ppp/8/2bp4/3P4/2P2N2/PP2P2P/RNBQK2R b KQkq - 0 8',
# 'rn2k2r/ppp1bppp/8/3p4/3P4/2P2N2/PP2P2P/RNBQK2R w KQkq - 1 9',
# 'rn2k2r/ppp1bppp/8/3pN3/3P4/2P5/PP2P2P/RNBQK2R b KQkq - 2 9',
# 'rn2k2r/ppp2ppp/8/3pN3/3P3b/2P5/PP2P2P/RNBQK2R w KQkq - 3 10',
# 'rn5r/ppp3pp/8/3p4/3P3b/2P5/PP2P2P/RNBQK2R b KQ - 0 10') # final move should NOT raise warning.
# 
# for (i in 1:length(moves)) {
# 	if (fen_move(positions[i], moves[i], 'atomic') != positions[i+1]) {
# 		stop('failed at ', positions[i], ' || ', moves[i], ' : ', fen_move(positions[i], moves[i], 'atomic'))
# 	}
# }



message('checking some more, difficult, cases. The first 3 tests are allowed to error/fail.')
# Likely to result in error.
tests <- list(c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', 'Ng3', 
'rnbqkbnr/pppppppp/8/8/8/6N1/PPPPPPPP/RNBQKB1R b KQkq - 1 1'), # Wrong direction
c('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', 'Nf6', 
'rnbqkbnr/pppppppp/5N2/8/8/8/PPPPPPPP/RNBQKB1R b KQkq - 1 1'), # bad direction
c('rnbqkb1r/pppp1ppp/5n2/4p3/4P3/8/PPPPKPPP/RNBQ1BNR w kq - 2 3', 'Bc1', 
'rnbqkb1r/pppp1ppp/5n2/4p3/4P3/8/PPPPKPPP/RNBQ1BNR b kq - 3 3'), # passing move
c('r1b1k2r/p1pq1ppp/2n5/1B2p3/Q3n3/2P5/PP3PPP/R1B1K1NR[PBpppn] w KQkq - 0 10', 'N@d2',
'r1b1k2r/p1pq1ppp/2n5/1B2p3/Q3n3/2P5/PP1N1PPP/R1B1K1NR[PBpppn] b KQkq - 1 10'))  # illegal placement

for (test in tests) {
	tryCatch({
		if (fen_move(test[1], test[2]) != test[3]) {
			warning('failed at ', test[1], ' || ', test[2], ' : ', fen_move(test[1], test[2]))
		}
	}, error = function(e) {
		message(paste("error at ", test[1], test[2], " : ", e$message))
	})
}
