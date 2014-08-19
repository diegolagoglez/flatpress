
PROJECT					:= "FlatPress"
AUTHOR					:= "Diego Lago Gonzalez <diego.lago.gonzalez@gmail.com>"
VERSION					:= "0.1"

CONVERT_TOOL			:= pandoc
RM						:= rm -rf

BIN_DIR					:= ./bin
SITE_CONTENTS_DIR		:= ./site
ARTICLES_DIR			:= $(SITE_CONTENTS_DIR)/articles
PAGES_DIR				:= $(SITE_CONTENTS_DIR)/pages
PUBLIC_DIR				:= ./public
TEMPLATES_DIR			:= ./templates
STATIC_RESOURCES_DIR	:= $(SITE_CONTENTS_DIR)/static
CACHE_DIR				:= ./cache

DEFAULT_TEMPLATE		:= $(TEMPLATES_DIR)/default.html
DEFAULT_INDEX_TEMPLATE	:= $(TEMPLATES_DIR)/default-index.html
DEFAULT_ART_DIR			:= art
DEFAULT_SCRIPTS_DIR		:= scripts
DEFAULT_STYLES_DIR		:= styles

PAGES_DIR				:= pages

FILE_PATTERN			:= *.md

ARTICLES_DIR_TREE		:= $(shell find $(ARTICLES_DIR) -type d 2>/dev/null)
ARTICLES_SRCS			:= $(foreach dir, $(ARTICLES_DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))

PAGES_DIR_TREE			:= $(shell find $(PAGES_DIR) -type d 2>/dev/null)
PAGES_SRCS				:= $(foreach dir, $(PAGES_DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))

# Configuration overridable variables:
FROM_FORMAT				:= markdown
TO_FORMAT				:= html5
SITE_TITLE				:= Your site's title
SITE_TAG				:= Your site's tag
PAGE_SIZE				:= 10
PAGE_AUTHOR				:= $(AUTHOR)
TEMPLATE				:= $(DEFAULT_TEMPLATE)
INDEX_TEMPLATE			:= $(DEFAULT_INDEX_TEMPLATE)
ARTICLES_PREFIX			:= /article
PAGE_PREFIX				:=

# Include custom configuration.
-include Makefile.config

# The articles with their prefix (if there is one).
ARTICLES				:= $(ARTICLES_SRCS:$(ARTICLES_DIR)/%.md=$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html)
PAGES_DIR				:= $()

# TODO: Limit file count in output to PAGE_SIZE (head -n $(PAGE_SIZE) outs one file per line).
INDEX_ARTICLES				:= $(shell find $(ARTICLES_DIR) -type f -name '$(FILE_PATTERN)' -print0  2>/dev/null | xargs -0 ls -t | head -n $(PAGE_SIZE))

# Pandoc's variables.
PANDOC_VARS			:= --variable site-title="$(SITE_TITLE)" --variable site-tag="$(SITE_TAG)"

# Find files for the index.

.PHONY: all message help test-dirs check-convert-tool config create-layout

all: message check-convert-tool test-dirs static-resources-links $(ARTICLES) $(PUBLIC_DIR)/index.html
	@echo Done.

config:
	@echo "SITE_CONTENTS_DIR    = $(SITE_CONTENTS_DIR)"
	@echo "ARTICLES_DIR         = $(ARTICLES_DIR)"
	@echo "PAGES_DIR            = $(PAGES_DIR)"
	@echo "PUBLIC_DIR           = $(PUBLIC_DIR)"
	@echo "STATIC_RESOURCES_DIR = $(STATIC_RESOURCES_DIR)"
	@echo "DEFAULT_ART_DIR      = \$$(STATIC_RESOURCES_DIR)/$(DEFAULT_ART_DIR)"
	@echo "DEFAULT_STYLES_DIR   = \$$(STATIC_RESOURCES_DIR)/$(DEFAULT_STYLES_DIR)"
	@echo "DEFAULT_SCRIPTS_DIR  = \$$(STATIC_RESOURCES_DIR)/$(DEFAULT_SCRIPTS_DIR)"
	@echo "TEMPLATE             = $(TEMPLATE)"
	@echo "INDEX_TEMPLATE       = $(INDEX_TEMPLATE)"
	@echo "FROM_FORMAT          = $(FROM_FORMAT)"
	@echo "TO_FORMAT            = $(TO_FORMAT)"
	@echo "SITE_TITLE           = $(SITE_TITLE)"
	@echo "SITE_TAG             = $(SITE_TAG)"
	@echo "PAGE_SIZE            = $(PAGE_SIZE)"
	@echo 'PAGE_AUTHOR          = $(PAGE_AUTHOR)'
	@echo 'ARTICLES_PREFIX      = $(ARTICLES_PREFIX)'
	@echo 'PAGE_PREFIX          = $(PAGE_PREFIX)'

