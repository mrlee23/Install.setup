(require 'ox-publish)
(require 'htmlize)
(defun pages-init (BASE_DIR TARGET_DIR)
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
		   :auto-index t
		   :index-filename "index.org"
		   :index-title "Index"
		   :auto-sitemap t
		   :publishing-directory ,TARGET_DIR
		   :publishing-function org-html-publish-to-html
		   :headline-levels 4
		   :recursive t
		   :auto-preamble nil
		   )
		  ("Install.setup" :components ("Install.setup-static" "Install.setup-org"))
		  )))
(defun pages-publish ()
  (org-publish "LifePlan"))
