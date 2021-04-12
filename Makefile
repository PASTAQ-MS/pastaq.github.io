OUT       := docs
SRC_DIR   := docs
TEMPLATES := templates
SOURCES   := $(shell find $(SRC_DIR) -name '*.md')
TARGETS   := $(patsubst $(SRC_DIR)%, $(OUT)%, $(patsubst %.md, %.html, $(SOURCES)))

## Generates an HTML file for a given markdown file.
## $(1) Input file
## $(2) Output file
## $(3) Template file
define generate_html
	@echo "Generating:$(2) ($(3) )"
	@pandoc -s $(1) -o $(2) --template=$(strip $(3))
endef

all: $(TARGETS)

%.html: %.md
	$(call generate_html, $<, $@, $(TEMPLATES)/default.html)

server:
	@python -m http.server --directory $(OUT)

deploy:
	@echo 'TODO: deploy with git push to gihub page'
