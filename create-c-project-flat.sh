#/bin/bash

ProjectName=$1

if [ -z "$ProjectName" ]; then
    echo "Usage: $0 <ProjectName>"
    exit 1
fi

# Create the project directory
mkdir $ProjectName

cd $ProjectName

mkdir -p src include lib docs

# Create the main.c file
echo '#include <stdio.h>
int main(int argc, char *argv[])
{
    printf("Hello, World!\\n");
    return 0;
}' >src/main.c

# Create the Makefile
echo '
CFG ?= debug

CC = gcc
CXX = g++
LD = $(CC)
STRIP = strip

TARGET_NAME = $(shell basename $(CURDIR))

SRC = $(wildcard src/*.c src/**/*.c)
	
CFLAGS = -MMD -MP

LDFLAGS = 


ifeq ($(CFG), debug)
CFLAGS += -DDEBUG
else
CFLAGS += -O3 -DNDEBUG
endif

BUILD_DIR = build/$(CFG)
BIN_DIR = bin/$(CFG)

OBJS_DIR = $(BUILD_DIR)/objs
TARGET = ${BIN_DIR}/${TARGET_NAME}
OBJS=$(patsubst %.c, $(OBJS_DIR)/%.o, ${SRC})
DEPS=$(patsubst %.c, $(OBJS_DIR)/%.d, ${SRC})

.PHONY: all
all: ${TARGET}

.PHONY: inform
inform:
ifneq ($(CFG),release)
ifneq ($(CFG),debug)
	@echo "┌---------------------------------------------------------------------┐"
	@echo "|                                                                     │" 
	@echo "| invalide configuration "$(CFG)" specified.                            │"
	@echo "| Possible choised for configuration are 'CFG=release' and 'CFG=debug'│"
	@echo "|                                                                     │"
	@echo "└---------------------------------------------------------------------┘"
	@exit 1
endif
endif

${TARGET}: ${OBJS} | inform
	mkdir -p ${dir $@}
	$(LD) $(LDFLAGS) -o $@.debug $(OBJS)
	$(STRIP) $@.debug -o $@
	# @ln -fs ${TARGET} ${TARGET_NAME} 

$(OBJS_DIR)/%.o: %.c | inform
	@mkdir -p ${dir $@}
	@$(CC) -c $(CFLAGS) -o $@ $<

.PHONY: clean
clean:
	@rm -rf $(OBJS) $(DEPS) ${TARGET} ${TARGET}.debug   ${TARGET_NAME}
	@echo "deleted [Objects|Dependency files] & ${TARGET}"

.PHONY: fclean
fclean: clean
	@rm -rf  build
	@echo "deleted build directory"

.PHONY: re
re : fclean  ${TARGET}

.Phony: install
install: ${TARGET}
	@cp ${TARGET} /usr/local/bin/${TARGET_NAME}
	@echo "Installed ${TARGET_NAME} to /usr/local/bin"

.PHONY: help
help:
	@echo "Usage: make [target] [CFG=debug|release]"
	@echo "Targets:"
	@echo "   all      Build the project (default target)"
	@echo "   clean    Remove object files and intermediate build files"
	@echo "   fclean   Remove the build directory"
	@echo "   re       Clean and rebuild"
	@echo "   install  Installs the ${TARGET_NAME} binary"
	@echo "   help     Show this help message"
	
-include $(DEPS)
' >Makefile

# Create the README.md file
echo "# $ProjectName" >README.md

# Create the .gitignore file
echo "bin/*
./build/*
*.o
*.out
*.exe" >.gitignore

# Run the make command
make
