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

(defun lc-macro/include-docs ()
  (mapconcat (lambda (dir-name)
			   (let ((name (substring dir-name 0 -4)))
				 (format "** %s\n#+INCLUDE: %s :lines \"7-\"" name dir-name)
				 ))
			 (seq-filter
			  (lambda (dir)
				(and (string-match "^\\([a-zA-Z0-9-_]+\\)\\.org$" dir) (not (equal dir "README.org"))))
			  (directory-files "./"))
			 "\n"))
