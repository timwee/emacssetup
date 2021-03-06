;;; erc-autoaway.el --- Provides autoaway for ERC

;; Copyright (C) 2002, 2003, 2004 Free Software Foundation, Inc.

;; Author: Jorgen Schaefer <forcer@forcix.cx>
;; URL: http://www.emacswiki.org/cgi-bin/wiki.pl?ErcAutoAway

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; TODO:
;; - Legacy names: erc-auto-discard-away, erc-auto-set-away

;;; Code:

(require 'erc)

(defconst erc-autoaway-version "$Revision: 1.25.2.1 $"
  "ERC Autoaway revision.")

(defgroup erc-autoaway nil
  "Set yourself automatically away after some idletime and set
yourself back when you type something."
  :group 'erc)

(defvar erc-autoaway-idletimer nil
  "The Emacs idletimer.
This is only used when `erc-autoaway-use-emacs-idle' is non-nil.")

(defcustom erc-autoaway-use-emacs-idle nil
  "*If non-nil, the idle time refers to idletime in Emacs.
If nil, the idle time refers to idletime on IRC only.
The time itself is specified by `erc-autoaway-idle-seconds'.
See `erc-autoaway-mode' for more information on the various
definitions of being idle.

Note that using Emacs idletime is currently broken for most versions,
since process activity (as happens all the time on IRC) makes Emacs
non-idle.  Emacs idle-time and user idle-time are just not the same."
  :group 'erc-autoaway
  :type 'boolean)

;;;###autoload (autoload 'erc-autoaway-mode "erc-autoaway")
(define-erc-module autoaway nil
  "In ERC autoaway mode, you can be set away automatically.
If `erc-auto-set-away' is set, then you will be set away after
the number of seconds specified in `erc-autoaway-idle-seconds'.

There are several kinds of being idle:

IRC idle time measures how long since you last sent something (see
`erc-autoaway-last-sent-time').  This is the default.

Emacs idle time measures how long Emacs has been idle.  This is
currently not useful, since Emacs is non-idle when it handles
ping-pong with IRC servers.  See `erc-autoaway-use-emacs-idle' for
more information.

User idle time measures how long you have not been sending any
commands to Emacs, or to your system.  Emacs currently provides no way
to measure user idle time.

If `erc-auto-discard-away' is set, then typing anything, will
set you no longer away.

Related variables: `erc-public-away-p' and `erc-away-nickname'."
  ;; Enable:
  ((add-hook 'erc-send-completed-hook 'erc-autoaway-reset-idletime)
   (add-hook 'erc-server-001-functions 'erc-autoaway-reset-idletime)
   (add-hook 'erc-timer-hook 'erc-autoaway-possibly-set-away)
   (when erc-autoaway-use-emacs-idle
     (erc-autoaway-reestablish-idletimer)))
  ;; Disable:
  ((remove-hook 'erc-send-completed-hook 'erc-autoaway-reset-idletime)
   (remove-hook 'erc-server-001-functions 'erc-autoaway-reset-idletime)
   (remove-hook 'erc-timer-hook 'erc-autoaway-possibly-set-away)
   (when erc-autoaway-idletimer
     (erc-cancel-timer erc-autoaway-idletimer)
     (setq erc-autoaway-idletimer nil))))

(defcustom erc-auto-set-away t
  "*If non-nil, set away after `erc-autoaway-idle-seconds' seconds of idling.
ERC autoaway mode can set you away when you idle, and set you no
longer away when you type something.  This variable controls whether
you will be set away when you idle.  See `erc-auto-discard-away' for
the other half."
  :group 'erc-autoaway
  :type 'boolean)

(defcustom erc-auto-discard-away t
  "*If non-nil, sending anything when away automatically discards away state.
ERC autoaway mode can set you away when you idle, and set you no
longer away when you type something.  This variable controls whether
you will be set no longer away when you type something.  See
`erc-auto-set-away' for the other half.
See also `erc-autoaway-no-auto-discard-regexp'."
  :group 'erc-autoaway
  :type 'boolean)

(defcustom erc-autoaway-no-auto-discard-regexp "^/g?away.*$"
  "*Input that matches this will not automatically discard away status.
See `erc-auto-discard-away'."
  :group 'erc-autoaway
  :type 'regexp)

(eval-when-compile (defvar erc-autoaway-idle-seconds))

(defun erc-autoaway-reestablish-idletimer ()
  "Reestablish the emacs idletimer.
You have to call this function each time you change
`erc-autoaway-idle-seconds', if `erc-autoaway-use-emacs-idle' is set."
  (interactive)
  (when erc-autoaway-idletimer
    (erc-cancel-timer erc-autoaway-idletimer))
  (setq erc-autoaway-idletimer
	(run-with-idle-timer erc-autoaway-idle-seconds
			     t
			     'erc-autoaway-set-away
			     erc-autoaway-idle-seconds)))

(defcustom erc-autoaway-idle-seconds 1800
  "*Number of seconds after which ERC will set you automatically away.
If you are changing this variable using lisp instead of customizing it,
you have to run `erc-autoaway-reestablish-idletimer' afterwards."
  :group 'erc-autoaway
  :set (lambda (sym val)
	 (set-default sym val)
	 (when erc-autoaway-use-emacs-idle
	   (erc-autoaway-reestablish-idletimer)))
  :type 'number)

(defcustom erc-autoaway-message
  "I'm gone (autoaway after %i seconds of idletime)"
  "*Message ERC will use when he sets you automatically away.
It is used as a `format' string with the argument of the idletime in
seconds."
  :group 'erc-autoaway
  :type 'string)

(defvar erc-autoaway-last-sent-time (erc-current-time)
  "The last time the user sent something.")

(defun erc-autoaway-reset-idletime (line &rest stuff)
  "Reset the stored idletime for the user.
This is one global variable since a user talking on one net can talk
on another net too."
  (when (and erc-auto-discard-away
	     (stringp line)
	     (not (string-match erc-autoaway-no-auto-discard-regexp line)))
    (erc-autoaway-set-back line))
  (setq erc-autoaway-last-sent-time (erc-current-time)))

(defun erc-autoaway-set-back (line)
  "Discard the away state globally."
  (when (erc-away-p)
    (setq erc-autoaway-last-sent-time (erc-current-time))
    (erc-cmd-GAWAY "")))

(defun erc-autoaway-possibly-set-away (current-time)
  "Set autoaway when `erc-auto-set-away' is true and the idletime is
exceeds `erc-autoaway-idle-seconds'."
  ;; A test for (erc-server-process-alive) is not necessary, because
  ;; this function is called from `erc-timer-hook', which is called
  ;; whenever the server sends something to the client.
  (when (and erc-auto-set-away
	     (not (erc-away-p)))
    (let ((idle-time (erc-time-diff erc-autoaway-last-sent-time
				    current-time)))
      (when (>= idle-time erc-autoaway-idle-seconds)
	(erc-display-message
	 nil 'notice nil
	 (format "Setting automatically away after %i seconds of idle-time"
		 idle-time))
	(erc-autoaway-set-away idle-time)))))

(defun erc-autoaway-set-away (idle-time)
  "Set the away state globally."
  ;; Note that the idle timer runs, even when Emacs is inactive.  In
  ;; order to prevent flooding when we connect, we test for an
  ;; existing process.
  (when (and (erc-server-process-alive)
	     (not (erc-away-p)))
    (erc-cmd-GAWAY (format erc-autoaway-message idle-time))))

(provide 'erc-autoaway)

;;; erc-autoaway.el ends here
;;
;; Local Variables:
;; indent-tabs-mode: t
;; tab-width: 8
;; End:

;; arch-tag: 16fc241e-8358-4b56-9fe2-116bdd0ba3bc
