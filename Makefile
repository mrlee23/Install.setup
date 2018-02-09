.PHONY: get-deps pages

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch

get-deps:
	echo "No dependencies."

pages:
	@$(BATCH) --eval "(progn\
	$$load_paths\
	(load-file \"pages.el\")\
	(pages-init \"./\" \".gh-pages\")
	(pages-publish)
	)"

define load_paths
(add-to-list 'load-path "./")
endef
export load_paths
