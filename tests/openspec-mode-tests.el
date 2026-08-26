;;; openspec-mode-tests.el --- ERT for openspec-mode -*- lexical-binding: t -*-

;; Run headless:
;;   emacs --init-directory=$HOME/.config/emacs -batch -l early-init.el \
;;     -l init.el -l tests/openspec-mode-tests.el -f ert-run-tests-batch-and-exit

(require 'ert)
(require 'openspec-mode)

(defun my/ost--face-at (content search)
  "Fontify CONTENT in `openspec-mode'; return face(s) at start of SEARCH."
  (with-temp-buffer
    (insert content)
    (delay-mode-hooks (openspec-mode))
    (font-lock-ensure)
    (goto-char (point-min))
    (search-forward search)
    (get-text-property (match-beginning 0) 'face)))

(defun my/ost--has-face (faces face)
  (if (listp faces) (memq face faces) (eq faces face)))

(ert-deftest my/ost-auto-mode-matches-openspec-paths ()
  (should (eq (assoc-default "/x/openspec/specs/auth/spec.md"
                             auto-mode-alist #'string-match)
              'openspec-mode))
  (should-not (eq (assoc-default "/x/notes/readme.md"
                                 auto-mode-alist #'string-match)
                  'openspec-mode)))

(ert-deftest my/ost-derives-from-gfm ()
  (with-temp-buffer
    (delay-mode-hooks (openspec-mode))
    (should (derived-mode-p 'gfm-mode 'markdown-mode))))

(ert-deftest my/ost-requirement-label-fontified ()
  (should (my/ost--has-face
           (my/ost--face-at "### Requirement: Console launch\n" "Requirement:")
           'font-lock-keyword-face)))

(ert-deftest my/ost-scenario-label-fontified ()
  (should (my/ost--has-face
           (my/ost--face-at "#### Scenario: Lockfile present\n" "Scenario:")
           'font-lock-keyword-face)))

(ert-deftest my/ost-delta-section-fontified ()
  (should (my/ost--has-face
           (my/ost--face-at "## ADDED Requirements\n" "ADDED")
           'font-lock-warning-face)))

(ert-deftest my/ost-when-then-fontified ()
  (should (my/ost--has-face
           (my/ost--face-at "- **WHEN** a lockfile exists\n" "WHEN")
           'font-lock-constant-face)))

(ert-deftest my/ost-plain-markdown-untouched ()
  (should-not (my/ost--has-face
               (my/ost--face-at "### Requirements overview\n" "Requirements")
               'font-lock-keyword-face)))

;;; openspec-mode-tests.el ends here
