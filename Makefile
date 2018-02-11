.PHONY: install test pages

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch
EMACS_DEPS_DIR=.emacs-dependencies

install: setup-git get-deps

setup-git:
	git submodule update

install-emacs:
	sudo apt update
	sudo apt-get install -y software-properties-common python-software-properties
	sudo apt-add-repository -y ppa:adrozdoff/emacs
	sudo apt update
	sudo apt-get install -y emacs25

get-deps:
	sudo apt-get install -y texinfo
	mkdir "$(EMACS_DEPS_DIR)"
	git clone https://github.com/hniksic/emacs-htmlize.git "$(EMACS_DEPS_DIR)/emacs-htmlize"
	git clone -b release_9.0.10 https://code.orgmode.org/bzg/org-mode.git "$(EMACS_DEPS_DIR)/org-mode"
	cd "$(EMACS_DEPS_DIR)/org-mode" && make

test:
	echo "No tests."
	echo "HI"

pages:
	rm -rf .org-timestamps
	@$(BATCH) --eval "(progn\
	$$load_paths\
	(message \"%s\" load-path)\
	(load-file \"pages.el\")\
	(pages-init \"./\" \".gh-pages/\")\
	(pages-publish)\
	)"
	rm -rf .gh-pages/$(EMACS_DEPS_DIR)
	rm -rf $(EMACS_DEPS_DIR)

define load_paths
(add-to-list 'load-path "./")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/emacs-htmlize")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/org-mode/lisp")
endef
export load_paths
