SRCS = \
       hello.s \
       joyreader.s

BINS = $(SRCS:.s=.prg)

%.prg: %.s
	64tass -Wall --cbm-prg \
		--vice-labels -l $@.l \
		-L $@.lst \
		-o $@ -a $<

all: $(BINS)

clean:
	rm -f $(BINS)

joyreader.prg: joyreader.s kernal.s
