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
	     :exclude "*~")))

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
