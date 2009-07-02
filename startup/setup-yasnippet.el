;; yasnippet setup

(load-file "$EMACS_LIB/plugins/yasnippet/yasnippet.el")
(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/yasnippet"))

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "$EMACS_LIB/plugins/yasnippet/snippets")
