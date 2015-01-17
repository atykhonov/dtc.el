(defvar dtc-cursor nil "Overlay for cursor.")

(defvar dtc-current-map nil "Current keymap.")

(defvar dtc-mode-map
  (let ((map (make-sparse-keymap)))
    ;; (set-keymap-parent map parent-mode-shared-map)
    (suppress-keymap map)
    (define-key map (kbd "C-c C-c") 'decur/test-output)
    (define-key map (kbd "o") 'dtc-new-line-below)
    (define-key map (kbd "O") 'dtc-new-line-above)
    ;; (define-key map (kbd "w") 'dtc-forward-word)
    ;; (define-key map (kbd "M-w") 'dtc-forward-word-alt)
    ;; (define-key map (kbd "b") 'dtc-backward-word)
    ;; (define-key map (kbd "M-b") 'dtc-backward-word-alt)
    (define-key map (kbd "dd") 'dtc-delete-line)
    (define-key map (kbd "dc") 'dtc-delete-to-cursor)
    (define-key map (kbd "dsu") 'dtc-delete-sexp-up-list)
    (define-key map (kbd "rec") 'test-best-rest)

    (define-key map (kbd "mc") 'dtc-mark-to-cursor)
    (define-key map (kbd "ml") 'dtc-mark-line)
    
    (define-key map (kbd "cc") 'decur/test-output)
    (define-key map (kbd "$") 'dtc-goto-eol)
    ;; (define-key map (kbd "f") 'dtc-occurrence-of-char-to-the-right)
    ;; (define-key map (kbd "n") 'dtc-next-line)
    (define-key map [remap next-line] 'dtc-next-line)
    (define-key map [remap previous-line] 'dtc-previous-line)
    (define-key map [remap forward-char] 'dtc-forward-char)
    (define-key map [remap backward-char] 'dtc-backward-char)
    (define-key map [remap forward-word] 'dtc-forward-word)
    (define-key map [remap backward-word] 'dtc-backward-word)
    (define-key map [remap forward-sexp] 'dtc-forward-sexp)
    (define-key map [remap backward-sexp] 'dtc-backward-sexp)
    ;; (define-key map "h" 'dtc-backward-char)
    ;; (define-key map "j" 'dtc-previous-line)
    ;; (define-key map "k" 'dtc-next-line)
    ;; (define-key map "l" 'dtc-forward-char)
    ;; (define-key map "T" 'dtc-up-list)
    ;; (define-key map "H" 'dtc-down-list)
    ;; (define-key map "D" 'dtc-backward-sexp)
    ;; (define-key map "N" 'dtc-forward-sexp)

    (define-key map (kbd "<up>") 'dtc-previous-line)
    (define-key map (kbd "<down>") 'dtc-next-line)
    (define-key map (kbd "<left>") 'dtc-backward-char)
    (define-key map (kbd "<right>") 'dtc-forward-char)

    ;; (define-key map "n" 'dtc-next-line)
    ;; (define-key map "p" 'dtc-previous-line)
    (define-key map "f" 'dtc-forward-char)
    (define-key map "b" 'dtc-backward-char)
    (define-key map "q" 'dtc-attach-all)
    (define-key map "e" 'dtc-expand)
    
    ;; (define-key map (kbd "M-t") 'dtc-up-list)
    ;; (define-key map (kbd "M-h") 'dtc-down-list)
    ;; (define-key map (kbd "M-n") 'dtc-forward-sexp)
    ;; (define-key map (kbd "M-d") 'dtc-backward-sexp)
    
    (define-key map "gfd" 'dtc-goto-function-definition)
    (define-key map "gvd" 'dtc-goto-variable-definition)
    (define-key map "gpl" 'dtc-goto-previous-like-this)
    (define-key map "gnl" 'dtc-goto-previous-like-this)
    (define-key map (kbd "C-j") 'dtc-attach-here)
    ;; (define-key map (kbd "m") 'dtc-custom-mode)
    map))

(defun dtc-move-line-up-attach ()
  (interactive)
  (dtc-move--line-up t))

(defun dtc-move-line-up ()
  (interactive)
  (dtc-move--line-up nil))

(defun dtc-move--line-up (attach)
  (let ((l1pos1 nil)
        (l1pos2 nil)
        (line nil)
        (column-pos nil))
    (dtc-move-overlay 
     '(progn
        (setq l1pos1 (line-beginning-position))
        (setq column-pos (- (point) l1pos1))
        (setq l1pos2 (line-end-position))
        (setq line (delete-and-extract-region l1pos1 (+ l1pos2 1)))
        (line-move -1)
        (insert line)
        (goto-char (line-beginning-position))
        (line-move -1)
        (goto-char (+ (point) column-pos))))
    (when attach
      (dtc-attach))))

(defun dtc-move-line-down-attach ()
  (interactive)
  (dtc-move--line-down t))

(defun dtc-move-line-down ()
  (interactive)
  (dtc-move--line-down nil))

(defun dtc-move--line-down (attach)
  (let ((l1pos1 nil)
        (l1pos2 nil)
        (line nil)
        (column-pos nil))
    (dtc-move-overlay 
     '(progn
        (setq l1pos1 (line-beginning-position))
        (setq column-pos (- (point) l1pos1))
        (setq l1pos2 (line-end-position))
        (setq line (delete-and-extract-region l1pos1 (+ l1pos2 1)))
        ;; test best rest
        (line-move 1)
        (insert line)
        (line-move -1)
        ;; (goto-char (line-beginning-position))
        ;; (line-move 1)
        (goto-char (+ (point) column-pos))
        ))
    (when attach
      (dtc-attach))))

(defvar dtc-line-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (define-key map (kbd "d") 'dtc-delete-line)
    (define-key map (kbd "U") 'dtc-move-line-up-attach)
    (define-key map (kbd "u") 'dtc-move-line-up)
    (define-key map (kbd "o") 'dtc-move-line-down)
    (define-key map (kbd "O") 'dtc-move-line-down-attach)
    (define-key map (kbd "m") 'dtc-mark-line)
    (define-key map (kbd "k") 'dtc-kill-line)
    ;; TODO: (define-key map (kbd "i") 'dtc-indent-line)
    (define-key map "q" 'dtc-attach)
    map))

(defvar dtc-sexp-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (define-key map (kbd "dd") 'dtc-delete-sexp)
    (define-key map (kbd "du") 'dtc-delete-up-sexp)
    (define-key map (kbd "mu") 'dtc-move-up-sexp)
    (define-key map (kbd "mU") 'dtc-move-up-sexp-attach)
    ;; (define-key map (kbd "D") 'dtc-delete-up-sexp)
    ;; (define-key map (kbd "U") 'dtc-move-line-up-attach)
    ;; (define-key map (kbd "u") 'dtc-move-line-up)
    ;; (define-key map (kbd "o") 'dtc-move-line-down)
    ;; (define-key map (kbd "O") 'dtc-move-line-down-attach)
    ;; (define-key map (kbd "m") 'dtc-mark-line)
    ;; (define-key map (kbd "k") 'dtc-kill-line)
    ;; TODO: (define-key map (kbd "i") 'dtc-indent-line)
    (define-key map "q" 'dtc-attach)
    map))

(defun dtc-move-up-sexp ()
  (interactive)
  (dtc-move-overlay '(dtc--move-up-sexp nil)))

(defun dtc-move-up-sexp-attach ()
  (interactive)
  (dtc-move-overlay '(dtc--move-up-sexp t)))

(defun dtc--move-up-sexp (attach)
  (interactive)
  (let ((pos1 nil)
        (pos2 nil)
        (pos3 nil)
        (pos4 nil)
        (sexp1 nil)
        (sexp2 nil))
    (backward-sexp)
    (setq pos3 (point))
    (backward-sexp)
    (setq pos1 (point))
    (forward-sexp)
    (setq pos2 (point))
    (forward-sexp)
    (setq pos4 (point))    

    (setq sexp2 (buffer-substring-no-properties pos3 pos4))
    (setq sexp1 (delete-and-extract-region pos1 pos2))
    (goto-char pos1)
    (insert sexp2)

    (setq pos2 (point))
    (forward-sexp)
    (setq pos4 (point))
    (backward-sexp)
    (setq pos3 (point))

    (delete-region pos3 pos4)
    (insert sexp1)
    (when attach
      (dtc-attach))))

;; (goto-char pos3)
;; (insert sexp1)
;; (goto-char pos1)
;; (insert sexp2)))

(defun dtc-delete-sexp ()
  (interactive)
  (let ((pos1 nil)
        (pos2 nil)))
  (backward-sexp)
  (setq pos1 (point))
  (forward-sexp)
  (setq pos2 (point))
  (delete-region pos1 pos2))

(defun dtc-delete-up-sexp ()
  (interactive)
  (let ((pos1 nil)
        (pos2 nil)))
  (up-list)
  (backward-sexp)
  (setq pos1 (point))
  (forward-sexp)
  (setq pos2 (point))
  (delete-region pos1 pos2))

(defvar dtc-custom-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    ;; (set-keymap-parent map dtc-mode-map)
    (define-key map "q" 'dtc-exit-custom-mode)
    map))

(defun dtc-delete-sexp-up-list ()
  (interactive)
  (let ((pos1 nil)
        (pos2 nil))
    (up-list nil)
    (backward-sexp)
    (setq pos1 (point))
    (forward-sexp)
    (setq pos2 (point))
    (delete-region pos1 pos2)))

(defun dtc-delete-to-cursor ()
  (interactive)
  (let ((pos1 (point))
        (pos2 (overlay-start dtc-cursor)))
    (delete-region pos1 pos2)
    (dtc-attach)))

(defun dtc-mark-to-cursor ()
  (interactive)
  (let ((pos1 (point))
        (pos2 (overlay-start dtc-cursor)))
    (goto-char pos1)
    (set-mark-command nil)
    (goto-char pos2)
    (dtc-attach)))

(defun dtc-mark-line ()
  (interactive)
  (let ((pos1 (line-beginning-position))
        (pos2 (line-end-position)))
    (goto-char pos1)
    (set-mark-command nil)
    (goto-char pos2)
    (dtc-attach)))

(defun dtc-kill-line ()
  (interactive)
  (let ((pos1 (line-beginning-position))
        (pos2 (line-end-position)))
    (kill-region pos1 (+ pos2 1))
    (dtc-attach)))

(defface dtc-cursor-face
  '(;; (t (:inverse-video t))
    ;; (((class color) (min-colors 16) (background light))
    ;;  :background "darkseagreen2")
    (((class color) (min-colors 8))
     :background "green" :foreground "black")
    )
  "The face used for fake cursors"
  :group 'dtc)

(defun dtc-test ()
  (interactive)
  (let ((repeat-key (event-basic-type last-input-event))
        (bindings (list "-" "-"))
        (msg "Test message"))
    (when t
      (set-temporary-overlay-map 
       (let ((map (make-sparse-keymap)))
         (dolist (binding bindings map)
           (define-key map (read-kbd-macro "-")
             `(lambda ()
                (interactive)
                (setq this-command `,(cadr ',binding))
                (or (minibufferp) (message "%s" ,msg))
                (eval `,(cdr ',binding))))))
       t)
      (or (minibufferp) (message "%s" msg)))))

(defun dtc-test2 ()
  (interactive)
  (set-temporary-overlay-map dtc-current-map))

(defun dtc-move-overlay (expr &optional move-cursor)
  (interactive)
  (set-temporary-overlay-map dtc-current-map)
  (let ((new-pos nil))
    (dolist (overlay (list dtc-cursor))
      (save-excursion
        (goto-char
         (overlay-start overlay))
        (eval expr)
        (if (eolp)
            (progn
              (move-overlay overlay (point) (point))
              (overlay-put overlay 'after-string (propertize " " 'face 'dtc-cursor-face)))
          (progn
            (move-overlay overlay (point) (+ (point) 1))
            (overlay-put overlay 'after-string nil)
            (overlay-put overlay 'face 'dtc-cursor-face)))
        (setq new-pos (point)))
      (when move-cursor
        (goto-char new-pos)))))

(defun dtc-new-line-below ()
  (interactive)
  (goto-char (line-end-position))
  (newline)
  (dtc-attach-all))

(defun dtc-new-line-above ()
  (interactive)
  (forward-line -1)
  (goto-char (line-end-position))
  (newline)
  (dtc-attach-all))

(defun dtc-delete-line ()
  (interactive)
  (goto-char (line-beginning-position))
  (kill-line)
  (kill-line))

(defun dtc-goto-eol ()
  (interactive)
  (goto-char (line-end-position))
  (dtc-attach-all))

(defun dtc-forward-word ()
  (interactive)
  (dtc-move-overlay '(forward-word)))

(defun dtc-backward-word ()
  (interactive)
  (dtc-move-overlay '(forward-word -1)))

(defun dtc-occurrence-of-char-to-the-right (char)
  (interactive "cInput character: ")
  (dtc-move-overlay '(search-forward (char-to-string char))))

(defun dtc-forward-word-alt ()
  (interactive)
  (dtc-move-overlay '(forward-word) t))

(defun dtc-backward-word-alt ()
  (interactive)
  (dtc-move-overlay '(forward-word -1) t))

(defun dtc-next-line ()
  (interactive)
  (dtc-move-overlay '(next-line)))

(defun dtc-previous-line ()
  (interactive)
  (dtc-move-overlay '(previous-line)))

(defun dtc-forward-char ()
  (interactive)
  (dtc-move-overlay '(forward-char)))

(defun dtc-backward-char ()
  (interactive)
  (dtc-move-overlay '(backward-char)))

(defun dtc-forward-sexp ()
  (interactive)
  (dtc-move-overlay '(forward-sexp)))

(defun dtc-backward-sexp ()
  (interactive)
  (dtc-move-overlay '(backward-sexp)))

(defun dtc-expand ()
  (interactive))

(defun dtc-goto-function-definition ()
  (interactive))

(defun dtc-goto-variable-definition()
  (interactive)
  (dtc-move-overlay '(search-backward "(defvar")))

(defun dtc-goto-previous-like-this ()
  (interactive)
  (dtc-move-overlay '(search-backward (thing-at-point 'symbol))))

(defun dtc-attach-here ()
  (interactive)
  (goto-char
   (overlay-start dtc-cursor))
  (dtc-attach))

(defun dtc-up-list ()
  (interactive)
  (dtc-move-overlay '(up-list)))

(defun dtc-down-list ()
  (interactive)
  (dtc-move-overlay '(down-list)))

(defun dtc-custom-mode ()
  (interactive)
  (overlay-put dtc-cursor 'display "c")
  (setq dtc-current-map dtc-custom-mode-map)
  (set-temporary-overlay-map dtc-current-map))

(defun dtc-exit-custom-mode ()
  (interactive)
  (overlay-put dtc-cursor 'display " ")
  (setq dtc-current-map dtc-mode-map)
  (set-temporary-overlay-map dtc-current-map))

(define-minor-mode decur-minor-mode
  "Get your foos in the right places."
  :lighter " decur-minor-mode"
  :keymap dtc-mode-map)

(define-derived-mode decur-major-mode fundamental-mode
  (setq mode-name "decur-major-mode")
  )

(define-key decur-major-mode-map (kbd "n") 'dtc-next-line)
(define-key decur-major-mode-map (kbd "p") 'dtc-previous-line)
(define-key decur-major-mode-map (kbd "f") 'dtc-forward-char)
(define-key decur-major-mode-map (kbd "u") 'dtc-backward-char)

(defun dtc-make-cursor-overlay-at-eol (pos)
  "Create overlay to look like cursor at end of line."
  (let ((overlay (make-overlay pos pos nil nil nil)))
    (overlay-put overlay
                 'after-string (propertize " " 'face 'dtc-cursor-face))
    overlay))

(defun dtc-make-cursor-overlay-inline (pos)
  "Create overlay to look like cursor inside text."
  (let ((overlay (make-overlay pos (1+ pos) nil nil nil)))
    (overlay-put overlay 'face 'dtc-cursor-face)
    overlay))

(defun dtc-make-cursor (map &optional display)
  "Create overlay to look like cursor.
Special case for end of line, because overlay over a newline
highlights the entire width of the window."
  (interactive)
  (let ((overlay nil))
    (setq overlay (if (eolp)
                      (dtc-make-cursor-overlay-at-eol (point))
                    (dtc-make-cursor-overlay-inline (point))))
    (overlay-put overlay 'keymap map)
    (overlay-put overlay 'tag 'decur)
    (when display
      (overlay-put overlay 'display display))
    overlay))

(defun dtc-detach ()
  (interactive)
  (setq dtc-current-map dtc-mode-map)
  (set-temporary-overlay-map dtc-current-map)
  (setq dtc-cursor (dtc-make-cursor dtc-current-map)))

(defun dtc--detach (map &optional display)
  (setq dtc-current-map map)
  (set-temporary-overlay-map dtc-current-map)
  (setq dtc-cursor (dtc-make-cursor dtc-current-map display)))

(defun dtc-detach-vim-cursor ()
  (interactive)
  (dtc--detach vim-keymap "v"))

(defun dtc-detach-line-cursor ()
  (interactive)
  (dtc--detach dtc-line-mode-map "L"))

(defun dtc-detach-sexp-cursor ()
  (interactive)
  (dtc--detach dtc-sexp-mode-map "S"))

(defun dtc-detach-to-defun ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "(defun" nil t nil)
      (goto-char (- (point) 6))
      (dtc-detach)
      (goto-char (+ (point) 1)))))

(defun dtc-attach ()
  (interactive)
  (delete-overlay dtc-cursor)
  (setq dtc-cursor nil)
  ;; (decur-minor-mode -1)
  ;; (dolist (overlay (car (overlay-lists)))
  ;;   (when (eq (overlay-get overlay 'tag) 'decur)
  ;;     (setq ov-start (overlay-start overlay))
  ;;     (when (eq (overlay-start overlay) (point))
  ;;       (delete-overlay overlay))))
  )

(defun dtc-attach-all ()
  (interactive)
  ;; (decur-minor-mode -1)
  (delete-overlay dtc-cursor)
  (setq dtc-cursor nil)
  ;; (dolist (overlay (overlays-in (point-min) (point-max)))
  ;;   (when (eq (overlay-get overlay 'tag) 'decur)
  ;;     (delete-overlay overlay)))
  )

(defun dtc-switch-to-next ()
  (interactive)
  (let ((max-position (point-max))
        (point (point))
        (ov-start nil))
    (dolist (overlay (car (overlay-lists)))
      (when (eq (overlay-get overlay 'tag) 'decur)
        (setq ov-start (overlay-start overlay))
        (when (and (> ov-start point)
                   (< ov-start max-position))
          (setq max-position ov-start))))
    (goto-char max-position)))

(defun dtc-switch-to-previous ()
  (interactive)
  (let ((min-position 0)
        (point (point))
        (ov-start nil))
    (dolist (overlay (car (overlay-lists)))
      (when (eq (overlay-get overlay 'tag) 'decur)
        (setq ov-start (overlay-start overlay))
        (when (and (< ov-start point)
                   (> ov-start min-position))
          (setq min-position ov-start))))
    (goto-char min-position)))


(when (not (fboundp 'set-temporary-overlay-map))
  ;; Backport this function from newer emacs versions
  (defun set-temporary-overlay-map (map &optional keep-pred)
    "Set a new keymap that will only exist for a short period of time.
The new keymap to use must be given in the MAP variable. When to
remove the keymap depends on user input and KEEP-PRED:

- if KEEP-PRED is nil (the default), the keymap disappears as
  soon as any key is pressed, whether or not the key is in MAP;

- if KEEP-PRED is t, the keymap disappears as soon as a key *not*
  in MAP is pressed;

- otherwise, KEEP-PRED must be a 0-arguments predicate that will
  decide if the keymap should be removed (if predicate returns
  nil) or kept (otherwise). The predicate will be called after
  each key sequence."

    (let* ((clearfunsym (make-symbol "clear-temporary-overlay-map"))
           (overlaysym (make-symbol "t"))
           (alist (list (cons overlaysym map)))
           (clearfun
            `(lambda ()
               (unless ,(cond ((null keep-pred) nil)
                              ((eq t keep-pred)
                               `(eq this-command
                                    (lookup-key ',map
                                                (this-command-keys-vector))))
                              (t `(funcall ',keep-pred)))
                 (remove-hook 'pre-command-hook ',clearfunsym)
                 (setq emulation-mode-map-alists
                       (delq ',alist emulation-mode-map-alists))))))
      (set overlaysym overlaysym)
      (fset clearfunsym clearfun)
      (add-hook 'pre-command-hook clearfunsym)

      (push alist emulation-mode-map-alists))))


(provide 'dtc)
