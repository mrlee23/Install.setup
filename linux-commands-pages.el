;;; pages.el --- Publish org-mode files to html

;; Copyright (C) 2018 Dongsoo Lee

;; Author: Dongsoo Lee <mrlee603@gmail.com>
;; Maintainer: Dongsoo Lee <mrlee603@gmail.com>
;; Created: 2018-02-11 17:37:43
;; 

;;; Commentary:

;; This codes are part of `LinuxCommands' project.
;; And completely processed html files deploy on `http://linux-command.org/'.
;;
;; If you want to contribute this project, please visit to our github page: `https://github.com/mrlee23/LinuxCommands'.
;; Thanks!
;;

;;; Code:

(require 'linux-commands-core)

(require 'ox-publish)
(require 'htmlize)
(require 'org-multilingual)
(require 'seq)

(defvar pages-timestamp "./org-timestamps/")

(defun pages-publish-to-html (plist filename pub-dir)
  (let (source-filename)
	(when (equal (file-name-base filename) "README")
	  (copy-file filename (setq source-filename (expand-file-name "index.org" (file-name-directory filename))))
	  (setq filename source-filename))
	;; .publish/lang/xxx.org -> .publish/lang/xxx.org multilingual preprocessing
	(setq source-filename (org-multilingual-publish plist filename (file-name-directory filename)))
	(lc-core/init-contents source-filename)
	;; .publish/lang/xxx.org -> .publish/lang/xxx.org.org macro preprocessing
	(org-org-publish-to-org plist source-filename (file-name-directory source-filename))
	;; .publish/lang/xxx.org.org -> .publish/lang/xxx.org move file
	(shell-command-to-string "mv -f \"%s\" \"%s\"" (concat source-filename ".org") source-filename)
	
	;; .publish/lang/xxx.org -> .publish/lang/xxx.org multilingual preprocessing
	(setq source-filename (org-multilingual-publish plist source-filename (file-name-directory source-filename)))
	;; .publish/lang/xxx.org -> .gh-pages/lang/xxx.html export to html
	(org-html-publish-to-html plist source-filename pub-dir)
	))

(defun pages-support-languages ()
  (if (file-exists-p ".supportLanguages")
	  (with-temp-buffer
		(insert-file-contents ".supportLanguages")
		(let (contents data)
		  (setq contents (buffer-substring-no-properties 1 (point-max)))
		  (setq data (split-string contents "\n"))))
	'()))

(defvar pages--multilingual-static-extensions '(html css js png jpg gif mp3 m4a mp4 woff2 woff svg eot ttf otf vcf))
(defun pages--multilingual-init (BASE_DIR TARGET_DIR &optional EXCLUDE_DIR LANG)
  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-timestamp-directory pages-timestamp)
  (unless EXCLUDE_DIR
	(setq EXCLUDE_DIR "\\.git"))
  (lc-core/init-lang LANG)
  (setq org-publish-project-alist
		`(("LinuxCommands-static"
		   :base-directory ,BASE_DIR
		   :base-extension ,(mapconcat 'symbol-name pages--multilingual-static-extensions "\\|")
		   :recursive t
		   :exclude: ,EXCLUDE_DIR
		   :publishing-directory ,(expand-file-name TARGET_DIR)
		   :publishing-function org-publish-attachment
		   )
		  ("LinuxCommands-org"
		   :base-directory ,BASE_DIR
		   :base-extension "org"
		   :auto-index nil
		   :exclude: ,EXCLUDE_DIR
		   :index-filename nil
		   :index-title nil
		   :auto-sitemap nil
		   :publishing-directory ,TARGET_DIR
		   :publishing-function pages-publish-to-html
		   :language ,LANG
		   :override t
		   :headline-levels 4
		   :recursive nil
		   :auto-preamble nil
		   )
		  ("LinuxCommands"
		   :components ("LinuxCommands-static" "LinuxCommands-org"))
		  )))

(defun pages--multilingual-cleanup (dir)
  (message "Cleanup unnecessary files in %s..." dir)
  (shell-command-to-string (format "find \"%s\" -d -name \".*\" -not -path \"%s\" -not -path \"*.git/*\" -exec rm -rf {} \\;" dir dir))
  )

(defun pages-publish (BASE_DIR PAGES_TARGET_DIR PUBLISH_TARGET_DIR)
  (let ((langs (pages-support-languages))
		(orig-dir (expand-file-name "orignal" PUBLISH_TARGET_DIR))
		)
	(when (file-directory-p orig-dir) (delete-directory orig-dir t))
	(make-directory orig-dir t)
	(message "Coping contents %s to %s..." BASE_DIR orig-dir)
	(shell-command-to-string (format "find %s -maxdepth 1 -not -path \"*.git/*\" -not -path \"%s\" -not -path \"%s\" -not -path \"%s\" -exec cp -rf {} \"%s\" \\;" BASE_DIR BASE_DIR PAGES_TARGET_DIR PUBLISH_TARGET_DIR orig-dir))
	(mapcar
	 (lambda (lang)
	   (setq lang (org-multilingual-normalize-code lang))
	   (let* ((orig-lang-dir (expand-file-name (symbol-name lang) PUBLISH_TARGET_DIR))
			  (lang-dir (expand-file-name  (symbol-name lang) PAGES_TARGET_DIR)))
		 (message "Coping contents %s to %s..." orig-dir orig-lang-dir)
		 (copy-directory orig-dir orig-lang-dir t t)
		 (pages--multilingual-init orig-lang-dir lang-dir nil lang)
		 (org-publish "LinuxCommands")
		 (pages--multilingual-cleanup orig-lang-dir)
		 (pages--multilingual-cleanup lang-dir)
		 ))
	 langs)
	))

(provide 'linux-commands-pages)

;;; pages.el ends here
