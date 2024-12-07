# CPSC-599-Final-Proj
#### Final project for CPSC 599 F24 | Goob: Mechanic Mayday

Controls: 
W, A, S, D: Move the cursor up, left, down, and right, respectively.
E: Toggle the placement of a portal at the cursor's current position.
Spacebar: Switch to the next level.

Conventions inside the code:
 - prefix of f_ means it is a subroutine
 - prefix of . means that label is private to that subroutine
 - ALL CAPS means it is a constant number
 - _z suffix means it is a zero page variable
 - _p suffix means it is a word sized pointer

Running the Game:
 1. Configure the Makefile in the base directory:
    1. Change the `DASM` variable to your dasm installation path
    2. Change the `REMOTE_SERVER` variable to your ssh login for the cpsc servers. You have ssh keys set up, so this is All That Is Required!
    3. Not really makefile related but you may have to change the permissions on your `~/www/` folder on the servers to allow it to be read or executed or both (I forget, but worth putting here)
    4. Put all prg(s) you want to compile and upload into the `ALL` variable
    5. Put the prg you want to run into the `START` variable
 2. In the base directory (in a git bash terminal on windows!), run `make -B` (-B just always enforced a make)
 3. To run on xvic emulator, drag created .prg into emulator.
 4. To run on web eumlator, run `make upload` to upload the game.prg to the cpsc servers
 5. Once uploaded, run `make start`. This should open a browser window that runs the `START` prg in the web emulator

Workflows for different parts of development:
 1. Make custom characters:
    1. Start up venv inside of `/screen_stuff` folder
    2. Run `python .\create_custom_chars.py`
    3. Import, create, and export custom characters as desired
    4. All created characters are stored into a txt file in `/screen_stuff/custom_char_charsets/`
 2. Use custom character inside of screen editor:
    1. Make custom characters using custom char creator as desired
    2. In txt file of created characters, copy/paste desired characters into `/screen_stuff/character_tables/{filename}.s`
    3. All of the characters inside of this file will be visible for use in the screen editor.
    4. Go into screen_editor script, and change `custom_char_table_file` variable to `"./character_tables/{filename}.s"`
 3. Editing a screen:
    1. Follow steps in *workflow 2.* to have characters exist inside of screen editor to use
    2. Start up venv inside of `screen_stuff` folder
    3. Run `python .\screen_editor.py`
    4. Import a screen using the `Import screen` button
    5. Make any desired changes
    6. Save the screen using the 'Export screen' button
    7. Make sure you keep in mind that screens created with an old char_table list of characters may not be importable. You may need to manually edit json to fix character names if you renamed or removed any characters
 4. Generate character table for use in game:
    1. Follow steps in *workflow 2.* to create a character table suitable for the screen editor
    2. Inside `screen_stuff/`, run `python .\convert_char_table_to_codes.py`
    3. Select the screen editor char table as the input file (e.g. `/character_tables/char_table.s`)
    4. Choose a file to save the generated char table as the output file (e.g. `/character_tables_with_codes/char_table_codes.s`)
    5. Copy/paste the output file contents to replace the contents of `/src/extras/character_table.s`
 5. Editing a screen, then putting that screen into the game:
    1. Follow steps 1-5 in *workflow 3.* to have a screen to work with
    2. With screen loaded in screen editor, press the `Export screen to draw` button
    3. Save the automagically generated assembly file to somewhere (e.g. `/extra_prgs/draw_titlescreen.s`)
    4. Follow steps in *workflow 4.*, but paste contents of output file into file beside the generated assembly file from above (e.g. `/extra_prgs/local_character_table.s`)
    5. Compile the generated assembly file to a .prg, and run that with local xvic emulator
    6. With prog running, click `File > Activate Monitor`
    7. Run this command (example for titlescreen): `bsave "titlescreen.bin" 0 1e00 1fff`
    8. Locate saved file, and slide that into the `/compression/` folder.
    9. Inside `/compression/`, run `python rle_encode.py`, and select .bin file to be encoded
    10. Compressed binary file should have been created with -rle-encoded suffix (e.g. titlescreen-rle-encoded.bin)
    11. Copy/paste this file into the appropriate spot in the `/src/` directory (e.g. `/src/titlescreen/titlescreen-rle-encoded.bin`)
    12. Ensure that `/src/main/s` is loading the correct file name
 6. Editing a level screen, and wanting to put that level into the game:
    1. Follow steps 1-5 in *workflow 3.* to have a level to work with. NOTE: levels should only contain objects inside the game borders!
    2. With level screen loaded in screen editor, press the `Export screen for level data" button
    3. Save the level data to a spot (e.g. `/screen_stuff/level_bins/`)
    4. Copy/paste the .bin file into the `/src/levels/` folder
    5. Ensure that `/src/main/s` is loading the correct level name

Known bugs/issues:
1. The terrible redraw of the lasers every movement!!!!
      The flicker seen whenever moving

      Issue: Every time the player moves, it triggers a clear of all laser and a redraw of the path, creating a terribly awful flicker effect (worse with more laser shooters!!)
      Possible Fix: This was our first approach to correctly drawing a constantly emitting laser beam, and it works perfectly. But, the time between clearing all the lasers and redrawing them
      is too great, and was planned to be changed later in development. A fix would be to only clear and redraw lasers whenever the player picks up or places an object, but this requires moving lots of
      functionality out of the redraw_laser func, which became too coupled with lots of other parts of the game, leading to it being too complicated for us to accomplish at the end of our development as more
      pressing concerns existed. This one hurts to not have fixed, but oh well! 
2. Portal Handling
      Multiple Lasers Entering a Portal:

      Issue: When two lasers simultaneously enter a portal, the portal may get erased from the map unexpectedly.
      Likely Cause: The logic for updating portal states doesn't handle concurrent laser interactions properly.
      Possible Fix: Add a state-check mechanism for portal occupancy and prioritize laser handling in sequential order.

      Portals on Crossing Lasers:

      Issue: Placing a portal on the crossing point of two lasers may cause unpredictable behavior or result in the portal disappearing.
      Likely Cause: Inadequate handling of laser collisions with active portal tiles.
      Possible Fix: Improve collision detection for portals and consider edge cases where lasers intersect before interacting with the portal.

3. Reflector Bugs:
      Multiple Lasers Hitting a Reflector:

      Issue: When a reflector is hit from multiple directions simultaneously, it may not display the correct reflection behavior or stop reflecting entirely.
      Likely Cause: Reflector state update logic doesn't account for simultaneous interactions effectively.
      Possible Fix: Add a queue system for processing laser interactions with reflectors sequentially.

      More Than Two Lasers at a Reflector:

      Issue: Reflectors may fail to reflect one or more lasers if more than two lasers are directed at it simultaneously.
      Likely Cause: Insufficient logic to handle more than two concurrent inputs at a reflector.
      Possible Fix: Extend the reflection logic to support dynamic laser counts and ensure proper direction assignments.

4. Title Screen Music
      Issue: The title screen music occasionally stalls and does not play as expected.
      Likely Cause: sound-handling subroutine conflicts during input collection since it implments a system delay.
      Possible Fix: overhauling pausing using timers instead of program pauses.