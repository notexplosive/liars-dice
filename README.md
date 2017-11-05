# Liar's Dice #

## How to play ##
Your objective is to bet on how many of (_n_) of dice (_d_) you think are
currently on the board. The only information you are given is the dice you have
in your hand and the number of total dice.

**Important caveat!** Ones are wildcards. This means they represent all possible
face values simultaneously.

At the start of the game, each player rolls 5 dice and does not reveal the
resulting rolls to the others. For the first round, the player who goes first is
assigned randomly.

On your turn you have two options, doing one of them will pass the turn to the
next person:

  * **Raise:** (Sometimes referred to as "betting") You can assert a new face/
value pair. So long as _n_ is higher than the previous bet OR _n_ is equal to
the original bet but _d_ is greater than the original.
  * **Call:** You assert that the current bet is too high. This will end the
round and reveal everyone's dice.

When someone calls, the round ends and all dice are revealed. The final raise is
compared to the total number of dice _d_ on the board (plus all the ones!).

If the count (_n_) is equal to or greater than what was asserted in the raise,
the raiser wins. Otherwise, the caller wins. Winner goes first next round, and
loser loses a di. When a di is lost, it is eliminated from play, giving that
player that much less information to work with in subsequent rounds.

When a player runs out of dice, they are out of the game, the last player
remaining wins.

## Plans for this project ##
First, I want to make a clean UI and working bot support. This way I can have
a simple prototype that works and feels good to play. Once that's done I want
to set up a network protocol so people can play over the internet.
