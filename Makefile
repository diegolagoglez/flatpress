
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

SRCS			:= $(shell find $(PRIVATE) -type f -name $(FILE_PATTERN))
HTMLS			:= $(SRCS:%.md=%.html)

# TODO: Load site's specify config file (with a Makefile.config, for example).
# That configuration should have: site title, site tag, and parts to generate.

all: message check-convert-tool $(HTMLS) index monthly-archive categories tags
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
	@echo "    help : Shows this help."

check-convert-tool:
	@which $(CONVERT) >/dev/null 2>&1 || ( echo "ERROR: '$(CONVERT)' tool must be installed." && exit 1)

%.html: %.md
	@echo -n "Building '$@'... "
	@echo OK

index:
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
