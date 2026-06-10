;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-ayu-dark)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Configure Ediff to show only two columns side-by-side and keep control panel in the same frame
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain
      magit-ediff-dwim-show-on-hunks t)

;; Git diff statistics in Doom Modeline (like LazyVim)
(defun my-diff-hl-stats ()
  "Get the number of added, modified, and deleted lines/hunks from diff-hl or git-gutter."
  (cond
   ((and (bound-and-true-p diff-hl-mode)
         (buffer-file-name))
    (let ((added 0)
          (modified 0)
          (deleted 0))
      (dolist (ov (overlays-in (point-min) (point-max)))
        (when (overlay-get ov 'diff-hl-hunk)
          (let ((type (overlay-get ov 'diff-hl-hunk-type)))
            (cond
             ((eq type 'insert)
              (setq added (+ added (count-lines (overlay-start ov) (overlay-end ov)))))
             ((eq type 'change)
              (setq modified (+ modified (count-lines (overlay-start ov) (overlay-end ov)))))
             ((eq type 'delete)
              (setq deleted (+ deleted 1)))))))
      (list added modified deleted)))
   ((and (bound-and-true-p git-gutter-mode)
         (buffer-file-name))
    (let ((stats (git-gutter:statistic)))
      (if stats
          (list (car stats) 0 (cdr stats))
        '(0 0 0))))
   (t '(0 0 0))))

;; Enable and configure clock
(setq display-time-format "%H:%M"
      display-time-default-load-average nil)
(display-time-mode 1)

(after! doom-modeline
  (setq doom-modeline-time-icon t)

  (doom-modeline-def-segment my-diff-hl-stats
    "Display git diff statistics (additions, modifications, deletions) in modeline."
    (let* ((stats (my-diff-hl-stats))
           (added (nth 0 stats))
           (modified (nth 1 stats))
           (deleted (nth 2 stats)))
      (when (> (+ added modified deleted) 0)
        (concat
         (when (> added 0)
           (propertize (format "   %d" added) 'face (if (facep 'diff-hl-insert) 'diff-hl-insert 'success)))
         (when (> modified 0)
           (propertize (format "   %d" modified) 'face (if (facep 'diff-hl-change) 'diff-hl-change 'warning)))
         (when (> deleted 0)
           (propertize (format "   %d" deleted) 'face (if (facep 'diff-hl-delete) 'diff-hl-delete 'error)))))))

  (doom-modeline-def-modeline 'main
    '(eldoc bar window-state workspace-name window-number modals matches follow buffer-info remote-host buffer-position word-count parrot selection-info)
    '(compilation objed-state misc-info project-name persp-name battery grip irc mu4e gnus github debug repl lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs my-diff-hl-stats check time)))

;; Customize Magit diff colors for better readability/contrast
(custom-set-faces!
  '(magit-diff-added :background "#1d3220" :foreground "#a6e3a1")
  '(magit-diff-added-highlight :background "#29462c" :foreground "#c5f7c1" :weight bold)
  '(magit-diff-removed :background "#3a1d20" :foreground "#f38ba8")
  '(magit-diff-removed-highlight :background "#50292c" :foreground "#ffb3b8" :weight bold)
  '(ediff-current-diff-A :background "#3a1d20" :foreground "#f38ba8")
  '(ediff-current-diff-B :background "#1d3220" :foreground "#a6e3a1")
  '(ediff-current-diff-C :background "#1e293b" :foreground "#7dd3fc")
  '(ediff-current-diff-Ancestor :background "#2e2a1d" :foreground "#fde047")
  '(ediff-fine-diff-A :background "#5f2e32" :foreground "#ffccd0" :weight bold)
  '(ediff-fine-diff-B :background "#2b4c2f" :foreground "#d1ffd7" :weight bold)
  '(ediff-fine-diff-C :background "#2e405a" :foreground "#c8e6ff" :weight bold)
  '(orderless-match-face-0 :foreground "#51afef" :background nil :weight bold)
  '(orderless-match-face-1 :foreground "#c678dd" :background nil :weight bold)
  '(orderless-match-face-2 :foreground "#98be65" :background nil :weight bold)
  '(orderless-match-face-3 :foreground "#ecbe7b" :background nil :weight bold)
  '(completions-common-part :foreground "#51afef" :background nil :weight bold)
  '(completions-first-difference :foreground "#c678dd" :background nil :weight bold)
  '(vertico-current :background "#303030" :foreground "#ffffff" :weight bold)
  '(corfu-current :background "#303030" :foreground "#ffffff" :weight bold)
  '(mode-line :background "#161616" :foreground "#bfbdb6" :inverse-video nil)
  '(mode-line-inactive :background "#0d0d0d" :foreground "#5c6773" :inverse-video nil)
  '(solaire-mode-line-face :background "#161616" :foreground "#bfbdb6" :inverse-video nil)
  '(solaire-mode-line-inactive-face :background "#0d0d0d" :foreground "#5c6773" :inverse-video nil)
  '(doom-modeline-project-dir :foreground "#bfbdb6" :weight normal)
  '(doom-modeline-buffer-path :foreground "#bfbdb6" :weight normal)
  '(doom-modeline-buffer-file :foreground "#bfbdb6" :weight normal)
  '(doom-modeline-buffer-modified :foreground "#bfbdb6" :weight normal)
  '(doom-modeline-vcs :foreground "#bfbdb6" :weight normal)
  '(doom-modeline-time :foreground "#bfbdb6" :weight normal)
  '(line-number :foreground "#5c6773" :background nil)
  '(line-number-current-line :foreground "#e6b450" :background nil :weight bold)
  '(solaire-line-number-face :foreground "#5c6773" :background nil)
  '(hl-line :background nil)
  '(solaire-hl-line-face :background nil))

;; Integration with Windows Clipboard in WSL terminal (Commented out because it fails with 'Exec format error')
;; (when (and (eq system-type 'gnu/linux)
;;            (string-match-p "microsoft" (downcase (shell-command-to-string "uname -a")))
;;            (not (display-graphic-p)))
;;   (require 'subr-x)
;;   (defun wsl-copy (text)
;;     (when (and text (not (string-empty-p text)))
;;       (let ((coding-system-for-write 'utf-8))
;;         (with-temp-buffer
;;           (insert text)
;;           (call-process-region (point-min) (point-max)
;;                                "/init" nil nil nil
;;                                "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
;;                                "-NoProfile" "-Command" "Set-Clipboard -Value ($input | Out-String).TrimEnd()")))))
;;   (defun wsl-paste ()
;;     (let ((coding-system-for-read 'utf-8))
;;       (with-temp-buffer
;;         (call-process "/init" nil t nil
;;                       "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
;;                       "-NoProfile" "-Command" "Get-Clipboard")
;;         (string-trim-right (buffer-string)))))
;;   (setq interprogram-cut-function 'wsl-copy
;;         interprogram-paste-function 'wsl-paste))

;; Disable eglot-booster if emacs-lsp-booster is not installed
(after! eglot-booster
  (unless (executable-find "emacs-lsp-booster")
    (eglot-booster-mode -1)))

;; Disable flyspell in git commit buffers if no spell checker is installed
(after! flyspell
  (unless (or (executable-find "ispell")
              (executable-find "aspell")
              (executable-find "hunspell"))
    (remove-hook 'git-commit-mode-hook #'flyspell-mode)))


;; ── Indent Guides estilo LazyVim ──

(after! indent-bars
  ;; ── Obligar a usar caracteres (esencial en terminal/Android) ──
  (setq indent-bars-prefer-character t
        indent-bars-char ?│
        indent-bars-no-color-char ?│

        ;; Color de la barra: gris azulado, sin mezcla
        indent-bars-color '("#3b4261" :blend 0.0)

        ;; Color de highlight (se usa en indent-bars--set-current-depth-highlight)
        indent-bars-highlight-current-depth
        '(:color "#7aa2f7" :blend 1.0)

        ;; Sin variación por profundidad (más limpio)
        indent-bars-color-by-depth nil
        ;; Mostrar guías incluso en líneas en blanco
        indent-bars-display-on-blank-lines 'least

        ;; Empezar desde la columna 0
        indent-bars-starting-column 0)

  ;; ── Reemplazar highlight interno por el nuestro (basado en columna) ──

  (defvar-local +jd/indent-bars--cursor-depth -1)

  (defun +jd/indent-bars-cursor-highlight ()
    (when indent-bars-mode
      (let* ((col (current-column))
             (spacing (or indent-bars-spacing 1))
             (offset (or indent-bars--offset 0))
             (depth (if (>= col offset)
                        (1+ (/ (- col offset) spacing))
                      0)))
        (unless (= depth +jd/indent-bars--cursor-depth)
          (setq +jd/indent-bars--cursor-depth depth)
          (indent-bars--set-current-depth-highlight depth)))))

  (defun +jd/indent-bars-after-setup ()
    "Después de indent-bars-setup: quita highlight interno, pone el nuestro."
    (remove-hook 'post-command-hook
                 #'indent-bars--update-current-depth-highlight t)
    (add-hook 'post-command-hook
              #'+jd/indent-bars-cursor-highlight nil t)
    (+jd/indent-bars-cursor-highlight))

  (advice-add #'indent-bars-setup :after #'+jd/indent-bars-after-setup))

;; ── Forzar guías de indentación en archivos HTML y Web con el espaciado correcto ──
(add-hook! '(html-mode-hook mhtml-mode-hook)
  (setq-local indent-bars-spacing-override sgml-basic-offset)
  (indent-bars-mode 1))

(add-hook! 'web-mode-hook
  (setq-local indent-bars-spacing-override web-mode-markup-indent-offset)
  (indent-bars-mode 1))

;; ── Autocompletado instantáneo y corrector en español para LaTeX ──
(add-hook! 'LaTeX-mode-hook
  (setq-local corfu-auto-prefix 1)
  (setq ispell-local-dictionary "es")
  (flyspell-mode 1))

;; ── Configuración de Corfu al estilo LazyVim (Instantáneo, con iconos y bordes limpios) ──
(after! corfu
  (setq corfu-auto-delay 0.02
        corfu-auto-prefix 1
        corfu-auto-trigger "./~"
        corfu-preselect 'first
        corfu-border-width 1)

  (custom-set-faces!
    '(corfu-border :background "#303030")
    '(corfu-default :background "#121212")))

;; CAPF personalizado para completado de rutas robusto en cualquier modo (Python, Julia, LaTeX, etc.)
(defun +jd/cape-file ()
  "Versión robusta de `cape-file' que funciona en cualquier major-mode sin importar la tabla de sintaxis."
  (interactive)
  (require 'cl-lib)
  (require 'cape)
  (cl-letf* ((orig-bounds (symbol-function 'cape--bounds))
             ((symbol-function 'cape--bounds)
              (lambda (thing)
                (let ((bounds (funcall orig-bounds thing)))
                  (if (and bounds (> (cdr bounds) (car bounds)))
                      bounds
                    (save-excursion
                      (let ((end (point)))
                        (skip-chars-backward "^ \t\n\"'")
                        (cons (point) end))))))))
    (cape-file)))

;; Ganchos seguros para completado LSP
(defun +jd/safe-eglot-capf ()
  "Ejecuta el completado de Eglot de forma segura para evitar errores en Corfu."
  (condition-case err
      (eglot-completion-at-point)
    (error
     (message "Eglot completion error: %s" (error-message-string err))
     nil)))

(defun +jd/safe-lsp-capf ()
  "Ejecuta el completado de lsp-mode de forma segura para evitar errores en Corfu."
  (condition-case err
      (lsp-completion-at-point)
    (error
     (message "LSP completion error: %s" (error-message-string err))
     nil)))

;; Habilitar completado de archivos en todos los buffers de programación, texto y configuración
(add-hook! '(prog-mode-hook text-mode-hook conf-mode-hook)
  (defun +corfu-add-cape-file-h ()
    (add-hook 'completion-at-point-functions #'+jd/cape-file -10 t)))

;; Unificar completado de LSP (Eglot/LSP-mode) con completado de archivos y palabras locales (dabbrev)
(defun +jd/eglot-capf-setup ()
  (when (bound-and-true-p eglot--managed-mode)
    (require 'cape)
    (setq-local completion-at-point-functions
                (list #'+jd/safe-eglot-capf
                      #'+jd/cape-file
                      #'cape-dabbrev))))

(defun +jd/lsp-capf-setup ()
  (when (bound-and-true-p lsp-mode)
    (require 'cape)
    (setq-local completion-at-point-functions
                (list #'+jd/safe-lsp-capf
                      #'+jd/cape-file
                      #'cape-dabbrev))))

(add-hook 'eglot-managed-mode-hook #'+jd/eglot-capf-setup)
(add-hook 'lsp-managed-mode-hook #'+jd/lsp-capf-setup)

;; Evitar que Eglot intente autoiniciar si el archivo está en la raíz de la carpeta Home (~/)
;; ya que Basedpyright intentará escanear de forma recursiva toda la carpeta Home y congelará Emacs.
(defun +jd/eglot-ensure-safe-advice (orig-fun &rest args)
  "Prevent eglot-ensure from running if the project root is the home directory."
  (let* ((proj (project-current))
         (proj-root (if proj (project-root proj) default-directory)))
    (unless (string-equal (directory-file-name (expand-file-name proj-root))
                          (directory-file-name (expand-file-name "~/")))
      (apply orig-fun args))))

(advice-add 'eglot-ensure :around #'+jd/eglot-ensure-safe-advice)

;; ── Activación automática de entornos virtuales (venv / uv) ──
(defun +jd/python-auto-venv-h ()
  "Detecta automáticamente si hay un entorno virtual (carpeta con pyvenv.cfg)
en la raíz del proyecto y lo activa antes de que inicie el autocompletado."
  (when (derived-mode-p 'python-mode)
    (require 'pyvenv)
    (let* ((proj (project-current))
           (proj-root (if proj (project-root proj) default-directory))
           (venv-path nil))
      ;; Buscar un subdirectorio inmediato en la raíz que contenga 'pyvenv.cfg'
      (when (file-directory-p proj-root)
        (let ((files (directory-files proj-root t)))
          (dolist (file files)
            (let ((name (file-name-nondirectory file)))
              (when (and (not (member name '("." "..")))
                         (file-directory-p file)
                         (file-exists-p (expand-file-name "pyvenv.cfg" file)))
                (setq venv-path file))))))
      ;; Si encontramos un entorno virtual, lo activamos
      (when venv-path
        (unless (and (boundp 'pyvenv-virtual-env-name)
                     (string-equal pyvenv-virtual-env-name venv-path))
          (pyvenv-activate venv-path)
          (message "LSP/Emacs: Entorno virtual activo -> %s" venv-path))))))

(add-hook 'python-mode-hook #'+jd/python-auto-venv-h)

;; ── Configuración de Basedpyright y Pyright en Eglot ──
;; Desactiva los avisos de "missing type stubs" y ajusta el nivel de chequeo a "standard"
;; para evitar alertas ruidosas de librerías de terceros (como numpy, matplotlib, etc.)
(defvar +jd/basedpyright-analysis-settings
  '(:typeCheckingMode "off"
    :reportMissingTypeStubs "none"
    :reportUnknownMemberType "none"
    :reportUnknownVariableType "none"
    :reportUnknownArgumentType "none"
    :reportUnknownParameterType "none"
    :reportAttributeAccessIssue "none"
    :reportUnusedCallResult "none"
    :diagnosticSeverityOverrides (:reportMissingTypeStubs "none"
                                  :reportUnknownMemberType "none"
                                  :reportUnknownVariableType "none"
                                  :reportUnknownArgumentType "none"
                                  :reportUnknownParameterType "none"
                                  :reportAttributeAccessIssue "none"
                                  :reportUnusedCallResult "none"))
  "Common Basedpyright/Pyright analysis settings.")

(setq-default eglot-workspace-configuration
              `(:basedpyright.analysis ,+jd/basedpyright-analysis-settings
                :python.analysis ,+jd/basedpyright-analysis-settings
                :pyright.analysis ,+jd/basedpyright-analysis-settings
                :basedpyright (:analysis ,+jd/basedpyright-analysis-settings)
                :pyright (:analysis ,+jd/basedpyright-analysis-settings)
                :python (:analysis ,+jd/basedpyright-analysis-settings)))

;; ── Optimizaciones de Rendimiento y LSP ──
(setq read-process-output-max (* 1024 1024)    ; 1MB
      gc-cons-threshold (* 100 1024 1024)      ; 100MB
      lsp-idle-delay 0.5
      lsp-log-io nil)

(after! eglot
  ;; Desactivar logging de eventos en eglot para evitar sobrecarga de CPU y memoria
  (setf (plist-get eglot-events-buffer-config :size) 0)
  ;; Desactivar inlay hints (anotaciones virtuales de tipo como NDArray[float64] dentro del código)
  (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider))

;; ── Integración con emacs-lsp-booster ──
(use-package! eglot-booster
  :after eglot
  :config
  (eglot-booster-mode 1))

;; ── Configuración de Vterm con libvterm vendada para evitar crashes ABI ──
(setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=no")

;; ── Desactivar el resaltado de la línea actual (hl-line-mode) ──
(remove-hook 'doom-first-buffer-hook #'global-hl-line-mode)

;; ── Treemacs Open Files Highlighting ──
(defface my-treemacs-open-file-face
  '((t :foreground "#BA5B0B" :weight bold))
  "Face utilizada para resaltar los archivos abiertos en Treemacs."
  :group 'treemacs)

(defun my-treemacs-highlight-open-files-in-current-buffer (&rest _args)
  "Resalta los archivos en Treemacs que coincidan con buffers abiertos."
  (when (derived-mode-p 'treemacs-mode)
    (with-silent-modifications
      (let ((inhibit-read-only t)
            (open-files (make-hash-table :test 'equal)))
        ;; Registrar todos los archivos con buffers activos
        (dolist (buf (buffer-list))
          (let ((file (buffer-file-name buf)))
            (when (and file (file-exists-p file))
              (puthash (expand-file-name file) t open-files))))
        
        ;; Limpiar resaltados anteriores
        (remove-overlays (point-min) (point-max) 'my-treemacs-open-file t)
        
        ;; Recorrer el árbol línea por línea
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (save-excursion
              ;; Ir al final de la línea para asegurar estar sobre el botón del archivo
              (goto-char (line-end-position))
              (when (> (point) (line-beginning-position))
                (backward-char 1))
              (let* ((node (treemacs-node-at-point))
                     (path (and node (treemacs-button-get node :path))))
                (when (and path 
                           (not (file-directory-p path))
                           (gethash (expand-file-name path) open-files))
                  ;; Aplicar el color solo al texto del nombre del archivo
                  (let* ((beg (or (and (fboundp 'button-start) (button-start node))
                                  (line-beginning-position)))
                         (end (or (and (fboundp 'button-end) (button-end node))
                                  (line-end-position)))
                         (ov (make-overlay beg end)))
                    (overlay-put ov 'my-treemacs-open-file t)
                    (overlay-put ov 'face 'my-treemacs-open-file-face)))))
            (forward-line 1)))))))

(defun my-treemacs-highlight-open-files-all-buffers (&rest _args)
  "Aplica el resaltado en todos los buffers activos de Treemacs."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'treemacs-mode)
        (my-treemacs-highlight-open-files-in-current-buffer)))))

(defun my-treemacs-highlight-open-files-trigger ()
  "Dispara el resaltado si hay alguna ventana de Treemacs visible."
  (let ((visible nil))
    (walk-windows (lambda (w)
                    (when (with-current-buffer (window-buffer w)
                            (derived-mode-p 'treemacs-mode))
                      (setq visible t)))
                  nil t)
    (when visible
      (my-treemacs-highlight-open-files-all-buffers))))

(with-eval-after-load 'treemacs
  ;; Actualizar después de que Treemacs refresque su árbol
  (add-hook 'treemacs-post-refresh-hook #'my-treemacs-highlight-open-files-all-buffers)
  ;; Actualizar cuando cambies, abras o cierres buffers en Emacs
  (add-hook 'buffer-list-update-hook #'my-treemacs-highlight-open-files-trigger))
