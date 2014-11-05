default: build

COFFEE=node_modules/.bin/coffee --js

SRCDIR = src
SRC = $(shell find $(SRCDIR) -type f -name '*.coffee' | sort)
LIBDIR = lib
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

.PHONY: test dev

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	cat JS_LICENSE > "$@"
	$(COFFEE) <"$<" >>"$@"

public/js/main.js: $(shell find $(SRCDIR)/client -type f -name '*.js' | sort)
	@./node_modules/.bin/cjsify -o public/js/main.js lib/client/gleemail.js
	# @./node_modules/.bin/npub prep public/js/main.js

setup:
	npm install

dev:
	node_modules/.bin/cjsify -w -o public/js/main.js src/client/gleemail.coffee

test: build
	@./node_modules/.bin/jasmine-node --coffee spec

build: $(LIB) public/js/main.js
	# @./node_modules/.bin/npub prep src

prepublish:
	# ./node_modules/.bin/npub prep

clean:
	@rm -rf "$(LIBDIR)"
	@rm -f public/js/main.js

# This will fail if there are unstaged changes in the checkout
test-checkout-clean:
	git diff --exit-code

all: setup clean test test-checkout-clean
