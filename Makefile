CC					=	gcc
AS					=	as
LD					=	ld
OBJCOPY				=	objcopy
CLFAGS				=	-g -Wall
ASFLAGS				=
LDFLAGS				=	-g

SRC_DIR				=	src
OBJ_DIR				=	obj
BIN_DIR				=	bin

UID					:=	$(shell id -u)
GID					:=	$(shell id -g)

DISK				=	$(BIN_DIR)/disk.img
DISK_SIZE			=	268435456
DISK_LOOP			=	/dev/loop690

PART1_START_SECTOR	=	2048
PART1_END_SECTOR	=	4096
PART1_START			=	$$(( $(PART1_START_SECTOR) * 512 ))
PART1_SIZE			=	$$(( ($(PART1_END_SECTOR) - $(PART1_START_SECTOR)) * 512 ))
PART1_ID			=	1
PART1_TYPE			=	0x9F
PART1_LOOP			=	/dev/loop691

PART2_START_SECTOR	=	6144
PART2_END_SECTOR	=	71680
PART2_START			=	$$(( $(PART2_START_SECTOR) * 512 ))
PART2_SIZE			=	$$(( ($(PART2_END_SECTOR) - $(PART2_START_SECTOR)) * 512 ))
PART2_ID			=	2
PART2_TYPE			=	0x83
PART2_FSTYPE		=	ext2
PART2_LABEL			=	smol
PART2_UUID			=	11223344-aabb-ccdd-ffee-cafebabed00d
PART2_LOOP			=	/dev/loop692

PART3_START_SECTOR	=	73728
PART3_END_SECTOR	=	$$(( ($(DISK_SIZE) / 512) - 1 ))
PART3_START			=	$$(( $(PART3_START_SECTOR) * 512 ))
PART3_SIZE			=	$$(( ($(PART3_END_SECTOR) - $(PART3_START_SECTOR)) * 512 ))
PART3_ID			=	3
PART3_TYPE			=	0x83
PART3_FSTYPE		=	ext2
PART3_LABEL			=	root
PART3_UUID			=	44332211-bbaa-ddcc-eeff-cafebabed00d
PART3_LOOP			=	/dev/loop693

.PHONY: clean

mnt:
	mkdir mnt

$(DISK): mnt
	# create img file
	truncate -s 256m $(DISK)
	# format img file in MBR and create partitions
	sudo losetup $(DISK_LOOP) $(DISK)
	sudo parted $(DISK_LOOP) mklabel msdos
	sudo parted $(DISK_LOOP) mkpart primary $(PART1_START_SECTOR)s $(PART1_END_SECTOR)s	# 1	- test pattern partition
	sudo parted $(DISK_LOOP) mkpart primary $(PART2_START_SECTOR)s $(PART2_END_SECTOR)s	# 2 - 32MB small EXT2 partition
	sudo parted $(DISK_LOOP) mkpart primary $(PART3_START_SECTOR)s $(PART3_END_SECTOR)s	# 3 - "root" EXT2 partition
	# set MBR partition types
	sudo parted $(DISK_LOOP) type $(PART1_ID) $(PART1_TYPE)	# 1 - 0x9F BSD/OS (BSD/386) as reference to Gundam: The 08th MS Team
	sudo parted $(DISK_LOOP) type $(PART2_ID) $(PART2_TYPE)	# 2 - 0x83 Linux 
	sudo parted $(DISK_LOOP) type $(PART3_ID) $(PART3_TYPE)	# 3 - 0x83 Linux
	# attach partitions
	sudo losetup --offset $(PART1_START) --sizelimit $(PART1_SIZE) $(PART1_LOOP) $(DISK)
	sudo losetup --offset $(PART2_START) --sizelimit $(PART2_SIZE) $(PART2_LOOP) $(DISK)
	sudo losetup --offset $(PART3_START) --sizelimit $(PART3_SIZE) $(PART3_LOOP) $(DISK)
	# format partitions
	python gen/test_pattern.py | sudo dd of=$(PART1_LOOP)
	sudo mkfs.ext2 -t $(PART2_FSTYPE) -L $(PART2_LABEL) -U $(PART2_UUID) $(PART2_LOOP)
	sudo mkfs.ext2 -t $(PART3_FSTYPE) -L $(PART3_LABEL) -U $(PART3_UUID) $(PART3_LOOP)
	# fill EXT2 partitions
	# mount and fill boot partition
	sudo mount $(PART2_LOOP) mnt/		# mount
	sudo chown -R ${UID}:${GID} mnt/	# because we ain't gonna run python with root, so own it by user
	python gen/generate_files.py --mode=boot --dirs=gen/rootfs-dirs.gz --path=mnt
	sudo chown -R 0:0 mnt/				# make it root
	sudo umount mnt/					# done
	# mount and fill root partition
	sudo mount $(PART3_LOOP) mnt/		# mount
	sudo chown -R ${UID}:${GID} mnt/	# because we ain't gonna run python with root, so own it by user
	python gen/generate_files.py --mode=root --dirs=gen/rootfs-dirs.gz --path=mnt
	sudo chown -R 0:0 mnt/				# make it root
	sudo umount mnt/					# done
	# detach loopback devices
	sudo losetup -d $(PART1_LOOP)
	sudo losetup -d $(PART2_LOOP)
	sudo losetup -d $(PART3_LOOP)
	sudo losetup -d $(DISK_LOOP)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<
	$(OBJCOPY) --remove-section .note.gnu.property $@

MBR_TEST_OBJ		=	obj/mbr_test.o

mbr_test: $(MBR_TEST_OBJ) $(DISK)
	$(LD) -T src/mbr_test.ld -o $(BIN_DIR)/mbr_test.bin $(MBR_TEST_OBJ)

mbr_test_clean:
	rm $(BIN_DIR)/mbr_test.bin
	rm $(OBJ_DIR)/mbr_test.o

clean:
	rm -f bin/*
	rm -f obj/*
