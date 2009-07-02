;;; html-upl.el --- Uploading of web sites

;; Copyright (C) 2006, 2007 Lennart Borgman

;; Author: Lennart Borgman <lennartDOTborgmanDOT073ATstudentDOTluDOTse>
;; Created: Mon Mar 06 19:09:19 2006
(defconst html-upl:version "0.2") ;; Version:
;; Last-Updated: Tue Apr 10 04:17:02 2007 (7200 +0200)
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:
(eval-when-compile (add-to-list 'load-path default-directory load-path))
(require 'html-site)

(defgroup html-upl nil
  "Customization group for html-upl."
  :group 'nxhtml)

(defcustom html-upl-dir
  (file-name-as-directory
   (expand-file-name
    "html-upl"
    (file-name-directory
     (if load-file-name load-file-name buffer-file-name))))

  "Directory where the tools needed are located.
The tools for html-upl includes:

- ftpsync.pl
"
  :type 'directory
  :group 'html-upl)

(defun html-upl-view-remote()
  (interactive)
  (let ((url (html-site-local-to-web html-site-current buffer-file-name nil)))
    (browse-url url)))
(defun html-upl-view-remote-with-toc()
  (interactive)
  (let ((url (html-site-local-to-web html-site-current buffer-file-name t)))
    (browse-url url)))
(defun html-upl-view-remote-frames()
  (interactive)
  (let ((url (html-site-local-to-web (html-site-current-frames-file) buffer-file-name nil)))
    (browse-url url)))

(defun html-upl-upload-site-with-toc()
  (interactive)
  (html-upl-upload-site1 t))
(defun html-upl-upload-site()
  (interactive)
  (html-upl-upload-site1 nil))
(defun html-upl-upload-site1(with-toc)
  (html-site-current-ensure-site-defined)
  (html-upl-ensure-site-has-host)
  (let ((local-dir (if with-toc
                       (html-site-current-merge-dir)
                     (html-site-current-site-dir)))
        (ftp-host (html-site-current-ftp-host))
        (ftp-user (html-site-current-ftp-user))
        (ftp-pw (html-site-current-ftp-password))
        (ftp-dir (if with-toc
                     (html-site-current-ftp-wtoc-dir)
                   (html-site-current-ftp-dir)))
        (ftpsync-pl (expand-file-name "ftpsync.pl" html-upl-dir))
        )
    (unless (< 0 (length ftp-host))
      (error "Ftp host not defined"))
    (unless (< 0 (length ftp-user))
      (error "Ftp user not defined"))
    (unless (< 0 (length ftp-dir))
      (if with-toc
          (error "Ftp remote directory for pages with TOC not defined")
        (error "Ftp remote directory not defined")))
    (unless (< 0 (length ftp-pw))
      (setq ftp-pw (html-site-get-ftp-pw)))
    (let* (
           (buffer (noshell-procbuf-setup "subprocess for upload"))
           (remote-url (concat "ftp://" ftp-user ":" ftp-pw "@" ftp-host ftp-dir))
           (opt (list
                 "-v"
                 "-p"
                 local-dir
                 remote-url)))
      (apply 'noshell-procbuf-run
             buffer
             "perl" "-w"
             ftpsync-pl
             opt
             ))))

(defun html-upl-ensure-site-has-host()
  (let ((host (html-site-current-ftp-host)))
    (unless (and host (< 0 (length host)))
      (error "Site %s has no ftp host defined" html-site-current))))

(defun html-upl-upload-file(filename)
  "Upload a single file in a site."
  (interactive (list
                (let ((f (file-relative-name buffer-file-name)))
                  (read-file-name "File: " nil nil t f))
                ))
  (html-site-current-ensure-file-in-site filename)
  (html-upl-ensure-site-has-host)
  (let* ((buffer (get-file-buffer filename))
         (remote-file (html-site-current-local-to-remote filename nil))
         (remote-buffer (get-file-buffer remote-file))
         (local-file filename))
    (when (or (not (buffer-modified-p buffer))
              (and
               (y-or-n-p (format "Buffer %s is modified. Save buffer and copy? "
                                (buffer-name buffer)))
               (with-current-buffer buffer
                 (save-buffer)
                 (not (buffer-modified-p)))))
      (when (and (fboundp 'w32-short-file-name)
                 (string-match " " local-file))
        (setq local-file (w32-short-file-name local-file)))
      (copy-file local-file
                 (html-site-current-local-to-remote filename nil)
                 0)
      (when remote-buffer
        (with-current-buffer remote-buffer
          (revert-buffer nil t t)))
      (message "Upload ready")
      )))

(defun html-upl-edit-remote-file()
  (interactive)
  (html-upl-edit-remote-file1 nil))
(defun html-upl-edit-remote-file-with-toc()
  (interactive)
  (html-upl-edit-remote-file1 t))

(defun html-upl-edit-remote-file1(with-toc)
  (html-site-current-ensure-buffer-in-site)
  (html-upl-ensure-site-has-host)
  (let* ((remote-root (concat "/ftp:"
                              (html-site-current-ftp-user)
                              "@" (html-site-current-ftp-host)
                              ":"
                              (if with-toc
                                  (html-site-current-ftp-wtoc-dir)
                                (html-site-current-ftp-dir))))
;;          (remote-file (html-site-path-in-mirror (html-site-current-site-dir)
;;                                                 buffer-file-name
;;                                                 remote-root))
         (remote-file (html-site-current-local-to-remote buffer-file-name nil))
         )
    (find-file remote-file)))

(defun html-upl-ediff-file(filename)
  "Run ediff on local and remote file.
FILENAME could be either the remote or the local file."
  (interactive "fFile (local or remote): ")
  (html-upl-ensure-site-has-host)
  (let* ((is-local (html-site-file-is-local filename))
         remote-name
         local-name)
    (if is-local
        (progn
          (html-site-current-ensure-file-in-site filename)
          (setq remote-name (html-site-current-local-to-remote filename nil))
          (setq local-name filename))
      (setq local-name (html-site-current-remote-to-local filename nil))
      (html-site-current-ensure-file-in-site local-name)
      (setq remote-name filename))
    (let ((local-buf (find-file local-name))
          (remote-buf (find-file remote-name)))
      (ediff-buffers local-buf remote-buf))))

(defun html-upl-ediff-buffer()
  "Run ediff on local and remote buffer file.
The current buffer must contain either the local or the remote file."
  (interactive)
  (html-upl-ediff-file (buffer-file-name)))

(provide 'html-upl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; html-upl.el ends here

;; (defun html-site-local-to-remote-path(local-file protocol with-toc)
;;   (let ((remote-dir (if (eq protocol 'ftp)
;;                         (if with-toc
;;                             (html-site-current-ftp-wtoc-dir)
;;                           (html-site-current-ftp-dir))
;;                       (if with-toc
;;                           (html-site-current-web-wtoc-dir)
;;                         (html-site-current-web-dir)))))
;;     (html-site-path-in-mirror
;;      (html-site-current-site-dir) local-file remote-dir)))

;; (defun html-site-local-to-web(local-file with-toc)
;;   (let ((web-file (html-site-local-to-remote-path local-file 'http with-toc))
;;         (web-host (html-site-current-web-host)))
;;     (save-match-data
;;       (unless (string-match "^https?://" web-host)
;;         (setq web-host (concat "http://" web-host))))
;;     (when (string= "/" (substring web-host -1))
;;       (setq web-host (substring web-host 0 -1)))
;;     (concat web-host web-file)
;;     ))
;;
;;; Use tramp-tramp-file-p instead:
;; (defun html-upl-file-name-is-local(file-name)
;;   "Return nil unless FILE-NAME is a Tramp file name."
;;   (save-match-data
;;     (not (string-match "^/[a-z]+:" file-name))))

;; (defun html-upl-remote-to-local(remote-file)
;;   (let ((remote-site-dir (html-site-current-web-dir)))
;;     (unless (html-site-dir-contains remote-site-dir remote-file)
;;       (error "")))
;;   )

