(require 'deferred (file-truename "emacs-deferred/deferred.el"))
(require 'concurrent (file-truename "emacs-deferred/concurrent.el"))
(require 'ctable (file-truename "emacs-ctable/ctable.el"))
(require 'epc (file-truename "emacs-epc/epc.el"))

(defun pyclang-init ()
  (setq pyclang-epc (epc:start-epc "python" '("clancs.py")))
  (message "Pyclang initialized."))

(defun pyclang-receive-completions (completions)
  (insert (prin1-to-string completions)))

(defun pyclang-query-completions ()
  (deferred:$
    (setq-local file-name (show-file-name))
    (setq-local project-folder (car (car dir-locals-class-alist)))
    (setq-local position (let* ((cursor-position (what-cursor-position)))
				     (string-match "point=\\([0-9]+\\)" cursor-position)
				     (string-to-number (match-string 1 cursor-position))))
    (setq-local compile-flags (mapcar (lambda (include-path)
					(unless (file-exists-p include-path)
					  (setq-local project-folder (car (car dir-locals-class-alist)))
					  (if (sequencep project-folder)
					      (setq-local project-folder (concat project-folder)))
					  (concat "-I" (symbol-name project-folder) include-path)))
				   (mapcar (lambda (include-path) (substring include-path 2))
					   (cdr (assoc 'pyclang-compile-flags
						       (cdr (assoc 'c++-mode (cdr (car dir-locals-class-alist)))))))))

    (epc:call-deferred pyclang-epc 'query_completions (list file-name (- position 1) "" compile-flags))
    (deferred:nextc it
      (lambda (x) (message (concat "Found " (number-to-string (length x)) " completions"))))))

(provide 'clancs-mode)
