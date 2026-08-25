;;; early-init.el --- frame and native-comp setup before GUI init -*- lexical-binding: t -*-

;; Frame decorations are baseline irritations; setting them here via
;; default-frame-alist avoids a visible flash of toolbar at startup and is
;; batch-safe (no tool-bar-mode call).
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Paint the first frame in Dracula's background; the theme itself loads in
;; init.el, and without this the frame flashes white until it does.
(push '(background-color . "#282a36") default-frame-alist)

;; No macOS title bar or traffic-light buttons — emacs-plus ships the
;; undecorated-round patch, which drops the bar while keeping rounded
;; corners. If a future build lacks the patch, swap for plain
;; (undecorated . t). Note: with no title bar the frame moves via window
;; management (or M-x), not by dragging a bar.
(push '(undecorated-round . t) default-frame-alist)

;; Start at max screen size — a maximized window, not macOS native
;; fullscreen (no separate Space, title-bar-less frame stays put).
(push '(fullscreen . maximized) default-frame-alist)

;; Font or theme changes should not resize the frame mid-session.
(setq frame-inhibit-implied-resize t)

;; Homebrew's gcc and emacs-plus's libgccjit disagree about where gcc's
;; runtime libs live (ld: library 'emutls_w' not found → "error invoking gcc
;; driver" on every async native compile). Point the driver at gcc's lib dir;
;; the wildcard survives gcc version bumps. Set here so it applies before the
;; first package triggers compilation.
(setq native-comp-driver-options
      (list (concat "-B" (car (file-expand-wildcards
                               "/opt/homebrew/opt/gcc/lib/gcc/current/gcc/*/*/")))))

;; Keep natively-compiled artifacts under var/ with the rest of the generated
;; state (this dir is a git repo; eln-cache/ at the root would need its own
;; ignore entry). Must run before any native compilation starts.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name "var/eln-cache/" user-emacs-directory))))

;;; early-init.el ends here
