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

RUNDIR    = $(TEXMFDIR)/tex/$(FORMAT)/$(NAME)
DOCDIR    = $(TEXMFDIR)/doc/$(FORMAT)/$(NAME)
SRCDIR    = $(TEXMFDIR)/source/$(FORMAT)/$(NAME)
TEXMFDIR  = $(shell kpsewhich --var-value TEXMFHOME)

CTAN_ZIP  = $(NAME).zip
ZIPS      = $(CTAN_ZIP)

DOLATEX   = texfot --quiet --tee=/dev/null --ignore "hypdoc" --ignore "^Overfull" --ignore "^Underfull" lualatex --shell-escape --recorder $(DTX)

all: $(GENERATED)
doc: all
unpack: $(UNPACKED)
ctan: check $(CTAN_ZIP)
world: all ctan

.PHONY: all doc unpack ctan check world

%.pdf: %.dtx
	@$(DOLATEX)
	@if( grep rerunfilecheck $(NAME).log |grep 'has changed' > /dev/null ); then $(DOLATEX); fi
	@if( grep 'Rerun to get' $(NAME).log > /dev/null ); then $(DOLATEX); fi

$(UNPACKED): $(DTX)
	luatex -interaction=batchmode $< >/dev/null

check: $(UNPACKED)
	@texfot --quiet --tee=/dev/null luatex -interaction=batchmode test-$(NAME)-plain.tex
	@texfot --quiet --tee=/dev/null lualatex -interaction=batchmode test-$(NAME)-latex.tex
	! grep "blank space"              test-$(NAME)-plain.log
	! grep "blank space"              test-$(NAME)-latex.log

$(CTAN_ZIP): $(SOURCES) $(DOC)
	@echo "Making $@ for CTAN upload."
	@$(RM) -- $@
	@mkdir -p $(NAME)
	@cp -f $(SOURCES) $(DOC) $(NAME)
	@zip -q -9 -r $@ $(NAME)
	@$(RM) -r $(NAME)

define run-install
@mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
@mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
@mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)
endef

.PHONY: install clean mrproper help

install: check $(ALL)
	@echo "Installing in '$(TEXMFDIR)'."
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
	@echo '                     check - run the test files'
	@echo '   install TEXMFDIR=<path> - install in <path>'
