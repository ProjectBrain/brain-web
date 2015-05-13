.PHONY: all build watch

all: build

build:
	node_modules/.bin/webpack

watch:
	node_modules/.bin/webpack --watch
