ALL = game.prg
START = game.prg
DASM = dasm
REMOTE_SERVER = cpsc
REMOTE_DIR = ~/www/

all: $(ALL)


music.prg: ./src/titlescreen_music.s ./src/extras/stub.s
	$(DASM) $< -o$@ -l$(<:.s=.lst)

game.prg: ./src/main.s
	$(DASM) $< -o$@ -l$(<:.s=.lst)

clean:
	$(RM) $(ALL)

upload: all
	scp $(ALL) $(REMOTE_SERVER):$(REMOTE_DIR)
	ssh $(REMOTE_SERVER) "cd $(REMOTE_DIR); chmod 644 $(ALL)"

start:
	start "https://cspages.ucalgary.ca/~aycock/599.82/vic20/?file=https://cspages.ucalgary.ca/~colton.gowans/$(START)"
