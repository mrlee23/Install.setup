;;; core.el --- Linux Commands core

;; Copyright (C) 2018 Dongsoo Lee

;; Author: Dongsoo Lee <mrlee603@gmail.com>
;; Maintainer: Dongsoo Lee <mrlee603@gmail.com>
;; Created: 2018-02-20 21:18:00
;; 

;;; Commentary:

;; 

;;; Code:

(defvar lc-core/url "http://linux-command.org")
(defvar lc-core/site-name "Linux Commands")
(defvar lc-core/site-desc "Provides a bunch of standardized documentation for various Linux commands, simple usage and detailed option descriptions, and actual usage examples.")

(defvar lc-core/root-dir nil) ;; git root directory
(defvar lc-core/base-dir nil)
(defvar lc-core/base-url nil)
(defvar lc-core/contents-data '())
(defvar lc-core/language nil)
(defvar lc-core/support-languages nil)
(defvar lc-core/special-files nil)

(defvar lc-core/current-filename nil)
(defvar lc-core/current-relative-filename nil)
(defvar lc-core/current-contents nil)
(defvar lc-core/current-contents-filename nil)

(defun lc-core/init-base (base-dir)
  (setq lc-core/root-dir (substring (shell-command-to-string "git rev-parse --show-toplevel") 0 -1))
  (setq lc-core/base-dir base-dir)
  (setq lc-core/special-files (split-string (shell-command-to-string "cat .specialFiles") "\n"))
  (setq lc-core/contents-data '()))

(defun lc-core/init-lang (lang)
  (setq lc-core/language (format "%s" lang))
  (setq lc-core/base-url (format "%s/%s" lc-core/url lc-core/language))
  (lc-core/set-site-name lang)
  (lc-core/set-site-desc lang))

(defun lc-core/set-site-name (lang)
  (setq lc-core/site-name
		(case lang
		  (en
		   "Linux Commands"
		   )
		  (es
		   "Comandos de Linux"
		   )
		  (ko
		   "리눅스 명령어"
		   )
		  (zh
		   "Linux命令"
		   )
		  (ja
		   "Linuxコマンド"
		   )
		  (t
		   "Linux Commands"))))

(defun lc-core/set-site-desc (lang)
  (setq lc-core/site-desc
		(case lang
		  (en
		   "Provides a bunch of standardized documentation for various Linux commands, simple usage and detailed option descriptions, and actual usage examples."
		   )
		  (es
		   "Proporciona una gran cantidad de documentación estandarizada para varios comandos de Linux, uso simple y descripciones de opciones detalladas, y ejemplos de uso reales."
		   )
		  (ko
		   "다양한 리눅스 명령어의 설치 방법, 간단한 사용법 및 자세한 옵션 설명, 다양한 사용예를 정형화된 문서로 제공합니다."
		   )
		  (zh
		   "它为各种Linux命令提供了一组文档，简单的用法和详细的选项描述以及各种使用示例。"
		   )
		  (ja
		   "様々なLinuxのコマンドのインストール方法、簡単な使い方とオプションの詳細な説明、様々な使用例を定型化された文書で提供します。"
		   )
		  (t
		   "Provides a bunch of standardized documentation for various Linux commands, simple usage and detailed option descriptions, and actual usage examples."))))

(defun lc-core/init-contents (filename)
  (setq filename (expand-file-name filename))
  (setq lc-core/current-filename filename)
  (setq lc-core/current-relative-filename (file-relative-name lc-core/current-filename lc-core/base-dir))
  (ignore-errors
	(setq lc-core/current-contents
		  (with-temp-buffer
			(insert-file-contents filename)
			(org-mode)
			(org-element-parse-buffer)
			))
	(setq lc-core/current-contents-filename filename)
	(lc-core/setup-contents-data lc-core/current-contents)
	))

(defun lc-core/setup-contents-data (contents)
  (let (title author category email
			  (desc '()))
	;; header keywords
	(org-element-map contents 'keyword
	  (lambda (keyword)
		(let ((key (org-element-property :key keyword))
			  (value (org-element-property :value keyword)))
		  (case (intern (upcase key))
			(TITLE
			 (setq title value)
			 )
			(CATEGORY
			 (setq category value)
			 )
			(DESCRIPTION
			 (push value desc)
			 )
			(AUTHOR
			 (setq author value))
			(EMAIL
			 (setq email value)))
		  )
		keyword))
	;; paragraph
	(org-element-map contents 'paragraph
	  (lambda (paragraph)
		(let* ((parent (org-element-property :parent paragraph))
			   (custom-id (ignore-errors (org-element-property :CUSTOM_ID (org-element-property :parent parent))))
			   (contents (caddr paragraph))
			   )
		  (when (and (eq (org-element-type parent) 'section)
					 (stringp custom-id)
					 (stringp contents))
			(case (intern (downcase custom-id))
			  (overview
			   (push contents desc)
			   )
			  (introduction
			   (push contents desc)
			   )
			  )))
		paragraph))

	(delete (assoc lc-core/current-relative-filename lc-core/contents-data) lc-core/contents-data)
	(push `(,lc-core/current-relative-filename . (:title ,title :author ,author :category ,category :email ,email :desc ,(string-join desc "\n")))
		  lc-core/contents-data)
	))

(defun lc-core/get-current-contents-data (key)
  (lc-core/get-contents-data lc-core/current-relative-filename key))

(defun lc-core/get-contents-data (filename key)
  (when (assoc filename lc-core/contents-data)
	(plist-get (cdr (assoc filename lc-core/contents-data)) key)))

(defun lc-core/get-current-contents ()
  (when (and
		 (stringp lc-core/current-contents-filename)
		 (equal lc-core/current-contents-filename buffer-file-name))
	lc-core/current-contents))

(defun lc-core/get-current-language ()
  (if (and (boundp 'lc-core/language)
		   (stringp lc-core/language))
	  (intern lc-core/language)
	nil))

(provide 'linux-commands-core)
