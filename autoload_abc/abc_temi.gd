# abc_temi.gd - iniziato 10/07/2025 - ultima modifica 10/07/2025 - versione 1.0
# Manager di temi - Sistema completo di gestione temi per Godot 4

# Impostazione del tema grafico
# Aggiungere come Autoload con nome "TG"
# Vai in Project → Project Settings → Autoload → Aggiungi il file con nome "TG"
# Nome: TG, Path: res://autoload_abc/abc_temi.gd

# Caratteristiche principali:

# Esempi d'uso:

extends Node

signal theme_changed
signal font_changed

var default_theme: Theme
var current_theme_name: String = "default"
var themes: Dictionary = {}

# Font system
var fonts: Dictionary = {
	"default": null,
	"title": null,
	"body": null,
	"mono": null,
	"ui": null
}

var current_font_family: String = "default"

# Carica font personalizzati se esistono
var font_paths = {
	"title": "res://fonts/title.ttf",
	"body": "res://fonts/body.ttf",
	"mono": "res://fonts/mono.ttf",
	"ui": "res://fonts/ui.ttf"
}

# Colori del tema - Sistema completo
var color_palettes: Dictionary = {
	"default": {
		"primary": Color("#3498db"),
		"secondary": Color("#2ecc71"),
		"accent": Color("#e74c3c"),
		"background": Color("#2c3e50"),
		"surface": Color("#34495e"),
		"text_primary": Color("#ffffff"),
		"text_secondary": Color("#bdc3c7"),
		"text_disabled": Color("#7f8c8d"),
		"success": Color("#27ae60"),
		"warning": Color("#f39c12"),
		"error": Color("#e74c3c"),
		"info": Color("#3498db"),
		"border": Color("#7f8c8d"),
		"shadow": Color("#000000", 0.3),
		"highlight": Color("#ffffff", 0.1),
		"focus": Color("#3498db", 0.7)
	},
	"dark": {
		"primary": Color("#1e88e5"),
		"secondary": Color("#26a69a"),
		"accent": Color("#ff5722"),
		"background": Color("#121212"),
		"surface": Color("#1e1e1e"),
		"text_primary": Color("#ffffff"),
		"text_secondary": Color("#b0b0b0"),
		"text_disabled": Color("#666666"),
		"success": Color("#4caf50"),
		"warning": Color("#ff9800"),
		"error": Color("#f44336"),
		"info": Color("#2196f3"),
		"border": Color("#404040"),
		"shadow": Color("#000000", 0.5),
		"highlight": Color("#ffffff", 0.05),
		"focus": Color("#1e88e5", 0.7)
	},
	"light": {
		"primary": Color("#1976d2"),
		"secondary": Color("#388e3c"),
		"accent": Color("#d32f2f"),
		"background": Color("#fafafa"),
		"surface": Color("#ffffff"),
		"text_primary": Color("#212121"),
		"text_secondary": Color("#757575"),
		"text_disabled": Color("#bdbdbd"),
		"success": Color("#388e3c"),
		"warning": Color("#f57c00"),
		"error": Color("#d32f2f"),
		"info": Color("#1976d2"),
		"border": Color("#e0e0e0"),
		"shadow": Color("#000000", 0.2),
		"highlight": Color("#ffffff", 0.8),
		"focus": Color("#1976d2", 0.3)
	}
}

var current_palette: Dictionary

# Dimensioni del font
var font_sizes: Dictionary = {
	"tiny": 10,
	"small": 12,
	"medium": 16,
	"large": 20,
	"xl": 24,
	"xxl": 32,
	"title": 36,
	"display": 48
}

# Spaziature e margini
var spacing: Dictionary = {
	"xs": 4,
	"sm": 8,
	"md": 16,
	"lg": 24,
	"xl": 32,
	"xxl": 48
}

# Raggi dei bordi
var border_radius: Dictionary = {
	"none": 0,
	"sm": 2,
	"md": 4,
	"lg": 8,
	"xl": 12,
	"full": 9999
}

# Ombre
var shadows: Dictionary = {
	"none": Vector2(0, 0),
	"sm": Vector2(1, 1),
	"md": Vector2(2, 2),
	"lg": Vector2(4, 4),
	"xl": Vector2(8, 8)
}

# Outline sizes
var outline_sizes: Dictionary = {
	"none": 0,
	"sm": 1,
	"md": 2,
	"lg": 3,
	"xl": 4
}

# Animazioni
var animation_durations: Dictionary = {
	"fast": 0.15,
	"medium": 0.3,
	"slow": 0.5
}

# Breakpoints per responsive design
var breakpoints: Dictionary = {
	"mobile": 480,
	"tablet": 768,
	"desktop": 1024,
	"wide": 1200
}

# === FUNZIONI INIZIALIZZAZIONE ===

func _ready():
	load_default_fonts()
	setup_default_themes()
	setup_preset_themes()  # Imposta i temi predefiniti
	connect_theme_signals()  # Connette i segnali
	set_theme("default")
	# print_current_theme_info() # DEBUG

