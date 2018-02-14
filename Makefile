.PHONY: install test pages

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch
GH_PAGES_DIR=.gh-pages
PUBLISH_PAGES_DIR=.publish
EMACS_DEPS_DIR=.emacs-dependencies
DIST_DIR=dist

install: setup-git mkdirs get-deps

setup-git:
	git submodule update

install-emacs:
	sudo apt update
	sudo apt-get install -y software-properties-common python-software-properties
	sudo apt-add-repository -y ppa:adrozdoff/emacs
	sudo apt update
	sudo apt-get install -y emacs25

mkdirs:
	if [ ! -d "$(EMACS_DEPS_DIR)" ]; then mkdir -p "$(EMACS_DEPS_DIR)"; fi
	if [ ! -d "$(GH_PAGES_DIR)" ]; then mkdir -p "$(GH_PAGES_DIR)"; fi
	if [ ! -d "$(PUBLISH_PAGES_DIR)" ]; then mkdir -p "$(PUBLISH_PAGES_DIR)"; fi
	if [ ! -d "$(DIST_DIR)" ]; then mkdir -p "$(DIST_DIR)"; fi

get-deps:
	sudo apt-get install -y texinfo
	git clone https://github.com/hniksic/emacs-htmlize.git "$(EMACS_DEPS_DIR)/emacs-htmlize"
	git clone https://github.com/mrlee23/org-multilingual.git "$(EMACS_DEPS_DIR)/org-multilingual"
	git clone -b release_9.0.10 https://code.orgmode.org/bzg/org-mode.git "$(EMACS_DEPS_DIR)/org-mode"
	cd "$(EMACS_DEPS_DIR)/org-mode" && make

test:
	echo "No tests."
	echo "HI"

index: mkdirs
	if [ -f "index.org" ]; then mv -f index.org "$(GH_PAGES_DIR)/index.org"; fi
	@$(BATCH) README.org --eval "(progn\
	$$load_paths\
	(require 'org)\
	(org-org-export-to-org)\
	(message \"README.org export to org.\")\
	)"
	mv -f README.org.org index.org
	rm -f README.org

pages: mkdirs pages-deps index
	if [ -d .org-timestamps ]; then rm -rf .org-timestamps; fi
	if [ -f "CNAME" ]; then cp CNAME "$(GH_PAGES_DIR)/CNAME"; fi
	if [ -d "$(DIST_DIR)" ]; then mv -f "$(DIST_DIR)" "$(GH_PAGES_DIR)/$(DIST_DIR)"; fi
	@$(BATCH) --eval "(progn\
	$$load_paths\
	(message \"%s\" load-path)\
	(load-file \"pages.el\")\
	(pages-publish \"./\" \"$(GH_PAGES_DIR)/\" \"$(PUBLISH_PAGES_DIR)\")\
	)"
	for lang in `cat .supportLanguages`; \
	do \
		echo "$$lang" > "$(PUBLISH_PAGES_DIR)/$${lang}/.language"; \
	done;
	find . -d -path "*/$(DIST_DIR)/*/.git" -prune -exec rm -rf {} \;

pages-deps:
	git clone https://github.com/mrlee23/org-html-themes.git $(DIST_DIR)/org-html-themes
	rm -rf dist/org-html-themes/.git

define load_paths
(add-to-list 'load-path "./")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/emacs-htmlize")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/org-multilingual")
(add-to-list 'load-path "$(EMACS_DEPS_DIR)/org-mode/lisp")
endef
define publish_pages

endef
define delete_pages_deps
(when (file-directory-p "$(GH_PAGES_DIR)/$(EMACS_DEPS_DIR)")
	(delete-directory "$(GH_PAGES_DIR)/$(EMACS_DEPS_DIR)" t))
(when (file-directory-p "$(EMACS_DEPS_DIR)")
	(delete-directory "$(EMACS_DEPS_DIR)" t))
endef

export load_paths
export publish_pages
export delete_pages_deps
