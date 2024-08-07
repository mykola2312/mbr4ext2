#include "chs.h"

void decode_chs(const uint8_t* chs, uint16_t* cylinder, uint16_t* head, uint16_t* sector)
{
    *head = chs[0];
    *sector = chs[1] & 0x3F;
    *cylinder = (((uint16_t)chs[1]) & 0xC0) << 2 | (uint16_t)chs[2];
}