func setup_default_themes():
	# Crea temi per ogni palette di colori
	for palette_name in color_palettes:
		create_theme_for_palette(palette_name)

func reset_to_defaults():
	# Ripristina tutte le impostazioni ai valori predefiniti
	current_theme_name = "default"
	current_font_family = "default"
	
	# Ripristina le palette di colori originali
	color_palettes = {
		"default": {
			"primary": Color("#3498db"),
			"secondary": Color("#2ecc71"),
			"accent": Color("#e74c3c"),
			"background": Color("#2c3e50"),
			"surface": Color("#34495e"),
			"text_primary": Color("#ffffff"),
			"text_secondary": Color("#bdc3c7"),
			"text_disabled": Color("#7f8c8d"),
			"success": Color("#27ae60"),
			"warning": Color("#f39c12"),
			"error": Color("#e74c3c"),
			"info": Color("#3498db"),
			"border": Color("#7f8c8d"),
			"shadow": Color("#000000", 0.3),
			"highlight": Color("#ffffff", 0.1),
			"focus": Color("#3498db", 0.7)
		}
	}
	
	setup_default_themes()
	setup_preset_themes()
	set_theme("default")
	print("Impostazioni ripristinate ai valori predefiniti")

func create_theme_for_palette(palette_name: String):
	var theme = Theme.new()
	var palette = color_palettes[palette_name]
	
	# Setup Label
	setup_label_theme(theme, palette)
	
	# Setup Button
	setup_button_theme(theme, palette)
	
	# Setup LineEdit
	setup_line_edit_theme(theme, palette)
	
	# Setup Panel
	setup_panel_theme(theme, palette)
	
	# Setup ProgressBar
	setup_progress_bar_theme(theme, palette)
	
	# Setup CheckBox
	setup_checkbox_theme(theme, palette)
	
	# Setup OptionButton
	setup_option_button_theme(theme, palette)
	
	# Setup TabContainer
	setup_tab_container_theme(theme, palette)
	
	# Setup ScrollContainer
	setup_scroll_container_theme(theme, palette)
	
	# Setup PopupMenu
	setup_popup_menu_theme(theme, palette)
	
	themes[palette_name] = theme


# === FUNZIONI SETUP ===

func setup_label_theme(theme: Theme, palette: Dictionary):
	theme.set_font("font", "Label", fonts[current_font_family])
	theme.set_font_size("font_size", "Label", font_sizes.medium)
	theme.set_color("font_color", "Label", palette.text_primary)
	theme.set_color("font_shadow_color", "Label", palette.shadow)
	theme.set_color("font_outline_color", "Label", palette.text_secondary)

func setup_button_theme(theme: Theme, palette: Dictionary):
	# Button Normal
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = palette.primary
	btn_normal.corner_radius_top_left = border_radius.md
	btn_normal.corner_radius_top_right = border_radius.md
	btn_normal.corner_radius_bottom_left = border_radius.md
	btn_normal.corner_radius_bottom_right = border_radius.md
	btn_normal.content_margin_left = spacing.md
	btn_normal.content_margin_right = spacing.md
	btn_normal.content_margin_top = spacing.sm
	btn_normal.content_margin_bottom = spacing.sm
	
	# Button Hover
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = palette.primary.lightened(0.1)
	btn_hover.shadow_color = palette.shadow
	btn_hover.shadow_size = 2
	
	# Button Pressed
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = palette.primary.darkened(0.1)
	
	# Button Disabled
	var btn_disabled = btn_normal.duplicate()
	btn_disabled.bg_color = palette.text_disabled
	
	# Button Focus
	var btn_focus = btn_normal.duplicate()
	btn_focus.border_width_left = 2
	btn_focus.border_width_right = 2
	btn_focus.border_width_top = 2
	btn_focus.border_width_bottom = 2
	btn_focus.border_color = palette.focus
	
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_stylebox("focus", "Button", btn_focus)
	
	theme.set_font("font", "Button", fonts[current_font_family])
	theme.set_font_size("font_size", "Button", font_sizes.medium)
	theme.set_color("font_color", "Button", palette.text_primary)
	theme.set_color("font_hover_color", "Button", palette.text_primary)
	theme.set_color("font_pressed_color", "Button", palette.text_primary)
	theme.set_color("font_disabled_color", "Button", palette.text_disabled)

