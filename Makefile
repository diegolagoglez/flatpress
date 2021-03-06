
PROJECT					= "FlatPress"
AUTHOR					= "Diego Lago Gonzalez <diego.lago.gonzalez@gmail.com>"
VERSION					= "0.1"

CONVERT_TOOL			= pandoc
RM						= rm -rf

BIN_DIR					= ./bin
SITE_DIR				= ./site
SITE_CONTENTS_DIR		= ./site/contents
ARTICLES_DIR			= $(SITE_CONTENTS_DIR)/articles
PAGES_DIR				= $(SITE_CONTENTS_DIR)/pages
ASIDE_DIR				= $(SITE_CONTENTS_DIR)/aside
PUBLIC_DIR				= ./public
TEMPLATES_DIR			= ./templates
STATIC_RESOURCES_DIR	= $(SITE_DIR)/static
CACHE_DIR				= ./cache
STATIC_INDEX			= $(SITE_CONTENTS_DIR)/index.md
PAGES_MENU_SRC_FILE		= $(CACHE_DIR)/pages-menu.md
PAGES_MENU_FILE			= $(CACHE_DIR)/pages-menu.html
BLOG_PAGES_SRCS				= 
BLOG_PAGER_FILE				= $(CACHE_DIR)/pager.html

DOCTITLE_TOOL			= $(BIN_DIR)/doctitle
DIRTREE_TOOL			= $(BIN_DIR)/dirtree2md
TAGWRAPPER_TOOL			= $(BIN_DIR)/tagwrapper

DEFAULT_TEMPLATE		= $(TEMPLATES_DIR)/default.html
DEFAULT_INDEX_TEMPLATE	= $(TEMPLATES_DIR)/default-index.html
DEFAULT_ASIDE_TEMPLATE	= $(TEMPLATES_DIR)/default-aside.html
ART_DIR					= art
SCRIPTS_DIR				= scripts
STYLES_DIR				= styles
FONTS_DIR				= fonts
DEFAULT_DATE_FORMAT		= "+%Y-%m-%d"
DEFAULT_TIME_FORMAT		= "+%H:%M:%S"

FILE_PATTERN			= *.md

ARTICLES_DIR_TREE		= $(shell find $(ARTICLES_DIR) -type d 2>/dev/null)
ARTICLES_SRCS			= $(foreach dir, $(ARTICLES_DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))

PAGES_DIR_TREE			= $(shell find $(PAGES_DIR) -type d 2>/dev/null)
PAGES_SRCS				= $(foreach dir, $(PAGES_DIR_TREE), $(wildcard $(dir)/$(FILE_PATTERN)))

ASIDE_EXISTS			= $(shell test -d $(ASIDE_DIR) && echo yes)
ifeq ($(ASIDE_EXISTS),yes)
ASIDE_SRCS				= $(shell find $(ASIDE_DIR) -type f 2>/dev/null | sort)
ASIDE_FILE				= $(CACHE_DIR)/aside.html
else
ASIDE_SRCS				=
ASIDE_FILE				=
endif

# Configuration overridable variables:
FROM_FORMAT				= markdown
TO_FORMAT				= html5
SITE_TITLE				= Your site's title
SITE_TAG				= Your site's tag
PAGE_SIZE				= 10
PAGE_AUTHOR				= $(AUTHOR)
TEMPLATE				= $(DEFAULT_TEMPLATE)
INDEX_TEMPLATE			= $(DEFAULT_INDEX_TEMPLATE)
ASIDE_TEMPLATE			= $(DEFAULT_ASIDE_TEMPLATE)
SITE_PREFIX				=
ARTICLES_PREFIX			= /article
PAGE_PREFIX				=
INCLUDE_PAGE_MENU		= yes
DATE_FORMAT				= $(DEFAULT_DATE_FORMAT)
TIME_FORMAT				= $(DEFAULT_TIME_FORMAT)
INCLUDE_ASIDE			= yes
INCLUDE_ASIDE_IN_INDEX	= yes
INCLUDE_IN_HEADER		=

# If there is an index file (index.md) into site's contents directory, do not
# generate an index.md and index.html with articles, use a static index page.
IS_THERE_INDEX			= $(shell test -f $(STATIC_INDEX) && echo yes)

