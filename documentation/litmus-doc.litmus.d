# Generated file (see litmus.mk) -- do not edit

# md5sum of "sed 's/[^:]*://' 'build/litmus-doc.litmusfigs' | sort -u"
LITMUSFIGSMD5 = 6b50d62b6447139a95ef813975c1bf35  -

$(FIGSDIR)/A64/MP.tikz $(FIGSDIR)/A64/MP.states.tex: AArch64/non-mixed-size/BASIC_2_THREAD/MP.litmus
FIGS += A64/MP

$(FIGSDIR)/PPC/MP.tikz $(FIGSDIR)/PPC/MP.states.tex: PPC/non-mixed-size/ORIGINAL/MP.litmus
FIGS += PPC/MP

$(FIGSDIR)/RV/MP.tikz $(FIGSDIR)/RV/MP.states.tex: RISCV/non-mixed-size/BASIC_2_THREAD/MP.litmus
FIGS += RV/MP

