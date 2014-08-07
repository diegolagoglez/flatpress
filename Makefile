
TOOL		:= "FlatPress"
AUTHOR		:= "Diego Lago Gonzalez <diego.lago.gonzalez@gmail.com>"
VERSION		:= "0.1"

CONVERT		:= pandoc

PUBLIC		:= ./public
PRIVATE		:= ./private
TEMPLATES	:= ./templates

all: check-convert-tool

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

.PHONY: clean

clean: