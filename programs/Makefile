##############################################################################
# GNU Makefile for brotli-mt
# /TR 2024-02-02
##############################################################################

# current versions we're using (tagged in their main repo)
BRO_VER	= "v1.1.0"

CC	= $(CROSS)gcc
RANLIB	= $(CROSS)ranlib
STRIP	= $(CROSS)strip
SFLAGS	= -R .note -R .comment
CFLAGS	= -W -pthread -Wall -pipe
CFLAGS	+= -fomit-frame-pointer
CFLAGS	+= -Wno-implicit-fallthrough
CFLAGS	+= -O3
LDFLAGS	= $(WIN_LDFLAGS) -lpthread

all:	brotli-mt
again:	clean brotli-mt

ZSTDMTDIR = ../lib
COMMON	= platform.c $(ZSTDMTDIR)/threading.c

BRO_MT	= $(COMMON) $(ZSTDMTDIR)/brotli-mt_common.c $(ZSTDMTDIR)/brotli-mt_compress.c \
	  $(ZSTDMTDIR)/brotli-mt_decompress.c brotli-mt.c


# Brotli, https://github.com/google/brotli
BRODIR	= brotli/c
ifndef LIBBRO
LIBBRO	+= \
	  $(BRODIR)/common/constants.c \
	  $(BRODIR)/common/context.c \
	  $(BRODIR)/common/dictionary.c \
	  $(BRODIR)/common/platform.c \
	  $(BRODIR)/common/shared_dictionary.c \
	  $(BRODIR)/common/transform.c \
	  $(BRODIR)/dec/bit_reader.c \
	  $(BRODIR)/dec/decode.c \
	  $(BRODIR)/dec/huffman.c \
	  $(BRODIR)/dec/state.c \
	  $(BRODIR)/enc/backward_references.c \
	  $(BRODIR)/enc/backward_references_hq.c \
	  $(BRODIR)/enc/bit_cost.c \
	  $(BRODIR)/enc/block_splitter.c \
	  $(BRODIR)/enc/brotli_bit_stream.c \
	  $(BRODIR)/enc/cluster.c \
	  $(BRODIR)/enc/command.c \
	  $(BRODIR)/enc/compound_dictionary.c \
	  $(BRODIR)/enc/compress_fragment.c \
	  $(BRODIR)/enc/compress_fragment_two_pass.c \
	  $(BRODIR)/enc/dictionary_hash.c \
	  $(BRODIR)/enc/encode.c \
	  $(BRODIR)/enc/encoder_dict.c \
	  $(BRODIR)/enc/entropy_encode.c \
	  $(BRODIR)/enc/fast_log.c \
	  $(BRODIR)/enc/histogram.c \
	  $(BRODIR)/enc/literal_cost.c \
	  $(BRODIR)/enc/memory.c \
	  $(BRODIR)/enc/metablock.c \
	  $(BRODIR)/enc/static_dict.c \
	  $(BRODIR)/enc/utf8_util.c
endif # ifndef LIBBRO
CF_BRO	= $(CFLAGS) -I$(BRODIR)/include

# append lib include directory
CFLAGS	+= -I. -I$(ZSTDMTDIR)

brotli-mt:
	$(CC) $(CF_BRO) $(BRO_MT) -DVERSION='$(BRO_VER)' -o $@ $(LIBBRO) $(LDFLAGS) -lm
	$(STRIP) $(SFLAGS) $@

# tests are unix / linux only
tests:
	@dd if=/dev/urandom of=testbytes.raw bs=1M count=10 2>/dev/null
	@for m in brotli ; do \
	cat testbytes.raw | ./$$m-mt -z > compressed.$$m ; \
	cat compressed.$$m | ./$$m-mt -d > testbytes-$$m.raw ; \
	cmp testbytes.raw testbytes-$$m.raw && echo "SUCCESS: $$m" || echo "FAILING: $$m" ; \
	rm compressed.$$m testbytes-$$m.raw ; \
	done
	@rm testbytes.raw

clean:
	@echo Cleaning built file...
	@rm -f brotli-mt
