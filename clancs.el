(require 'epc "emacs-epc/epc.el")

(defun pyclang-init ()
  (pymacs-exec "from pyclang import sublimeclang")
  (pymacs-exec "from pyclang import sublime")
  (setq pymacs-forget-mutability t)
  (setq pyclang-scaa (pymacs-eval "sublimeclang.SublimeClangAutoComplete()")))

(defun pyclang-receive-completions (completions)
  (insert (prin1-to-string completions)))

(defun pyclang-query-completions ()
  (let* ((view-constructor (pymacs-eval "sublime.View"))
	 (position (let* ((cursor-position (what-cursor-position)))
		     (string-match "point=\\([0-9]+\\)" cursor-position)
		     (string-to-number (match-string 1 cursor-position))))
	 (flags (list "-I/home/aparulekar/Developer/GamePlay/gameplay/src" "-I/home/aparulekar/Developer/GamePlay/external-deps/bullet/include" "-I/home/aparulekar/Developer/GamePlay/external-deps/oggvorbis/include" "-I/home/aparulekar/Developer/GamePlay/external-deps/libpng/include" "-I/home/aparulekar/Developer/GamePlay/external-deps/zlib/include" "-I/home/aparulekar/Developer/GamePlay/external-deps/lua/include" "-I/home/aparulekar/Developer/GamePlay/external-deps/glew/include"))
	 (view (funcall view-constructor (show-file-name) (- position 1) flags))
	 (query-completions (pymacs-call "getattr" pyclang-scaa "on_query_completions")))
    (funcall query-completions view "" (list (- position 1)))))

(provide 'clancs-mode)
