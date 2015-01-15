(defvar dtc-cursor nil "Overlay for cursor.")

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
  (set-temporary-overlay-map dtc-mode-map))

(defun dtc-move-overlay (expr &optional move-cursor)
  (interactive)
  (set-temporary-overlay-map dtc-mode-map)
  (let ((new-pos nil))
    (dolist (overlay (list dtc-cursor))
      (save-excursion
        (goto-char
         (overlay-start overlay))
        (eval expr)
        (move-overlay overlay (point) (+ (point) 1))
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
    (define-key map "n" 'dtc-next-line)
    (define-key map "p" 'dtc-previous-line)
    (define-key map "f" 'dtc-forward-char)
    (define-key map "F" 'dtc-backward-char)
    (define-key map "b" 'dtc-backward-char)
    (define-key map "q" 'dtc-attach-all)
    ;; (define-key map (kbd "C-n") 'dtc-next-line)
    ;; (define-key map (kbd "C-p") 'dtc-previous-line)
    ;; (define-key map (kbd "C-f") 'dtc-forward-char)
    ;; (define-key map (kbd "C-b") 'dtc-backward-char)
    map))

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
      (overlay-put dtc-cursor 'display display))
    overlay))

(defun dtc-detach ()
  (interactive)
  (set-temporary-overlay-map dtc-mode-map)
  (setq dtc-cursor (dtc-make-cursor dtc-mode-map)))

(defun dtc--detach (map &optional display)
  (set-temporary-overlay-map map)
  (setq dtc-cursor (dtc-make-cursor map display)))

(defun dtc-detach-vim-cursor ()
  (interactive)
  (dtc--detach vim-keymap "v"))

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
