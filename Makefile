LEX = flex
YACC = bison
LEX_SRC = $(SRC_DIR)/lexer.l
YACC_SRC = $(SRC_DIR)/parser.y
LEX_OBJ = $(BUILD_DIR)/lexer.o
YACC_OBJ = $(BUILD_DIR)/parser.o
YACC_HEADER = $(INCLUDE_DIR)/parser.h

debug ?= 0
NAME := JSH
SRC_DIR := src
BUILD_DIR := build
INCLUDE_DIR := include
TESTS_DIR := tests
BIN_DIR := bin
SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o, $(SRCS)) $(LEX_OBJ) $(YACC_OBJ)
CC := clang
LINTER := clang-tidy
FORMATTER := clang-format
CFLAGS := -std=gnu23 -D _GNU_SOURCE -D __STDC_WANT_LIB_EXT1__ -Wall -Wextra -pedantic -I$(INCLUDE_DIR)
LDFLAGS := -L/opt/homebrew/opt/llvm/lib -lreadline -lfl

ifeq ($(debug), 1)
	CFLAGS := $(CFLAGS) -g -O0
else
	CFLAGS := $(CFLAGS) -Oz
endif

$(NAME): format lint dir $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/$@ $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | dir
	$(CC) $(CFLAGS) -o $@ -c $<

$(LEX_OBJ): $(LEX_SRC)
    $(LEX) -o $(BUILD_DIR)/lexer.c $(LEX_SRC)
    $(CC) $(CFLAGS) -o $@ -c $(BUILD_DIR)/lexer.c

$(YACC_OBJ): $(YACC_SRC)
    $(YACC) -d -o $(BUILD_DIR)/parser.c $(YACC_SRC)
    mv $(BUILD_DIR)/parser.tab.h $(YACC_HEADER)
    $(CC) $(CFLAGS) -o $@ -c $(BUILD_DIR)/parser.c

lint:
	@$(LINTER) --config-file=.clang-tidy $(SRCS) $(LEX_SRC) $(YACC_SRC) -- $(CFLAGS)

format:
	find $(SRC_DIR) -type f \( -name '*.c' -o -name '*.l' -o -name '*.y' \) -exec $(FORMATTER) -style=file -i {} +

dir:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(BUILD_DIR)/lib

clean:
	@rm -rf $(BUILD_DIR) $(BIN_DIR)

bear:
	bear -- make $(NAME)

.PHONY: lint format check dir clean bear
