#ifndef __MBR_H
#define __MBR_H

#include <stdint.h>
#include "chs.h"

// https://wiki.osdev.org/MBR_(x86)
// https://en.wikipedia.org/wiki/Master_boot_record

typedef struct {
    uint8_t attributes;
    chs_encoded_t chs_first;
    uint8_t type;
    chs_encoded_t chs_last;
    uint32_t lba_start;
    uint32_t num_sectors;
} __attribute__((packed)) mbr_part_t;

typedef struct {
    char bootstrap[440];
    uint32_t unique_id;
    uint16_t reserved;
    mbr_part_t part_table[4];
    uint16_t signature;
} __attribute__((packed)) mbr_t;

#endif