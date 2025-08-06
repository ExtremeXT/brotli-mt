##############################################################################
# GNU Makefile for brotli-mt
# /TR 2024-02-02
##############################################################################

SUBMODULE_TAG := $(shell git -C brotli describe --tags --exact-match 2>/dev/null | xargs basename)

CC	= clang
RANLIB	= ranlib
STRIP	= strip
SFLAGS	= -R .note -R .comment
CFLAGS	= -W -pthread -Wall -pipe -flto -O3 -fomit-frame-pointer 
LDFLAGS	= -lpthread

all:	brotli-mt
again:	clean brotli-mt

BROTLI_MT	= src/platform.c src/threading.c src/brotli-mt_common.c src/brotli-mt_compress.c src/brotli-mt_decompress.c src/brotli-mt.c

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
CFLAGS	+= -Iinclude

brotli-mt:
	@mkdir -p out
	$(CC) $(CF_BRO) $(BROTLI_MT) -DVERSION=\"$(SUBMODULE_TAG)\" -o out/$@ $(LIBBRO) $(LDFLAGS) -lm
	@$(STRIP) $(SFLAGS) out/$@

tests:
	@if [ ! -x ./out/brotli-mt ]; then \
		echo "Error: brotli-mt hasn't been built yet!"; \
		exit 1; \
	fi
	@dd if=/dev/urandom of=testbytes.raw bs=1M count=10 2>/dev/null
	@cat testbytes.raw | ./out/brotli-mt -z > compressed.brotli
	@cat compressed.brotli | ./out/brotli-mt -d > testbytes-brotli.raw
	@cmp testbytes.raw testbytes-brotli.raw && echo "SUCCESS" || echo "FAILING"
	@rm compressed.brotli testbytes-brotli.raw testbytes.raw

clean:
	@echo Cleaning output folder...
	@rm -rf out

