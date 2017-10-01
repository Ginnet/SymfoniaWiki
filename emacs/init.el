
;; This file is in %appdata%/Roaming/.emacs.d

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "/usr/share/emacs/site-lisp")
(server-start)
(require 'recentf)
(recentf-mode 1)
(require 'bookmark)
(bookmark-maybe-load-default-file)

;;{{{ loading and configuring additional modules

;;{{{ eww
(condition-case nil
  (require 'eww)
  ('error (message "%s" "Could not load 'eww"))
)
;;}}}

;;{{{ folding
(set 'folding-isearch-install nil)
(load "~/.emacs.d/packages/folding.el")
(add-hook 'folding-mode-hook (lambda ()
  (define-key folding-mode-map "\M-g" nil)
  (define-key folding-mode-map "\C-e" nil)))
(turn-on-folding-mode)
(folding-add-to-marks-list 'ambasic-mode "{{{" "}}}")
(folding-add-to-marks-list 'fundamental-mode "{{{" "}}}")
(folding-add-to-marks-list 'sh-mode "{{{" "}}}")
(folding-add-to-marks-list 'sql-mode "{{{" "}}}")
(defun fold-all ()
  (interactive)
  (folding-mode t)
  (folding-whole-buffer)
)
;;}}}

(if (file-exists-p "~/.emacs.d/packages/csharp-mode.el")
  (progn
    (load "~/.emacs.d/packages/csharp-mode.el")
    (folding-add-to-marks-list 'csharp-mode "{{{" "}}}")
  )
)

(if (file-exists-p "~/.emacs.d/packages/yasnippet.el")
  (progn
    (setq yas-extra-modes (list 'all-mode))
    (load "~/.emacs.d/packages/yasnippet.el")
    (yas-reload-all t)
    (setq yas-indent-line nil)
  )
)

(if (file-exists-p "~/.emacs.d/packages/xml-parse.el")
  (let ((load-path load-path))
    (add-to-list 'load-path "~/.emacs.d/packages")
    (require 'xml-parse))
)

(if (file-exists-p "~/.emacs.d/packages/groovy-mode.el")
  (progn 
    (load "~/.emacs.d/packages/groovy-mode.el")
    (add-to-list 'auto-mode-alist '("\\.gvy\\'" . groovy-mode))
  )
)

;;{{{ emacspeak
(eval-after-load 'emacspeak-setup '(jarek-key-bindings))
(set-default 'dtk-quiet t)
;;}}}

;;{{{ erc
(setq erc-hide-list '("JOIN" "PART" "QUIT"))
;;}}}

;;{{{ rmail settings
(setq rmail-preserve-inbox t)
(setq rmail-remote-password-required t)
(setq rmail-primary-inbox-list '(
  "po:jarekczek@poczta.onet.pl:pop3.poczta.onet.pl"))
;;}}}

;;}}} additional modules

(set-default 'c-electric-flag nil)

;;{{{ ambasic mode
(define-derived-mode ambasic-mode prog-mode "Ambasic"
  "Symfonia report files"
  (set (make-local-variable 'comment-start) "//")
  ;;(set (make-local-variable 'comment-start-skip) "#+\\s-*")
  (setq ambasic-mode-map (make-sparse-keymap))
  (define-key ambasic-mode-map "\M-\C-a" 'ambasic-beginning-of-defun)
  (define-key ambasic-mode-map "\M-\C-e" 'ambasic-end-of-defun)
  (define-key ambasic-mode-map "\M-\C-h" 'ambasic-mark-defun)
  (use-local-map ambasic-mode-map)
)
(add-to-list 'auto-mode-alist '("\\.sc[a-z]?\\'" . ambasic-mode))

(defconst ambasic-defun-start-regexp
  "\\(^\\|[ \t]\\)\\([Ss]ub\\|[Re]ecord\\)[ \t]+\\(\\w+\\)[ \t]*(?")

(defconst ambasic-defun-end-regexp
  "^[ \t]*[Ee]nd\\([Ss]ub\\|[Rr]ecord\\)")

(defun ambasic-beginning-of-defun ()
  (interactive)
  (re-search-backward ambasic-defun-start-regexp))

(defun ambasic-end-of-defun ()
  (interactive)
  (re-search-forward ambasic-defun-end-regexp))

(defun ambasic-mark-defun ()
  (interactive)
  (beginning-of-line)
  (ambasic-end-of-defun)
  (set-mark (point))
  (ambasic-beginning-of-defun))
;;}}}

;;{{{ cmd defun
(defun cmd ()
  (interactive)
  (if (eq system-type (quote windows-nt))
    (start-process "cmd" nil "cmd" "/c" "start" "cmd")
    (start-process "cmd" nil "gnome-terminal")))
;;}}}
;;{{{ commit defun
(defun commit (&optional repo-type)
  (interactive)
  (setq repo-type (cond
    ((or (file-exists-p (expand-file-name ".svn"))
         (file-exists-p (expand-file-name "../.svn"))
         (file-exists-p (expand-file-name "../../.svn")))
      "svn")
    (t repo-type)))
  (cond
    ((string-equal repo-type "svn")
      (shell-command "svn commit --force-interactive"))
    (t (error "Nieznany typ repozytorium")))
)
;;}}}
;;{{{ duplicate-line defun
(defun duplicate-line (&optional n)
  "duplicate current line (or selected lines),
  make more than 1 copy given a numeric argument"
  (interactive "p")
  (save-excursion
    (let ((nb (or n 1)) start end top bot current-line)
      (setq current-line
        (if mark-active (progn
          ; calculate top and bottom part of the selection
          (if (< (point) (mark))
            (progn (setq top (point)) (setq bot (mark)))
            (progn (setq bot (point)) (setq top (mark))))
          (save-excursion
            ; set start position
            (goto-char top)
            (beginning-of-line)
            (setq start (point))
            ; set end position
            (goto-char bot)
            (forward-thing 'line 1)
            (setq end (point))
            (buffer-substring start end)
          ))
        (thing-at-point 'line)))
      ;; move point to the last line, the correct position before insert
      (if bot (goto-char bot))
      ;; when on last line, insert a newline first
      (when (or (= 1 (forward-line 1)) (eq (point) (point-max)))
        (insert "\n"))
    
      ;; now insert as many time as requested
      (while (> nb 0)
        (insert current-line)
        (decf nb)
      )
   ))
)
;;}}}
;;{{{ find-file-hook
(defun jarek-find-file-hook ()
  (size-indication-mode 1)
  (line-number-mode 1)
  (column-number-mode 1)
)
(add-hook 'find-file-hook 'jarek-find-file-hook)
;;}}}
;;{{{ run defun
(defun run (args)
  (interactive (list (read-shell-command "Run: "
    (if (eq major-mode 'dired-mode)
      (file-name-nondirectory (dired-get-filename)) nil)
    'run-history)))
  (let (
    (cmd (car (split-string args)))
    (cmd-args (cdr (split-string args)))
    )
    (message "%s" (concat "\"" args "\""))
    (condition-case err
      (apply 'start-process
        (append (list (concat "run: " cmd) nil cmd) cmd-args))
      (file-error
        (if (file-exists-p args)
          (cond
            ((eq system-type 'windows-nt)
              (start-process (concat "run (start): " cmd) "*run buffer*"
                "cmd" "/c" "start" "\"st\"" args))
            ((eq system-type 'gnu/linux)
              (start-process (concat "run (start): " cmd) "*run buffer*"
                "xdg-open" args)))
        (signal (car err) (cdr err)))
      )
    )
  )
)
;;}}}

(defun kill-other-buffer-and-window ()
  (interactive)
  (other-window 1)
  (kill-buffer-and-window)
)

;;{{{ define goto-bookmark-n and set-bookmark-n

(defun goto-bookmark-0 ()
  (interactive)
  (bookmark-jump "zzz0")
)
(defun set-bookmark-0 ()
  (interactive)
  (bookmark-set "zzz0" nil)
)
(defun goto-bookmark-1 ()
  (interactive)
  (bookmark-jump "zzz1")
)
(defun set-bookmark-1 ()
  (interactive)
  (bookmark-set "zzz1" nil)
)
(defun goto-bookmark-2 ()
  (interactive)
  (bookmark-jump "zzz2")
)
(defun set-bookmark-2 ()
  (interactive)
  (bookmark-set "zzz2" nil)
)
(defun goto-bookmark-3 ()
  (interactive)
  (bookmark-jump "zzz3")
)
(defun set-bookmark-3 ()
  (interactive)
  (bookmark-set "zzz3" nil)
)
(defun goto-bookmark-4 ()
  (interactive)
  (bookmark-jump "zzz4")
)
(defun set-bookmark-4 ()
  (interactive)
  (bookmark-set "zzz4" nil)
)
(defun goto-bookmark-5 ()
  (interactive)
  (bookmark-jump "zzz5")
)
(defun set-bookmark-5 ()
  (interactive)
  (bookmark-set "zzz5" nil)
)

;;}}} bookmark-n

;;{{{ print-buffer-file-name
(defun print-buffer-file-name (PREF)
  "If prefixed, put it in the kill ring"
  (interactive "P")
  (let* (name)
  (setq name (or
    buffer-file-name
    (and (eq major-mode 'dired-mode) (dired-current-directory))
    default-directory))
  (if (and name (eq system-type 'windows-nt))
    (setq name (replace-regexp-in-string "/" "\\\\" name)))
  (print name t)
  (if PREF (kill-new name)))
)
;;}}}
;;{{{ switch-to-messages-buffer
(defun switch-to-messages-buffer ()
  (interactive)
  (switch-to-buffer "*Messages*")
)
;;}}}

;;{{{ tag-dir
(defun tag-dir ()
  (interactive)
  (let (
      (exe (if (eq system-type (quote windows-nt))
        "c:\\temp\\src\\ctags\\ctags.exe" "ctags"))
      (cmd)
    )
    (setq cmd (concat
      (if (eq system-type (quote windows-nt))
        (concat exe " --options=J:\\lang\\symfonia\\ctags_ambasic.txt ")
        exe
      )
      "-e "
      "*.sc* *.c *.cpp *.java *.cs"
      )
    )
    (print cmd t)
    (shell-command cmd)
    (shell-command (concat exe " -a -e *.c *.cpp *.java *.cs"))
    (visit-tags-table (concat (file-name-directory (buffer-file-name)) "TAGS"))
  )
)
;;}}}

;;{{{ helper library
;;{{{ ambasic-utf8-encoding defun
(defun ambasic-utf8-encoding ()
  (with-current-buffer (get-buffer "*Messages*")
  (setq a "ąćęłńóśźżĄĆĘŁŃÓŚŹŻ")
  (setq using1 "(using \"")
  (setq using2 "")
  (mapc (lambda (c)
    (let ((enc (encode-coding-char c 'utf-8)) out)
    (setq out (concat out "arg "))
  
    ; lewa strona arg
    (setq out (concat out "(using \""))
    (mapc (lambda (c2) (setq out (concat out "%c"))) enc)
    (mapc (lambda (c2) (setq out (concat out (format ", %d" c2)))) enc)
    (setq out (concat out "\""))
    (setq out (concat out ")"))
  
    (setq out (concat out ", "))
  
    ; prawa strona arg
    (setq out (concat out (format "\"%s\"" (char-to-string c))))
  
    (setq out (concat out "\n"))
    (insert out)

    ; using do sZnakiPl
    (setq using1 (concat using1 "%c"))
    (setq using2 (concat using2 ", " (mapconcat
      (lambda (c2) (number-to-string c2)) enc ", ")))

    )) a)
  (insert (concat using1 using2 "\n"))
  )
)
;;}}}
;;}}} helper library

;;{{{ key bindings
(defun jarek-key-bindings ()
(interactive)
(global-set-key (kbd "<M-return>") 'folding-show-current-entry)
(global-set-key (kbd "<M-S-return>") 'folding-hide-current-entry)
(global-set-key (kbd "<S-return>") 'newline-and-indent)
(global-set-key (kbd "<C-S-delete>") 'delete-region)
(global-set-key (kbd "C-<left>") 'backward-word)
(global-set-key (kbd "C-<right>") 'forward-word)
(global-set-key (kbd "C-<down>") 'scroll-up-line)
(global-set-key (kbd "C-<up>") 'scroll-down-line)
(global-set-key (kbd "C-<f4>") 'kill-this-buffer)
(global-set-key (kbd "C-S-<f4>") 'kill-other-buffer-and-window)
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "<f6>") 'other-window)
(global-set-key (kbd "<C-f6>") 'next-buffer)
(global-set-key (kbd "<C-S-f6>") 'previous-buffer)
(global-set-key (kbd "<f7>") 'occur-prev)
(global-set-key (kbd "<f8>") 'occur-next)
(global-set-key (kbd "<f10>") 'tmm-menubar)
(global-set-key (kbd "<f11>") 'toggle-truncate-lines)
(global-set-key (kbd "C-0") 'goto-bookmark-0)
(global-set-key (kbd "C-)") 'set-bookmark-0)
(global-set-key (kbd "C-]") 'blink-matching-open)
(global-set-key (kbd "C-<") 'delete-rectangle)
(global-set-key (kbd "C->") 'string-insert-rectangle)
(global-set-key (kbd "C-/") 'comment-or-uncomment-region)
(global-set-key (kbd "C-1") 'goto-bookmark-1)
(global-set-key (kbd "C-!") 'set-bookmark-1)
(global-set-key (kbd "C-2") 'goto-bookmark-2)
(global-set-key (kbd "C-@") 'set-bookmark-2)
(global-set-key (kbd "C-3") 'goto-bookmark-3)
(global-set-key (kbd "C-#") 'set-bookmark-3)
(global-set-key (kbd "C-4") 'goto-bookmark-4)
(global-set-key (kbd "C-$") 'set-bookmark-4)
(global-set-key (kbd "C-5") 'goto-bookmark-5)
(global-set-key (kbd "C-5") 'goto-bookmark-5)
(global-set-key (kbd "C-%") 'set-bookmark-5)
(global-set-key (kbd "C-M-.") 'tags-apropos)
(global-set-key (kbd "C-c f") 'print-buffer-file-name)
(global-set-key (kbd "C-c m") 'switch-to-messages-buffer)
(global-set-key (kbd "C-S-d") 'duplicate-line)
(global-set-key (kbd "C-k") 'kill-whole-line)
(global-set-key (kbd "C-t") 'test)
(global-set-key (kbd "C-w") 'clipboard-kill-region)
(global-set-key (kbd "M-w") 'clipboard-kill-ring-save)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-z") 'undo)
) ; defsubst
(jarek-key-bindings)
;;}}}

(set 'auto-save-default nil)
(set 'version-control t)
(set 'tab-stop-list (list 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80))
(put 'narrow-to-region 'disabled nil)

;;{{{ os dependent settings
(if (file-exists-p "c:\\temp")
  (progn
    ;;(setq w32-use-visible-system-caret t)
    (setq backup-directory-alist '(("." . "D:\\backup\\temp\\emacs_temp")))
    (setq exec-path (cons "." exec-path))
    (prefer-coding-system 'windows-1250-dos)
    (prefer-coding-system 'utf-8-dos)
    (set-terminal-coding-system 'cp852)
    (set-keyboard-coding-system 'cp852)
    (setq find-program "ufind")
  )
  (progn ;; else
    (setq backup-directory-alist '(("." . "/m/temp/emacs_temp")))
    (prefer-coding-system 'utf-8-unix)
    (prefer-coding-system 'windows-1250-unix)
  )
)
;;}}} os dependent

;;{{{ bs library
(defun bs-cut-line-text (ind) ;;{{{
  (let (start text) (save-excursion
  (goto-line ind)
  (setq start (point))
  (goto-char (line-end-position))
  (setq text (buffer-substring start (point)))
  (delete-region start (point))
  text
  ))
)
;;}}}
(defun bs-swap-lines (ind1 ind2) ;;{{{
  (let (start text1 text2) (save-excursion

  (setq text1 (bs-cut-line-text ind1))
  (setq text2 (bs-cut-line-text ind2))
  (goto-line ind2)
  (insert text1)
  (goto-line ind1)
  (insert text2)

  ))
)
;;}}}
(defun bs-open-error-file (err-file) ;;{{{
  (let* (dir src-file line buf src-buf match) (catch 'exit
  (setq dir (file-name-directory (buffer-file-name)))
  (setq buf (find-file-noselect err-file t))
  (switch-to-buffer-other-window buf)
  (revert-buffer t t)

  ; extract file and line
  (goto-char (point-min))
  (setq match (re-search-forward "plik : " nil t))
  (if (not match) (throw 'exit))
  (setq src-file (buffer-substring (point) (line-end-position)))
  (setq match (re-search-forward "linia: " nil t))
  (if (not match) (throw 'exit))
  (setq line (buffer-substring (point) (line-end-position)))

  ; remove trash
  (delete-region (line-end-position) (point-max))
  (goto-char (point-min))
  (replace-string (string 13) "")
  (goto-char (point-min))
  (if (and (string= (buffer-substring (point-min) (+ (point-min) 1)) "1")
           (< (- (line-end-position) (line-beginning-position)) 2))
    (delete-char 2))
  (save-buffer)

  (start-process "espeak-error" nil
    "D:\\Program_Files\\eSpeak\\command_line\\espeak.exe"
    "-v" "europe/pl" "-s" "300" "-f" err-file)

  ; locate the buffer containing src-file in the first line
  (dolist (buf (buffer-list))
    (let* (line)
    (with-current-buffer buf (if (buffer-file-name) (save-excursion
      (goto-char (point-min))
      (setq line (or (thing-at-point 'line) ""))
      (if (string-match (concat "\"" src-file "\"") line)
        (setq src-buf buf))
    )))))

  ;(find-file-other-window (expand-file-name src-file dir))
  (if src-buf (progn 
    (switch-to-buffer-other-window src-buf)
    (goto-line (string-to-number line)))
    ; else
    (message "Buffer with %s not found" src-file))
))) ;;}}}
;;}}} bs library

;;{{{ snippets
(if (functionp 'yas-reload-all) (progn 

;;{{{ ant
  (yas-define-snippets 'nxml-mode '(
    ("condition-os" ;;{{{
"    <condition property=\"src.dir\" value=\"/usr/src/zbar\" else=\"c:\temp\30\zbar\">
      <os family=\"unix\" /></condition>"
  "condition-os" nil nil nil nil nil nil) ;;}}}
    ("condition-equals" ;;{{{
"    <condition property=\"prog2\" value=\"FK\" else=\"KP\">
      <equals arg1=\"${prog}\" arg2=\"FK\" /></condition>"
  "condition-equals" nil nil nil nil nil nil) ;;}}}
  ))
;;}}} ant

;;{{{ autohotkey
  (yas-define-snippets 'fundamental-mode '(

    ("FileAppend"
"FileAppend, %t%, \"c:\\temp\\1\\win_text.txt\""
"ahk-FileAppend" nil ("autohotkey") nil nil nil nil)

    ("If x = string"
"If (x = \"Okresy\") {
  ; albo !=
  ; albo = %sApp%
  MsgBox Tak
}"
"ahk-if-x-string" nil ("autohotkey") nil nil nil nil)

    ("If x empty"
"If x =
  MsgBox One line action.
If x =
{
  MsgBox Multi
  MsgBox line action.
}"
"ahk-if-x-empty" nil ("autohotkey") nil nil nil nil)

    ("lf"
"`n"
"ahk-lf" nil ("autohotkey") nil nil nil nil)

    ("Reload"
"#q::
ExitApp
return

#o::
Run %A_AhkPath% /restart %A_ScriptFullPath% %1%
return
"
"ahk-reload-quit" nil ("autohotkey") nil nil nil nil)

    ("Run"
"Run J:\\lang\\c\\execute_hidden\\execute_hidden.exe D:\\Program_Files\\eSpeak\\command_line\\espeak.exe -v europe/pl -s 300 -f %f%"
"ahk-Run" nil ("autohotkey") nil nil nil nil)

    ("string concat"
"sMsg := \"tekst1\"
sMsg := sMsg . \", tekst2 \"
sMsg = %sMsg%, tekst3"
"ahk-string-concat" nil ("autohotkey") nil nil nil nil)

    ("shortcut"
"#q::
Exit
return"
"ahk-shortcut" nil ("autohotkey") nil nil nil nil)

    ("While"
"  ok := 0
  while not ok
  {
"
"ahk-while" nil ("autohotkey") nil nil nil nil)

    ("WinGetText"
"WinGetText t, A
MsgBox %t%"
"ahk-WinGetText" nil ("autohotkey") nil nil nil nil)
  ))

;;}}} autohotkey

;;{{{ java
  (yas-define-snippets 'java-mode '(
    ("font-metrics"
"  int nCharWidth = getFontMetrics(new JLabel().getFont()).charWidth('X');
  int nCharHeight = getFontMetrics(new JLabel().getFont()).getHeight();
"
"font-metrics" nil nil nil nil nil nil)
  ))
;;}}} java

;;{{{ latex
  (yas-define-snippets 'latex-mode '(
    ("bold"
"\\textbf{$0}"
"bold" nil nil nil nil nil nil)

    ("center"
"\\begin{center}
{$0}
\\end{center}"
"center" nil nil nil nil nil nil)

    ("image"
"\\usepackage{graphicx}
\\includegraphics[width=0.9\\linewidth,natwidth=1,natheight=1]{tightvnc_select_components.png}
" "image" nil nil nil nil nil nil)

    ("html-link"
"\\htmladdnormallink{name$0}{url}"
"html-link" nil nil nil nil nil nil)

  ))

  (yas-define-snippets 'latex-mode '(
    ("ref"
"\\ref{sec:$0}"
"ref" nil nil nil nil nil nil)
  ))

  (yas-define-snippets 'latex-mode '(
    ("ref-create label"
"\\phantomsection \\label{sec:$0}"
"ref-create label" nil nil nil nil nil nil)
  ))

  (yas-define-snippets 'latex-mode '(
    ("less than"
"\\textless"
"less than" nil nil nil nil nil nil)
  ))

  (yas-define-snippets 'latex-mode '(
    ("greater than"
"\\textgreater"
"greater than" nil nil nil nil nil nil)
  ))

  (yas-define-snippets 'latex-mode '(
    ("table"
"\\begin{tabular}{ | c | l | l | }
\\hline
Analityka rodzaju &
\\multicolumn{1}{|c|}{Kategoria} \\\\\\\\ \\hline
431010 & WYNAGR.OSOBOWE \\\\\\\\ \\hline
\\end{tabular}
"
"table" nil nil nil nil nil nil)
  ))

  (yas-define-snippets 'latex-mode '(
    ("vspace"
"\\vspace{2em}"
"vspace" nil nil nil nil nil nil)
  ))

;;}}} latex

;;{{{ shell
  (yas-define-snippets 'shell-mode '(
    ("bzr commit"
"bzr commit --fixes debbugs:x -F"
"bzr commit" nil ("bzr") nil nil nil nil)
  ))
;;}}}

  (yas-define-snippets 'dummy-mode '(
    ("snippetname"
"snippettext"
"snippetname" nil ("group name") nil nil nil nil)
  )) ; dummy-mode

)) ;;}}} snippets

;;{{{ customizing section
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compilation-scroll-output t)
 '(delete-old-versions t)
 '(electric-indent-mode nil)
 '(fill-column 78)
 '(folding-folding-on-startup nil)
 '(global-hl-line-mode t)
 '(global-whitespace-mode (not (eq system-type (quote windows-nt))))
 '(grep-command "grep -nHi ")
 '(indent-tabs-mode nil)
 '(kept-new-versions 6)
 '(line-number-display-limit-width 500)
 '(mode-require-final-newline nil)
 '(proced-format-alist
   (quote
    ((short user pid tree pcpu pmem vsize start time
            (args comm))
     (medium user pid tree pcpu pmem vsize rss ttname state start time
             (args comm))
     (long user euid group pid tree pri nice pcpu pmem vsize rss ttname state start time
           (args comm))
     (verbose user euid group egid pid ppid tree pgrp sess pri nice pcpu pmem state thcount vsize rss ttname tpgid minflt majflt cminflt cmajflt start time utime stime ctime cutime cstime etime
              (args comm)))))
 '(revert-without-query (quote (".*")))
 '(safe-local-variable-values
   (quote
    ((py-indent-offset . 4)
     (outline-regexp . =)
     (eval fold-set-marks "# {{{" "# }}}")
     (major-mode . makefile-mode)
     (major-mode . emacs-lisp-mode)
     (folded-file . t)
     (voice-lock-mode . t)
     (major-mode . tcl-mode))))
 '(send-mail-function (quote mailclient-send-it))
 '(tab-width 2)
 '(truncate-lines t)
 '(warning-suppress-types (quote ((undo))))
 '(whitespace-line-column 78)
 '(whitespace-style
   (quote
    (spaces newline indentation empty space-after-tab tab-mark newline-mark face))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;}}} customizing section

;;{{{ window state
(toggle-frame-maximized)
(split-window-right)
(bookmark-bmenu-list)
;;}}}

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
