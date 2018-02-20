;;; macro.el --- macros for Linux Commands

;; Copyright (C) 2018 Dongsoo Lee

;; Author: Dongsoo Lee <mrlee603@gmail.com>
;; Maintainer: Dongsoo Lee <mrlee603@gmail.com>
;; Created: 2018-02-20 14:52:52
;; 

;;; Commentary:

;; 

;;; Code:

(require 'seq)

(defun lc-macro/collect-files ()
  (seq-filter
   (lambda (file)
	 (and (string-match "^\\([a-zA-Z0-9-_]+\\)\\.org$" file) (not (equal file "README.org"))))
   (directory-files "./")))

(defun lc-macro/include-progress ()
  (concat
   "|Name|Overview|Install|Usage|Options|See also|\n"
   (mapconcat (lambda (file-name)
				(let ((name (substring file-name 0 -4))
					  (flags '())
					  contents)
				  (with-temp-buffer
					(insert-file-contents file-name)
					(setq contents (buffer-substring-no-properties 1 (point-max))))
				  (and (string-match "^\* Overview\n" contents) (push 'overview flags))
				  (and (string-match "^\*\* Install\n" contents) (push 'install flags))
				  (and (string-match "^\* Usage\n" contents) (push 'usage flags))
				  (and (string-match "^\*\* Options\n" contents) (push 'options flags))
				  (and (string-match "^\* See also\n" contents) (push 'seealso flags))
				  (format "|[[./%s][%s]]|%s|%s|%s|%s|%s"
						  file-name
						  name
						  (if (member 'overview flags) (format "[[./%s#%s][Yes]]" file-name "overview") "No")
						  (if (member 'install flags) (format "[[./%s#%s][Yes]]" file-name "install") "No")
						  (if (member 'usage flags) (format "[[./%s#%s][Yes]]" file-name "usage") "No")
						  (if (member 'options flags) (format "[[./%s#%s][Yes]]" file-name "options") "No")
						  (if (member 'seealso flags) (format "[[./%s#%s][Yes]]" file-name "seealso") "No"))
				  ))
			  (lc-macro/collect-files)
			  "\n")))

(defun lc-macro/include-docs ()
  (mapconcat (lambda (file-name)
			   (let ((name (substring file-name 0 -4)))
				 (format "** %s\n#+INCLUDE: %s :lines \"7-\"" name file-name)
				 ))
			 (lc-macro/collect-files)
			 "\n"))
