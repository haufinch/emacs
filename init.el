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

;; y/n instead of yes/no: fewer keystrokes on constant confirmations.
(setq use-short-answers t)

;; The startup screen is noise on every launch.
(setq inhibit-startup-screen t)

;; Audible bell on C-g is an irritation, not information.
(setq ring-bell-function #'ignore)

;; Reopen files at the point they were left — matches editor muscle memory.
(save-place-mode 1)

;; Minibuffer history across sessions; also what the completion stack's
;; ordering will learn from once layer 2 lands.
(savehist-mode 1)

;; Recently opened files, for C-x C-r now and consult sources later.
(recentf-mode 1)

;;; Keybinding trial

;; TRIAL (decision bead emacs-uaa.1): the Positron/emacs-mcx habit is alt+n/p
;; for paragraph movement; standard Emacs is M-{ / M-}. Both stay live during
;; the soak so the decision is made by feel rather than argument.
(keymap-global-set "M-n" #'forward-paragraph)
(keymap-global-set "M-p" #'backward-paragraph)

;;; init.el ends here
