#ifndef __MBR_H
#define __MBR_H

#include <stdint.h>

typedef struct {
    uint8_t attributes;
    uint8_t chs_first[3];
    uint8_t type;
    uint8_t chs_last[3];
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