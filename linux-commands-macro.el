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
(require 'cl)

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
				  (and (string-match "^\* \\(Overview\\|Visión de conjunto\\|개요\\|摘要\\|概要\\)\n" contents) (push 'overview flags))
				  (and (string-match "^\*\* \\(Install\\|Instalar\\|설치\\|安装\\|インストール\\)\n" contents) (push 'install flags))
				  (and (string-match "^\* \\(Usage\\|Uso\\|사용법\\|如何使用\\|命令説明\\)\n" contents) (push 'usage flags))
				  (and (string-match "^\*\* \\(Options\\|Opciones\\|옵션\\|选项\\|オプション\\)\n" contents) (push 'options flags))
				  (and (string-match "^\* \\(See also\\|Ver también\\|관련 항목\\|相关主题\\|関連項目\\)\n" contents) (push 'seealso flags))
				  (format "|[[./%s][%s]]|%s|%s|%s|%s|%s|"
						  file-name
						  name
						  (if (member 'overview flags) (format "[[file:%s::#%s][Yes]]" file-name "overview") "No")
						  (if (member 'install flags) (format "[[file:%s::#%s][Yes]]" file-name "install") "No")
						  (if (member 'usage flags) (format "[[file:%s::#%s][Yes]]" file-name "usage") "No")
						  (if (member 'options flags) (format "[[file:%s::#%s][Yes]]" file-name "options") "No")
						  (if (member 'seealso flags) (format "[[file:%s::#%s][Yes]]" file-name "seealso") "No"))
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

(defun lc-macro/join-oneline (list-data)
  (setq list-data (reverse list-data)
		list-data (mapconcat (lambda (str) str) list-data " ")
		list-data (replace-regexp-in-string "\n" " " list-data)
		list-data (replace-regexp-in-string "[ ]+" " " list-data)))

(defun lc-macro/meta ()
  (unless (fboundp 'lc-core/get-current-contents)
	(load-file "./linux-commands-core.el"))
  (let ((contents (lc-core/get-current-contents)
				  )
		(keywords '("TITLE" "AUTHOR" "DATE" "DESCRIPTION"))
		(title '())
		(desc '())
		(author '())
		(meta '()))
	(when contents
	  (org-element-map contents 'keyword
		(lambda (keyword)
		  (let ((key (org-element-property :key keyword))
				(value (org-element-property :value keyword)))
			(when (member key keywords)
			  (case (intern key)
				(TITLE
				 (push value title)
				 )
				(DESCRIPTION
				 (push value desc)
				 )
				(AUTHOR
				 (push value author)))
			  ))
		  keyword))
	  (org-element-map contents 'paragraph
		(lambda (paragraph)
		  (let ((custom-id (ignore-errors (org-element-property :CUSTOM_ID (org-element-property :parent (org-element-property :parent paragraph)))))
				)
			(when (equal custom-id "overview")
			  (push (car (org-element-contents paragraph)) desc))
			)))
	  (push "-" title)
	  (push lc-core/site-name title)
	  (setq title (lc-macro/join-oneline title))
	  (setq desc (lc-macro/join-oneline desc))
	  (setq author (lc-macro/join-oneline author))
	  (message "%s" buffer-file-name)
	  (message "%s" desc)
	  
	  (push (format "<meta name=\"title\" content=\"%s\">" title) meta)
	  (push (format "<meta name=\"description\" content=\"%s\">" desc) meta)
	  (push (format "<meta name=\"by\" content=\"%s\">" author) meta)
	  (push (format "<meta property=\"og:type\" content=\"article\">") meta)
	  (push (format "<meta property=\"og:title\" content=\"%s\">" title) meta)
	  (push (format "<meta property=\"og:description\" content=\"%s\">" desc) meta)
	  (push (format "<meta name=\"twitter:title\" content=\"%s\">" title) meta)
	  (push (format "<meta name=\"twitter:description\" content=\"%s\">" desc) meta)

	  (when (and (boundp 'lc-core/language)
				 (stringp 'lc-core/language))
		(push (format "<meta http-equiv=\"Content-Language\" content=\"%s\">" lc-core/language) meta))

	  (when (and (boundp 'lc-core/site-name)
				 (stringp 'lc-core/site-name))
		(push (format "<meta name=\"article:media_name\" content=\"%s\">" lc-core/site-name) meta)
		(push (format "<meta property=\"og:site_name\" content=\"%s\">" lc-core/site-name) meta)
		(push (format "<meta name=\"twitter:site\" content=\"%s\">" lc-core/site-name) meta))
	  
	  (when (and (boundp 'lc-core/base-url)
				 (stringp 'lc-core/base-url))
		(push (format "<meta name=\"article:pc_service_home\" content=\"%s\">" lc-core/base-url) meta)
		(push (format "<meta name=\"article:mobile_service_home\" content=\"%s\">" lc-core/base-url) meta))

	  (concat "\n"
			  (mapconcat (lambda (metadata)
						   (format "#+HTML_HEAD: %s" metadata))
						 (reverse meta)
						 "\n")
			  "\n")
	  )))

(provide 'linux-commands-macro)
