######################################################################
## Generate .tikz and .states.tex files for litmus test figures
##
## Minimal (and inefficient) Makefile example:
## |include litmus.mk
## |.SECONDEXPANSION:
## |doc.pdf: doc.tex $$(LITMUSPREREQ)
## |	pdflatex $<
## |	$(MAKE) $(LITMUS)
## |	pdflatex $<
## |	$(MAKE) $(LITMUS)
## |	pdflatex $<
##
## If the file pointed by RMEM (initially ~/rems/rmem/rmem)
## exists, make will use it to build missing figures and to update
## existing ones. If you do not want make to do that, set the variable
## RMEM to nothing.
##
## .SECONDEXPANSION enables the use of automatic variables (e.g. $@)
## in prerequisites. This might be dangerous if prerequisite file names
## have literal $ in them, and it has negligible effect on performance.
## If using .SECONDEXPANSION is a problem you can remove it and change
## $$(LITMUSPREREQ) to $(call litmusprereq,<target>), where <target>
## is the the expansion of $@ (doc.pdf in the example above). You can
## also just not use any of those prerequisites, but then changes to
## figure sources will not trigger a rebuild.
##
## When '$(MAKE) $(LITMUS)' does not do anything, e.g. because the
## diff from previous run does not involve litmus tests, it runs very
## fast (fraction of a second). In that case, the following latex and
## '$(MAKE) $(LITMUS)' runs are superfluous. To that end,
## '$(MAKE) $(LITMUS)' will touch $@.rebuild (e.g. doc.pdf.rebuild),
## making it newer than $@, if it did anything meaningful and the
## following commands should run. The function 'ifneeded' (defined
## below) takes advantage of this and runs its argument as needed.
## Hence, the recipe above can be made more efficient like this:
## |	pdflatex $<
## |	$(MAKE) $(LITMUS)
## |	$(call ifneeded,pdflatex $<)
## |	$(MAKE) $(LITMUS)
## |	$(call ifneeded,pdflatex $<)
## Now, running make after a minor change will run latex only once.
##

## The following variables can be overridden but this must be before
## including this file and can not be target specific.
## TODO: I think making those variables target specific will work as
## long as they are exported, except in LITMUSPREREQ where we call
## make from $(shell ...), I don't see an elegant way to pass the
## target specific variables to the shell/make.

# This is the directory where this makefile is
LITMUSMKDIR := $(dir $(lastword $(MAKEFILE_LIST)))

# This should be the same as the latex output directory (can be set
# using the latex argument -output-directory)
BUILDDIR ?= .
# This is where rmem should save .tikz files
FIGSDIR ?= litmus-tikz-figures
# This is where the REMS tools are
REMSDIR ?= $(HOME)/rems
# This is where 'find' should look for .litmus files
TESTSDIRS += $(REMSDIR)/litmus-tests-regression-machinery/tests

MSUM ?= msum7

HWLOGS ?= hw-logs

# These are the architectures as used in latex
# ARCHS += A64 RV PPC x86
# These are the sub-folders of TESTSDIRS where the corresponding
# .litmus files are
A64_SUBDIR ?= AArch64
 RV_SUBDIR ?= RISCV
PPC_SUBDIR ?= PPC
x86_SUBDIR ?= x86
# These are the rmem models
A64_RMEMMODEL ?= flat
 RV_RMEMMODEL ?= flat
PPC_RMEMMODEL ?= pldi11
x86_RMEMMODEL ?= tso

# To build the external figures we run '$(PDFLATEX) $(LATEXFLAGS) ...'
PDFLATEX   ?= pdflatex
LATEXFLAGS ?= -output-directory $(BUILDDIR)

