// program to read MBR and its partition table
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include "mbr.h"
#include "chs.h"

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
    printf("Unique ID:\t%x\n", mbr.unique_id);
    printf("Reserved:\t%x\n", (unsigned int)mbr.reserved);
    for (unsigned i = 0; i < 4; i++)
    {
        const mbr_part_t* part = &mbr.part_table[i];
        chs_t chs_first, chs_last;

        chs_decode(&part->chs_first, &chs_first);
        chs_decode(&part->chs_last, &chs_last);

        printf("Partition:\t%u\n", i);
        printf("\tAttributes:\t%x (%s)\n", part->attributes, part->attributes & 0x80 ? "active" : "");
        printf("\tType:\t%x\n", part->type);

        printf("\tCHS First:\tC %u\tH %u\tS %u\n", chs_first.cylinder, chs_first.head, chs_first.sector);
        printf("\tCHS Last:\tC %u\tH %u\tS %u\n", chs_last.cylinder, chs_last.head, chs_last.sector);
        
        printf("\tLBA:\t%u\n", part->lba_start);
        printf("\tTotal Sectors:\t%u\n", part->num_sectors);
    }

    return 0;
}
