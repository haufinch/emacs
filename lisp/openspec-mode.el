;;; openspec-mode.el --- major mode for OpenSpec markdown -*- lexical-binding: t -*-

;; OpenSpec (github.com/Fission-AI/OpenSpec) writes specs as structured
;; markdown: `### Requirement:' headers, `#### Scenario:' headers, delta
;; sections (`## ADDED Requirements' ...), bold WHEN/THEN bullets and
;; SHALL-style requirement text. This mode derives from gfm-mode so task
;; checkboxes and everything markdown keep working, and adds font-lock for
;; the OpenSpec structure on top. Format verified against the
;; @fission-ai/openspec templates and parsers (2026-08-26).

(require 'markdown-mode)

(defconst openspec-mode--font-lock-keywords
  `(;; Delta sections a change's spec files use: ## ADDED Requirements
    ("^##\\s-+\\(ADDED\\|MODIFIED\\|REMOVED\\|RENAMED\\)\\s-+Requirements?"
     1 'font-lock-warning-face prepend)
    ;; ### Requirement: Name — the label, not the name
    ("^###\\s-+\\(Requirement:\\)" 1 'font-lock-keyword-face prepend)
    ;; #### Scenario: Name
    ("^####\\s-+\\(Scenario:\\)" 1 'font-lock-keyword-face prepend)
    ;; Scenario steps: - **WHEN** ... / - **THEN** ...
    ("\\*\\*\\(GIVEN\\|WHEN\\|THEN\\|AND\\)\\*\\*" 1 'font-lock-constant-face prepend)
    ;; RFC-style requirement verbs
    ("\\_<SHALL\\(?: NOT\\)?\\_>" 0 'font-lock-keyword-face prepend))
  "Extra font-lock for OpenSpec structure, layered over gfm-mode's.")

;;;###autoload
(define-derived-mode openspec-mode gfm-mode "OpenSpec"
  "Major mode for OpenSpec spec, delta and task documents.
Inherits everything from `gfm-mode' (including checkbox toggling on
task lists) and highlights OpenSpec's structural markup."
  (font-lock-add-keywords nil openspec-mode--font-lock-keywords 'append))

;;;###autoload
(add-to-list 'auto-mode-alist '("/openspec/.*\\.md\\'" . openspec-mode))

(provide 'openspec-mode)
;;; openspec-mode.el ends here