func setup_line_edit_theme(theme: Theme, palette: Dictionary):
	var line_edit_normal = StyleBoxFlat.new()
	line_edit_normal.bg_color = palette.surface
	line_edit_normal.border_width_left = 1
	line_edit_normal.border_width_right = 1
	line_edit_normal.border_width_top = 1
	line_edit_normal.border_width_bottom = 1
	line_edit_normal.border_color = palette.border
	line_edit_normal.corner_radius_top_left = border_radius.sm
	line_edit_normal.corner_radius_top_right = border_radius.sm
	line_edit_normal.corner_radius_bottom_left = border_radius.sm
	line_edit_normal.corner_radius_bottom_right = border_radius.sm
	line_edit_normal.content_margin_left = spacing.sm
	line_edit_normal.content_margin_right = spacing.sm
	line_edit_normal.content_margin_top = spacing.xs
	line_edit_normal.content_margin_bottom = spacing.xs
	
	var line_edit_focus = line_edit_normal.duplicate()
	line_edit_focus.border_color = palette.focus
	line_edit_focus.border_width_left = 2
	line_edit_focus.border_width_right = 2
	line_edit_focus.border_width_top = 2
	line_edit_focus.border_width_bottom = 2
	
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	theme.set_font("font", "LineEdit", fonts[current_font_family])
	theme.set_font_size("font_size", "LineEdit", font_sizes.medium)
	theme.set_color("font_color", "LineEdit", palette.text_primary)
	theme.set_color("font_selected_color", "LineEdit", palette.text_primary)
	theme.set_color("selection_color", "LineEdit", palette.primary)
	theme.set_color("caret_color", "LineEdit", palette.primary)

func setup_panel_theme(theme: Theme, palette: Dictionary):
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = palette.surface
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = palette.border
	panel_style.corner_radius_top_left = border_radius.md
	panel_style.corner_radius_top_right = border_radius.md
	panel_style.corner_radius_bottom_left = border_radius.md
	panel_style.corner_radius_bottom_right = border_radius.md
	panel_style.shadow_color = palette.shadow
	panel_style.shadow_size = 4
	
	theme.set_stylebox("panel", "Panel", panel_style)

func setup_progress_bar_theme(theme: Theme, palette: Dictionary):
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = palette.surface
	progress_bg.corner_radius_top_left = border_radius.full
	progress_bg.corner_radius_top_right = border_radius.full
	progress_bg.corner_radius_bottom_left = border_radius.full
	progress_bg.corner_radius_bottom_right = border_radius.full
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = palette.primary
	progress_fill.corner_radius_top_left = border_radius.full
	progress_fill.corner_radius_top_right = border_radius.full
	progress_fill.corner_radius_bottom_left = border_radius.full
	progress_fill.corner_radius_bottom_right = border_radius.full
	
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)

func setup_checkbox_theme(theme: Theme, palette: Dictionary):
	var checkbox_unchecked = StyleBoxFlat.new()
	checkbox_unchecked.bg_color = palette.surface
	checkbox_unchecked.border_width_left = 2
	checkbox_unchecked.border_width_right = 2
	checkbox_unchecked.border_width_top = 2
	checkbox_unchecked.border_width_bottom = 2
	checkbox_unchecked.border_color = palette.border
	checkbox_unchecked.corner_radius_top_left = border_radius.sm
	checkbox_unchecked.corner_radius_top_right = border_radius.sm
	checkbox_unchecked.corner_radius_bottom_left = border_radius.sm
	checkbox_unchecked.corner_radius_bottom_right = border_radius.sm
	
	var checkbox_checked = checkbox_unchecked.duplicate()
	checkbox_checked.bg_color = palette.primary
	checkbox_checked.border_color = palette.primary
	
	theme.set_stylebox("unchecked", "CheckBox", checkbox_unchecked)
	theme.set_stylebox("checked", "CheckBox", checkbox_checked)
	theme.set_font("font", "CheckBox", fonts[current_font_family])
	theme.set_font_size("font_size", "CheckBox", font_sizes.medium)
	theme.set_color("font_color", "CheckBox", palette.text_primary)

func setup_option_button_theme(theme: Theme, palette: Dictionary):
	var option_normal = StyleBoxFlat.new()
	option_normal.bg_color = palette.surface
	option_normal.border_width_left = 1
	option_normal.border_width_right = 1
	option_normal.border_width_top = 1
	option_normal.border_width_bottom = 1
	option_normal.border_color = palette.border
	option_normal.corner_radius_top_left = border_radius.sm
	option_normal.corner_radius_top_right = border_radius.sm
	option_normal.corner_radius_bottom_left = border_radius.sm
	option_normal.corner_radius_bottom_right = border_radius.sm
	option_normal.content_margin_left = spacing.sm
	option_normal.content_margin_right = spacing.sm
	option_normal.content_margin_top = spacing.xs
	option_normal.content_margin_bottom = spacing.xs
	
	var option_hover = option_normal.duplicate()
	option_hover.bg_color = palette.highlight
	
	theme.set_stylebox("normal", "OptionButton", option_normal)
	theme.set_stylebox("hover", "OptionButton", option_hover)
	theme.set_font("font", "OptionButton", fonts[current_font_family])
	theme.set_font_size("font_size", "OptionButton", font_sizes.medium)
	theme.set_color("font_color", "OptionButton", palette.text_primary)

