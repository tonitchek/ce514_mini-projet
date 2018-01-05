TOOLCHAIN=/opt/Xilinx/SDK/2017.2/gnu/arm/lin
CC=$(TOOLCHAIN)/bin/arm-xilinx-linux-gnueabi-gcc
SYS_INC=$(TOOLCHAIN)/arm-xilinx-linux-gnueabi/libc/usr/include
ARM_INC=$(TOOLCHAIN)/lib/gcc/arm-xilinx-linux-gnueabi/4.9.2/include
SYS_LIB=$(TOOLCHAIN)/arm-xilinx-linux-gnueabi/libc/usr/lib
CFLAGS=-c -O3 -Wall -I. -I$(SYS_INC) -I$(ARM_INC)
LDFLAGS= -L$(SYS_LIB)

APP=m4x4_multiplier
TARGET_APP_HOME=../platform/linux/rootfs/mnt_ramdisk/root

all: $(APP).elf


main.o: $(APP).c
	$(CC) $(CFLAGS) -o $(APP).o $(APP).c

neon.o: neon.c
	$(CC) $(CFLAGS) -mfloat-abi=softfp -mfpu=neon -o neon.o neon.c

utils.o: utils.c
	$(CC) $(CFLAGS) -o utils.o utils.c

$(APP).elf: $(APP).o neon.o utils.o
	$(CC) $(LDFLAGS) -static -o $(APP).elf $(APP).o neon.o utils.o $(LIBS)

clean:
	rm *.o $(APP).elf

install:
	$(TOOLCHAIN)/bin/arm-xilinx-linux-gnueabi-strip $(APP).elf
	cp $(APP).elf $(TARGET_APP_HOME)
	cp ../hdl/tb/tb_matrix.dat $(TARGET_APP_HOME)
