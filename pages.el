(require 'ox-publish)
(require 'htmlize)
(require 'seq)
(defvar pages-timestamp "./org-timestamps/")
(defun pages-init (BASE_DIR TARGET_DIR &optional EXCLUDE_DIR)
  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-timestamp-directory pages-timestamp)
  (unless EXCLUDE_DIR
	(setq EXCLUDE_DIR "\\.git\\|CNAME"))
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
		   :publishing-function org-html-publish-to-html
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
