
# Multithreading Library for [Brotli]

## Description
- Works with skippables frame id 0x184D2A50 (12 bytes per compressed frame), it will encapsulate the real brotli stream within an 16 byte frame header

## [Brotli] frame definition

- the frame header for brotli is defined a bit different:

size    | value             | description
--------|-------------------|------------
4 bytes | 0x184D2A50U       | magic for skippable frame (like zstd)
4 bytes | 8                 | size of skippable frame
4 bytes | compressed size   | size of the following frame (compressed data)
2 bytes | 0x5242U           | magic for brotli "BR"
2 bytes | uncompressed size | allocation hint for decompressor (64KB * this size)

[Brotli]:https://github.com/google/brotli/

