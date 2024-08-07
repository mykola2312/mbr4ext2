// program to read MBR and its partition table
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint8_t cylinder;
    uint8_t head;
    uint8_t sector;
} __attribute__((packed)) chs_t;

typedef struct {
    uint8_t attributes;
    chs_t chs_first;
    uint8_t type;
    chs_t chs_last;
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

int main(int argc, char** argv)
{
    mbr_t mbr;

    // if (argc < 2)
    // {
    //     fputs("provide filename to disk image as first argument\n", stderr);
    //     return 1;
    // }

    // int fd = open(argv[1], O_RDONLY);
    // if (fd < 0)
    // {
    //     perror("failed to open disk image\n");
    //     return 1;
    // }


    // close(fd);

    printf("%lu\n", sizeof(mbr_t));
    printf("%lu\n", sizeof(mbr_part_t));

    return 0;
}