func setup_tab_container_theme(theme: Theme, palette: Dictionary):
	var tab_selected = StyleBoxFlat.new()
	tab_selected.bg_color = palette.primary
	tab_selected.corner_radius_top_left = border_radius.md
	tab_selected.corner_radius_top_right = border_radius.md
	
	var tab_unselected = StyleBoxFlat.new()
	tab_unselected.bg_color = palette.surface
	tab_unselected.corner_radius_top_left = border_radius.md
	tab_unselected.corner_radius_top_right = border_radius.md
	
	var tab_disabled = tab_unselected.duplicate()
	tab_disabled.bg_color = palette.text_disabled
	
	theme.set_stylebox("tab_selected", "TabContainer", tab_selected)
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected)
	theme.set_stylebox("tab_disabled", "TabContainer", tab_disabled)
	theme.set_font("font", "TabContainer", fonts[current_font_family])
	theme.set_font_size("font_size", "TabContainer", font_sizes.medium)
	theme.set_color("font_selected_color", "TabContainer", palette.text_primary)
	theme.set_color("font_unselected_color", "TabContainer", palette.text_secondary)

func setup_scroll_container_theme(theme: Theme, palette: Dictionary):
	var scroll_bg = StyleBoxFlat.new()
	scroll_bg.bg_color = palette.surface
	
	var scroll_grabber = StyleBoxFlat.new()
	scroll_grabber.bg_color = palette.text_secondary
	scroll_grabber.corner_radius_top_left = border_radius.full
	scroll_grabber.corner_radius_top_right = border_radius.full
	scroll_grabber.corner_radius_bottom_left = border_radius.full
	scroll_grabber.corner_radius_bottom_right = border_radius.full
	
	var scroll_grabber_hover = scroll_grabber.duplicate()
	scroll_grabber_hover.bg_color = palette.text_primary
	
	theme.set_stylebox("scroll", "VScrollBar", scroll_bg)
	theme.set_stylebox("scroll_focus", "VScrollBar", scroll_bg)
	theme.set_stylebox("grabber", "VScrollBar", scroll_grabber)
	theme.set_stylebox("grabber_highlight", "VScrollBar", scroll_grabber_hover)
	theme.set_stylebox("grabber_pressed", "VScrollBar", scroll_grabber_hover)
	
	theme.set_stylebox("scroll", "HScrollBar", scroll_bg)
	theme.set_stylebox("scroll_focus", "HScrollBar", scroll_bg)
	theme.set_stylebox("grabber", "HScrollBar", scroll_grabber)
	theme.set_stylebox("grabber_highlight", "HScrollBar", scroll_grabber_hover)
	theme.set_stylebox("grabber_pressed", "HScrollBar", scroll_grabber_hover)

func setup_popup_menu_theme(theme: Theme, palette: Dictionary):
	var popup_bg = StyleBoxFlat.new()
	popup_bg.bg_color = palette.surface
	popup_bg.border_width_left = 1
	popup_bg.border_width_right = 1
	popup_bg.border_width_top = 1
	popup_bg.border_width_bottom = 1
	popup_bg.border_color = palette.border
	popup_bg.corner_radius_top_left = border_radius.md
	popup_bg.corner_radius_top_right = border_radius.md
	popup_bg.corner_radius_bottom_left = border_radius.md
	popup_bg.corner_radius_bottom_right = border_radius.md
	popup_bg.shadow_color = palette.shadow
	popup_bg.shadow_size = 8
	
	var popup_hover = StyleBoxFlat.new()
	popup_hover.bg_color = palette.primary
	
	theme.set_stylebox("panel", "PopupMenu", popup_bg)
	theme.set_stylebox("hover", "PopupMenu", popup_hover)
	theme.set_font("font", "PopupMenu", fonts[current_font_family])
	theme.set_font_size("font_size", "PopupMenu", font_sizes.medium)
	theme.set_color("font_color", "PopupMenu", palette.text_primary)
	theme.set_color("font_hover_color", "PopupMenu", palette.text_primary)

# Funzioni per inizializzare i temi preset
func setup_preset_themes():
	create_material_theme()
	create_cyberpunk_theme()
	create_nature_theme()
	create_high_contrast_theme()
	print("Temi preset creati: material, cyberpunk, nature, high_contrast")


# === FUNZIONI TEMI ===

# Cambio tema
func set_theme(theme_name: String):
	if theme_name in themes:
		default_theme = themes[theme_name]
		current_theme_name = theme_name
		current_palette = color_palettes[theme_name]
		theme_changed.emit()
		print("Tema cambiato a: ", theme_name)
	else:
		print("Tema non trovato: ", theme_name)

func get_available_themes() -> Array:
	return themes.keys()

func get_current_theme_name() -> String:
	return current_theme_name

# Gestione temi personalizzati
func create_custom_theme(theme_name: String, base_theme: String = "default") -> bool:
	if base_theme not in themes:
		print("Tema base non trovato: ", base_theme)
		return false
	
	var base_palette = color_palettes.get(base_theme, color_palettes.default).duplicate()
	color_palettes[theme_name] = base_palette
	create_theme_for_palette(theme_name)
	print("Tema personalizzato creato: ", theme_name)
	return true

