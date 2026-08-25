;;; r-version-tests.el --- ERT for renv/rig R version resolution -*- lexical-binding: t -*-

;; Run headless:
;;   emacs --init-directory=$HOME/.config/emacs -batch -l init.el \
;;     -l tests/r-version-tests.el -f ert-run-tests-batch-and-exit

(require 'ert)

(defun my/rvt--lockdir (content)
  "Make a temp dir holding a renv.lock with CONTENT; return the dir."
  (let ((dir (make-temp-file "rvt" t)))
    (with-temp-file (expand-file-name "renv.lock" dir)
      (insert content))
    dir))

(ert-deftest my/rvt-reads-lockfile-version ()
  (let ((dir (my/rvt--lockdir "{\"R\": {\"Version\": \"4.3.2\"}}")))
    (should (equal (my/renv-lock-r-version dir) "4.3.2"))))

(ert-deftest my/rvt-finds-lockfile-from-subdirectory ()
  (let* ((dir (my/rvt--lockdir "{\"R\": {\"Version\": \"4.6.1\"}}"))
         (sub (expand-file-name "R/deep/" dir)))
    (make-directory sub t)
    (should (equal (my/renv-lock-r-version sub) "4.6.1"))))

(ert-deftest my/rvt-no-lockfile-is-nil ()
  (let ((dir (make-temp-file "rvt-empty" t)))
    (should (null (my/renv-lock-r-version dir)))))

(ert-deftest my/rvt-malformed-lockfile-is-nil ()
  (let ((dir (my/rvt--lockdir "not json at all")))
    (should (null (my/renv-lock-r-version dir)))))

(ert-deftest my/rvt-executable-plain-name ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (name) (when (equal name "R-4.6") "/usr/local/bin/R-4.6"))))
    (should (equal (my/rig-r-executable "4.6.1") "/usr/local/bin/R-4.6"))))

(ert-deftest my/rvt-executable-arm64-suffix ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (name) (when (equal name "R-4.3-arm64")
                              "/usr/local/bin/R-4.3-arm64"))))
    (should (equal (my/rig-r-executable "4.3.2") "/usr/local/bin/R-4.3-arm64"))))

(ert-deftest my/rvt-executable-missing-is-nil ()
  (cl-letf (((symbol-function 'executable-find) (lambda (_) nil)))
    (should (null (my/rig-r-executable "9.9.9")))))

(ert-deftest my/rvt-major-minor-only-version ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (name) (when (equal name "R-4.5") "/usr/local/bin/R-4.5"))))
    (should (equal (my/rig-r-executable "4.5") "/usr/local/bin/R-4.5"))))

;;; r-version-tests.el ends here
