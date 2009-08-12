;;; COLOR SCHEME AND FONTS ------------------------
;(set-default-font "-outline-ProFont-normal-r-normal-normal-11-97-96-96-c-*-iso8859-1")
;(set-default-font "-outline-ProggySquareTT-normal-r-normal-normal-18-97-96-96-c-*-iso8859-1")
;(set-default-font "-outline-ProggyCleanTT-normal-r-normal-normal-16-97-96-96-c-*-iso8859-1")
;(set-default-font "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1")
;(set-default-font "-raster-Fixedsys-normal-r-normal-normal-12-90-96-96-c-80-iso8859-1")

;--------------------
;; Color theme
;(load-file (substitute-in-file-name "$EMACS_LIB/plugins/color-theme-6.6.0/themes/manoj-colors.el"))
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/color-theme-6.6.0"))
;(require 'color-theme)
;(color-theme-initialize)
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/misc"))
;(require 'theme-manager)
;(color-theme-manoj-dark)
;(color-theme-manoj-font-lock)
;(color-theme-scintilla)

;--------------------
;; Use font Monaco 10 for Mac OS X -- 
;(create-fontset-from-fontset-spec 
; (concat
;  "-apple-monaco-medium-r-normal--12-*-*-*-*-*-fontset-monaco,"
;  "ascii:-apple-monaco-medium-r-normal--12-100-*-*-m-100-mac-roman,"
;  "latin-iso8859-1:-apple-monaco-medium-r-normal--12-100-*-*-m-100-mac-roman"))
; Use fontset-monaco in all frames
;(setq initial-frame-alist `((width . 170) (height . 50) 
;                            (font . "fontset-monaco")))
;(setq default-frame-alist initial-frame-alist)


(require 'color-theme)
 
(defun brads-color-theme ()
  (interactive)
  ;; main theme
  (color-theme-install
   (let ((orange "#E67321")
         (comments "gray40")
         (green "#65A63A")
         (mauve "#8722C9")
         (chalk "#D3D7CF")
         (blue "#398EE6")
         (red "red3"))
   `(brads-color-theme
     ((background-color . "gray20")
      (foreground-color . ,chalk)
      (cursor-color . "white")
      (mouse-color . "white")
      (background-mode . dark))
     (default ((t (nil))))
     (bold ((t (:bold t))))
     (bold-italic ((t (:italic t :bold t))))
     (italic ((t (:italic t))))
     (region ((t (:background "MediumPurple4"))))
     (font-lock-builtin-face ((t (:foreground ,"SteelBlue2"))))
     (font-lock-comment-face ((t (:foreground ,comments))))
     (font-lock-constant-face ((t (:foreground ,chalk))))
     (font-lock-doc-string-face ((t (:foreground ,comments))))
     (font-lock-function-name-face ((t (:foreground "gold2"))))
     (font-lock-keyword-face ((t (:foreground ,"orange2"))))
     (font-lock-preprocessor-face ((t (:foreground ,mauve))))
     (font-lock-reference-face ((t (:foreground ,red))))
     (font-lock-string-face ((t (:foreground ,green))))
     (font-lock-type-face ((t (:foreground ,chalk))))
     (font-lock-variable-name-face ((t (:foreground ,chalk))))
     (font-lock-warning-face ((t (:bold t :foreground ,red))))
     (py-builtins-face ((t (:foreground ,chalk))))
     (py-pseudo-keyword-face ((t (:foreground ,blue))))
     (nxml-element-local-name ((t (:foreground "white"))))
     (rst-level-1-face ((t (:bold t :foreground "white" :background "black"))))
     (rst-level-2-face ((t (:bold t :foreground "white" :background "black"))))
     (rst-level-3-face ((t (:bold t :foreground "white" :background "black"))))
     (rst-level-4-face ((t (:bold t :foreground "white" :background "black"))))
     (trailing-whitespace ((t (:background "gray30"))))))))
(brads-color-theme)