# Default Makefile.config file location.
MAKEFILE_CONFIG_FILE	= $(SITE_DIR)/Makefile.config

# Include custom configuration.
-include $(MAKEFILE_CONFIG_FILE)

# The articles with their prefix (if there is one).
ARTICLES				= $(ARTICLES_SRCS:$(ARTICLES_DIR)/%.md=$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html)
PAGES					= $(PAGES_SRCS:$(PAGES_DIR)/%.md=$(PUBLIC_DIR)$(PAGES_PREFIX)/%.html)

# Find files for the index.
INDEX_ARTICLES			= $(shell find $(ARTICLES_DIR) -type f -name '$(FILE_PATTERN)' -print0 2>/dev/null | xargs -0 ls -t | head -n $(PAGE_SIZE))

GEN_DATE				= $(shell date $(DATE_FORMAT))
GEN_TIME				= $(shell date $(TIME_FORMAT))

# Pandoc's variables.
PANDOC_VARS				= --variable site-title="$(SITE_TITLE)" --variable site-tag="$(SITE_TAG)"\
	--variable gen-date=$(GEN_DATE) --variable gen-time=$(GEN_TIME)
PANDOC_VARS_INDEX		= --variable site-title="$(SITE_TITLE)" --variable site-tag="$(SITE_TAG)"\
	--variable gen-date=$(GEN_DATE) --variable gen-time=$(GEN_TIME)
PANDOC_VARS_PAGES		=
PANDOC_VARS_ARTICLES	=

ifneq ($(INCLUDE_IN_HEADER),)
PANDOC_VARS				+= --include-in-header $(INCLUDE_IN_HEADER)
endif

ifneq ($(INCLUDE_PAGE_MENU),)
PANDOC_VARS_INDEX		+= --include-before-body $(PAGES_MENU_FILE)
PANDOC_VARS_PAGES		+= --include-before-body $(PAGES_MENU_FILE)
PANDOC_VARS_ARTICLES	+= --include-before-body $(PAGES_MENU_FILE)
endif

ifeq ($(INCLUDE_ASIDE),yes)
ifeq ($(ASIDE_EXISTS),yes)
PANDOC_VARS_PAGES		+= --include-after-body $(ASIDE_FILE)
PANDOC_VARS_ARTICLES	+= --include-after-body $(ASIDE_FILE)
endif
endif

ifeq ($(INCLUDE_ASIDE_IN_INDEX),yes)
ifeq ($(ASIDE_EXISTS),yes)
PANDOC_VARS_INDEX		+= --include-after-body $(ASIDE_FILE)
endif
endif

# Stats.
PAGE_COUNT			= 0
ARTICLE_COUNT		= 0
PAGE_FILE_PREFIX	= page-

SHELL				= /bin/bash

.PHONY: all message help test-dirs check-convert-tool config layout

all: message check-convert-tool test-dirs static-resources-links $(PAGES_MENU_FILE) $(PUBLIC_DIR)/index.html $(PAGES) $(ARTICLES) stats