func duplicate_theme(source_theme: String, new_theme: String) -> bool:
	if source_theme not in themes:
		print("Tema sorgente non trovato: ", source_theme)
		return false
	
	if new_theme in themes:
		print("Tema destinazione già esistente: ", new_theme)
		return false
	
	color_palettes[new_theme] = color_palettes[source_theme].duplicate()
	create_theme_for_palette(new_theme)
	print("Tema duplicato: ", source_theme, " -> ", new_theme)
	return true

func remove_custom_theme(theme_name: String) -> bool:
	if theme_name in ["default", "dark", "light"]:
		print("Impossibile rimuovere tema predefinito: ", theme_name)
		return false
	
	if theme_name not in themes:
		print("Tema non trovato: ", theme_name)
		return false
	
	themes.erase(theme_name)
	color_palettes.erase(theme_name)
	
	if current_theme_name == theme_name:
		set_theme("default")
	
	print("Tema rimosso: ", theme_name)
	return true

# Validazione e controlli
func validate_theme(theme_name: String) -> bool:
	if theme_name not in themes:
		return false
	
	var palette = color_palettes.get(theme_name, {})
	var required_colors = ["primary", "secondary", "background", "surface", "text_primary", "text_secondary"]
	
	for color in required_colors:
		if color not in palette:
			print("Colore mancante nel tema ", theme_name, ": ", color)
			return false
	
	return true

# Tema ad alto contrasto
func create_high_contrast_theme():
	var high_contrast_palette = {
		"primary": Color.WHITE,
		"secondary": Color.YELLOW,
		"accent": Color.CYAN,
		"background": Color.BLACK,
		"surface": Color(0.1, 0.1, 0.1),
		"text_primary": Color.WHITE,
		"text_secondary": Color.YELLOW,
		"text_disabled": Color.GRAY,
		"success": Color.GREEN,
		"warning": Color.YELLOW,
		"error": Color.RED,
		"info": Color.CYAN,
		"border": Color.WHITE,
		"shadow": Color.BLACK,
		"highlight": Color.WHITE,
		"focus": Color.YELLOW
	}
	
	color_palettes["high_contrast"] = high_contrast_palette
	create_theme_for_palette("high_contrast")
	print("Tema ad alto contrasto creato")


# Applicazione tema
func apply_theme_to_node(node: Node):
	if node is Control:
		node.theme = default_theme
	
	for child in node.get_children():
		apply_theme_to_node(child)

func apply_theme_to_scene(scene: Node):
	apply_theme_to_node(scene)

# Performance e ottimizzazioni
func optimize_theme_application():
	# Ottimizza la cache dei temi
	var unused_themes = []
	for theme_name in themes:
		if theme_name != current_theme_name:
			unused_themes.append(theme_name)
	
	# Mantieni solo i temi essenziali in memoria
	if unused_themes.size() > 5:
		print("Troppi temi in memoria, considerare la pulizia")

# === FUNZIONI FONT ===

func load_default_fonts():
	# Carica i font predefiniti
	fonts["default"] = ThemeDB.fallback_font
	
	for font_name in font_paths:
		var path = font_paths[font_name]
		if ResourceLoader.exists(path):
			fonts[font_name] = load(path)
			print("Font caricato: ", font_name, " -> ", path)
		else:
			fonts[font_name] = fonts["default"]

# Gestione font
func set_font_family(font_name: String):
	if font_name in fonts:
		current_font_family = font_name
		setup_default_themes()  # Ricrea i temi con il nuovo font
		font_changed.emit()
		print("Font family cambiato a: ", font_name)
	else:
		print("Font non trovato: ", font_name)

func load_custom_font(font_name: String, font_path: String):
	if ResourceLoader.exists(font_path):
		fonts[font_name] = load(font_path)
		print("Font personalizzato caricato: ", font_name, " -> ", font_path)
		return true
	else:
		print("Font non trovato al percorso: ", font_path)
		return false

func get_available_fonts() -> Array:
	return fonts.keys()

# Utility per dimensioni
func get_font_size(size_name: String) -> int:
	return font_sizes.get(size_name, font_sizes.medium)

# === FUNZIONI LABEL ===

# Creazione componenti
func label_crea(text: String = "", size: int = 16, color: Color = Color.WHITE) -> Label:
	var label = Label.new()
	label.text = text
	label.theme = default_theme
	label.add_theme_font_override("font", fonts[current_font_family])
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func create_label_preset(text: String = "", size_preset: String = "medium", color_preset: String = "text_primary") -> Label:
	var size = font_sizes.get(size_preset, font_sizes.medium)
	var color = current_palette.get(color_preset, current_palette.text_primary)
	return label_crea(text, size, color)

