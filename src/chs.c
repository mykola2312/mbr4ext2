#include "chs.h"

void chs_decode(const chs_encoded_t* enc, chs_t* chs)
{
    chs->head = enc->b[0];
    chs->sector = enc->b[1] & 0x3F;
    chs->cylinder = (((uint16_t)enc->b[1]) & 0xC0) << 2 | (uint16_t)enc->b[2];
}

uint32_t chs_to_lba(const chs_conf_t* conf, const chs_t* chs)
{
    return (chs->cylinder * conf->num_heads + chs->head) * conf->num_sectors + (chs->sector - 1);
}

void lba_to_chs(const chs_conf_t* conf, uint32_t lba, chs_t* chs)
{
    chs->head = lba / (conf->num_heads * conf->num_sectors);
    chs->cylinder = (lba / conf->num_sectors) % conf->num_heads;
    chs->sector = (lba % conf->num_sectors) + 1;
}
