
CONVERT	:= pandoc

all: check-convert-tool

check-convert-tool:
	@which $(CONVERT) >/dev/null || ( echo "ERROR: '$(CONVERT)' tool must be installed." && exit 1)

.PHONY: clean

clean: