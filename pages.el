(require 'ox-publish)
(require 'htmlize)
(require 'seq)
(defun pages-init (BASE_DIR TARGET_DIR)
  (setq org-publish-use-timestamps-flag nil)
  (setq org-publish-project-alist
		`(("Install.setup-static"
		   :base-directory ,BASE_DIR
		   :base-extension "html\\|css\\|js\\|png\\|jpg\\|gif\\|mp3\\|m4a\\|mp4\\|woff2\\|woff\\|svg\\|eot\\|ttf\\|otf\\|vcf"
		   :recursive t
		   :publishing-directory ,(expand-file-name TARGET_DIR)
		   :publishing-function org-publish-attachment
		   )
		  ("Install.setup-org"
		   :base-directory ,BASE_DIR
		   :base-extension "org"
		   :auto-index nil
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
  (org-publish "Install.setup"))