func create_label_with_shadow(text: String = "", size: int = 16, color: Color = Color.WHITE, shadow_color: Color = Color.BLACK, shadow_offset: Vector2 = Vector2(1, 1)) -> Label:
	var label = label_crea(text, size, color)
	label.add_theme_color_override("font_shadow_color", shadow_color)
	label.add_theme_constant_override("shadow_offset_x", int(shadow_offset.x))
	label.add_theme_constant_override("shadow_offset_y", int(shadow_offset.y))
	return label

func create_label_with_outline(text: String = "", size: int = 16, color: Color = Color.WHITE, outline_color: Color = Color.BLACK, outline_size: int = 1) -> Label:
	var label = label_crea(text, size, color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)
	return label

# === FUNZIONI BUTTON ===

func create_button(text: String = "", size_preset: String = "medium") -> Button:
	var button = Button.new()
	button.text = text
	button.theme = default_theme
	button.add_theme_font_size_override("font_size", font_sizes.get(size_preset, font_sizes.medium))
	return button

# === FUNZIONI LINE EDIT ===

func create_line_edit(placeholder: String = "", size_preset: String = "medium") -> LineEdit:
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = placeholder
	line_edit.theme = default_theme
	line_edit.add_theme_font_size_override("font_size", font_sizes.get(size_preset, font_sizes.medium))
	return line_edit

# === FUNZIONI PANEL ===

func create_panel() -> Panel:
	var panel = Panel.new()
	panel.theme = default_theme
	return panel

# === FUNZIONI COLORI ===

# Utility per colori
func get_color(color_name: String) -> Color:
	return current_palette.get(color_name, Color.WHITE)

func get_all_colors() -> Dictionary:
	return current_palette.duplicate()

func update_color(color_name: String, new_color: Color):
	if color_name in current_palette:
		current_palette[color_name] = new_color
		setup_default_themes()
		theme_changed.emit()

func validate_color_contrast(bg_color: Color, text_color: Color) -> float:
	# Calcola il contrasto WCAG
	var bg_luminance = get_relative_luminance(bg_color)
	var text_luminance = get_relative_luminance(text_color)
	
	var lighter = max(bg_luminance, text_luminance)
	var darker = min(bg_luminance, text_luminance)
	
	return (lighter + 0.05) / (darker + 0.05)

func get_relative_luminance(color: Color) -> float:
	var r = color.r
	var g = color.g
	var b = color.b
	
	# Converte sRGB a luminanza relativa
	r = r * 0.2126 if r <= 0.03928 else pow((r + 0.055) / 1.055, 2.4) * 0.2126
	g = g * 0.7152 if g <= 0.03928 else pow((g + 0.055) / 1.055, 2.4) * 0.7152
	b = b * 0.0722 if b <= 0.03928 else pow((b + 0.055) / 1.055, 2.4) * 0.0722
	
	return r + g + b

func get_accessible_text_color(bg_color: Color, prefer_dark: bool = true) -> Color:
	var dark_contrast = validate_color_contrast(bg_color, Color.BLACK)
	var light_contrast = validate_color_contrast(bg_color, Color.WHITE)
	
	# WCAG AA richiede almeno 4.5:1 per testo normale
	if prefer_dark and dark_contrast >= 4.5:
		return Color.BLACK
	elif light_contrast >= 4.5:
		return Color.WHITE
	else:
		return Color.WHITE if light_contrast > dark_contrast else Color.BLACK

# Utility avanzate
func interpolate_colors(color1: Color, color2: Color, weight: float) -> Color:
	return color1.lerp(color2, weight)

func create_color_variant(base_color: Color, variant_type: String) -> Color:
	match variant_type:
		"lighter":
			return base_color.lightened(0.2)
		"darker":
			return base_color.darkened(0.2)
		"saturated":
			return Color.from_hsv(base_color.h, min(base_color.s + 0.2, 1.0), base_color.v)
		"desaturated":
			return Color.from_hsv(base_color.h, max(base_color.s - 0.2, 0.0), base_color.v)
		"complementary":
			return Color.from_hsv(fmod(base_color.h + 0.5, 1.0), base_color.s, base_color.v)
		"triadic1":
			return Color.from_hsv(fmod(base_color.h + 0.333, 1.0), base_color.s, base_color.v)
		"triadic2":
			return Color.from_hsv(fmod(base_color.h + 0.666, 1.0), base_color.s, base_color.v)
		_:
			return base_color

func generate_color_palette(base_color: Color) -> Dictionary:
	return {
		"primary": base_color,
		"secondary": create_color_variant(base_color, "triadic1"),
		"accent": create_color_variant(base_color, "complementary"),
		"background": create_color_variant(base_color, "darker").darkened(0.4),
		"surface": create_color_variant(base_color, "darker").darkened(0.2),
		"text_primary": get_accessible_text_color(base_color),
		"text_secondary": get_accessible_text_color(base_color).lightened(0.3),
		"text_disabled": Color.GRAY,
		"success": Color.GREEN,
		"warning": Color.ORANGE,
		"error": Color.RED,
		"info": base_color.lightened(0.2),
		"border": create_color_variant(base_color, "desaturated"),
		"shadow": Color.BLACK,
		"highlight": Color.WHITE,
		"focus": base_color.lightened(0.3)
	}