# This is how we run rmem to generate the .tikz and .states.tex files:
RMEM       ?= $(wildcard $(REMSDIR)/rmem/rmem)
_RMEMFLAGS := -interactive false
_RMEMFLAGS += -eager true -hash_prune true
# _RMEMFLAGS += -shallow_embedding true
_RMEMFLAGS += -pp_hex false
_RMEMFLAGS += -dot_final_ok true -graph_backend tikz
RMEMFLAGS  := $(_RMEMFLAGS) $(RMEMFLAGS)
# Additional flags for mixed-size tests
RMEMFLAGSMIXEDSIZE := -pp_hex true $(RMEMFLAGSMIXEDSIZE)

# Customise rmem for specific tests:
-include litmustests.mk

# This allows latex to find the .tikz files
export TEXINPUTS := .:$(abspath $(FIGSDIR)):$(TEXINPUTS)

# This is where make looks for .litmus prerequisites
vpath %.litmus $(TESTSDIRS)

######################################################################

_FORCEBUILD:
.PHONY: _FORCEBUILD

LITMUS = $(call litmus,$@)
litmus = _JOBNAME='$(notdir $(basename $1))' _JOBTARGET='$1' $1.rebuild

# $(call ifneeded,<cmd>) in a recipe will run <cmd> iff $@.rebuild
# exists and is newer than $@
# NOTE: 'env' forces GNU test instead of the shell built-in test. This
# is needed because some shells (e.g. bash) do not support sub-second
# resolution. Even with sub-second resolution the '-nt' is not 100%
# reliable.
# time { n=1000; e=0; while [ "$n" -gt "0" ]; do touch aa; sleep 0.1s; touch bb; env [ bb -nt aa ] || e="$((e+1))"; n="$((n-1))"; done; echo $e; rm -f aa bb; }
ifneeded = env [ ! $@.rebuild -nt $@ ] || ( $1 )

# TODO: FIXME
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/litmus.sty)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/litmus.names.cfg)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/litmuscusts.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/pgflibrarymykeys.code.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.code.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.listings.code.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlocal.cfg)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlang0.sty)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.aarch64.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlangaarch64.sty)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.power.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlangpower.sty)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.riscv.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlangriscv.sty)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/tikzlibrarylitmus.x86.tex)
# LITMUSPACKAGESRCS += $(wildcard $(LITMUSMKDIR)/lstlangx86.sty)

# Use $$(LITMUSPREREQ) when .SECONDEXPANSION is enabled,
# use $(call litmusprereq,<target>) otherwise.
# This will make the .tikz, .states.tex, .litmus and external .pdf
# files trigger a rebuild of the target without rebuilding those
# files, as it is better to do that after running latex.
# This also adds all the package sources as prerequisites, if they are
# present.
LITMUSPREREQ = $(call litmusprereq,$@)
litmusprereq = \
  $(if $1,,$(error Error: missing target name (did you forget '.SECONDEXPANSION:'?)))\
  $(if $(or \
        $(and $(findstring q,$(MAKEFLAGS)),$(_JOBNAME)),\
        $(shell ! $(MAKE) -q $(MAKEOVERRIDES) $(call litmus,$1) >/dev/null 2>/dev/null || echo 1)),\
    $1.rebuild,\
    _FORCEBUILD)\
  $(LITMUSPACKAGESRCS)

######################################################################
######################################################################
ifneq "$(_JOBNAME)" ""
## Everything below this line depends on _JOBNAME being set

# This is the target '$(MAKE) $(LITMUS)' builds:
$(_JOBTARGET).rebuild: $(FIGSDIR)/$(_JOBNAME).tikz_figures.sentinel
$(_JOBTARGET).rebuild: $(BUILDDIR)/$(_JOBNAME)-externals/sentinel
$(_JOBTARGET).rebuild: $(FIGSDIR)/$(_JOBNAME).hw-tables.sentinel
# tikzlibrarylitmus.code.tex prints the warning "run latex again." if
# latex needs to be run again because of 'computed assem width'
$(_JOBTARGET).rebuild: $(shell ! grep -q '^run latex again.' $(BUILDDIR)/$(_JOBNAME).log 2>/dev/null || echo _FORCEBUILD)
	touch $@

