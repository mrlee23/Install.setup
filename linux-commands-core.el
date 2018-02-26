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

(defvar lc-core/base-dir nil)
(defvar lc-core/base-url nil)
(defvar lc-core/language nil)
(defvar lc-core/support-languages nil)

(defvar lc-core/current-filename nil)
(defvar lc-core/current-contents nil)
(defvar lc-core/current-contents-filename nil)

(defun lc-core/init-base (base-dir)
  (setq lc-core/base-dir base-dir))

(defun lc-core/init-lang (lang)
  (setq lc-core/language (format "%s" lang))
  (setq lc-core/base-url (format "%s/%s" lc-core/url lc-core/language))
  (lc-core/set-site-name lang))

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

(defun lc-core/init-contents (filename)
  (setq filename (expand-file-name filename))
  (setq lc-core/current-filename filename)
  (ignore-errors
	(setq lc-core/current-contents
		  (with-temp-buffer
			(insert-file-contents filename)
			(org-mode)
			(org-element-parse-buffer)
			))
	(setq lc-core/current-contents-filename filename)
	))

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