# Preset temi popolari
func create_material_theme():
	var material_palette = {
		"primary": Color("#1976D2"),
		"secondary": Color("#388E3C"),
		"accent": Color("#FF5722"),
		"background": Color("#FAFAFA"),
		"surface": Color("#FFFFFF"),
		"text_primary": Color("#212121"),
		"text_secondary": Color("#757575"),
		"text_disabled": Color("#BDBDBD"),
		"success": Color("#4CAF50"),
		"warning": Color("#FF9800"),
		"error": Color("#F44336"),
		"info": Color("#2196F3"),
		"border": Color("#E0E0E0"),
		"shadow": Color("#000000", 0.2),
		"highlight": Color("#FFFFFF"),
		"focus": Color("#1976D2", 0.3)
	}
	
	color_palettes["material"] = material_palette
	create_theme_for_palette("material")

func create_cyberpunk_theme():
	var cyberpunk_palette = {
		"primary": Color("#00FFFF"),
		"secondary": Color("#FF00FF"),
		"accent": Color("#FFFF00"),
		"background": Color("#0D001A"),
		"surface": Color("#1A0D33"),
		"text_primary": Color("#00FFFF"),
		"text_secondary": Color("#FF00FF"),
		"text_disabled": Color("#666666"),
		"success": Color("#00FF00"),
		"warning": Color("#FFFF00"),
		"error": Color("#FF0080"),
		"info": Color("#00FFFF"),
		"border": Color("#00FFFF"),
		"shadow": Color("#000000", 0.8),
		"highlight": Color("#00FFFF", 0.2),
		"focus": Color("#FF00FF")
	}
	
	color_palettes["cyberpunk"] = cyberpunk_palette
	create_theme_for_palette("cyberpunk")

func create_nature_theme():
	var nature_palette = {
		"primary": Color("#4CAF50"),
		"secondary": Color("#8BC34A"),
		"accent": Color("#FF9800"),
		"background": Color("#E8F5E8"),
		"surface": Color("#F1F8E9"),
		"text_primary": Color("#2E7D32"),
		"text_secondary": Color("#558B2F"),
		"text_disabled": Color("#A5D6A7"),
		"success": Color("#66BB6A"),
		"warning": Color("#FFA726"),
		"error": Color("#EF5350"),
		"info": Color("#42A5F5"),
		"border": Color("#C8E6C9"),
		"shadow": Color("#000000", 0.1),
		"highlight": Color("#FFFFFF"),
		"focus": Color("#4CAF50", 0.3)
	}
	
	color_palettes["nature"] = nature_palette
	create_theme_for_palette("nature")


# === FUNZIONI TRANSIZIONI ===

# Animazioni e transizioni
func create_smooth_transition(control: Control, property: String, target_value, duration: float = 0.3):
	var tween = create_tween()
	tween.tween_property(control, property, target_value, duration)
	tween.tween_callback(func(): print("Transizione completata per ", property))

func animate_theme_change(target_theme: String, duration: float = 0.5):
	if target_theme not in themes:
		print("Tema target non trovato: ", target_theme)
		return
	
	var old_theme = current_theme_name
	theme_changed.emit()
	
	# Trova tutti i nodi Control nella scena
	var root = get_tree().current_scene
	if root:
		animate_nodes_theme_change(root, duration)
	
	# Cambia il tema dopo un breve delay per permettere l'animazione
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration * 0.1
	timer.timeout.connect(func(): 
		set_theme(target_theme)
		timer.queue_free()
	)
	timer.start()

func animate_nodes_theme_change(node: Node, duration: float):
	if node is Control:
		var control = node as Control
		var tween = create_tween()
		tween.tween_property(control, "modulate:a", 0.5, duration * 0.5)
		tween.tween_property(control, "modulate:a", 1.0, duration * 0.5)
	
	for child in node.get_children():
		animate_nodes_theme_change(child, duration)

# === FUNZIONI UTILI ===

func get_spacing(spacing_name: String) -> int:
	return spacing.get(spacing_name, spacing.md)

func get_border_radius(radius_name: String) -> int:
	return border_radius.get(radius_name, border_radius.md)

func get_shadow_offset(shadow_name: String) -> Vector2:
	return shadows.get(shadow_name, shadows.md)

func get_outline_size(outline_name: String) -> int:
	return outline_sizes.get(outline_name, outline_sizes.md)

func get_animation_duration(duration_name: String) -> float:
	return animation_durations.get(duration_name, animation_durations.medium)

# === FUNZIONI SALVATAGGIO ===

