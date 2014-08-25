
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

DOCTITLE_TOOL			:= $(BIN_DIR)/doctitle

DEFAULT_TEMPLATE		:= $(TEMPLATES_DIR)/default.html
DEFAULT_INDEX_TEMPLATE	:= $(TEMPLATES_DIR)/default-index.html
ART_DIR					:= art
SCRIPTS_DIR				:= scripts
STYLES_DIR				:= styles

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

# Default Makefile.config file location.
MAKEFILE_CONFIG_FILE	:= $(SITE_CONTENTS_DIR)/Makefile.config

# Include custom configuration.
-include $(MAKEFILE_CONFIG_FILE)

# The articles with their prefix (if there is one).
ARTICLES				:= $(ARTICLES_SRCS:$(ARTICLES_DIR)/%.md=$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html)
PAGES					:= $(PAGES_SRCS:$(PAGES_DIR)/%.md=$(PUBLIC_DIR)$(PAGES_PREFIX)/%.html)

# TODO: Limit file count in output to PAGE_SIZE (head -n $(PAGE_SIZE) outs one file per line).
INDEX_ARTICLES				:= $(shell find $(ARTICLES_DIR) -type f -name '$(FILE_PATTERN)' -print0  2>/dev/null | xargs -0 ls -t | head -n $(PAGE_SIZE))

# Pandoc's variables.
PANDOC_VARS			:= --variable site-title="$(SITE_TITLE)" --variable site-tag="$(SITE_TAG)"

# Stats.
PAGE_COUNT		:= 0
ARTICLE_COUNT	:= 0

# Find files for the index.

.PHONY: all message help test-dirs check-convert-tool config layout

all: message check-convert-tool test-dirs static-resources-links $(PAGES) $(ARTICLES) $(PUBLIC_DIR)/index.html stats

config:
	@echo "SITE_CONTENTS_DIR    = $(SITE_CONTENTS_DIR)"
	@echo "ARTICLES_DIR         = $(ARTICLES_DIR)"
	@echo "PAGES_DIR            = $(PAGES_DIR)"
	@echo "PUBLIC_DIR           = $(PUBLIC_DIR)"
	@echo "STATIC_RESOURCES_DIR = $(STATIC_RESOURCES_DIR)"
	@echo "ART_DIR              = \$$(STATIC_RESOURCES_DIR)/$(ART_DIR)"
	@echo "STYLES_DIR           = \$$(STATIC_RESOURCES_DIR)/$(STYLES_DIR)"
	@echo "SCRIPTS_DIR          = \$$(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR)"
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

layout:
	@echo -n "Creating basic directory layout for a new site... "
	@mkdir -p $(SITE_CONTENTS_DIR) $(PAGES_DIR) $(ARTICLES_DIR)\
		$(PUBLIC_DIR) $(CACHE_DIR) $(STATIC_RESOURCES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(ART_DIR)\
		$(STATIC_RESOURCES_DIR)/$(STYLES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR)
	@echo OK.

message:
	@echo "  SITE    $(SITE_TITLE) -- $(PROJECT)"

help:
	@echo $(PROJECT) $(VERSION) - $(AUTHOR)
	@echo "Really, really simple utility to build static Internet sites."
	@echo "Usage:"
	@echo "    make [target]"
	@echo "Targets:"
	@echo "      all : Builds the full site and/or update all files (default target)."
	@echo "    index : Rebuilds the index (index.html)."
	@echo "   config : Shows the values of the configurable variables."
	@echo "   layout : Creates the basic directory layout for a new site."
	@echo "     help : Shows this help."

test-dirs:
	@test -d $(ARTICLES_DIR) || (echo "ERROR: Site contents directory ($(ARTICLES_DIR)) does not exists." && exit 1)
	@test ! -d $(PUBLIC_DIR) && echo "Site generated contents directory ($(PUBLIC_DIR)) does not exist. Creating..." && mkdir -p $(PUBLIC_DIR) || true
	@test ! -d $(TEMPLATES_DIR) && echo "WARNING: There are not templates." || true
	@test ! -d $(CACHE_DIR) && echo "WARNING: There are not cache directory." || true

check-convert-tool:
	@which $(CONVERT_TOOL) >/dev/null 2>&1 || (echo "ERROR: '$(CONVERT_TOOL)' tool must be installed." && exit 1)

$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html: $(ARTICLES_DIR)/%.md $(TEMPLATE)
	$(eval url := $(shell echo $@ | sed 's/^public//'))
	@echo "  ARTICLE $(url)"
	$(eval doctitle := $(shell $(DOCTITLE_TOOL) $<))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title="$(doctitle)" \
		$(PANDOC_VARS) --output $@ $<
	$(eval ARTICLE_COUNT := $(shell expr $(ARTICLE_COUNT) + 1))

$(PUBLIC_DIR)$(PAGES_PREFIX)/%.html: $(PAGES_DIR)/%.md $(TEMPLATE)
	$(eval url := $(shell echo $@ | sed 's/^public//'))
	@echo "  PAGE    $(url)"
	$(eval doctitle := $(shell $(DOCTITLE_TOOL) $<))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title="$(doctitle)" \
		$(PANDOC_VARS) --output $@ $<
	$(eval PAGE_COUNT := $(shell expr $(PAGE_COUNT) + 1))

$(PUBLIC_DIR)/index.html: $(INDEX_ARTICLES) $(INDEX_TEMPLATE)
	@echo "  HTML    index.html"
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		$(PANDOC_VARS) --template $(INDEX_TEMPLATE) --section-divs \
		--output $@ $(INDEX_ARTICLES)
# Replace <section> with <article> in index.html.
	@sed -re 's/<section(.*)>/<article\1>/g' -e 's/<\/section>/<\/article>/g' -i $@

.PHONY: index static-resources-links monthly-archive categories tags

index: $(PUBLIC_DIR)/index.html

static-resources-links:
	@test ! -L $(PUBLIC_DIR)/$(STYLES_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(STYLES_DIR) $(PUBLIC_DIR)/$(STYLES_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(ART_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(ART_DIR) $(PUBLIC_DIR)/$(ART_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(SCRIPTS_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR) $(PUBLIC_DIR)/$(SCRIPTS_DIR) || true

monthly-archive:
	@echo "Regenerating monthly archive..."

categories:
	@echo "Regenerating categories..."

tags:
	@echo "Regenerating tags..."

.PHONY: clean stats

stats:
	@echo "  STATS   $(PAGE_COUNT) pages, $(ARTICLE_COUNT) articles"

clean:
	@echo "  CLEAN"
	@$(RM) $(PUBLIC_DIR)/* $(CACHE_DIR)/*
