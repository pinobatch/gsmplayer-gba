# Replace default rules with devkitARM default rules

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif
.SUFFIXES:
include $(DEVKITARM)/gba_rules

#--------------------------------------------------------------------
# TARGET is the filename of the executable; if it ends with _mb
#   then it can run in RAM
# VERSION is the suffix added after TARGET in the zipfile name
# OBJS is the notdir basename of each .o file, which usually matches
# that of the corresponding .c or .png file
# BUILD is the directory in which to place object files and other
#   intermediate files
# SOURCES is the primary source code directory
# LIBDIRS is a list of directories that have include/*.h and
#   lib/lib*.a files
#
# All directories are specified relative to the project directory
# where the makefile is found
#
#--------------------------------------------------------------------
TARGET := allnewgsm
VERSION := 0.01
OBJS := \
  main asm libgbfs gsmcode.iwram \
  8x16
LIBS := -lgba

BUILD		:= obj/gba
SOURCES		:= src
LIBDIRS     := $(LIBGBA)

#--------------------------------------------------------------------
# some calculations
#--------------------------------------------------------------------
export INCLUDE := \
  $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
  -I$(CURDIR)/$(BUILD)
export LIBPATHS	:= \
  $(foreach dir,$(LIBDIRS),-L$(dir)/lib)
export OFILES := \
  $(foreach o,$(OBJS),$(BUILD)/$(o).o)

#--------------------------------------------------------------------
# programs and options for code generation
#--------------------------------------------------------------------

ARCH := -mthumb-interwork
CFLAGS := \
  -g -Wall -O2 -fomit-frame-pointer -ffast-math \
  -mcpu=arm7tdmi -mtune=arm7tdmi $(ARCH)
CFLAGS += $(INCLUDE)
ASFLAGS	:=	-g $(ARCH)
LD	:=	$(CC)
LDFLAGS	:=	-g $(ARCH) -Wl,-Map,$(notdir $*.map)

# Grit comes from GritHub, https://github.com/devkitPro/grit
ifdef COMSPEC
  GRIT := $(DEVKITARM)/bin/grit
  PADBIN := $(DEVKITARM)/bin/padbin
  PY := py -3
  EMU := start ""
else
  GRIT := $(DEVKITPRO)/tools/bin/grit
  PADBIN := $(DEVKITPRO)/tools/bin/padbin
  PY := python3
  EMU := mgba-qt
endif

# targets begin
.PHONY: run all clean dist zip
run: $(TARGET).gba
	$(EMU) $<
all: $(TARGET).gba

# Compiling and linking

$(TARGET).gba: $(TARGET)-bare.gba gsmsongs.gbfs
	$(PADBIN) 256 $<
	cat $^ > $@

$(TARGET)-bare.elf: $(OFILES)

$(BUILD)/%.o: $(SOURCES)/%.c $(SOURCES)/global.h
	$(CC) $(CFLAGS) -g -c -mthumb $< -o $@

$(BUILD)/%.iwram.o: $(SOURCES)/%.c $(SOURCES)/global.h
	$(CC) $(CFLAGS) -g -c -marm $< -o $@

$(BUILD)/%.o: $(SOURCES)/%.S
	$(CC) $(CFLAGS) -g -c -mthumb-interwork $< -o $@

$(BUILD)/%.o: $(BUILD)/%.s
	$(AS) $< -o $@

# Files that #include specialized libraries' headers

$(BUILD)/stills.o: $(SOURCES)/4bcanvas.h

# Image conversion

$(BUILD)/8x16.s: tilesets/8x16.png
	$(GRIT) $< -g -gu8 -gB1 -th16 -m! -p! -fs -o $(basename $@)

# Packaging

clean:
	-rm $(BUILD)/*.o $(BUILD)/*.s $(BUILD)/*.h $(TARGET).elf
dist: zip
zip: $(TARGET)-$(VERSION).zip
$(TARGET)-$(VERSION).zip: zip.in \
  README.md $(BUILD)/index.txt $(TARGET).gba
	zip -9 -u $@ -@ < $<
$(BUILD)/index.txt: makefile
	echo Files produced by build tools go here, but caulk goes where? > $@