# Escapes wildcards in litmus names
escwildcards = $(subst [,\[,$(subst ],\],$(subst *,\*,$(subst ?,\?,$1))))

TIKZSCMD = sed 's/[^:]*://' '$(BUILDDIR)/$(_JOBNAME).litmusfigs' | sort -u

# If there is no rmem we don't want dependencies that will trigger rmem
ifneq "$(RMEM)" ""
ifneq "$(wildcard $(BUILDDIR)/$(_JOBNAME).litmusfigs)" ""
ifeq "$(findstring q,$(MAKEFLAGS))" ""
# If the above conditions hold we can include, and re-generate as needed,
# the .litmus.d file.
include $(_JOBNAME).litmus.d

# NOTE: In order for this canned recipe to work inside a foreach it must
# start (or end) with an empty line!!!
define findlitmus =
  $(eval _arch := $(patsubst %/,%,$(dir $1)))
  $(if $($(_arch)_SUBDIR),$(eval _arch := $($(_arch)_SUBDIR)))
  $(if $(wildcard $(TESTSDIRS:=/$(_arch))),,$(error Error: None of the directories in TESTSDIRS ($(TESTSDIRS)) have a subdir '$(_arch)'))
  LITFILE="$$(find -L $(wildcard $(TESTSDIRS:=/$(_arch)))\
    -name '$(call escwildcards,$(notdir $1)).litmus'\
    -printf '$(_arch)/%P'\
    -quit)" &&\
  if [ -n "$$LITFILE" ]; then\
    echo '$$(FIGSDIR)/$1.tikz $$(FIGSDIR)/$1.states.tex:' "$$LITFILE" &&\
    echo 'FIGS += $1' &&\
    echo;\
  else\
    echo 'Warning: cannot find ($(_arch)) $(notdir $1).litmus' >&2;\
  fi >> $2
endef

# Expects the following line format in $(_JOBNAME).litmusfigs:
#   <context>:<arch>/<test name>
# Adds the following lines to $(_JOBNAME).litmus.d, where <.litmus file>
# is the first <name>.litmus file that 'find' finds in TESTSDIRS/<arch'>:
#   $(FIGSDIR)/<arch>/<name>.tikz $(FIGSDIR)/<arch>/<name>.states.tex $(FIGSDIR)/<arch>/<name>.hw.tex: <.litmus file>
#   FIGS += <arch>/<name>
$(_JOBNAME).litmus.d: $(BUILDDIR)/$(_JOBNAME).litmusfigs
ifneq "$(shell $(TIKZSCMD) 2>/dev/null | md5sum)" "$(LITMUSFIGSMD5)"
	{ printf "# Generated file (see litmus.mk) -- do not edit\n\n";\
	  printf "# md5sum of \"$(TIKZSCMD)\"\n";\
	  printf "LITMUSFIGSMD5 = %s\n\n" "$$($(TIKZSCMD) | md5sum)";\
	} > $@
	@echo 'Looking for litmus files...'
	@$(foreach test,$(shell $(TIKZSCMD)),$(call findlitmus,$(test),$@))
	@echo 'Litmus files were added to $@'
else
	touch $@
endif
endif
endif
# If the above didn't include the .litmus.d, then just try to include
# it if it already exists.
ifeq "$(findstring $(_JOBNAME).litmus.d,$(MAKEFILE_LIST))" ""
-include $(_JOBNAME).litmus.d
endif
endif


ARCHS := $(sort $(foreach f,$(FIGS),$(firstword $(subst /, ,$f))))

