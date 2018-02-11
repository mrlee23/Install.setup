.PHONY: install test pages

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch
GH_PAGES_DIR=.gh-pages
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

pages: pages-deps
	rm -rf .org-timestamps
	@$(BATCH) --eval "(progn\
	$$load_paths\
	(message \"%s\" load-path)\
	(load-file \"pages.el\")\
	(pages-init \"./\" \"$(GH_PAGES_DIR)/\")\
	(pages-publish)\
	$$delete_pages_deps\
	)"
	if [ -f "CNAME" ]; then cp CNAME $(GH_PAGES_DIR)/CNAME; fi
	rm -rf $(GH_PAGES_DIR)/$(EMACS_DEPS_DIR)
	rm -rf $(EMACS_DEPS_DIR)

pages-deps:
	git clone https://github.com/mrlee23/org-html-themes.git dist/org-html-themes

define load_paths
(add-to-list 'load-path "./")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/emacs-htmlize")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/org-mode/lisp")
endef
define delete_pages_deps
(when (file-directory-p "$(GH_PAGES_DIR)/$(EMACS_DEPS_DIR)")
	(delete-directory "$(GH_PAGES_DIR)/$(EMACS_DEPS_DIR)" t))
(when (file-directory-p "$(EMACS_DEPS_DIR)")
	(delete-directory "$(EMACS_DEPS_DIR)" t))
endef

export load_paths
export delete_pages_deps
