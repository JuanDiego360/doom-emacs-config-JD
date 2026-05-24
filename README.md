# Personalización de Doom Emacs (`doom-emacs-config-JD`)

Este repositorio contiene mi configuración personal y optimizada de **Doom Emacs** (`~/.config/doom/`). Está estructurado para ser 100% independiente del framework de Doom Emacs, lo que permite realizar actualizaciones seguras sin perder mis personalizaciones.

---

## 🚀 Características Principales

### 🎨 Estética Premium y Tokyo Night
* **Tema**: Tokyo Night oscuro (`doom-tokyo-night`) para un look moderno y limpio estilo LazyVim.
* **Barra de estado**: Configuración personalizada de `doom-modeline` con soporte nativo de iconos (`nerd-icons`) y barra de color de estado.
* **Reloj integrado**: Reloj del sistema con indicador en vivo y formato integrado en la modeline.

### 🔍 Búsqueda Difusa (Fuzzy Finding)
* **Completado de Minibúfer**: Basado en **Vertico** (diseño vertical limpio) con anotaciones enriquecidas de **Marginalia** (metadata a la derecha).
* **Concordancia Dinámica**: Búsqueda difusa y flexible en cualquier orden potenciada por **Orderless**.
* **Completado de Código**: Auto-completado dentro de los buffers a través de **Corfu** con motor `+orderless`.

### 📝 Renderizado y Visualización de Markdown
* **Modo Lectura Nativo**: Un modo de lectura limpio directo en el buffer que oculta la sintaxis de marcado (`#`, `**`, etc.), desactiva números de línea y aplica tipografía proporcional.
* **Tablas y Bloques con Estilo**: Formateador dinámico para tablas en Markdown con bordes Unicode finos (`│`, `─`) y etiquetas elegantes flotantes para los lenguajes de bloques de código (ej. ` elisp`).
* **Visor Leaf Integrado**: Integración interactiva del renderizador nativo `leaf` en un panel dividido de terminal `term` a la derecha con guardado automático al instante.

---

## ⌨️ Mapa de Atajos Personalizados

Los atajos de teclado personalizados están integrados bajo el prefijo líder `SPC` (o `M-x` / `SPC :` para comandos interactivos):

| Atajo | Comando Emacs | Ámbito | Descripción |
| :--- | :--- | :--- | :--- |
| `SPC t m` | `jd/markdown-read-mode` | Markdown Mode | Activa/Desactiva la vista de lectura limpia del buffer (tablas y bloques formateados). |
| `SPC t L` | `jd/markdown-open-in-leaf` | Markdown Mode | Abre/Cierra de forma automática el visor interactivo `leaf` en un panel a la derecha. |
| `M-x doom/reload` | `doom/reload` | Global | Recarga y evalúa los cambios de `config.el` en caliente sin reiniciar Emacs. |

### 💡 Consejos de Uso para el Visor `leaf` (`SPC t L`):
La terminal integrada de Emacs captura todas tus teclas para enviarlas a `leaf` (permitiéndote navegar con las flechas o presionar `q` para salir). Si deseas liberar los atajos de teclado estándar de Emacs:
* **`C-c C-j`** (modo de línea): Libera el teclado. Los comandos de Doom Emacs como `SPC w c` (cerrar ventana) vuelven a funcionar.
* **`C-c C-k`** (modo de caracteres): Regresa el control a la terminal/visor de Leaf.

---

## 🛠️ Instalación y Sincronización

Si clonas este repositorio en una nueva máquina bajo `~/.config/doom/`, asegúrate de correr los siguientes comandos para descargar las dependencias y aplicar las configuraciones:

```bash
# 1. Sincronizar y compilar paquetes de terceros (mixed-pitch, etc.)
~/.config/emacs/bin/doom sync

# 2. Descargar fuentes de iconos en Emacs (ejecutar dentro de Emacs una vez abierto)
M-x nerd-icons-install-fonts
```
