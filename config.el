;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;;(setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; ── CSV: columnas coloreadas ──
;; Solución con font-lock (rainbow-csv no está en MELPA)

(defvar-local jd/csv--col 0
  "Columna actual durante el font-lock de csv.")

(defvar jd/csv-colors
  ["#f7768e" "#7dcfff" "#e0af68" "#9ece6a" "#bb9af7"
   "#73daca" "#ff9e64" "#2ac3de" "#c0caf5"]
  "Colores cíclicos para las columnas CSV (paleta Tokyo Night).")

;; Crear las caras (faces) una sola vez
(dotimes (i (length jd/csv-colors))
  (let ((face (intern (format "jd/csv-c%d" i)))
        (color (aref jd/csv-colors i)))
    (unless (facep face)
      (make-face face)
      (set-face-foreground face color))))

(defun jd/csv-matcher (limit)
  "Busca campos CSV, reinicia contador de columna al inicio de línea."
  (let ((sep (or (and (boundp 'csv-separator) csv-separator) ","))
        (found nil))
    (while (and (not found)
                (re-search-forward (format "[^%s\n]+" sep) limit t))
      ;; ¿Es el primer campo de la línea? → reinicia contador
      (save-excursion
        (goto-char (match-beginning 0))
        (skip-chars-backward " \t")
        (when (bolp)
          (setq jd/csv--col 0)))
      ;; Guarda índice y avanza
      (setq jd/csv--current-col jd/csv--col)
      (cl-incf jd/csv--col)
      (setq found t))
    found))

(defun jd/csv-face-func ()
  "Devuelve la cara según la columna actual."
  (intern (format "jd/csv-c%d"
                  (mod jd/csv--current-col (length jd/csv-colors)))))

(use-package! csv-mode
  :hook (csv-mode . csv-align-mode)     ; alinea columnas
  :config
  ;; Separadores comunes
  (setq csv-separators '("," ";" "|" "\t"))
  ;; Keywords de font-lock: un color por columna
  (font-lock-add-keywords 'csv-mode
    '((jd/csv-matcher . (0 (jd/csv-face-func) prepend)))))

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
(setq doom-theme 'doom-tokyo-night)

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


