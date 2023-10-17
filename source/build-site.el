;; Load the publishing system
(require 'ox-publish)

;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "website"
	     :recursive t
	     :base-directory "~/Documents/vishalnarayan.github.io/source"
	     :publishing-directory "~/Documents/vishalnarayan.github.io/docs"
	     :publishing-function 'org-html-publish-to-html
	     :with-author  nil ;; Don't include author name
	     :with-creator nil ;; Include Emacs and Org versions in footer
	     :with-toc t ;; Include a table of contents
	     :section-numbers nil ;; Don't include section numbers
	     :time-stamp-file nil ;; Don't include time stamp in file
	     :exclude "*~")))

;; Get rid of validate link at bottom
(setq org-html-validation-link nil)

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
