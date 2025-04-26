;; Load the publishing system
(require 'ox-publish)


;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)



;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "website"
	     :recursive t
	     :base-directory "./content"
	     :publishing-directory "./docs"
	     :publishing-function 'org-html-publish-to-html
	     :with-author  nil ;; Don't include author name
	     :with-creator nil ;; Include Emacs and Org versions in footer
	     :with-toc nil ;; Include a table of contents
	     :section-numbers nil ;; Don't include section numbers
	     :time-stamp-file nil ;; Don't include time stamp in file
	     :exclude "*~"
	     :html-head-include-default-style nil ;; Don't use the default style
             :html-head "<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />
                        <script type=\"text/javascript\" src=\"https://code.jquery.com/jquery-3.6.0.min.js\"></script>" ;; Include jQuery and custom script tag
             :html-preamble nil ;; Remove the preamble (header)
             :html-postamble nil ;; Remove the postamble (footer)
             :with-javascript t ;; Enable JavaScript in Org HTML export
             :with-attributes '("src" "href" "id" "class" "style" "type"))))

;; Get rid of validate link at bottom
(setq org-html-validation-link nil
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head "<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />")

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
