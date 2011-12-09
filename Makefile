NAME      = luamplib
FORMAT    = luatex

DTX       = $(NAME).dtx
DOC       = $(NAME).pdf
STY       = $(NAME).sty
LUA       = $(NAME).lua
TEST      = test-$(NAME)-plain.tex test-$(NAME)-latex.tex

UNPACKED  = $(STY) $(LUA)
GENERATED = $(UNPACKED) $(DOC)
SOURCES   = $(DTX) README NEWS Makefile $(TEST)

DOCFILES  = $(DOC) $(TEST) README NEWS
SRCFILES  = $(DTX) Makefile
RUNFILES  = $(STY) $(LUA)

ALL       = $(SRCFILES) $(DOCFILES) $(RUNFILES)

TEXMFROOT = ./texmf
RUNDIR    = $(TEXMFROOT)/tex/$(FORMAT)/$(NAME)
DOCDIR    = $(TEXMFROOT)/doc/$(FORMAT)/$(NAME)
SRCDIR    = $(TEXMFROOT)/source/$(FORMAT)/$(NAME)

CTAN_ZIP  = $(NAME).zip
TDS_ZIP   = $(NAME).tds.zip
ZIPS      = $(CTAN_ZIP) $(TDS_ZIP)

all: $(GENERATED)
doc: $(DOC)
unpack: $(UNPACKED)
ctan: check $(CTAN_ZIP)
tds: $(TDS_ZIP)
world: all ctan

.PHONY: all doc unpack ctan tds check world

%.pdf: %.dtx
	latexmk -pdf -silent $< >/dev/null

$(UNPACKED): $(DTX)
	tex -interaction=batchmode $< >/dev/null

check: $(UNPACKED)
	luatex   -interaction=batchmode test-$(NAME)-plain.tex  >/dev/null
	lualatex -interaction=batchmode test-$(NAME)-latex.tex  >/dev/null

$(CTAN_ZIP): $(SOURCES) $(DOC) $(TDS_ZIP)
	@echo "Making $@ for CTAN upload."
	@$(RM) -- $@
	@zip -9 $@ $^ >/dev/null

define run-install
@mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
@mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
@mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)
endef

$(TDS_ZIP): TEXMFROOT=./tmp-texmf
$(TDS_ZIP): $(ALL)
	@echo "Making TDS-ready archive $@."
	@$(RM) -- $@
	@if test -e $(TEXMFROOT); then echo 'bad TEXMFROOT'; false; fi
	$(run-install)
	@cd $(TEXMFROOT) && zip -q -9 ../$@ -r .
	@$(RM) -r -- $(TEXMFROOT)

.PHONY: install clean mrproper help

install: check $(ALL)
	@echo "Installing in '$(TEXMFROOT)'."
	$(run-install)

clean:
	@latexmk -silent -c $(DTX) *.tex >/dev/null
	@rm -f -- *.log test*.pdf

mrproper: clean
	@rm -f -- $(GENERATED) $(ZIPS)

help:
	@echo '$(NAME) makefile targets:'
	@echo '                      help - (this message)'
	@echo '                       all - (default target) all generated files'
	@echo '                     world - synonymous for ctan'
	@echo '                    unpack - extract all files'
	@echo '                       doc - compile documentation'
	@echo '                      ctan - run check & generate archive for CTAN'
	@echo '                       tds - generate a TDS compliant archive'
	@echo '                     check - run the test files'
	@echo '  install TEXMFROOT=<path> - install in <path>'
