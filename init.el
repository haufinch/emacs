;;; init.el --- layer 1: baseline -*- lexical-binding: t -*-

;; Layer 1 of the rebuild (bead emacs-uaa): sane defaults and the two
;; packages the scaffolding decisions put at the start — no-littering and
;; the theme. Navigation/completion, git, terminal, R and Claude come as
;; later layers, each only after this one is boring.

;;; Package bootstrap

;; Explicit bootstrap so a cold start works identically in a GUI session and
;; in the batch load-check (where startup's auto package-initialize does not
;; run).
(require 'package)
;; The theme and no-littering are MELPA packages; GNU/NonGNU ELPA (defaults)
;; carry most of what later layers need.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; First run on an empty elpa/ has no archive index; fetch it once.
(unless package-archive-contents
  (package-refresh-contents))

;; use-package-ensure must be required explicitly: the autoloaded use-package
;; macro alone leaves the :ensure keyword unhandled (verified in batch — every
;; declaration silently skipped installation).
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;;; Generated-file hygiene

;; Generated files (transient history, recentf, auto-saves, ...) land under
;; etc/ and var/ instead of littering this directory, which is a git repo.
;; First package by design: it must be active before anything else writes
;; state.
(use-package no-littering
  :demand t
  :config
  ;; Backup clutter next to working files was a standing annoyance; keep the
  ;; backups but let no-littering place them.
  (setq backup-directory-alist
        `(("." . ,(no-littering-expand-var-file-name "backup/")))))

;; package.el writes package-selected-packages via Custom on every install;
;; without this it appends to init.el — a tracked file.
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;;; Theme

;; Dracula across frame and buffers — carried-over preference, not a trial.
;; The t arg skips the load-theme confirmation prompt for an installed theme.
(use-package dracula-theme
  :demand t
  :config (load-theme 'dracula t))

;;; Baseline defaults

;; Default face at 14pt — the stock size is too small on this display.
;; :height is 1/10 pt; tune here, not per-mode.
(set-face-attribute 'default nil :height 140)

;; y/n instead of yes/no: fewer keystrokes on constant confirmations.
(setq use-short-answers t)

;; The startup screen is noise on every launch.
(setq inhibit-startup-screen t)

;; Audible bell on C-g is an irritation, not information.
(setq ring-bell-function #'ignore)

;; Automatic splits (R console, magit, help) open beside the current window,
;; not below it: never stack on height, allow side-by-side once the frame
;; fits two ~60-column windows.
(setq split-height-threshold nil)
(setq split-width-threshold 120)

;; Reopen files at the point they were left — matches editor muscle memory.
(save-place-mode 1)

;; Minibuffer history across sessions; also what the completion stack's
;; ordering will learn from once layer 2 lands.
(savehist-mode 1)

;; Recently opened files, for C-x C-r now and consult sources later.
(recentf-mode 1)

;; Launching the binary directly (the en alias) bypasses LaunchServices, so
;; macOS leaves keyboard focus with the terminal — claim it once startup
;; finishes. Named function so it can be removed cleanly.
(defun my/focus-initial-frame ()
  "Give the initial frame keyboard focus (skipped in batch/daemon)."
  (when (display-graphic-p)
    (select-frame-set-input-focus (selected-frame))))
(add-hook 'after-init-hook #'my/focus-initial-frame)

;; Land in a folder view of the launch directory instead of *scratch* —
;; opening a project should show the project. Named function, not a lambda,
;; so it can be advised or removed cleanly. Also applies to a bare
;; emacsclient. Session restore (desktop-save-mode) deliberately deferred
;; until its absence proves irritating (bead emacs-uaa.2).
(defun my/initial-dired-buffer ()
  "Return a dired buffer for the directory Emacs was launched in."
  (dired-noselect default-directory))
(setq initial-buffer-choice #'my/initial-dired-buffer)

;;; Layer 2 — navigation / completion (bead emacs-87m)

;; Vertical minibuffer completion; the inventory's command-prompt record
;; (partial match, ~10 visible candidates, movement keys in the list) is this
;; UI. vertico-count already defaults to 10 — no override needed.
(use-package vertico
  :init (vertico-mode 1))

;; Space-separated pattern matching in any order — the "partial matching" the
;; inventory records. basic stays as fallback so exact prefixes still win.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Annotations (docstrings, file sizes, keybindings) beside candidates.
(use-package marginalia
  :init (marginalia-mode 1))

;; Buffer switching with preview — the "navigate processes and open new
;; buffers" need from the layer-1 soak — and in-buffer line search. More
;; consult commands only when a concrete need names them.
(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("C-s" . consult-line)))

;; In-buffer completion popup; corfu-auto gives the as-you-type feel the
;; Positron habit expects. Built-in completion-at-point has no popup UI.
(use-package corfu
  :custom (corfu-auto t)
  :init (global-corfu-mode 1))

;; embark deliberately omitted: it changes workflow rather than feel, and
;; the layer-2 verdict should not depend on learning it.

;;; Layer 3 — project + git (bead emacs-mtw)

;; project.el is built in; nothing to configure yet. The worktree helper
;; (bead emacs-mtw.2) and per-worktree windows (emacs-mtw.1) come next.

;; magit: the inventory's git loop (status, diffs, discard/commit/pull/push)
;; is stock magit, and edamagit muscle memory transfers. Built-in vc.el
;; covers less of that surface, hence the package.
(use-package magit
  :bind ("C-x g" . magit-status))

;;; Layer 5 core — R console (bead emacs-l82)

;; ESS gives the R eval loop: M-x R for a console, C-RET to send the line or
;; region and step. Runs R in a comint buffer — no terminal emulator needed,
;; which is why this lands before the layer-4 backend decision (that choice
;; gates only Claude Code). eglot/languageserver, the Air hook, the test
;; panel and Quarto stay as separate beads under this layer.
(use-package ess
  :defer t
  :init
  ;; Start R in default-directory without prompting — launching from a
  ;; worktree's buffer puts its console in that worktree, which is the
  ;; one-console-per-worktree habit from the inventory.
  (setq ess-ask-for-ess-directory nil))

;; ace-window: M-o jumps to any window by home-row label (direct jump when
;; only two windows exist). Kept alongside windmove by explicit preference —
;; the key placement feels more natural than shifted arrows.
(use-package ace-window
  :bind ("M-o" . ace-window)
  :custom
  ;; Labels on the home row instead of the default number keys.
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;;; Keybindings

;; Paragraph movement on M-n/M-p — the emacs-mcx carry-over, kept over the
;; M-{ / M-} defaults by soak verdict (decision bead emacs-uaa.1).
(keymap-global-set "M-n" #'forward-paragraph)
(keymap-global-set "M-p" #'backward-paragraph)

;;; init.el ends here