# Prerequisites are in $(_JOBNAME).litmus.d
$(FIGSDIR)/%.tikz $(FIGSDIR)/%.states.tex: RMEMMODEL ?= $($(firstword $(subst /, ,$*))_RMEMMODEL)
$(FIGSDIR)/%.tikz $(FIGSDIR)/%.states.tex:
	mkdir -p $(dir $@)
	$(RMEM) $(RMEMFLAGS) $(if $(findstring /mixed-size/,$<),$(RMEMFLAGSMIXEDSIZE)) $(if $(STATE),-final_cond 'observed $(STATE)') -model $(RMEMMODEL) -dot_dir $(dir $@) $<
	if [ ! -f '$@' ]; then\
	  $(RMEM) $(RMEMFLAGS) $(if $(findstring /mixed-size/,$<),$(RMEMFLAGSMIXEDSIZE)) -model relaxed -dot_dir $(dir $@) $<;\
	fi
	@if [ ! -f '$@' ]; then\
	  echo "Error: rmem did not generate $@, check that the expected state is observable and that the name of the test in the header of $< matches the file name." &&\
	  exit 1;\
	fi

# Build all the .tikz/.states.tex files (FIGS is defined in $(_JOBNAME).litmus.d)
$(FIGSDIR)/$(_JOBNAME).tikz_figures.sentinel: $(addprefix $(FIGSDIR)/,$(FIGS:=.tikz) $(FIGS:=.states.tex))
	mkdir -p $(dir $@)
	touch $@

##########

define hw-table =
# List of machines for the experimental result tables. Each machine is
# expected to be a sub folder of $(HWLOGS)/$($(1)_SUBDIR).
# Machines with multiple kinds of cores should be listed as mach/kind1
# mach/kind2 and so on. The order of machines here determines the order
# in which they appear in the table
$(1)_MACHS ?= $(shell cd $(HWLOGS)/$($(1)_SUBDIR) && ls -d1 */  | sed 's:/$$::')

$$(FIGSDIR)/$(1)/%.hw.tex: $$(addprefix $$(FIGSDIR)/$(1)/$$(_JOBNAME).,$$($(1)_MACHS:=.hw-res))
	mkdir -p $$(dir $$@)
	for mach in $$^; do\
	  grep -HF '($$*)' "$$$$mach" || echo "$$$${mach}:($$*) 0 0";\
	done |\
	  awk '\
	    BEGIN {\
	      o = 0;\
	      r = 0;\
	      print "%% This is an autogenerated file";\
	      print "%%";\
	      print "\\newcommand{\\litmusobservations}{%";\
	    }\
	    { o += $$$$2;\
	      r += $$$$2 + $$$$3;\
	      mach = gensub(/^.*\/$$(_JOBNAME)\.(.*)\.hw-res:\([^[:space:]]*\)/,"\\1",1,$$$$1);\
	      printf "  %1s%-25s%s\n", comma, $$$$2 "/" $$$$2+$$$$3 "%", mach;\
	      comma = ",";\
	    }\
	    END {\
	      print "}%\n\\newcommand{\\litmusobstotal}{" o "/" r "}%";\
	    }' > $$@

$$(FIGSDIR)/$(1)/$$(_JOBNAME).%.hw-res: $$(HWLOGS)/$$($(1)_SUBDIR)/%/*
	mkdir -p $$(dir $$@)
	$(MSUM) -q $$(HWLOGS)/$$($(1)_SUBDIR)/$$*/* 2>/dev/null |\
	  awk '$$$$1 == "Test" {printf "(%s) ", $$$$2} $$$$1 == "Positive:" {print $$$$2, $$$$4}' > $$@
# We use .PRECIOUS below, instead of .SECONDARY, as the latter does not allow
# patterns (%) and the former does. We just want to prevent make from deleting
# the .hw-res file, in successful runs. If we let make delete these files, and
# it will because they are intermediate, every time we add a new litmus test
# all the externalised litmus figures (of the same architecture) will be rebuilt.
.PRECIOUS: $$(FIGSDIR)/$(1)/$$(_JOBNAME).%.hw-res

$$(FIGSDIR)/$(1)/$$(_JOBNAME).table.tex: $$(addprefix $$(FIGSDIR)/,$$(filter $(1)/%,$$(FIGS:=.hw.tex)))
	{ echo '%% This is an autogenerated file' &&\
	  echo '%%' &&\
	  echo "\begin{litmusresults}{$$$$(echo "$$($(1)_MACHS)" | tr ' ' ',')}%" &&\
	  $$(patsubst %,echo '\litmusexprow{%}%' &&,$$(subst /,}{,$$(filter $(1)/%,$$(FIGS))))\
	  echo '\end{litmusresults}%';\
	} > $$@
