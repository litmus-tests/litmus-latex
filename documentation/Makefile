BUILDDIR ?= build

LITMUSLATEXDIR ?= ../

PDFLATEX  ?= pdflatex

LATEXFLAGS += -output-directory $(BUILDDIR)
LATEXFLAGS += -file-line-error
# No terminal output:
# LATEXFLAGS += -interaction=batchmode
RUNLATEX = $(PDFLATEX) $(LATEXFLAGS) $<
export TEXINPUTS := .:$(abspath .):$(abspath $(LITMUSLATEXDIR)):$(abspath $(BUILDDIR)):$(TEXINPUTS)
# Control latex log file line breaking:
export max_print_line ?= 1000

# Setup the litmus test figures
REMSDIR ?= $(HOME)/rems
FIGSDIR ?= figs

include $(LITMUSLATEXDIR)/litmus.mk

.DELETE_ON_ERROR:
.SECONDEXPANSION:

%.pdf: $(BUILDDIR)/%.pdf
	cp '$<' '$@'

# If no other target is specified on the command line make will build this one:
.DEFAULT_GOAL = all
.PHONY: all

#####################################################################

$(BUILDDIR)/minimal.pdf: minimal.tex $$(LITMUSPREREQ)
	mkdir -p $(dir $@)
	$(RUNLATEX) $<
	$(MAKE) $(LITMUS)
	$(call ifneeded,$(RUNLATEX) $<)
	$(MAKE) $(LITMUS)
	$(call ifneeded,$(RUNLATEX) $<)

all: minimal.pdf

######################################################################

# RMEM cannot generate diagrams for some litmus tests with causality
# loop (not even the relaxed model), hence we specify a different
# state to look for:
$(FIGSDIR)/A64/LB+addr+data.tikz: RMEMMODEL = relaxed
$(FIGSDIR)/A64/LB+addr+data.tikz: STATE = x=1; y=1; 0:X0=1; 1:X0=0;
# or use a different model:
$(FIGSDIR)/A64/WRC+addrs.tikz: RMEMMODEL = flowing -topauto true

$(BUILDDIR)/tikz_doc.pdf: tikz_doc.tex $$(LITMUSPREREQ)
	mkdir -p $(dir $@)
	$(RUNLATEX) $<
	$(MAKE) $(LITMUS)
	$(call ifneeded,$(RUNLATEX) $<)
	$(MAKE) $(LITMUS)
	$(call ifneeded,$(RUNLATEX) $<)

all: tikz_doc.pdf

#####################################################################

all_minimal: minimal.pdf
all_minimal: minimal.svg
all_minimal: minimal.ps minimal.eps
all_minimal: minimal.png minimal.jpg
.PHONY: all_minimal

LATEX ?= latex
DVIPS ?= dvips
DVISVGM ?= dvisvgm
PS2EPS ?= ps2eps
# https://www.imagemagick.org
# ubuntu: sudo apt install imagemagick
CONVERT ?= convert

DPI ?= 150

# We need minimal.pdf in the prerequisites to make sure the .tikz file
# is generated
$(BUILDDIR)/minimal-dvisvgm.dvi $(BUILDDIR)/minimal-dvips.dvi: $(BUILDDIR)/minimal-%.dvi: minimal.tex $(BUILDDIR)/minimal.pdf
	mkdir -p $(dir $@)
	$(LATEX) $(LATEXFLAGS) -jobname 'minimal-$*' '\PassOptionsToClass{$*}{standalone}\input{$<}'

%.svg: $(BUILDDIR)/%-dvisvgm.dvi
	$(DVISVGM) -b papersize -o $@ $<

%.ps: $(BUILDDIR)/%-dvips.dvi
	$(DVIPS) -o $@ $<

%.eps: %.ps
	$(PS2EPS) -f $<

%.png: $(BUILDDIR)/%.pdf
	$(CONVERT) -density $(DPI) $< -strip -quality 100 $@
# 	 +antialias

%.jpg: $(BUILDDIR)/%.pdf
	$(CONVERT) -density $(DPI) $< -background white -flatten -quality 100 $@

######################################################################

clean:
	rm -rf '$(BUILDDIR)'
	rm -f random_seed.dat
	rm -f tikz_doc.pdf
	rm -f minimal.pdf
	rm -f minimal.svg
	rm -f minimal.ps
	rm -f minimal.eps
	rm -f minimal.png
	rm -f minimal.jpg
.PHONY: clean