# Show configuration variables (overridable by Makefile.config).
config:
	@echo "SITE_DIR               = $(SITE_DIR)"
	@echo "SITE_CONTENTS_DIR      = $(SITE_CONTENTS_DIR)"
	@echo "ARTICLES_DIR           = $(ARTICLES_DIR)"
	@echo "PAGES_DIR              = $(PAGES_DIR)"
	@echo "PUBLIC_DIR             = $(PUBLIC_DIR)"
	@echo "STATIC_RESOURCES_DIR   = $(STATIC_RESOURCES_DIR)"
	@echo "ART_DIR                = $(STATIC_RESOURCES_DIR)/$(ART_DIR)"
	@echo "STYLES_DIR             = $(STATIC_RESOURCES_DIR)/$(STYLES_DIR)"
	@echo "SCRIPTS_DIR            = $(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR)"
	@echo "FONTS_DIR              = $(STATIC_RESOURCES_DIR)/$(FONTS_DIR)"
	@echo "TEMPLATE               = $(TEMPLATE)"
	@echo "INDEX_TEMPLATE         = $(INDEX_TEMPLATE)"
	@echo "ASIDE_EXISTS           = $(ASIDE_EXISTS)"
	@echo "ASIDE_TEMPLATE         = $(ASIDE_TEMPLATE)"
	@echo "ASIDE_FILE             = $(ASIDE_FILE)"
	@echo "FROM_FORMAT            = $(FROM_FORMAT)"
	@echo "TO_FORMAT              = $(TO_FORMAT)"
	@echo "SITE_TITLE             = $(SITE_TITLE)"
	@echo "SITE_TAG               = $(SITE_TAG)"
	@echo "PAGE_SIZE              = $(PAGE_SIZE)"
	@echo 'PAGE_AUTHOR            = $(PAGE_AUTHOR)'
	@echo 'SITE_PREFIX            = $(SITE_PREFIX)'
	@echo 'ARTICLES_PREFIX        = $(ARTICLES_PREFIX)'
	@echo 'PAGE_PREFIX            = $(PAGE_PREFIX)'
	@echo "INCLUDE_PAGE_MENU      = $(INCLUDE_PAGE_MENU)"
	@echo "INCLUDE_ASIDE          = $(INCLUDE_ASIDE)"
	@echo "INCLUDE_ASIDE_IN_INDEX = $(INCLUDE_ASIDE_IN_INDEX)"
	@echo "INCLUDE_IN_HEADER      = $(INCLUDE_IN_HEADER)"
	@echo "PAGES_MENU_FILE        = $(PAGES_MENU_FILE)"
	@echo "DATE_FORMAT            = $(DATE_FORMAT)"
	@echo "TIME_FORMAT            = $(TIME_FORMAT)"

config-all: config
	@echo
	@echo "PAGES_DIR_TREE       = $(PAGES_DIR_TREE)"
	@echo "PAGES_SRCS           = $(PAGES_SRCS)"
	@echo "PAGES                = $(PAGES)"
	@echo "ARTICLES_DIR_TREE    = $(ARTICLES_DIR_TREE)"
	@echo "ARTICLES_SRCS        = $(ARTICLES_SRCS)"
	@echo "ARTICLES             = $(ARTICLES)"
	@echo "ASIDE_SRCS           = $(ASIDE_SRCS)"
	@echo "INDEX_ARTICLES       = $(INDEX_ARTICLES)"
	@echo "GEN_DATE             = $(GEN_DATE)"
	@echo "GEN_TIME             = $(GEN_TIME)"
	@echo "PANDOC_VARS          = $(PANDOC_VARS)"
	@echo "PANDOC_VARS_INDEX    = $(PANDOC_VARS_INDEX)"
	@echo "PANDOC_VARS_ARTICLES = $(PANDOC_VARS_ARTICLES)"
	@echo "PANDOC_VARS_PAGES    = $(PANDOC_VARS_PAGES)"

