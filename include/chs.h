#ifndef __CHS_H
#define __CHS_H

#include <stdint.h>

void decode_chs(const uint8_t* chs, uint16_t* cylinder, uint16_t* head, uint16_t* sector);

#endif