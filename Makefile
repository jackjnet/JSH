CC := clang
LEX := flex
YACC := bison

SRC_DIR := src
BUILD_DIR := build
BIN_DIR := bin
INCLUDE_DIR := include

LEX_SRC := $(SRC_DIR)/shell.l
YACC_SRC := $(SRC_DIR)/shell.y
YACC_C := $(BUILD_DIR)/y.tab.c
YACC_H := $(BUILD_DIR)/y.tab.h
LEX_C := $(BUILD_DIR)/lex.yy.c
LEX_OBJ := $(BUILD_DIR)/lexer.o
YACC_OBJ := $(BUILD_DIR)/parser.o
C_SRCS := $(wildcard $(SRC_DIR)/*.c)
C_OBJS := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS))
OBJS := $(C_OBJS) $(LEX_OBJ) $(YACC_OBJ)

NAME := jsh

CFLAGS := -std=gnu23 -D _GNU_SOURCE -D __STDC_WANT_LIB_EXT1__ -Wall -Wextra -pedantic -I$(INCLUDE_DIR)
LDFLAGS := -L/opt/homebrew/opt/llvm/lib -lreadline

LINTER := clang-tidy
FORMATTER := clang-format

debug ?= 0
ifeq ($(debug), 1)
	CFLAGS := $(CFLAGS) -g -O0
else
	CFLAGS := $(CFLAGS) -Oz
endif

all: $(BIN_DIR)/$(NAME)

# Build the final binary 
$(BIN_DIR)/$(NAME): $(OBJS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

# Compile C source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile lexer
$(LEX_OBJ): $(LEX_C)
	$(CC) $(CFLAGS) -c $< -o $@

$(LEX_C): $(LEX_SRC) $(YACC_H) | $(BUILD_DIR)
	$(LEX) -o $@ $<

# Compile parser
$(YACC_OBJ): $(YACC_C)
	$(CC) $(CFLAGS) -c $< -o $@

$(YACC_C) $(YACC_H): $(YACC_SRC) | $(BUILD_DIR)
	$(YACC) -d -y -o $(BUILD_DIR)/y.tab.c $(YACC_SRC)


$(BUILD_DIR) $(BIN_DIR):
	@mkdir -p $@

lint:
	@$(LINTER) --config-file=.clang-tidy $(SRCS) $(LEX_SRC) $(YACC_SRC) -- $(CFLAGS)

format:
	find $(SRC_DIR) -type f \( -name '*.c' -o -name '*.l' -o -name '*.y' \) -exec $(FORMATTER) -style=file -i {} +

dir:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(BUILD_DIR)/lib

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

bear:
	bear -- make $(NAME)

.PHONY: lint format check dir clean bear
