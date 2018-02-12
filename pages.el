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

(require 'ox-publish)
(require 'htmlize)
(require 'org-multilingual)
(require 'seq)

(defvar pages-timestamp "./org-timestamps/")

(defun pages-publish-to-html (plist filename pub-dir)
  (setq filename (org-multilingual-publish plist filename pub-dir))
  (org-html-publish-to-html plist filename pub-dir)
  )

(defun pages-support-languages ()
  (if (file-exists-p ".supportLanguages")
	  (with-temp-buffer
		(insert-file-contents ".supportLanguages")
		(let (contents data)
		  (setq contents (buffer-substring-no-properties 1 (point-max)))
		  (setq data (split-string contents "\n"))))
	'()))

(defun pages-init (BASE_DIR TARGET_DIR &optional EXCLUDE_DIR LANG)
  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-timestamp-directory pages-timestamp)
  (unless EXCLUDE_DIR
	(setq EXCLUDE_DIR "\\.git"))
  (setq org-publish-project-alist
		`(("Install.setup-static"
		   :base-directory ,BASE_DIR
		   :base-extension "html\\|css\\|js\\|png\\|jpg\\|gif\\|mp3\\|m4a\\|mp4\\|woff2\\|woff\\|svg\\|eot\\|ttf\\|otf\\|vcf"
		   :recursive t
		   :exclude: ,EXCLUDE_DIR
		   :publishing-directory ,(expand-file-name TARGET_DIR)
		   :publishing-function org-publish-attachment
		   )
		  ("Install.setup-org"
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
		   :headline-levels 4
		   :recursive nil
		   :auto-preamble nil
		   )
		  ("Install.setup" :components ("Install.setup-static" "Install.setup-org"))
		  )))

(defun pages-publish ()
  (org-publish "Install.setup")
  (when (and pages-timestamp (file-directory-p pages-timestamp))
	(delete-directory pages-timestamp t)))


(provide 'pages)

;;; pages.el ends here
