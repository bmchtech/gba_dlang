PATH := $(DEVKITARM)/bin:$(PATH)

TITLE		:= GBADlang

#  Project settings

NAME		:= $(TITLE)
SOURCE_DIR 	:= src
LIB_DIR    	:= lib
TOOLS_DIR	:= ../tools
DATA_DIR   := asset/build
SPECS      := -specs=gba.specs

# Compilation settings

CROSS	?= arm-none-eabi-
AS	:= $(CROSS)as
CC	:= $(CROSS)gcc
LD	:= $(CROSS)gcc
OBJCOPY	:= $(CROSS)objcopy
LDC     := ldc2
NELUA	:= nelua

ARCH	:= -mthumb-interwork -mthumb

INCFLAGS := --I$(DEVKITPRO)/libtonc/include -I$(DEVKITPRO)/libgba/include -I$(SOURCE_DIR) -I$(DATA_DIR)
LIBFLAGS := -L$(DEVKITPRO)/libtonc/lib -ltonc -L$(DEVKITPRO)/libgba/lib -lmm
ASFLAGS	:= -mthumb-interwork
CFLAGS	:= $(ARCH) -Wall -Werror -Wno-error=unused-variable -fno-strict-aliasing -mcpu=arm7tdmi -mtune=arm7tdmi $(INCFLAGS) $(LIBFLAGS)
LDFLAGS	:= $(ARCH) $(SPECS) $(LIBFLAGS) -Wl,-Map,$(TITLE).map
DFLAGS  := -betterC --defaultlib=no -mtriple=arm-none-eabi -mcpu=arm7tdmi \
				-mattr=+strict-align,+loop-align\
				-I$(SOURCE_DIR) \
				--d-version=DevkitARM --d-version=CRuntime_Newlib_GBA --d-version=_GBA \
				-function-sections
NELUA_FLAGS := -P noentrypoint -P nogc -P nochecks --release --add-path $(SOURCE_DIR)/lua

ASSET_MKFLAGS := TOOLS_DIR=$(addprefix $(CURDIR)/,$(TOOLS_DIR))

DSTDLIB := ../libd
DINCFLAGS :=
DFLAGS += -I$(DSTDLIB)

ifeq ($(DEBUG),1)
	CFLAGS += -O2 -g -DDEBUG
	DFLAGS += -g --d-version=DEBUG
else
	# non-debug
	CFLAGS += -O2 -fomit-frame-pointer -ffast-math
	DFLAGS += -O2 -frame-pointer=none -ffast-math
endif

.PHONY : build clean

# Find and predetermine all relevant source files

APP_MAIN_SOURCE := $(shell find $(SOURCE_DIR) -name '*main.c')
APP_MAIN_OBJECT := $(APP_MAIN_SOURCE:%.c=%.o)
APP_SOURCES_C     := $(shell find $(SOURCE_DIR) -name '*.c' ! -name "*main.c"  ! -name "*.test.c")
APP_SOURCES_S     := $(shell find $(SOURCE_DIR) -name '*.s')
APP_OBJECTS_C     := $(APP_SOURCES_C:%.c=%.o)
APP_OBJECTS_S     := $(APP_SOURCES_S:%.s=%.o)
APP_SOURCES_D     := $(shell find $(DSTDLIB) $(SOURCE_DIR) -name '*.d')
APP_OBJECTS_D     := $(APP_SOURCES_D:%.d=%.o)
APP_SOURCES_NELUA := $(shell find $(SOURCE_DIR) -name '*.lua')
APP_NELUA_SCRIPTS := $(shell find $(SOURCE_DIR) -name '*.nelua')
APP_OBJECTS_NELUA := $(APP_SOURCES_NELUA:%.lua=%.o)
APP_OBJECTS		  := $(APP_OBJECTS_C) $(APP_OBJECTS_S) $(APP_OBJECTS_D) $(APP_OBJECTS_NELUA)

# Build commands and dependencies

.PHONY: build

build: $(NAME).gba

no-content: $(NAME)-code.gba

# GBA ROM Build

$(NAME).gba : $(NAME)-code.gba
	cat $^ > $(NAME).gba

$(NAME)-code.gba : $(NAME).elf
	$(OBJCOPY) -v -O binary $< $@
	-@gbafix $@ -t$(NAME)
	padbin 256 $@

$(NAME).elf : $(APP_OBJECTS) $(APP_MAIN_OBJECT)
	$(LD) $^ $(LDFLAGS) -o $@

$(APP_OBJECTS_C) : %.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(APP_OBJECTS_S) : %.o : %.s
	$(CC) $(CFLAGS) -c $< -o $@

$(APP_OBJECTS_D) : %.o : %.d
	$(LDC) $(DFLAGS) -c -of=$@ $<

$(APP_OBJECTS_NELUA) : %.o : %.lua $(APP_NELUA_SCRIPTS)
	$(NELUA) -B $(NELUA_FLAGS) --cc $(CC) --cflags="$(CFLAGS)" -o $@ $<

$(APP_MAIN_OBJECT) : $(APP_MAIN_SOURCE)
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME).gbfs:
	gbfs $@ $(shell find $(DATA_DIR) -name '*.bin')

clean:
	@rm -fv *.gba
	@rm -fv *.elf
	@rm -fv *.sav
	@rm -fv *.gbfs
	@rm -rf $(APP_OBJECTS)
	@rm -rf $(APP_MAIN_OBJECT)
