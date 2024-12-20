debug ?= 0
NAME := JSH
SRC_DIR := src
BUILD_DIR := build
INCLUDE_DIR := include
TESTS_DIR := tests
BIN_DIR := bin
SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o, $(SRCS)) 
CC := clang
LINTER := clang-tidy
FORMATTER := clang-format
CFLAGS := -std=gnu23 -D _GNU_SOURCE -D __STDC_WANT_LIB_EXT1__ -Wall -Wextra -pedantic -I$(INCLUDE_DIR)
LDFLAGS := -L/opt/homebrew/opt/llvm/lib -lreadline

ifeq ($(debug), 1)
	CFLAGS := $(CFLAGS) -g -O0
else
	CFLAGS := $(CFLAGS) -Oz
endif

$(NAME): format lint dir $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/$@ $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | dir
	$(CC) $(CFLAGS) -o $@ -c $<

lint:
	@$(LINTER) --config-file=.clang-tidy $(SRCS) -- $(CFLAGS)

format:
	@if [ -n "$(SRCS)" ]; then \
		find $(SRC_DIR) -type f -name '*.c' -exec $(FORMATTER) -style=file -i {} +; \
	fi
	@if [ -n "$(wildcard $(INCLUDE_DIR)/*.h)" ]; then \
		find $(INCLUDE_DIR) -type f -name '*.h' -exec $(FORMATTER) -style=file -i {} +; \
	fi


dir:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(BUILD_DIR)/lib

clean:
	@rm -rf $(BUILD_DIR) $(BIN_DIR)

bear:
	bear -- make $(NAME)

.PHONY: lint format check dir clean bear
