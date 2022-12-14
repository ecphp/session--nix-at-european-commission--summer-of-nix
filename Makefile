INPUT ?= src/nix-at-ec/index.tex
OUTPUT ?= $(shell basename "$(shell dirname "$(INPUT)")")
OUTPUT_DIRECTORY = build
LATEXMK_ARGS ?= -pdflua -halt-on-error -MP -logfilewarninglist -shell-escape -interaction=nonstopmode -file-line-error -output-directory=$(OUTPUT_DIRECTORY)
TEXINPUTS = "$(shell pwd)/src//:"

TEXLIVE_RUN = TEXINPUTS=$(TEXINPUTS)
LATEXMK_COMMAND = $(TEXLIVE_RUN) latexmk $(LATEXMK_ARGS)

# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

.PHONY: build view

%:
	$(MAKE) build INPUT=src/$@/index.tex

build :
	HOME=$(OUTPUT_DIRECTORY) $(LATEXMK_COMMAND) -jobname=$(OUTPUT) $(INPUT)

pandoc :
	$(PANDOC_RUN) -s $(INPUT) -o $(OUTPUT)

latexindent :
	$(TEXLIVE_RUN) latexindent

clean :
	rm -rf build

lint :
	# $(foreach file, $(call rwildcard,$(shell dirname "$(INPUT)"),*.tex), lacheck $(file);)
	# $(foreach file, $(call rwildcard,$(shell dirname "$(INPUT)"),*.tex), chktex $(file);)
	$(foreach file, $(call rwildcard,$(shell dirname "$(INPUT)"),*.tex), latexindent -l -w $(file);)

chmodbuild:
	$(TEXLIVE_RUN) chmod 777 build

watch:
	$(LATEXMK_COMMAND) -pvc -jobname=$(OUTPUT) $(INPUT)
	$(MAKE) chmodbuild

fresh:
	$(MAKE) chmodbuild clean build

buildall:
	$(MAKE) clean
	$(foreach file, $(wildcard src/**/index.tex), $(MAKE) build INPUT=$(file);)
