;;; ---------------------------------------------
;;; Clojure
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/slime"))
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/clojure/clojure-mode"))
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/clojure/swank-clojure))
;(load-file (substitute-in-file-name "$EMACS_LIB/plugins/misc/parenface.el"))

;(require 'parenface)

;(require 'slime) 
;(slime-setup) 

;(setq swank-clojure-binary "/Users/jboner/src/clojure/clojure-extra/sh-script/clojure") 
;(setq swank-clojure-binary "clojure")

;(require 'clojure-auto)
;(require 'swank-clojure-autoload)

;(add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-mode))


;$EMACS_LIB/plugins/clojure
;; clojure-mode
(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/clojure/clojure-mode"))
(require 'clojure-mode)

;; swank-clojure
(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/clojure/swank-clojure"))
(require 'swank-clojure-autoload)
(swank-clojure-config
 (setq swank-clojure-jar-path (substitute-in-file-name "$EMACS_LIB/plugins/clojure/clojurecode/clojure/target/classes"))
 (setq swank-clojure-extra-classpaths
       (list (substitute-in-file-name "$EMACS_LIB/plugins/clojure/clojurecode/clojure-contrib/target/classes") (substitute-in-file-name "$EMACS_LIB/plugins/clojure/clojurecode/.clojure/"))))

;; slime
(eval-after-load "slime"
  '(progn (slime-setup '(slime-repl))))

(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/slime"))
(require 'slime)
(slime-setup)


 (autoload 'clojure-test-mode "clojure-test-mode" "Clojure test mode" t)
 (add-hook 'clojure-mode-hook
   (lambda () (save-excursion
     (goto-char (point-min))
       (if (search-forward "(deftest" nil t)
         (clojure-test-mode)))))

(defun slime-project (path)
  "Setup classpaths for a maven/clojure project & refresh slime"
  (interactive "GPath: ")
  (when (get-buffer "*inferior-lisp*")
    (kill-buffer "*inferior-lisp*"))
  (setq swank-clojure-binary nil
        swank-clojure-jar-path (expand-file-name "target/dependency/" path)
        swank-clojure-extra-classpaths
        	(append (mapcar (lambda (d) (expand-file-name d path))
                '("src/" "target/classes/" "test/"))
			(let ((lib (expand-file-name "target/dependency/" path)))
				                  (if (file-exists-p lib)
				                      (directory-files lib t ".jar$"))))
        swank-clojure-extra-vm-args
        (list (format "-Dclojure.compile.path=%s"
                      (expand-file-name "target/classes/" path)))
        slime-lisp-implementations
        (cons `(clojure ,(swank-clojure-cmd) :init swank-clojure-init)
              (remove-if #'(lambda (x) (eq (car x) 'clojure))
                         slime-lisp-implementations)))
  (save-window-excursion
    (slime)))