$$(FIGSDIR)/$$(_JOBNAME).hw-tables.sentinel: $$(FIGSDIR)/$(1)/$$(_JOBNAME).table.tex
endef
$(foreach arch,$(ARCHS),$(eval $(call hw-table,$(arch))))

$(FIGSDIR)/$(_JOBNAME).hw-tables.sentinel:
	mkdir -p $(dir $@)
	touch $@

######################################################################
## Do the job of \jobname.makefile that TikZ extern generates
##

ifneq "$(wildcard $(BUILDDIR)/$(_JOBNAME).figlist)" ""
EXTERNALS := $(shell sort -u $(BUILDDIR)/$(_JOBNAME).figlist)
EXTERNALS := $(EXTERNALS:%=$(BUILDDIR)/%.pdf)
endif

# This will force-build externals that need to rebuild because of
# 'computed assem width' which requires two runs
EXTERNALLOGS := $(wildcard $(call escwildcards,$(EXTERNALS:.pdf=.log)))
ifneq "$(EXTERNALLOGS)" ""
$(BUILDDIR)/$(_JOBNAME)-externals/runagain.d: $(EXTERNALLOGS)
	mkdir -p $(dir $@)
	grep -l '^run latex again.' $^ | sort -u | sed 's/\.log$$/.pdf: _FORCEBUILD/' > $@
-include $(BUILDDIR)/$(_JOBNAME)-externals/runagain.d
endif

# Build the externalised TikZ pictures
$(BUILDDIR)/$(_JOBNAME)-externals/sentinel: $(EXTERNALS)
	mkdir -p $(dir $@)
	touch $@

LATEXSOURCE ?= \input{$(_JOBNAME)}
define gen-external-pdf =
	mkdir -p $(dir $@)
	rm -f $@
# Some packages (e.g. beamer) write and read auxiliary files (e.g. \jobname.vrb
# for fragile frames), this creates unwanted interference between multiple runs
# (as in make -j2) as they all write to the same file. To fix that we set
# \tikzexternalrealjob to a unique value, and pass the real jobname in \litmusexternaljobname
# We also copy jobname.aux to the <fake>_job.aux so width information can be read from it.
	-cp $(BUILDDIR)/$(_JOBNAME).aux $(@:.pdf=)_job.aux
	-$(PDFLATEX) $(LATEXFLAGS) -jobname "$(patsubst $(BUILDDIR)/%,%,$(@:.pdf=))" "\def\tikzexternalrealjob{$(@:.pdf=)_job}\def\litmusexternaljobname{$(_JOBNAME)}$(LATEXSOURCE)"
	@[ -f '$@' ] || { echo "** Error: failed to build an externalized TikZ picture, see $(@:.pdf=.log)"; exit 1; }
endef

# This will apply to all the externals:
$(BUILDDIR)/$(_JOBNAME)-externals/%.pdf: LATEXFLAGS += -halt-on-error
$(BUILDDIR)/$(_JOBNAME)-externals/%.pdf: LATEXFLAGS += -interaction=batchmode

# Generate externals that are not specialized below:
$(BUILDDIR)/$(_JOBNAME)-externals/%.pdf:
	$(gen-external-pdf)

ifneq "$(wildcard $(BUILDDIR)/$(_JOBNAME).litmusfigs)" ""
define externals =
$(BUILDDIR)/$(_JOBNAME)-externals/$(context)/%.assem.pdf: $(FIGSDIR)/%.tikz $(FIGSDIR)/%.states.tex $(FIGSDIR)/%.hw.tex
	$(gen-external-pdf)

$(BUILDDIR)/$(_JOBNAME)-externals/$(context)/%.events.pdf: $(FIGSDIR)/%.tikz
	$(gen-external-pdf)

