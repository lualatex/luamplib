# Makefile for luainputenc.

NAME = luamplib
DOC = $(NAME).pdf
DTX = $(NAME).dtx

# Files grouped by generation mode
COMPILED = $(DOC)
UNPACKED = luamplib-createmem.lua luamplib.lua luamplib.sty
SOURCE = $(DTX) README Makefile
GENERATED = $(COMPILED) $(UNPACKED)

# Files grouped by installation location
RUNFILES = $(UNPACKED)
DOCFILES = $(DOC) README
SRCFILES = $(DTX) Makefile

# The following definitions should be equivalent
# ALL_FILES = $(RUNFILES) $(DOCFILES) $(SRCFILES)
ALL_FILES = $(GENERATED) $(SOURCE)

# Installation locations
FORMAT = luatex
RUNDIR = tex/$(FORMAT)/$(NAME)
DOCDIR = doc/$(FORMAT)/$(NAME)
SRCDIR = source/$(FORMAT)/$(NAME)
ALL_DIRS = $(RUNDIR) $(DOCDIR) $(SRCDIR)

FLAT_ZIP = $(NAME).zip
TDS_ZIP = $(NAME).tds.zip
CTAN = $(FLAT_ZIP) $(TDS_ZIP)

DO_TEX = tex --interaction=batchmode $< >/dev/null
DO_PDFLATEX = pdflatex --interaction=batchmode $< >/dev/null

all: $(GENERATED)
ctan: $(CTAN)
world: all ctan

$(COMPILED): $(DTX)
	$(DO_PDFLATEX)
	$(DO_PDFLATEX)

$(UNPACKED): $(DTX)
	$(DO_TEX)

$(FLAT_ZIP): $(ALL_FILES)
	@echo "Making $@ for normal CTAN distribution."
	@$(RM) -- $@
	@zip -9 $@ $(ALL_FILES) >/dev/null

$(TDS_ZIP): $(ALL_FILES)
	@echo "Making $@ for TDS-ready CTAN distribution."
	@$(RM) -- $@
	@mkdir -p $(ALL_DIRS)
	@cp $(RUNFILES) $(RUNDIR)
	@cp $(DOCFILES) $(DOCDIR)
	@cp $(SRCFILES) $(SRCDIR)
	@zip -9 $@ -r $(ALL_DIRS) >/dev/null
	@$(RM) -r tex doc source

clean: 
	@$(RM) -- *.log *.aux

mrproper: clean
	@$(RM) -- $(GENERATED) $(CTAN)

.PHONY: clean mrproper
