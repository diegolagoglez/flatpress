
TOOL			:= "FlatPress"
AUTHOR			:= "Diego Lago Gonzalez <diego.lago.gonzalez@gmail.com>"
VERSION			:= "0.1"

# TODO: These two variables should be loaded from a configuration file.
SITE_TITLE		:= \$$TITLE
SITE_TAG		:= \$$TAG

CONVERT			:= pandoc

PUBLIC			:= ./public
PRIVATE			:= ./private
TEMPLATES		:= ./templates
FILE_PATTERN	:= *.md

DIR_TREE		:= $(shell find $(PRIVATE) -type d 2>/dev/null)
SRCS			:= $(foreach dir, $(DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))
HTMLS			:= $(SRCS:$(PRIVATE)/%.md=$(PUBLIC)/%.html)

# TODO: Load site's specify config file (with a Makefile.config, for example).
# That configuration should have: site title, site tag, and parts to generate.

.PHONY: all message help test-dirs check-convert-tool

all: message check-convert-tool test-dirs $(HTMLS) $(PUBLIC)/index.html monthly-archive categories tags
	@echo Done.

message:
	@echo "Building site '$(SITE_TITLE)' with $(TOOL)..."

help:
	@echo $(TOOL) $(VERSION) - $(AUTHOR)
	@echo "Really, really simple utility to build static Internet sites."
	@echo "Usage:"
	@echo "    make [target]"
	@echo "Targets:"
	@echo "     all : Builds the full site and/or update all files (default target)."
	@echo "   index : Rebuilds the index (index.html)."
	@echo "    help : Shows this help."

test-dirs:
	@test -d $(PRIVATE) || (echo "ERROR: Site contents directory ($(PRIVATE)) does not exists." && exit 1)
	@test ! -d $(PUBLIC) && echo "Site generated contents directory ($(PUBLIC)) does not exist. Creating..." && mkdir -p $(PUBLIC) || true
	@test ! -d $(TEMPLATES) && echo "WARNING: There are not templates."

check-convert-tool:
	@which $(CONVERT) >/dev/null 2>&1 || (echo "ERROR: '$(CONVERT)' tool must be installed." && exit 1)

$(PUBLIC)/%.html: $(PRIVATE)/%.md
	@echo -n "Building '$@' from '$<'... "
	@echo OK

$(PUBLIC)/index.html: $(HTMLS)
	@echo "Regenerating 'index.html'..."

monthly-archive:
	@echo "Regenerating monthly archive..."

categories:
	@echo "Regenerating categories..."

tags:
	@echo "Regenerating tags..."

.PHONY: clean

clean:
	@echo "Cleaning site..."