$(BUILDDIR)/$(_JOBNAME)-externals/$(context)/%.full.pdf: $(FIGSDIR)/%.tikz $(FIGSDIR)/%.states.tex $(FIGSDIR)/%.hw.tex
	$(gen-external-pdf)
endef
$(foreach context,$(shell sed 's/:.*//' $(BUILDDIR)/$(_JOBNAME).litmusfigs | sort -u),$(eval $(value externals)))
endif

endif # ifneq "$(_JOBNAME)" ""

######################################################################

clean_figures:
	rm -rf $(FIGSDIR)
.PHONY: clean_figures

clean_tikz_figures:
	find $(FIGSDIR) -name '*.tikz' -delete
	find $(FIGSDIR) -name '*.states.tex' -delete
.PHONY: clean_tikz_figures

clean_hw_tables:
	find $(FIGSDIR) -name '*.hw-res' -delete
	find $(FIGSDIR) -name '*.hw.tex' -delete
	find $(FIGSDIR) -name '*.table.tex' -delete
	rm -f $(FIGSDIR)/*.hw-tables.sentinel
.PHONY: clean_hw_tables

######################################################################
######################################################################

ifeq "$(MAKECMDGOALS)" "find_unused_figures"
define include_litmus_d =
include $d
_JOBNAME := $(d:.litmus.d=)
$(if $(shell [ ! -f '$(BUILDDIR)/$(_JOBNAME).litmusfigs' ] || [ "$$($(TIKZSCMD) | md5sum)" = "$(LITMUSFIGSMD5)" ] || echo 1),\
    $(error Error: $(_JOBNAME).litmus.d is out of date))
endef
$(foreach d,$(wildcard *.litmus.d),$(eval $(value include_litmus_d)))
else ifneq "$(filter find_unused_figures,$(MAKECMDGOALS))" ""
  $(error Error: you can only use the target 'find_unused_figures' by itself)
endif

# Find .tikz/.states.tex files we generated but don't use any more
find_unused_figures:
ifneq "$(FIGS)" ""
	@find $(FIGSDIR) -name '*.tikz' -or -name '*.states.tex' | grep -Fxv $(addprefix -e $(FIGSDIR)/,$(FIGS:=.tikz) $(FIGS:=.states.tex))\
	  || echo "No unused figures in '$(FIGSDIR)'"
endif
.PHONY: find_unused_figures

# After rebuilding the .tikz figures, revert figures that changed only
# in comments (not including the hash comment).
checkout_unchanged_figs: CHANGEDFIGS := $(shell git diff -G '^([^%]|(% Litmus hash:))' --name-only -- '$(FIGSDIR)/')
checkout_unchanged_figs:
	@$(if $(CHANGEDFIGS),\
	     printf 'Checkout all the files in $(FIGSDIR)/ except:\n  $(CHANGEDFIGS)\n',\
	     printf 'Checkout all the files in $(FIGSDIR)/\n')
	@while true; do\
	  read -r -p "Do you want to continue? [y/N/d/g/?] " YN || exit 1;\
	  case "$$YN" in\
	    y|Y|yes|Yes|YES) break;;\
	    ""|n|N|no|No|NO) exit 1;;\
	    d|D|diff) git diff '$(FIGSDIR)/';;\
	    g) git diff -G '^([^%]|(% Litmus hash:))' '$(FIGSDIR)/';;\
	    *)\
	       echo '  y: continue' &&\
	       echo '  n: stop' &&\
	       echo '  d: show "git diff $(FIGSDIR)"' &&\
	       echo '  g: same as "d" but only diffs that are not comments (not including hash comment)';;\
	  esac;\
	done
	$(if $(CHANGEDFIGS),git stash push $(CHANGEDFIGS))
	git checkout '$(FIGSDIR)/'
	$(if $(CHANGEDFIGS),git stash pop)
.PHONY: checkout_unchanged_figs