# Create site's default directory layout.
layout:
	@echo -n "Creating basic directory layout for a new site... "
	@mkdir -p $(SITE_DIR) $(SITE_CONTENTS_DIR) $(PAGES_DIR) $(ARTICLES_DIR)\
		$(PUBLIC_DIR) $(CACHE_DIR) $(STATIC_RESOURCES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(ART_DIR)\
		$(STATIC_RESOURCES_DIR)/$(STYLES_DIR)\
		$(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR)
	@echo OK.

# Print a message.
message:
	@echo "  SITE    $(SITE_TITLE) -- $(PROJECT)"

# Show help.
help:
	@echo $(PROJECT) $(VERSION) - $(AUTHOR)
	@echo "Really, really simple utility to build static Internet sites."
	@echo "Usage:"
	@echo "    make [target]"
	@echo "Targets:"
	@echo "       all : Builds the full site and/or update all files (default target)."
	@echo "     index : Rebuilds the index (index.html)."
	@echo "    config : Shows the values of the configurable variables."
	@echo "config-all : Shows the values of the configurable variables and generated variables."
	@echo "    layout : Creates the basic directory layout for a new site."
	@echo "      help : Shows this help."

# Check directory existence.
test-dirs:
	@test -d $(SITE_DIR) || (echo "ERROR: Site base directory ($(SITE_DIR)) does not exists." && exit 1)
	@test -d $(SITE_CONTENTS_DIR) || (echo "ERROR: Site contents directory ($(SITE_CONTENTS_DIR)) does not exists." && exit 1)
	@test ! -d $(PUBLIC_DIR) && echo "Site generated contents directory ($(PUBLIC_DIR)) does not exist. Creating..." && mkdir -p $(PUBLIC_DIR) || true
	@test ! -d $(TEMPLATES_DIR) && echo "WARNING: There are not templates." || true
	@test ! -d $(CACHE_DIR) && echo "WARNING: There are not cache directory." || true

# Check convert tool (pandoc) existence.
check-convert-tool:
	@which $(CONVERT_TOOL) >/dev/null 2>&1 || (echo "ERROR: '$(CONVERT_TOOL)' tool must be installed." && exit 1)

# Articles generation.
$(PUBLIC_DIR)$(ARTICLES_PREFIX)/%.html: $(ARTICLES_DIR)/%.md $(PAGES_MENU_FILE) $(TEMPLATE) $(ASIDE_FILE)
	$(eval url = $(shell echo $@ | sed 's/^public//'))
	@echo "  ARTICLE $(url)"
	$(eval doctitle = $(shell $(DOCTITLE_TOOL) $<))
	$(eval filetimestamp = $(shell stat -c %y $< | cut -d'.' -f1))
	$(eval date = $(shell date -d "$(filetimestamp)" $(DATE_FORMAT)))
	$(eval time = $(shell date -d "$(filetimestamp)" $(TIME_FORMAT)))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title='$(doctitle)' \
		--variable date='$(date)' --variable time='$(time)'\
		$(PANDOC_VARS) $(PANDOC_VARS_ARTICLES) --output $@ $<
	$(eval ARTICLE_COUNT = $(shell expr $(ARTICLE_COUNT) + 1))

# Pages generation.
$(PUBLIC_DIR)$(PAGES_PREFIX)/%.html: $(PAGES_DIR)/%.md $(PAGES_MENU_FILE) $(TEMPLATE) $(ASIDE_FILE)
	$(eval url = $(shell echo $@ | sed 's/^public//'))
	@echo "  PAGE    $(url)"
	$(eval doctitle = $(shell $(DOCTITLE_TOOL) $<))
	$(eval filetimestamp = $(shell stat -c %y $< | cut -d'.' -f1))
	$(eval date = $(shell date -d "$(filetimestamp)" $(DATE_FORMAT)))
	$(eval time = $(shell date -d "$(filetimestamp)" $(TIME_FORMAT)))
	@mkdir -p $(dir $@)
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(TEMPLATE) --variable title='$(doctitle)' \
		--variable date='$(date)' --variable time='$(time)'\
		$(PANDOC_VARS) $(PANDOC_VARS_PAGES) --output $@ $<
	$(eval PAGE_COUNT = $(shell expr $(PAGE_COUNT) + 1))

# Index generation (markdown; cached).
$(CACHE_DIR)/index.md: $(INDEX_ARTICLES)
ifeq ($(IS_THERE_INDEX),)
	@echo "  GEN     $@"
	@$(DOCTITLE_TOOL) -p $(ARTICLES_PREFIX) -b -f -a $(ARTICLES_DIR) $(INDEX_ARTICLES) > $@
else
	@echo "  LINK    .$(STATIC_INDEX) -> $@"
	@ln -s .$(STATIC_INDEX) $@
endif

# Public index generation.
$(PUBLIC_DIR)/index.html: $(CACHE_DIR)/index.md $(PAGES_SRCS) $(INDEX_TEMPLATE) $(PAGES_MENU_FILE) $(ASIDE_FILE)
	@echo "  HTML    $@"
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT) --standalone \
		--template $(INDEX_TEMPLATE) --section-divs \
		$(PANDOC_VARS) $(PANDOC_VARS_INDEX)\
		--output $@ $(CACHE_DIR)/index.md
# Replace <section> with <article> in index.html.
	@sed -re 's/<section(.*)>/<article\1>/g' -e 's/<\/section>/<\/article>/g' -i $@

