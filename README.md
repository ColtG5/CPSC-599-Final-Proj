# CPSC-599-Final-Proj
## Final project for CPSC 599 F24 | Goob: Mechanic Mayday

#### For WIP Demo Submission:
A few notes...
- All of the code that actually is used to compile the game is in `src`, any other folders contain complimentary programs/data/etc.
- Convention for code in files other than main: `_` prepended to label means private, `f_` prepended means public subroutine.
- The `level_editor.py` was not used right now for level data. It is still being worked on to output level data for the game. The script `make_level_data.py` was used instead.
- The code is YUCKY and GROSS in some areas. These will be commented where the approach is knowingly terrible and needs to be improved on later. It was just done this way for now to hack together a demo of the game.

Features
Cursor Movement: Move the cursor around the screen using W, A, S, D keys.
Portal Placement: Place and pick up a portal using the E key.
Level Transition: Advance to the next level by pressing the spacebar. If the last level is reached, the game will restart from the first level.
Custom Characters: The cursor and portal are represented by custom character codes.
Automatic Reset: The game resets the screen and color memory upon level transition to create a clean slate for each level.
Controls
W, A, S, D: Move the cursor up, left, down, and right, respectively.
E: Toggle the placement of a portal at the cursor's current position.
Spacebar: Switch to the next level.
