"""
This file is to answer the question: who is more likely to win, Alice or Bob?
Flip a coin 100 times. Every time HH appears in the sequence, Alice get's a point.
Every time HT appears in the sequence, Bob get's a point.
"""

import numpy as np

def sim_n_flips(n):
    flips = np.random.choice(["H", "T"], n)
    return flips

def score(flips, make_equal=False):
    alice_pts = 0
    bob_pts = 0
    for i in range(len(flips) - 1):
        if flips[i] == "H" and flips[i + 1] == "H":
            alice_pts += 1
        elif flips[i] == "H" and flips[i + 1] == "T":
            bob_pts += 1
    if make_equal and flips[-1] == "H" and flips[0] == "H":
        alice_pts += 1
    return alice_pts, bob_pts

def main(trials = 100000):
    alice_wins = 0
    bob_wins = 0
    ties = 0
    for _ in range(trials):
        flips = sim_n_flips(100)
        alice_pts, bob_pts = score(flips)
        if alice_pts > bob_pts:
            alice_wins += 1
        elif bob_pts > alice_pts:
            bob_wins += 1
        else:
            ties += 1
    print(f"{alice_wins = }, {bob_wins = }, {ties = }")


if __name__ == "__main__":
    main()