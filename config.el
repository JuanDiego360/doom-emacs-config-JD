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
(setq doom-theme 'doom-miramare)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; ── Modeline: mostrar hora y estado git detallado ──

;; Variables y función auxiliar (no requieren doom-modeline cargado)
(defvar-local jd/git-diff-cache nil
  "Cached git diff stats: (files . (added . removed)) or nil.")
(defvar-local jd/git-diff-cache-buffer nil
  "Buffer content hash for cache invalidation.")
(defvar-local jd/git-diff-cache-time 0
  "Time when the cache was last updated.")

(defun jd/get-git-diff-stats ()
  "Return string like '+5 -3 ~2' with lines added/removed + files modified."
  (when (and buffer-file-name
             (executable-find "git")
             (locate-dominating-file default-directory ".git"))
    (let* ((buffer-hash (buffer-hash))
           (now (float-time)))
      (unless (and jd/git-diff-cache
                   (equal jd/git-diff-cache-buffer buffer-hash)
                   (< (- now jd/git-diff-cache-time) 3))
        (setq jd/git-diff-cache
              (with-temp-buffer
                (when (zerop (call-process "git" nil t nil
                                           "diff" "--shortstat" "HEAD"))
                  (goto-char (point-min))
                  (let ((files 0) (added 0) (removed 0))
                    (when (re-search-forward
                           "\\([0-9]+\\) files? changed" nil t)
                      (setq files (string-to-number (match-string 1))))
                    (goto-char (point-min))
                    (when (re-search-forward
                           "\\([0-9]+\\) insertion" nil t)
                      (setq added (string-to-number (match-string 1))))
                    (goto-char (point-min))
                    (when (re-search-forward
                           "\\([0-9]+\\) deletion" nil t)
                      (setq removed (string-to-number (match-string 1))))
                    (cons files (cons added removed)))))
              jd/git-diff-cache-buffer buffer-hash
              jd/git-diff-cache-time now)))
    (when jd/git-diff-cache
      (let ((files (car jd/git-diff-cache))
            (added (cadr jd/git-diff-cache))
            (removed (cddr jd/git-diff-cache)))
        (unless (and (zerop files) (zerop added) (zerop removed))
          (concat
           (propertize (format "+%d" added) 'face 'doom-modeline-info)
           " "
           (propertize (format "-%d" removed) 'face 'doom-modeline-urgent)
           " "
           (propertize (format "~%d" files) 'face 'doom-modeline-warning)))))))

;; Configuración de doom-modeline (se ejecuta cuando el paquete carga)
(after! doom-modeline
  ;; ── Hora ──
  (setq display-time-24hr-format t)
  (display-time-mode 1)
  (setq doom-modeline-time t
        doom-modeline-time-icon t
        doom-modeline-time-live t)

  ;; ── VCS (rama de git) ──
  (setq doom-modeline-vcs t)

  ;; ── Iconos y estilo ──
  (setq doom-modeline-icon t
        doom-modeline-bar-width 3
        doom-modeline-height 25
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-encoding t
        doom-modeline-github nil)

  ;; ── Segmento personalizado de git (se añade después de la rama) ──
  (doom-modeline-def-segment jd/vcs-diff-stats
    "Muestra +añadidas -quitadas ~archivos modificados."
    (jd/get-git-diff-stats))

  (doom-modeline-add-segment 'jd/vcs-diff-stats 'vcs :after 'main))


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


;; ── Configuración para Markdown (Modo Lectura / Renderizado) ──

(use-package! valign
  :defer t
  :config
  (setq valign-fancy-bar t))

(use-package! mixed-pitch
  :defer t
  :config
  ;; Asegurar que las fuentes fijas incluyan código y tablas en markdown
  (after! markdown-mode
    (add-to-list 'mixed-pitch-fixed-pitch-faces 'markdown-code-face)
    (add-to-list 'mixed-pitch-fixed-pitch-faces 'markdown-inline-code-face)
    (add-to-list 'mixed-pitch-fixed-pitch-faces 'markdown-table-face)))

(after! markdown-mode
  ;; Estilos de cabeceras proporcionales y legibles
  (custom-set-faces!
    '(markdown-header-face-1 :height 1.45 :weight bold :inherit variable-pitch)
    '(markdown-header-face-2 :height 1.3 :weight bold :inherit variable-pitch)
    '(markdown-header-face-3 :height 1.18 :weight bold :inherit variable-pitch)
    '(markdown-header-face-4 :height 1.12 :weight bold :inherit variable-pitch)
    '(markdown-header-face-5 :height 1.08 :weight bold :inherit variable-pitch)
    '(markdown-header-face-6 :height 1.04 :weight bold :inherit variable-pitch)
    ;; Estilo tipo KBD / Caja para código en línea
    `(markdown-inline-code-face
      :background "#292e42" ; fondo discreto de Tokyo Night
      :foreground "#ff9e64" ; naranja suave
      :weight normal
      :inherit fixed-pitch
      :box (:line-width (3 . -1) :color "#292e42" :style nil)))

  ;; Palabras clave de font-lock para embellecer las tablas y bloques de código al estilo de Leaf / Glow
  (defvar jd/markdown-table-prettify-keywords
    '(;; 1. Forzar fuente fija (fixed-pitch) en toda la línea de la tabla para alinearla
      ("^[ \t]*\\(|.*|\\)$" 0 'fixed-pitch append)
      ;; 2. Convertir barras verticales '|' en '│' y hacerlas visibles (anulando markdown-hide-markup)
      ("^[ \t]*\\(|\\)\\(.*\\)"
       (1 '(face fixed-pitch invisible nil display "│") prepend)
       ("[ \t]*\\(|\\)[ \t]*" (save-excursion (goto-char (match-beginning 0)) (line-end-position)) nil
        (1 '(face fixed-pitch invisible nil display "│") prepend)))
      ;; 3. Convertir guiones '-' y ':' de la fila divisoria en una línea continua '─'
      ("^[ \t]*|\\([-:| \t]+\\)$"
       ("[-:]" (save-excursion (goto-char (match-beginning 0)) (line-end-position)) nil
        (0 '(face fixed-pitch display "─") prepend)))
      ;; 4. Mostrar el lenguaje del bloque de código como una etiqueta elegante y ocultar las comillas ```
      ("^[ \t]*\\(```\\)\\([a-zA-Z0-9-+#]+\\)"
       (1 '(face nil invisible nil display "    ") prepend)
       (2 '(face (:background "#2e3047" :foreground "#7aa2f7" :weight bold :box (:line-width (4 . -1) :color "#2e3047")) invisible nil) prepend))
      ;; 5. Convertir comillas de cierre del bloque de código en una línea divisoria inferior discreta
      ("^[ \t]*\\(```\\)$"
       (1 '(face (:foreground "#2e3047") invisible nil display "  ──────────────────────────────────────────") prepend)))
    "Keywords de font-lock para embellecer visualmente tablas y bloques de código en modo lectura.")

  ;; Definición del minor mode para el modo lectura/renderizado
  (define-minor-mode jd/markdown-read-mode
    "Modo menor para leer y renderizar Markdown de forma limpia."
    :init-value nil
    :lighter " MD-Read"
    :keymap nil
    (if jd/markdown-read-mode
        (progn
          ;; 1. Ocultar marcado (forzar activación con 1)
          (markdown-toggle-markup-hiding 1)
          ;; 2. Activar mixed-pitch para fuente proporcional
          (mixed-pitch-mode 1)
          ;; 3. Activar el embellecimiento visual de tablas y bloques estilo Leaf
          (font-lock-add-keywords nil jd/markdown-table-prettify-keywords)
          ;; 4. Ocultar números de línea
          (display-line-numbers-mode -1))
      ;; Al desactivar:
      ;; 1. Mostrar marcado de nuevo (forzar desactivación con -1)
      (markdown-toggle-markup-hiding -1)
      ;; 2. Desactivar mixed-pitch
      (mixed-pitch-mode -1)
      ;; 3. Desactivar el embellecimiento visual de tablas y bloques de código
      (font-lock-remove-keywords nil jd/markdown-table-prettify-keywords)
      ;; 4. Restaurar números de línea
      (display-line-numbers-mode 1))
    ;; Forzar el reinicio completo de font-lock para aplicar y renderizar los cambios en caliente
    (font-lock-mode -1)
    (font-lock-mode 1))

  ;; Mapeo de tecla SPC t m dentro de markdown-mode
  (map! :map markdown-mode-map
        :leader
        :desc "Toggle Markdown Render"
        "t m" #'jd/markdown-read-mode)

  ;; Función para abrir el archivo en term nativo con Leaf a la derecha
  (defun jd/markdown-open-in-leaf ()
    "Abre el archivo Markdown actual en un panel term (nativo) a la derecha ejecutando 'leaf'."
    (interactive)
    (require 'term)
    (unless (derived-mode-p 'markdown-mode)
      (user-error "Este comando solo se puede usar en buffers de Markdown"))
    (unless buffer-file-name
      (user-error "El buffer actual no está asociado a ningún archivo en el disco"))
    ;; Guardar automáticamente el archivo si tiene cambios para que Leaf muestre lo más reciente
    (when (buffer-modified-p)
      (save-buffer))
    (let* ((file-path (expand-file-name buffer-file-name))
           (buffer-name (format "leaf: %s" (file-name-nondirectory file-path)))
           (leaf-buffer (get-buffer (format "*%s*" buffer-name)))
           (leaf-window (and leaf-buffer (get-buffer-window leaf-buffer))))
      (if leaf-window
          ;; Si la ventana de Leaf ya está visible, la cerramos (Toggle Off)
          (delete-window leaf-window)
        ;; Si no está visible, dividimos la ventana a la derecha y abrimos Leaf
        (let ((new-window (split-window-right)))
          (select-window new-window)
          (if (and leaf-buffer (buffer-live-p leaf-buffer))
              ;; Si el buffer de Leaf ya existe pero no estaba visible, lo matamos y lo recreamos para refrescar
              (progn
                (kill-buffer leaf-buffer)
                (let ((leaf-path (executable-find "leaf")))
                  (unless leaf-path
                    (user-error "No se encontró el comando 'leaf' en tu sistema"))
                  (let ((term-buffer (make-term buffer-name leaf-path nil file-path)))
                    (switch-to-buffer term-buffer)
                    (term-mode)
                    (term-char-mode))))
            ;; Si el buffer no existe, lo creamos
            (let ((leaf-path (executable-find "leaf")))
              (unless leaf-path
                (user-error "No se encontró el comando 'leaf' en tu sistema"))
              (let ((term-buffer (make-term buffer-name leaf-path nil file-path)))
                (switch-to-buffer term-buffer)
                (term-mode)
                (term-char-mode))))))))

  ;; Mapeo de tecla SPC t L dentro de markdown-mode para abrir con Leaf
  (map! :map markdown-mode-map
        :leader
        :desc "Toggle Leaf Viewer (term)"
        "t L" #'jd/markdown-open-in-leaf))


;; ── Configuración de colores para scripts Shell (.zshrc, .zshrc_custom) ──

;; Asociar cualquier variante de .zshrc (como .zshrc_custom) a sh-mode
(add-to-list 'auto-mode-alist '("\\.zshrc.*\\'" . sh-mode))

(after! sh-script
  ;; Añadir reglas de resaltado personalizadas para que las estructuras de control
  ;; como if, then, else, fi, for, while, etc., resalten en un color llamativo y
  ;; no se vean planas. Usamos 'font-lock-warning-face' (naranja/amarillo vibrante) para que resalten.
  (font-lock-add-keywords 'sh-mode
    '(("\\<\\(if\\|then\\|elif\\|else\\|fi\\|for\\|in\\|do\\|done\\|while\\|until\\|case\\|esac\\)\\>"
       0 'font-lock-warning-face prepend))))


;; ── Ajuste de línea automático (Evitar Scroll Horizontal) ──

;; Activar el ajuste de línea automático (soft wrap) de forma global
(global-visual-line-mode 1)


;; ── Configuración de Corfu al estilo LazyVim (Instantáneo, con iconos y bordes limpios) ──
(after! corfu
  (setq corfu-auto-delay 0.02
        corfu-auto-prefix 1
        corfu-auto-trigger "./~"
        corfu-preselect 'first
        corfu-border-width 1)

  (custom-set-faces!
    '(corfu-border :background "#3b4261")
    '(corfu-default :background "#16161e")))

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




