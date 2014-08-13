
PROJECT			:= "FlatPress"
AUTHOR			:= "Diego Lago Gonzalez <diego.lago.gonzalez@gmail.com>"
VERSION			:= "0.1"

CONVERT_TOOL	:= pandoc

PUBLIC_DIR		:= ./public
PRIVATE_DIR		:= ./private
TEMPLATES		:= ./templates
static			:= ./static
FILE_PATTERN	:= *.md

DIR_TREE		:= $(shell find $(PRIVATE_DIR) -type d 2>/dev/null)
SRCS			:= $(foreach dir, $(DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))
HTMLS			:= $(SRCS:$(PRIVATE_DIR)/%.md=$(PUBLIC_DIR)/%.html)

# Configuration overridable:

FROM_FORMAT		:= markdown_github
TO_FORMAT		:= html5
SITE_TITLE		:= \$$TITLE
SITE_TAG		:= \$$TAG

# TODO: Load site's specify config file (with a Makefile.config, for example).
# That configuration should have: site title, site tag, and parts to generate.

.PHONY: all message help test-dirs check-convert-tool config

all: message check-convert-tool test-dirs $(HTMLS) $(PUBLIC_DIR)/index.html monthly-archive categories tags
	@echo Done.

config:
	@echo "PUBLIC_DIR   = $(PUBLIC_DIR)"
	@echo "PRIVATE_DIR  = $(PRIVATE_DIR)"
	@echo "CONVERT_TOOL = $(CONVERT_TOOL)"
	@echo "FROM_FORMAT  = $(FROM_FORMAT)"
	@echo "TO_FORMAT    = $(TO_FORMAT)"
	@echo "SITE_TITLE   = $(SITE_TITLE)"
	@echo "SITE_TAG     = $(SITE_TAG)"

message:
	@echo "Building site '$(SITE_TITLE)' with $(PROJECT)..."

help:
	@echo $(PROJECT) $(VERSION) - $(AUTHOR)
	@echo "Really, really simple utility to build static Internet sites."
	@echo "Usage:"
	@echo "    make [target]"
	@echo "Targets:"
	@echo "     all : Builds the full site and/or update all files (default target)."
	@echo "   index : Rebuilds the index (index.html)."
	@echo "  config : Shows the values of the configurable variables."
	@echo "    help : Shows this help."

test-dirs:
	@test -d $(PRIVATE_DIR) || (echo "ERROR: Site contents directory ($(PRIVATE_DIR)) does not exists." && exit 1)
	@test ! -d $(PUBLIC_DIR) && echo "Site generated contents directory ($(PUBLIC_DIR)) does not exist. Creating..." && mkdir -p $(PUBLIC_DIR) || true
	@test ! -d $(TEMPLATES) && echo "WARNING: There are not templates." || true

check-convert-tool:
	@which $(CONVERT_TOOL) >/dev/null 2>&1 || (echo "ERROR: '$(CONVERT_TOOL)' tool must be installed." && exit 1)

$(PUBLIC_DIR)/%.html: $(PRIVATE_DIR)/%.md
	@echo -n "Building '$@' from '$<'... "
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --output $< $@
	@echo OK

$(PUBLIC_DIR)/index.html: $(HTMLS)
	@echo "Regenerating 'index.html'..."

.PHONY: index

index: $(PUBLIC_DIR)/index.html

monthly-archive:
	@echo "Regenerating monthly archive..."

categories:
	@echo "Regenerating categories..."

tags:
	@echo "Regenerating tags..."

.PHONY: clean

clean:
	@echo "Cleaning site..."
