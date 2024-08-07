#ifndef __CHS_H
#define __CHS_H

#include <stdint.h>

typedef struct {
    uint8_t b[3];
} __attribute__((packed)) chs_encoded_t;

typedef struct {
    uint16_t cylinder;
    uint16_t head;
    uint16_t sector;
} chs_t;

typedef struct {
    uint16_t num_cylinders;
    uint16_t num_heads;
    uint16_t num_sectors;
} chs_conf_t;

void chs_decode(const chs_encoded_t* enc, chs_t* chs);

uint32_t chs_to_lba(const chs_conf_t* conf, const chs_t* chs);
void lba_to_chs(const chs_conf_t* conf, uint32_t lba, chs_t* chs);

#endif