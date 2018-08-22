simulator=hspice
dbgsp=dbgtest5.b4
Model_deps=modelcard.pmos modelcard.nmos modflags.inc
Model_VA_deps=va/modelcard_va.pmos va/modelcard_va.nmos ../bsim4_release.va modflags.inc
netlist=$(shell ls *.b4)
outfiles=$(subst .b4,.lis,$(netlist))
targets_c=$(addprefix out/hsp_,$(outfiles))
targets_v=$(addprefix va/out/hspva_,$(outfiles))

.PHONY: all clean comp SIMU_DONE distclean
all: SIMU_DONE comp
	@echo "run && compare results C vs. VA Done"
	@touch SIMU_DONE

SIMU_DONE: $(targets_c) $(targets_v)

out/hsp_%.lis: %.b4 $(Model_deps)   
	@if [ ! -d out ]; then mkdir -p out; fi
	@$(simulator) -i $< -o $(subst .lis,,$@)

va/out/hspva_%.lis: va/%.b4 $(Model_VA_deps) 
	@if [ ! -d va/out ]; then mkdir -p va/out; fi
	@$(simulator) -i $< -o $(subst .lis,,$@)

comp: SIMU_DONE
	@echo "run compare results C vs. VA"
	./run_tests.sh

dbg:  out/hsp_$(subst .b4,.lis,$(dbgsp)) va/out/hspva_$(subst .b4,.lis,$(dbgsp)) $(Model_deps) $(Model_VA_deps) 
	touch dbg
	gvim -d out/hsp_$(subst .b4,,$(dbgsp)).lis va/out/hspva_$(subst .b4,,$(dbgsp)).lis

clean:
	rm -rf out/hsp_*.sw* out/hsp_*.tr* out/hsp_*.ac* out/hsp_*.lis
	rm -rf va/out/hspva_*.sw* va/out/hspva_*.tr* va/out/hspva_*.ac* va/out/hspva_*.lis va/out/hspva_*.pvadir SIMU_DONE
distclean:
	rm -rf out va/out SIMU_DONE results-*.log