# Salvataggio e caricamento configurazioni
func save_theme_config(config_name: String = "user_theme"):
	var config = ConfigFile.new()
	config.set_value("theme", "current_theme", current_theme_name)
	config.set_value("theme", "current_font", current_font_family)
	config.set_value("colors", "palette", current_palette)
	config.set_value("sizes", "font_sizes", font_sizes)
	config.set_value("sizes", "spacing", spacing)
	config.set_value("sizes", "border_radius", border_radius)
	
	var path = "user://theme_config_" + config_name + ".cfg"
	config.save(path)
	print("Configurazione tema salvata: ", path)

func load_theme_config(config_name: String = "user_theme"):
	var config = ConfigFile.new()
	var path = "user://theme_config_" + config_name + ".cfg"
	
	if config.load(path) == OK:
		current_theme_name = config.get_value("theme", "current_theme", "default")
		current_font_family = config.get_value("theme", "current_font", "default")
		
		var saved_palette = config.get_value("colors", "palette", {})
		if not saved_palette.is_empty():
			current_palette = saved_palette
			color_palettes[current_theme_name] = saved_palette
		
		var saved_font_sizes = config.get_value("sizes", "font_sizes", {})
		if not saved_font_sizes.is_empty():
			font_sizes = saved_font_sizes
		
		var saved_spacing = config.get_value("sizes", "spacing", {})
		if not saved_spacing.is_empty():
			spacing = saved_spacing
		
		var saved_border_radius = config.get_value("sizes", "border_radius", {})
		if not saved_border_radius.is_empty():
			border_radius = saved_border_radius
		
		setup_default_themes()
		set_theme(current_theme_name)
		print("Configurazione tema caricata: ", path)
		return true
	else:
		print("Impossibile caricare la configurazione tema: ", path)
		return false

func export_theme_to_json(theme_name: String) -> String:
	if theme_name not in color_palettes:
		return ""
	
	var theme_data = {
		"name": theme_name,
		"colors": color_palettes[theme_name],
		"font_sizes": font_sizes,
		"spacing": spacing,
		"border_radius": border_radius,
		"version": "1.0"
	}
	
	return JSON.stringify(theme_data)

func import_theme_from_json(json_string: String) -> bool:
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Errore parsing JSON: ", json.get_error_message())
		return false
	
	var theme_data = json.data
	if typeof(theme_data) != TYPE_DICTIONARY:
		print("Formato JSON non valido")
		return false
	
	var theme_name = theme_data.get("name", "imported_theme")
	var colors = theme_data.get("colors", {})
	
	if colors.is_empty():
		print("Nessun colore trovato nel tema")
		return false
	
	color_palettes[theme_name] = colors
	create_theme_for_palette(theme_name)
	print("Tema importato: ", theme_name)
	return true

# === FUNZIONI SEGNALI ===

# Gestione eventi e callback
func connect_theme_signals():
	theme_changed.connect(_on_theme_changed)
	font_changed.connect(_on_font_changed)

func _on_theme_changed():
	print("Tema cambiato - Applicando modifiche...")
	# Applica il tema a tutti i nodi Control attivi
	var root = get_tree().current_scene
	if root:
		apply_theme_to_node(root)

func _on_font_changed():
	print("Font cambiato - Aggiornando temi...")
	# Notifica tutti i nodi che potrebbero aver bisogno di ridisegnare

# === FUNZIONI RESPONSIVE ===

# Responsive design
func get_screen_size_category() -> String:
	var screen_size = DisplayServer.screen_get_size()
	var width = screen_size.x
	
	if width < breakpoints.mobile:
		return "mobile"
	elif width < breakpoints.tablet:
		return "tablet"
	elif width < breakpoints.desktop:
		return "desktop"
	else:
		return "wide"

func get_responsive_font_size(base_size: String) -> int:
	var category = get_screen_size_category()
	var base = font_sizes.get(base_size, font_sizes.medium)
	
	match category:
		"mobile":
			return int(base * 0.9)
		"tablet":
			return base
		"desktop":
			return int(base * 1.1)
		"wide":
			return int(base * 1.2)
		_:
			return base

func get_responsive_spacing(base_spacing: String) -> int:
	var category = get_screen_size_category()
	var base = spacing.get(base_spacing, spacing.md)
	
	match category:
		"mobile":
			return int(base * 0.8)
		"tablet":
			return base
		"desktop":
			return int(base * 1.2)
		"wide":
			return int(base * 1.4)
		_:
			return base

# === FUNZIONI DEBUG ===

# Debug e utility
func print_current_theme_info():
	print("=== THEME MANAGER INFO ===")
	print("Tema corrente: ", current_theme_name)
	print("Font family: ", current_font_family)
	print("Screen category: ", get_screen_size_category())
	print("Temi disponibili: ", get_available_themes())
	print("Font disponibili: ", get_available_fonts())
	print("Palette colori corrente:")
	for color_name in current_palette:
		print("  ", color_name, ": ", current_palette[color_name])
	print("Font sizes:")
	for size_name in font_sizes:
		print("  ", size_name, ": ", font_sizes[size_name])
	print("Spacing values:")
	for spacing_name in spacing:
		print("  ", spacing_name, ": ", spacing[spacing_name])
	print("========================")