create-layout:
	@echo -n "Creating basic directory layout for a new site... "
	@mkdir -p $(SITE_CONTENTS_DIR) $(ARTICLES_DIR) $(PUBLIC_DIR)\
		$(CACHE_DIR) $(STATIC_RESOURCES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(DEFAULT_ART_DIR)\
		$(STATIC_RESOURCES_DIR)/$(DEFAULT_STYLES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(DEFAULT_SCRIPTS_DIR)
	@echo OK.

message:
	@echo "Building site '$(SITE_TITLE)' with $(PROJECT)..."

help:
	@echo $(PROJECT) $(VERSION) - $(AUTHOR)
	@echo "Really, really simple utility to build static Internet sites."
	@echo "Usage:"
	@echo "    make [target]"
	@echo "Targets:"
	@echo "          all : Builds the full site and/or update all files (default target)."
	@echo "        index : Rebuilds the index (index.html)."
	@echo "       config : Shows the values of the configurable variables."
	@echo "create-layout : Creates the basic directory layout for a new site."
	@echo "         help : Shows this help."

test-dirs:
	@test -d $(ARTICLES_DIR) || (echo "ERROR: Site contents directory ($(ARTICLES_DIR)) does not exists." && exit 1)
	@test ! -d $(PUBLIC_DIR) && echo "Site generated contents directory ($(PUBLIC_DIR)) does not exist. Creating..." && mkdir -p $(PUBLIC_DIR) || true
	@test ! -d $(TEMPLATES_DIR) && echo "WARNING: There are not templates." || true
	@test ! -d $(CACHE_DIR) && echo "WARNING: There are not cache directory." || true

check-convert-tool:
	@which $(CONVERT_TOOL) >/dev/null 2>&1 || (echo "ERROR: '$(CONVERT_TOOL)' tool must be installed." && exit 1)

$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html: $(ARTICLES_DIR)/%.md
	@echo -n "Building article '$@' from '$<'... "
	$(eval doctitle := $(shell $(BIN_DIR)/doctitle $<))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title="$(doctitle)" \
		$(PANDOC_VARS) --output $@ $<
	@echo OK

$(PUBLIC_DIR)$(PAGES_PREFIX)/%.html: $(PAGES_DIR)/%.md
	@echo -n "Building page '$@' from '$<'... "
	$(eval doctitle := $(shell $(BIN_DIR)/doctitle $<))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title="$(doctitle)" \
		$(PANDOC_VARS) --output $@ $<
	@echo OK

$(PUBLIC_DIR)/index.html: $(INDEX_ARTICLES)
	@echo -n "Regenerating index.html... "
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		$(PANDOC_VARS) --template $(INDEX_TEMPLATE) --section-divs \
		--output $@ $(INDEX_ARTICLES)
# Replace <section> with <article> in index.html.
	@sed -re 's/<section(.*)>/<article\1>/g' -e 's/<\/section>/<\/article>/g' -i $@
	@echo OK

.PHONY: index static-resources-links pages monthly-archive categories tags

index: $(PUBLIC_DIR)/index.html

static-resources-links:
	@test ! -L $(PUBLIC_DIR)/$(DEFAULT_STYLES_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(DEFAULT_STYLES_DIR) $(PUBLIC_DIR)/$(DEFAULT_STYLES_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(DEFAULT_ART_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(DEFAULT_ART_DIR) $(PUBLIC_DIR)/$(DEFAULT_ART_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(DEFAULT_SCRIPTS_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(DEFAULT_SCRIPTS_DIR) $(PUBLIC_DIR)/$(DEFAULT_SCRIPTS_DIR) || true

pages:
	@echo "Regenerating pages..."

monthly-archive:
	@echo "Regenerating monthly archive..."

categories:
	@echo "Regenerating categories..."

tags:
	@echo "Regenerating tags..."

.PHONY: clean

clean:
	@echo -n "Cleaning site... "
	@$(RM) $(PUBLIC_DIR)/*
	@echo OK.