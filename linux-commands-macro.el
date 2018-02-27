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
(require 'subr-x)
(require 'cl)

(defun lc-macro/arg-trim (arg)
  (when (stringp arg)
	(setq arg (string-trim arg))
	(when (equal arg "t")
	  (setq arg t))
	(when (equal arg "")
	  (setq arg nil)))
  arg
  )

(defun lc-macro/gen-heading (name &optional level)
  (unless (numberp level)
	(setq level 1))
  (format "%s %s" (make-string level ?*) name))

(defun lc-macro/gen-properties (cons-data)
  (concat
   ":PROPERTIES:\n"
   (string-join
	(seq-filter
	 (lambda (str) (stringp str))
	 (mapcar
	  (lambda (data)
		(if (cdr data) (format ":%s: %s" (car data) (cdr data)) nil))
	  cons-data))
	"\n")
	 "\n:END:"))

(defun lc-macro/collect-files (&optional recursive with-special-files)
  (let ((cmd (format "find . %s -name \"*.org\" -not -path \"*/.*\""
					 (if (not recursive) "-maxdepth 1" ""))
			 ))
	(seq-filter
	 (lambda (arg)
	   (and (not (eq arg nil))
			(if with-special-files t
			  (not (member arg lc-core/special-files)))))
	 (mapcar
	  (lambda (file)
		(when (> (length file) 0)
		  (file-relative-name (expand-file-name file) lc-core/base-dir)))
	  (split-string (shell-command-to-string cmd) "\n")))))

(defun lc-macro/include-progress ()
  (concat
   "|Name|Overview|Install|Usage|Options|See also|
|-+-+-+-+-+-|\n"
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
		list-data (seq-filter (lambda (str) (stringp str)) list-data)
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
	(if (not contents)
		""
	  (push (lc-core/get-current-contents-data :title) title)
	  (push (lc-core/get-current-contents-data :author) author)
	  (push (lc-core/get-current-contents-data :desc) desc)
	  
	  (push "-" title)
	  (push lc-core/site-name title)
	  (setq title (lc-macro/join-oneline title))
	  (setq desc (lc-macro/join-oneline desc))
	  (setq author (lc-macro/join-oneline author))
	  
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

(defun lc-macro/make-hreflang (lang)
  (if (or (not lc-core/current-filename) (string-match "README\\|index" (file-name-base lc-core/current-filename)))
	  (format "#+HTML_HEAD: <link rel=\"alternate\" href=\"%s/%s/\" hreflang=\"%s\" />" lc-core/url lang lang)
	(format "#+HTML_HEAD: <link rel=\"alternate\" href=\"%s/%s/%s.html\" hreflang=\"%s\" />"
			lc-core/url
			lang
			(file-name-sans-extension lc-core/current-relative-filename)
			lang)))

(defun lc-macro/hreflang ()
  (concat
   "\n"
   (mapconcat
	(lambda (lang)
	  (lc-macro/make-hreflang lang))
	lc-core/support-languages
	"\n")
   "\n"))

(defun lc-macro/make-header (name value &optional cons-flag)
  (if cons-flag
	  `(,name . ,value)
	(format "#+%s: %s" name value)))

(defun lc-macro/header ()
  (let ((headers '()))
	(push (lc-macro/header-language t) headers)
	(concat
	 "\n"
	 (mapconcat
	  (lambda (header)
		(lc-macro/make-header (car header) (cdr header)))
	  (reverse headers)
	  "\n")
	 "\n")))

(defun lc-macro/header-language (&optional cons-flag)
  (lc-macro/make-header "LANGUAGE" lc-core/language cons-flag))

(defun lc-macro/builtin ()
  (case (lc-core/get-current-language)
	(en
	 "This is builtin command.")
	(es
	 "Este es el comando integrado.")
	(ko
	 "기본으로 내장되어 있는 명령어입니다.")
	(zh
	 "它是内置命令。")
	(ja
	 "基本的に内蔵されているコマンドです。")
	(t
	 "This is builtin command.")))

(defun lc-macro/emphasis-version (ver)
  (setq ver (lc-macro/arg-trim ver))
  (setq ver (format "@@html:<span class=\"org-programming-version\">%s</span>@@" ver)))

(defun lc-macro/version (ver)
  (setq ver (lc-macro/arg-trim ver))
  (setq ver (lc-macro/emphasis-version ver))
  (format (case (lc-core/get-current-language)
			(en
			 "This is updated for version %s.")
			(es
			 "Esto se actualiza para la versión %s.")
			(ko
			 "%s 버전을 기준으로 작성되었습니다.")
			(zh
			 "基于版本%s创建。")
			(ja
			 "バージョン%sを基準に作成されました。")
			(t
			 "This is updated for version %s."))
		  ver))

(defun lc-macro/latest-version (ver)
  (setq ver (lc-macro/arg-trim ver))
  (setq ver (lc-macro/emphasis-version ver))
  (format (case (lc-core/get-current-language)
			(en
			 "Currently latest version is %s.")
			(es
			 "Actualmente la última versión es %s.")
			(ko
			 "현재 최신 버전은 %s 입니다.")
			(zh
			 "目前最新版本是%s。")
			(ja
			 "現在の最新バージョンは%sです。")
			(t
			 "Currently latest version is %s."))
		  ver))

(defun lc-macro/see (name)
  (setq name (lc-macro/link name))
  (format (case (lc-core/get-current-language)
			(en
			 "See %s.")
			(es
			 "Ver %s.")
			(ko
			 "%s 문서를 참조하세요.")
			(zh
			 "请参阅%s文章。")
			(ja
			 "%sドキュメントを参照してください。")
			(t
			 "See %s."))
		  name))

(defun lc-macro/link (link &optional name)
  (setq link (lc-macro/arg-trim link))
  (setq name (or (lc-macro/arg-trim name) (replace-regexp-in-string "/" "-" link)))
  (setq link (format "%s/%s.org"
					 (file-relative-name lc-core/base-dir (file-name-directory lc-core/current-filename))
					 link))
  (format "[[%s][%s]]" link name))

(defun lc-macro/image--get-local-path (path)
  (expand-file-name
   (concat (file-name-as-directory (file-relative-name (file-name-base lc-core/current-filename) lc-core/base-dir)) "/" path)
   (expand-file-name "assets/images" lc-core/base-dir)))

(defun lc-macro/image (path &optional name classes align with-meta)
  (setq path (lc-macro/arg-trim path))
  (setq name (or (lc-macro/arg-trim name) (file-name-base path)))
  (setq classes (lc-macro/arg-trim classes))
  (setq align (lc-macro/arg-trim align))
  (setq with-meta (lc-macro/arg-trim with-meta))
  (when (stringp classes)
	(setq classes (split-string classes "[\t ]+")))
  (unless (consp classes)
	(setq classes '()))
  (when (and (stringp align) (equal align "center"))
	(push "center" classes)
	(setq align nil))
  (let* ((cur-name (file-name-base lc-core/current-filename))
		 (base-dir lc-core/base-dir)
		 (dir-path (file-name-as-directory (file-relative-name cur-name base-dir)))
		 (img-path (concat lc-core/url
						   (replace-regexp-in-string "/+" "/" (format "/dist/assets/images/%s/%s" dir-path path))))
		 (img-tag (format "@@html:<img class=\"org-img %s\" src=\"%s\" alt=\"%s\" %s>@@"
						  (mapconcat (lambda (cls) (format "%s" cls)) classes " ")
						  img-path
						  name
						  (if align (format "align=\"%s\"" align) "")))
		 (meta '())
		 ret)
	(setq ret
		  (if (string-match "http[s]?://" name)
			  (format "@@html:<a href=\"%s\">@@%s@@html:</a>@@" name img-tag)
			img-tag))
	(when with-meta
	  (push (format "<meta property=\"og:image\" content=\"%s\">" img-path) meta)
	  (push (format "<meta property=\"twitter:image\" content=\"%s\">" img-path) meta)
	  (push (format "<meta name=\"twitter:image\" content=\"%s\">" img-path) meta)
	  (setq ret (format "\n%s\n\n%s"
						(mapconcat (lambda (str) (format "#+HTML_HEAD: %s" str)) meta "\n")
						ret)))
	(or ret "")
	))

(defun lc-macro/inline-image (path &optional name)
  "If NAME has start http[s]?, treats as link with PATH image."
  (lc-macro/image path name "org-inline-img"))

(defun lc-macro/image-link (path &optional name classes align)
  (lc-macro/link name (lc-macro/image path nil classes align)))

(defun lc-macro/image-inline-link (path &optional name)
  (lc-macro/image-link path name "org-inline-img"))

(defun lc-macro/main-image ()
  (let ((jpg (lc-macro/image--get-local-path "main.jpg"))
		(png (lc-macro/image--get-local-path "main.png"))
		path)
	(if (file-exists-p jpg)
		(setq path jpg)
	  (if (file-exists-p png)
		  (setq path png)))
	(if (and (stringp path) (file-exists-p path))
		(lc-macro/image (file-name-nondirectory path) "main" "main" "right" t) "")))

(defun lc-macro/rss-generator ()
  (let ((files (lc-macro/collect-files t nil)))
	(setq files
		  (mapcar
		   (lambda (file)
			 `(,file . ,(string-to-number (replace-regexp-in-string "\n" "" (shell-command-to-string (format "git log -1 --pretty=\"%%ct\" \"%s\"" (expand-file-name lc-core/root-dir)))))))
		   files))
	(setq files
		  (seq-sort
		   (lambda (a b)
			 (> (cdr a) (cdr b)))
		   files))
	(setq files (mapcar 'car files))
	(concat
	 "\n"
	 (mapconcat
	 (lambda (file)
	   (let ((heading (or (lc-core/get-contents-data file :title) (file-name-sans-extension file)))
			 (pubdate (shell-command-to-string (format "git log -1 --pretty=\"<%%ci>\" \"%s\"" (expand-file-name file lc-core/root-dir)))))
		 (format "%s\n%s\n%s"
				 (lc-macro/gen-heading heading)
				 (lc-macro/gen-properties `((RSS_PERAMLINK . ,(concat heading ".html"))
											(PUBDATE . ,(replace-regexp-in-string "\n" "" pubdate))
											(AUTHOR . ,(lc-core/get-contents-data file :author))
											(EMAIL . ,(lc-core/get-contents-data file :email))
											(CATEGORY . ,(lc-core/get-contents-data file :category))))
				 (or (lc-core/get-contents-data file :desc) ""))
	   ))
	 files
	 "\n")
	 "\n")))

(provide 'linux-commands-macro)
