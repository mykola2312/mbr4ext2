CC					=	gcc
CLFAGS				=	-g -Wall
LDFLAGS				=	-g

DISK				=	bin/disk.img
DISK_SIZE			=	268435456
DISK_LOOP			=	/dev/loop690

PART1_START_SECTOR	=	2048
PART1_END_SECTOR	=	4096
PART1_ID			=	1
PART1_TYPE			=	0x9F
PART1_LOOP			=	/dev/loop691

PART2_START_SECTOR	=	6144
PART2_END_SECTOR	=	71680
PART2_ID			=	2
PART2_TYPE			=	0x83
PART2_LOOP			=	/dev/loop692

PART3_START_SECTOR	=	73728s
PART3_END_SECTOR	=	$$(( ($(DISK_SIZE) / 512) - 1 ))
PART3_ID			=	3
PART3_TYPE			=	0x83
PART3_LOOP			=	/dev/loop693

.PHONY: clean

$(DISK):
	# create img file
	truncate -s 256m $(DISK)
	# format img file in MBR and create partitions
	sudo losetup $(DISK_LOOP) $(DISK)
	sudo parted $(DISK_LOOP) mklabel msdos
	sudo parted $(DISK_LOOP) mkpart primary $(PART1_START_SECTOR)s $(PART1_END_SECTOR)s	# 1	- test pattern partition
	sudo parted $(DISK_LOOP) mkpart primary $(PART2_START_SECTOR)s $(PART2_END_SECTOR)s	# 2 - 32MB small EXT2 partition
	sudo parted $(DISK_LOOP) mkpart primary $(PART3_START_SECTOR)s $(PART3_END_SECTOR)s	# 3 - "root" EXT2 partition
	# set MBR partition types
	sudo parted $(DISK_LOOP) type $(PART1_ID) $(PART1_TYPE)
	sudo parted $(DISK_LOOP) type $(PART2_ID) $(PART2_TYPE)
	sudo parted $(DISK_LOOP) type $(PART3_ID) $(PART3_TYPE)
	# detach loopback devices
	sudo losetup -d $(DISK_LOOP)

clean:
	rm -f bin/*
	rm -f obj/*
