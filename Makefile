TLC ?= tlc
MODEL ?= Alpenglow.tla


.PHONY: all safety fast slow resilience clean

all: safety fast slow resilience

safety:
	$(TLC) -config Alpenglow.cfg $(MODEL)

fast:
	$(TLC) -config cfg/fast_path.cfg $(MODEL)

slow:
	$(TLC) -config cfg/slow_path.cfg $(MODEL)

resilience:
	$(TLC) -config cfg/resilience.cfg $(MODEL)

clean:
	rm -f states/*.chk states/*.tlc states/*.log
