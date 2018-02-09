.PHONY: get-deps pages

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch
EMACS_DEPS = $(shell echo $$emacs_deps)

test:
	echo "No tests."

get-deps:
	echo "No dependencies."

pages:
	@$(BATCH) --eval "(progn\
	$$load_paths\
	(load-file \"pages.el\")\
	(pages-init \"./\" \".gh-pages\")\
	(pages-publish)\
	)"

define load_paths
(add-to-list 'load-path "./")
(add-to-list 'load-path "$(EMACS_DEPS)/emacs-htmlize")
endef
export load_paths
