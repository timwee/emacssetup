(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/plugins/erlang"))
(setq erlang-root-dir (substitute-in-file-name "/usr/local/lib/erlang"))
(setq exec-path (cons (substitute-in-file-name "/usr/local/lib/erlang/bin") exec-path))
(require 'erlang-start)