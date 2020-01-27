SRCS = $(wildcard *.s)
BINS = $(SRCS:.s=.prg)

%.prg: %.s
	64tass -Wall --cbm-prg -o $@ -a $<

all: $(BINS)

clean:
	rm -f $(BINS)