# Pager generation (a list with links to pages).
$(BLOG_PAGER_FILE):
	@echo "  GEN     $@"
	$(eval total = $(shell echo $(ARTICLES) | xargs -n $(PAGE_SIZE) | wc -l))
	@echo "<ul class=\"pager\">" > $@
	@echo "<li><a href=\"/index.html\">$$i</a></li>" >> $@
	$(eval BLOG_PAGES_SRCS += $(shell for i in $$(seq 1 $(total)); do\
		echo page-$$i.md;\
		echo "<li><a href=\"/page-$$i.html\">$$i</a></li>" >> $@;\
	done))
	@echo "</ul>" >> $@

# Blog pages generation.
$(BLOG_PAGES_SRCS): $(ARTICLES_SRCS) $(BLOG_PAGER_FILE)
	@count=1
	@echo $(ARTICLES_SRCS) | xargs -n $(PAGE_SIZE) echo |\
		while read -r REPLY; do\
			let 'count+=1';\
			file=$(PAGE_FILE_PREFIX)$$count.md;\
			echo "  GEN     $$file";\
			$(DOCTITLE_TOOL) -p $(ARTICLES_PREFIX) -b -f -a $(ARTICLES_DIR) $$REPLY >> $(CACHE_DIR)/$$file;\
		done

pages: $(BLOG_PAGER_FILE) $(BLOG_PAGES_SRCS)
	@echo $(BLOG_PAGES_SRCS)

$(PUBLIC_DIR)/page-%.html: $(CACHE_DIR)/page-%.md
	@echo "  HTML    $@"

# Aside data generation (from files).
$(CACHE_DIR)/aside.md: $(ASIDE_SRCS)
	@echo "  GEN     $@"
	@cat $(ASIDE_SRCS) > $@

# Aside files generation (if any).
$(ASIDE_FILE): $(CACHE_DIR)/aside.md
	@echo "  HTML    $@"
	@$(CONVERT_TOOL) --from=$(FROM_FORMAT) --to=$(TO_FORMAT)\
		--template $(ASIDE_TEMPLATE) --output $@ $<

.PHONY: index static-resources-links monthly-archive categories tags

# Alias for public/index.html
index: $(PUBLIC_DIR)/index.html

# Pages menu generation (markdown; cached).
$(PAGES_MENU_SRC_FILE): $(PAGES_SRCS)
ifneq ($(INCLUDE_PAGE_MENU),)
	@echo "  GEN     $@"
	@$(DIRTREE_TOOL) -l -b $(PAGES_DIR) -f > $@
endif

# Pages menu generation (to include in index, pages and articles).
$(PAGES_MENU_FILE): $(PAGES_MENU_SRC_FILE)
ifneq ($(INCLUDE_PAGE_MENU),)
	@echo "  HTML    $@"
	@$(CONVERT_TOOL) -f markdown -t html5 $< | $(TAGWRAPPER_TOOL) -t "<nav>" > $@
endif

# Links from resources (from site) directories to public directory.
static-resources-links:
	@test ! -L $(PUBLIC_DIR)/$(STYLES_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(STYLES_DIR) $(PUBLIC_DIR)/$(STYLES_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(ART_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(ART_DIR) $(PUBLIC_DIR)/$(ART_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(SCRIPTS_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(SCRIPTS_DIR) $(PUBLIC_DIR)/$(SCRIPTS_DIR) || true
	@test ! -L $(PUBLIC_DIR)/$(FONTS_DIR) &&\
		ln -s .$(STATIC_RESOURCES_DIR)/$(FONTS_DIR) $(PUBLIC_DIR)/$(FONTS_DIR) || true

monthly-archive:
	@echo "Regenerating monthly archive..."

categories:
	@echo "Regenerating categories..."

tags:
	@echo "Regenerating tags..."

.PHONY: clean stats

# Show generation stats.
stats:
	@echo "  STATS   $(PAGE_COUNT) pages, $(ARTICLE_COUNT) articles"

clean-public:
	@echo "  CLEAN   $(PUBLIC_DIR)"
	@$(RM) $(PUBLIC_DIR)/*

clean-cache:
	@echo "  CLEAN   $(CACHE_DIR)"
	@$(RM) $(CACHE_DIR)/*

# Clean (remove public and cache directory contents).
clean: clean-public clean-cache
