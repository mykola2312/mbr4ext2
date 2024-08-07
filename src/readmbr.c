// program to read MBR and its partition table
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
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

void decode_chs(const uint8_t* chs, uint16_t* cylinder, uint16_t* head, uint16_t* sector)
{
    *head = chs[0];
    *sector = chs[1] & 0x3F;
    *cylinder = (((uint16_t)chs[1]) & 0xC0) << 2 | (uint16_t)chs[2];
}

int main(int argc, char** argv)
{
    mbr_t mbr;

    if (argc < 2)
    {
        fputs("provide filename to disk image as first argument\n", stderr);
        return 1;
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd < 0)
    {
        perror("failed to open disk image\n");
        return 1;
    }

    if (read(fd, &mbr, sizeof(mbr_t)) < sizeof(mbr_t))
    {
        perror("failed to read MBR!\n");
        close(fd);
        return 1;
    }
    close(fd);

    printf("== Master Boot Record ==\n");
    printf("Unique ID:\t%u\n", mbr.unique_id);
    printf("Reserved:\t%u\n", (unsigned int)mbr.reserved);
    for (unsigned i = 0; i < 4; i++)
    {
        const mbr_part_t* part = &mbr.part_table[i];
        uint16_t cylinder, head, sector;

        printf("Partition:\t%u\n", i);
        printf("\tAttributes:\t%u (%s)\n", part->attributes, part->attributes & 0x80 ? "active" : "");
        printf("\tType:%u\n", part->type);

        decode_chs(part->chs_first, &cylinder, &head, &sector);
        printf("\tCHS First:\tC %u\tH %u\tS %u\n", cylinder, head, sector);
        
        decode_chs(part->chs_last, &cylinder, &head, &sector);
        printf("\tCHS Last:\tC %u\tH %u\tS %u\n", cylinder, head, sector);
        
        printf("\tLBA:\t%u\n", part->lba_start);
        printf("\tTotal Sectors:\t%u\n", part->num_sectors);
    }

    return 0;
}