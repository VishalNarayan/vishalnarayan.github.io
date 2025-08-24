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




;; AI added the following lines
;; This is for adding lazy loading tags to the html, so that the page
;; doesn't error out when loading on mobile devices. 

;;; --- Post-write HTML patcher (runs after org writes the .html) ---

(defun my-site--patch-html-string (s)
  "Lightweight HTML rewrites to improve mobile stability/perf."
  (let* ((case-fold-search t) ;; be liberal about case
         (html s))

    ;; 0) Remove jQuery include(s)
    (setq html (replace-regexp-in-string
                "<script[^>]*jquery[^>]*>\\(.\\|\n\\)*?</script>\\s*" "" html t))
    (setq html (replace-regexp-in-string
                "<script[^>]*jquery[^>]*/>\\s*" "" html t))

    ;; --- IMG: add lazy/async (idempotent) ---

    ;; Remove any existing loading/decoding so we can re-insert cleanly
    (setq html (replace-regexp-in-string "\\s+loading=\"[^\"]*\"" "" html t))
    (setq html (replace-regexp-in-string "\\s+decoding=\"[^\"]*\"" "" html t))

    ;; Insert after the <img
    ;; Works for <img ...> and <img .../>
    (setq html (replace-regexp-in-string
                "<img\\([^>]*\\)>"
                "<img loading=\"lazy\" decoding=\"async\"\\1>"
                html t))

    ;; --- VIDEO: preload none + playsinline ---

    ;; Strip any existing preload/playsinline to avoid duplicates
    (setq html (replace-regexp-in-string "\\s+preload=\"[^\"]*\"" "" html t))
    (setq html (replace-regexp-in-string "\\s+playsinline\\b" "" html t))

    ;; Insert attributes right after <video
    (setq html (replace-regexp-in-string
                "<video\\([^>]*\\)>"
                "<video preload=\"none\" playsinline\\1>"
                html t))

    ;; Lazy-load videos: <source src="..."> -> <source data-src="...">
    ;; Don't touch sources that already use data-src
    (setq html (replace-regexp-in-string
                "<source\\([^>]*\\)\\s+src=\""
                "<source\\1 data-src=\""
                html t))

    ;; Inject tiny IntersectionObserver once
    (if (string-match "IntersectionObserver" html)
        html
      (replace-regexp-in-string
       "</body>"
       (concat
        "<script>
document.addEventListener('DOMContentLoaded',function(){
  if(!('IntersectionObserver'in window))return;
  const io=new IntersectionObserver((ents)=>{
    ents.forEach(e=>{
      if(e.isIntersecting){
        const v=e.target;
        const s=v.querySelector('source[data-src]');
        if(s && !s.dataset.loaded){
          s.src=s.dataset.src;
          s.dataset.loaded='1';
          s.removeAttribute('data-src');
          v.load();
        }
        io.unobserve(v);
      }
    });
  },{rootMargin:'200px'});
  document.querySelectorAll('video').forEach(v=>io.observe(v));
});
</script>\n</body>")
       html t t))))

(defun my-site--patch-file (path)
  "In-place patch of PATH (HTML)."
  (when (and path (file-exists-p path)
             (string-match-p "\\.html?\\'" path))
    (with-temp-buffer
      (insert-file-contents path)
      (let* ((orig (buffer-string))
             (patched (my-site--patch-html-string orig)))
        (when (not (string= orig patched))
          (erase-buffer)
          (insert patched)
          (write-region (point-min) (point-max) path nil 'silent)
          (message "[my-site] Patched %s" path))))
    path))

(defun my-html-publish-to-html (plist filename pub-dir)
  "Publish then patch the resulting HTML file."
  (let ((out (org-html-publish-to-html plist filename pub-dir)))
    (my-site--patch-file out)))


;; AI added the above lines





;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "website"
	     :recursive t
	     :base-directory "./content"
	     :publishing-directory "./docs"
	     :publishing-function 'my-html-publish-to-html
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
             :with-attributes '("src" "href" "id" "class" "style" "type"))

       (list "website-assets"
	     :recursive t
	     :base-directory "./content"
	     :base-extension "png\\|jpg\\|jpeg\\|gif\\|svg\\|webp\\|ico\\|bmp\\|mp4"
	     :publishing-directory "./docs"
	     :publishing-function 'org-publish-attachment)
       ))

;; Get rid of validate link at bottom
(setq org-html-validation-link nil
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head "<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />")


;; Generate the site output
(org-publish-all t)

(message "Build complete!")
