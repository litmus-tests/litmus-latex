# Generated file (see litmus.mk) -- do not edit

# md5sum of "sed 's/[^:]*://' 'build/tikz-doc.litmusfigs' | sort -u"
LITMUSFIGSMD5 = 06f2fca8c04b6cc317039b6bbeeabc48  -

$(FIGSDIR)/A64/LB+addr+data.tikz $(FIGSDIR)/A64/LB+addr+data.states.tex: AArch64/non-mixed-size/PPO/LB/LB+addr+data.litmus
FIGS += A64/LB+addr+data

$(FIGSDIR)/A64/MP+dmb.sy+ctrl.tikz $(FIGSDIR)/A64/MP+dmb.sy+ctrl.states.tex: AArch64/non-mixed-size/HAND/MP+dmb.sy+ctrl.litmus
FIGS += A64/MP+dmb.sy+ctrl

$(FIGSDIR)/A64/MP+dmb.sy+fri-rfi-ctrlisb.tikz $(FIGSDIR)/A64/MP+dmb.sy+fri-rfi-ctrlisb.states.tex: AArch64/non-mixed-size/PPO/MP/MP+dmb.sy+fri-rfi-ctrlisb.litmus
FIGS += A64/MP+dmb.sy+fri-rfi-ctrlisb

$(FIGSDIR)/A64/MP+dmbsy+misaligned2+1.tikz $(FIGSDIR)/A64/MP+dmbsy+misaligned2+1.states.tex: AArch64/mixed-size/HAND/MP+dmbsy+misaligned2+1.litmus
FIGS += A64/MP+dmbsy+misaligned2+1

$(FIGSDIR)/A64/WRC+addrs.tikz $(FIGSDIR)/A64/WRC+addrs.states.tex: AArch64/non-mixed-size/TUTORIAL/WRC+addrs.litmus
FIGS += A64/WRC+addrs

