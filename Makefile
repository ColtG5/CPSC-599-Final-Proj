ALL = game.prg
START = game.prg
DASM = /c/Users/fam20/Desktop/CPSC-599-A1/Fambospecficfoldernotforgit/dasm.exe
REMOTE_SERVER = fam.ghaly@cslinux.ucalgary.ca
REMOTE_DIR = ~/www/

all: $(ALL)


music.prg: ./src/titlescreen_music.s ./src/extras/stub.s
	$(DASM) $< -o$@ -l$(<:.s=.lst)

game.prg: ./src/main.s ./src/extras/stub.s
	$(DASM) $< -o$@ -l$(<:.s=.lst)

clean:
	$(RM) $(ALL)

upload: all
	scp $(ALL) $(REMOTE_SERVER):$(REMOTE_DIR)
	ssh $(REMOTE_SERVER) "cd $(REMOTE_DIR); chmod 644 $(ALL)"

start:
	start "https://cspages.ucalgary.ca/~aycock/599.82/vic20/?file=https://cspages.ucalgary.ca/~fam.ghaly/$(START)"
