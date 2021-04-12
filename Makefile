OUT       := docs
SRC_DIR   := content
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

all: clean rsync $(TARGETS)

rsync:
	@mkdir -p $(OUT)
	@echo "Copying content tree to output directory."
	@rsync -a $(SRC_DIR)/* $(OUT)
	@rsync -a $(SRC_DIR)/.nojekyll $(OUT)

%.html: %.md rsync
	$(call generate_html, $<, $@, $(TEMPLATES)/default.html)

server: rsync
	@python -m http.server --directory $(OUT)

deploy:
	@echo 'TODO: deploy with git push to gihub page'

clean:
	@echo "Cleaning output directory."
	@touch $(OUT) && rm -r $(OUT)

.PHONY: clean
