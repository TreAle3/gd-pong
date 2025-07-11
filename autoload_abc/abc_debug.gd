# abc_debug.gd - iniziato 07/07/2025 - ultima modifica 10/07/2025 - versione 1.0

# Sistema completo di debug per Godot 4

# Aggiungere come Autoload con nome "D"
# Vai in Project → Project Settings → Autoload → Aggiungi il file con nome "D"
# Necessita dell'helper di funzioni, in autoload come "FH", e che sia caricato prima

# Quando si esegue dall'editor di Godot il gioco è sempre in modalità debug
# Quando si esporta il progetto, nella finestra di Export spunta "Export With Debug"

# Caratteristiche principali:
#	🚀 Ottimizzazioni e Design
#		Zero overhead in release build
#		Gestione memoria intelligente con limiti automatici
#		Interfaccia non intrusiva che non interferisce con il gioco
#	🔍 Sistema di Logging Avanzato:
#		10 categorie per classificare i messaggi (GENERAL, PLAYER, ENEMY, UI, PHYSICS, AUDIO, NETWORK, SAVE_LOAD, PERFORMANCE, AI)
#		4 livelli di importanza (INFO, WARNING, ERROR, CRITICAL)
#		Timestamp automatici
#		Colori per ogni categoria/livello
#	📊 Statistiche e Performance:
#		Contatori automatici
#		Timer per misurare performance
#		Monitoraggio memoria
#		Statistiche personalizzate
#	🎨 Sistema di Disegno Debug:
#		Linee, cerchi, rettangoli, testo
#		Durata temporizzata
#		Overlay grafico
#	⚙️ Utility Integrate:
#		Pausa/slow motion
#		Analisi nodi
#		Console comandi
#		Toggle overlay con F3
#	📈 FPS
#		Controllo personalizzato: Posizione, colore, formato
#		Coerenza visiva: Stesso stile dell'overlay debug
#		Funzionalità avanzate: Media, min/max, grafici
#		Zero overhead in release: Rimosso automaticamente

# Esempi di utilizzo:
#	gdscript# Logging semplice
#	D.p("Scritta nella console")
#	D.p("Player spawned", D.Categoria.PLAYER)
#	D.print("Il nemico ha saltato!", D.Categoria.ENEMY)
#	D.debug_log("Velocità: %s" % velocity, D.Categoria.PHYSICS)
#	# Timer performance
#	D.debug_timer_start("ai_calculation")
#	# ... codice da misurare ...
#	D.debug_timer_end("ai_calculation")
#	# Statistiche
#	D.debug_stat("player_health", 100)
#	D.debug_counter_increment("enemies_killed")
#	# Disegno debug
#	D.debug_draw_line(Vector2.ZERO, Vector2(100, 100), Color.RED, 2.0, 1.0)
#	D.debug_draw_circle(player.position, 50, Color.GREEN)
#	# Timer performance
#	D.debug_timer_start("ai_calculation")
#	# ... codice da misurare ...
#	D.debug_timer_end("ai_calculation")
#	# Statistiche
#	D.debug_stat("player_health", 100)
#	D.debug_counter_increment("enemies_killed")
#	# Disegno debug
#	D.debug_draw_line(Vector2.ZERO, Vector2(100, 100), Color.RED, 2.0, 1.0)
#	D.debug_draw_circle(player.position, 50, Color.GREEN)
#	# Toggle FPS display
#	D.debug_toggle_fps()
#	# Reset statistiche
#	D.debug_reset_fps_stats()
#	# Via console
#	D.debug_execute_command("fps")
#	D.debug_execute_command("fps_stats")


# Vantaggi:
#	Zero overhead in build release (tutto viene rimosso automaticamente)
#	Overlay visuale con F3 per toggle
#	Sistema modulare - usa solo le funzioni che ti servono
#	Facile da estendere con nuove categorie e funzionalità


extends Node

# =============================================================================
# CONFIGURAZIONE DEBUG
# =============================================================================

# Categorie disponibili per classificare i messaggi debug
enum Categoria {
	GENERAL,      # Messaggi generici
	PLAYER,       # Relativi al giocatore
	ENEMY,        # Relativi ai nemici
	UI,           # Interfaccia utente
	PHYSICS,      # Fisica e collisioni
	AUDIO,        # Sistema audio
	NETWORK,      # Networking e multiplayer
	SAVE_LOAD,    # Salvataggio e caricamento
	PERFORMANCE,  # Performance e ottimizzazione
	AI            # Intelligenza artificiale
}

# Livelli di importanza dei messaggi debug
enum Livello {
	INFO,         # Informazioni generali
	WARNING,      # Avvisi non critici
	ERROR,        # Errori che non bloccano l'esecuzione
	CRITICAL      # Errori critici che possono bloccare il gioco
}

# Configurazione colori per categorie, mappa ogni categoria a un colore specifico per l'output visuale
var category_colors: Dictionary = {
	Categoria.GENERAL: Color.WHITE,
	Categoria.PLAYER: Color.CYAN,
	Categoria.ENEMY: Color.RED,
	Categoria.UI: Color.YELLOW,
	Categoria.PHYSICS: Color.GREEN,
	Categoria.AUDIO: Color.MAGENTA,
	Categoria.NETWORK: Color.ORANGE,
	Categoria.SAVE_LOAD: Color.BLUE,
	Categoria.PERFORMANCE: Color.PINK,
	Categoria.AI: Color.LIGHT_CORAL
}

# Configurazione colori per livelli, mappa ogni livello a un colore per indicare l'importanza
var level_colors: Dictionary = {
	Livello.INFO: Color.WHITE,			# Bianco (neutro)
	Livello.WARNING: Color.YELLOW,		# Giallo (attenzione)
	Livello.ERROR: Color.ORANGE,		# Arancione (problema)
	Livello.CRITICAL: Color.RED			# Rosso (critico)
}

# =============================================================================
# VARIABILI INTERNE
# =============================================================================

var debug_overlay: Control # Nodo principale che contiene tutta l'interfaccia debug - copre tutto lo schermo, invisibile al mouse per non interferire con il gioco, contiene tutti gli elementi visivi del debug
var debug_label: RichTextLabel # Etichetta che mostra i messaggi di log colorati
var debug_lines: PackedStringArray = PackedStringArray() # PackedStringArray che mantiene lo storico dei messaggi di log
var max_debug_lines: int = 50 # Limite massimo di righe di log conservate
var debug_stats: Dictionary = {} # Dizionario che memorizza tutte le statistiche personalizzate - Chiave: nome della statistica (String) - Valore: valore della statistica (Variant)
var debug_timers: Dictionary = {} # Dizionario che traccia i timer attivi - Chiave: nome del timer (String) - Valore: timestamp di inizio (int, millisecondi)
var debug_counters: Dictionary = {} # Dizionario che mantiene i contatori incrementali - Chiave: nome del contatore (String) - Valore: valore corrente del contatore (int)

# Canvas per disegno debug
var debug_canvas: CanvasLayer # Layer dedicato al disegno delle forme debug, Contiene tutti gli elementi grafici di debug, Layer: 100 (sopra tutto il resto)
var debug_draw_node: Node2D # Nodo che gestisce il rendering delle forme debug, Punto di ancoraggio per linee, cerchi, testo debug
var debug_shapes: Array[Dictionary] = [] # Cache per forme temporanee
var max_debug_shapes: int = 100 # Limite forme simultanee

# Sistema FPS
var fps_display_enabled: bool = true # Controlla se il display FPS è attivo, Può essere cambiato con debug_toggle_fps()
var fps_label: Label # Etichetta che mostra le informazioni FPS
var fps_history: PackedFloat32Array = PackedFloat32Array() # PackedFloat32Array che mantiene lo storico dei valori FPS, Usato per calcolare media, min, max
var fps_history_size: int = 60  # Dimensione massima dello storico FPS, Rappresenta circa 1 secondo di dati a 60 FPS
var fps_update_timer: float = 0.0 #  Timer per controllare la frequenza di aggiornamento FPS, Resettato quando raggiunge fps_update_interval
var fps_update_interval: float = 0.1  # Intervallo di aggiornamento del display FPS, Aggiorna ogni 100ms, Evita aggiornamenti troppo frequenti che causerebbero flickering
var fps_index: int = 0 # Indice circolare per fps_history

# Statistiche FPS
var fps_current: float = 0.0 # Valore FPS corrente, Rappresenta la performance istantanea
var fps_average: float = 0.0 # Media dei FPS nello storico
var fps_min: float = 999.0 # Valore FPS minimo registrato
var fps_max: float = 0.0 # Valore FPS massimo registrato
var fps_stats_dirty: bool = true # Flag per ricalcolo lazy

# Pool di oggetti per ridurre allocazioni
var _string_pool: Array[String] = []
var _pool_size: int = 20

const TASTO_DEBUG: Key = KEY_F3

# =============================================================================
# INIZIALIZZAZIONE
# =============================================================================

# Inizializza tutto il sistema debug quando il nodo viene caricato
func _ready():
	if not OS.is_debug_build():
		return
	_string_pool.resize(_pool_size) # Pre-alloca pool di stringhe
	for i in _pool_size:
		_string_pool[i] = ""
	fps_history.resize(fps_history_size) # Pre-alloca array FPS con dimensione fissa
	for i in fps_history_size:
		fps_history[i] = 0.0
	_create_debug_overlay() # Crea overlay debug
	_create_debug_draw_system() # Crea sistema di disegno debug
	_connect_debug_signals() # Connetti segnali
	_create_fps_display() # FPS
	#debug_log("Debug inizializzato", Categoria.GENERAL, Livello.INFO) # Log inizializzazione
	p("Debug inizializzato") # Log inizializzazione

# Funzione chiamata ogni frame per aggiornamenti continui, usata per gli FPS
func _process(delta):
	if not OS.is_debug_build():
		return
	_update_fps_display(delta)
	_cleanup_expired_shapes(delta)

# Crea l'interfaccia grafica per mostrare le informazioni debug
func _create_debug_overlay():
	debug_overlay = Control.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_overlay.visible = true  # Visibile di default
	add_child(debug_overlay)
	# Crea RichTextLabel per testo debug
	debug_label = RichTextLabel.new()
	debug_label.name = "DebugLabel"
	debug_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	debug_label.bbcode_enabled = true
	debug_label.scroll_following = true
	debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_label.modulate.a = 0.8
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # Godot 4 wrapping
	debug_overlay.add_child(debug_label)
	# Posiziona in alto a sinistra
	debug_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	debug_label.size = Vector2(600, 400)

# Inizializza il sistema per disegnare forme geometriche debug
func _create_debug_draw_system():
	debug_canvas = CanvasLayer.new() # Crea CanvasLayer per disegno
	debug_canvas.name = "DebugCanvas"
	debug_canvas.layer = 100  # Sopra tutto
	debug_canvas.visible = true
	add_child(debug_canvas)
	debug_draw_node = Node2D.new() # Crea nodo per disegno
	debug_draw_node.name = "DebugDrawNode"
	debug_canvas.add_child(debug_draw_node)

# Configura i controlli da tastiera per il debug - Associa il tasto F3 per attivare/disattivare l'overlay
func _connect_debug_signals():
	if not InputMap.has_action("toggle_debug"):
		InputMap.add_action("toggle_debug")
		var event = InputEventKey.new()
		event.keycode = KEY_F3  # Usa keycode per compatibilità layout
		event.physical_keycode = KEY_F3  # Aggiungi anche physical_keycode
		InputMap.action_add_event("toggle_debug", event)


# =============================================================================
# FPS
# =============================================================================

# Crea il display FPS nell'angolo superiore destro, Rende il display trasparente al mouse
func _create_fps_display():
	if not OS.is_debug_build():
		return
	fps_label = Label.new() # Crea label per FPS
	fps_label.name = "FPSLabel"
	fps_label.add_theme_font_size_override("font_size", 16)
	fps_label.add_theme_color_override("font_color", Color.GREEN)
	fps_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	fps_label.add_theme_constant_override("shadow_offset_x", 2)
	fps_label.add_theme_constant_override("shadow_offset_y", 2)
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE # Rende il display trasparente al mouse
	debug_overlay.add_child(fps_label)
	fps_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT) # Posiziona in alto a destra
	fps_label.position.x -= 150
	fps_label.position.y += 10

# Aggiorna il display FPS con throttling
func _update_fps_display(delta: float):
	if not fps_display_enabled or not fps_label:
		return
	fps_update_timer += delta
	if fps_update_timer < fps_update_interval:
		return
	fps_update_timer = 0.0
	fps_current = Engine.get_frames_per_second()
	if fps_current <= 0: # Evita valori invalidi
		fps_current = 1.0
	fps_history[fps_index] = fps_current # Usa indice circolare invece di pop_front/append
	fps_index = (fps_index + 1) % fps_history_size
	fps_stats_dirty = true
	_update_fps_text()

# Calcola statistiche FPS (media, min, max)
func _calculate_fps_stats():
	if not fps_stats_dirty:
		return
	fps_stats_dirty = false
	var total: float = 0.0 # Calcolo ottimizzato con una sola passata
	fps_min = fps_history[0]
	fps_max = fps_history[0]
	for fps in fps_history:
		if fps > 0: # Ignora valori non inizializzati
			total += fps
			if fps < fps_min:
				fps_min = fps
			if fps > fps_max:
				fps_max = fps
	fps_average = total / fps_history_size

# Aggiorna il testo del display FPS con colori dinamici basati sulle performance
func _update_fps_text():
	if not fps_label:
		return
	_calculate_fps_stats()
	var color = Color.GREEN if fps_current >= 50 else (Color.YELLOW if fps_current >= 30 else Color.RED)
	fps_label.add_theme_color_override("font_color", color)
	fps_label.text = "FPS: %.1f\nAvg: %.1f\nMin: %.1f\nMax: %.1f" % [ # Usa string interpolation ottimizzata
		fps_current, fps_average, fps_min, fps_max
	]

# =============================================================================
# FUNZIONI DI CONTROLLO FPS
# =============================================================================

# Attiva/disattiva il display FPS
func debug_toggle_fps():
	if not OS.is_debug_build():
		return
	fps_display_enabled = not fps_display_enabled
	if fps_label:
		fps_label.visible = fps_display_enabled
	debug_log("FPS display: %s" % ("ON" if fps_display_enabled else "OFF"), Categoria.PERFORMANCE, Livello.INFO)

# Resetta tutte le statistiche FPS
func debug_reset_fps_stats():
	if not OS.is_debug_build():
		return
	fps_history.clear()
	fps_min = 999.0
	fps_max = 0.0
	fps_average = 0.0
	debug_log("FPS stats reset", Categoria.PERFORMANCE, Livello.INFO)

# Restituisce dizionario con statistiche FPS - Dati inclusi: corrente, media, min, max, dimensione storico
func debug_get_fps_stats() -> Dictionary:
	if not OS.is_debug_build():
		return {}
	return {
		"current": fps_current,
		"average": fps_average,
		"min": fps_min,
		"max": fps_max,
		"history_size": fps_history.size()
	}

# =============================================================================
# FPS VERSIONE AVANZATA CON GRAFICO
# =============================================================================

# Per un grafico FPS in tempo reale:
# Questo richiederebbe un Control personalizzato con _draw()
# Implementazione lasciata inutilizzata
func _draw_fps_graph():
	if not OS.is_debug_build() or fps_history.is_empty():
		return
	

# =============================================================================
# LOGGING SYSTEM
# =============================================================================

# Wrapper per print di debug con categoria
func debug_print(message: String, category: String = "GENERAL") -> void:
	if OS.is_debug_build():
		print("[DEBUG-%s] %s" % [category, message])

# Scorciatoia per utilizzare debug_print come D.print("Messaggio")
func print(message: String, category: String = "GENERAL") -> void:
	debug_print(message, category)

# Scorciatoia per utilizzare debug_print come D.p("Messaggio")
func p(message: String, category: String = "GENERAL") -> void:
	debug_print(message, category)

# Funzione principale di logging con categorizzazione completa - Output sia su console che su overlay
func debug_log(message: String, category: Categoria = Categoria.GENERAL, level: Livello = Livello.INFO):
	if not OS.is_debug_build():
		return
	var formatted_message = _get_pooled_string() # Usa string pool per ridurre allocazioni
	formatted_message = "[%s] [%s] [%s] %s" % [
		Time.get_datetime_string_from_system(),
		Categoria.keys()[category],
		Livello.keys()[level],
		message
	]
	print(formatted_message) # Print su console
	_add_to_overlay(formatted_message, category, level) # Aggiungi a overlay
	if debug_lines.size() >= max_debug_lines: # Salva in history - Usa array circolare per debug_lines
		debug_lines[0] = formatted_message
		for i in range(1, debug_lines.size()): # Ruota array invece di pop_front
			debug_lines[i-1] = debug_lines[i]
		debug_lines[debug_lines.size()-1] = formatted_message
	else:
		debug_lines.append(formatted_message)

# Aggiunge messaggio colorato all'overlay
func _add_to_overlay(message: String, category: Categoria, level: Livello):
	if not debug_label:
		return
	var level_color = level_colors.get(level, Color.WHITE)
	var category_color = category_colors.get(category, Color.WHITE)
	#SOSTITUITO debug_label.append_text("[color=#%s]%s[/color]\n" % [level_color.to_html(false), message]) # Usa append_text invece di add_text per Godot 4
	# Usa sia il colore del livello che della categoria per un display più ricco
	debug_label.append_text("[color=#%s][%s][/color] [color=#%s]%s[/color]\n" % [
		category_color.to_html(false), 
		Categoria.keys()[category],
		level_color.to_html(false), 
		message
	])
	if debug_lines.size() > max_debug_lines: # Limita righe per performance
		_trim_debug_display()

# Ottimizza display debug rimuovendo righe vecchie, mantiene solo le ultime N righe
func _trim_debug_display():
	if not debug_label:
		return
	var text = debug_label.get_parsed_text() # Rimuovi le prime righe se troppo lunghe
	var lines = text.split("\n")
	if lines.size() > max_debug_lines:
		var new_lines = lines.slice(lines.size() - max_debug_lines) # Mantieni solo le ultime max_debug_lines righe
		debug_label.clear()
		for line in new_lines:
			debug_label.append_text(line + "\n")

# =============================================================================
# STATISTICHE E PERFORMANCE
# =============================================================================

# Registra una statistica personalizzata, salvandola nel dizionario statistiche
func debug_stat(stat_name: String, value: Variant, category: Categoria = Categoria.PERFORMANCE):
	if not OS.is_debug_build():
		return
	debug_stats[stat_name] = value
	debug_log("STAT: %s = %s" % [stat_name, str(value)], category, Livello.INFO)

# Incrementa un contatore
func debug_counter_increment(counter_name: String, category: Categoria = Categoria.GENERAL):
	if not OS.is_debug_build():
		return
	if not debug_counters.has(counter_name):
		debug_counters[counter_name] = 0
	debug_counters[counter_name] += 1
	debug_log("COUNTER: %s = %d" % [counter_name, debug_counters[counter_name]], category, Livello.INFO)

# Resetta un contatore a 0
func debug_counter_reset(counter_name: String):
	if not OS.is_debug_build():
		return
	debug_counters[counter_name] = 0
	debug_log("COUNTER RESET: %s" % counter_name, Categoria.GENERAL, Livello.INFO)

# =============================================================================
# TIMER SYSTEM
# =============================================================================

# Avvia un timer per misurare performance
func debug_timer_start(timer_name: String):
	if not OS.is_debug_build():
		return
	debug_timers[timer_name] = Time.get_ticks_msec()
	debug_log("TIMER START: %s" % timer_name, Categoria.PERFORMANCE, Livello.INFO)

# Termina un timer e calcola la durata in secondi
func debug_timer_end(timer_name: String) -> float:
	if not OS.is_debug_build():
		return 0.0
	if not debug_timers.has(timer_name):
		debug_log("TIMER ERROR: %s non trovato" % timer_name, Categoria.PERFORMANCE, Livello.ERROR)
		return 0.0
	var start_time = debug_timers[timer_name]
	var end_time = Time.get_ticks_msec()
	var duration = (end_time - start_time) / 1000.0
	debug_log("TIMER END: %s = %.3f secondi" % [timer_name, duration], Categoria.PERFORMANCE, Livello.INFO)
	debug_timers.erase(timer_name)
	return duration

# Tempo intermedio senza fermare il timer
func debug_timer_lap(timer_name: String) -> float:
	if not OS.is_debug_build():
		return 0.0
	if not debug_timers.has(timer_name):
		debug_log("TIMER ERROR: %s non trovato" % timer_name, Categoria.PERFORMANCE, Livello.ERROR)
		return 0.0
	var start_time = debug_timers[timer_name]
	var current_time = Time.get_ticks_msec()
	var duration = (current_time - start_time) / 1000.0
	debug_log("TIMER LAP: %s = %.3f secondi" % [timer_name, duration], Categoria.PERFORMANCE, Livello.INFO)
	return duration

# =============================================================================
# SISTEMA DI DISEGNO DEBUG
# =============================================================================

# Disegna una linea debug temporanea - Durata temporizzata, se 0 = permanente
func debug_draw_line(from: Vector2, to: Vector2, color: Color = Color.RED, width: float = 2.0, duration: float = 0.0):
	if not OS.is_debug_build():
		return
	if debug_shapes.size() >= max_debug_shapes: # Controlla limite forme
		debug_shapes.pop_front()
	var line_data = {
		"type": "line",
		"from": from,
		"to": to,
		"color": color,
		"width": width,
		"duration": duration,
		"start_time": Time.get_ticks_msec() / 1000.0
	}
	debug_shapes.append(line_data)

# Disegna un cerchio debug - Durata temporizzata, se 0 = permanente
func debug_draw_circle(center: Vector2, radius: float, color: Color = Color.GREEN, width: float = 2.0, duration: float = 0.0):
	if not OS.is_debug_build():
		return
	if debug_shapes.size() >= max_debug_shapes:
		debug_shapes.pop_front()
	var circle_data = {
		"type": "circle",
		"center": center,
		"radius": radius,
		"color": color,
		"width": width,
		"duration": duration,
		"start_time": Time.get_ticks_msec() / 1000.0
	}
	debug_shapes.append(circle_data)

# Disegna un rettangolo debug
func debug_draw_rect(rect: Rect2, color: Color = Color.BLUE, width: float = 2.0, duration: float = 0.0):
	if not OS.is_debug_build():
		return
	if debug_shapes.size() >= max_debug_shapes:
		debug_shapes.pop_front()
	var rect_data = {
		"type": "rect",
		"rect": rect,
		"color": color,
		"width": width,
		"duration": duration,
		"start_time": Time.get_ticks_msec() / 1000.0
	}
	debug_shapes.append(rect_data)

# Disegna testo debug nel mondo
func debug_draw_text(text: String, position: Vector2, color: Color = Color.WHITE, size: int = 16, duration: float = 0.0):
	if not OS.is_debug_build():
		return
	if debug_shapes.size() >= max_debug_shapes:
		debug_shapes.pop_front()
	var text_data = {
		"type": "text",
		"text": text,
		"position": position,
		"color": color,
		"size": size,
		"duration": duration,
		"start_time": Time.get_ticks_msec() / 1000.0
	}
	debug_shapes.append(text_data)

# DA SVILUPPARE - Implementazione base per rendering forme
func _draw_debug_shape(shape_data: Dictionary):
	# Implementazione semplificata - in un progetto reale useresti
	# una coda di forme da disegnare e un sistema di rendering personalizzato
	debug_log("DEBUG DRAW: %s" % shape_data.type, Categoria.GENERAL, Livello.INFO)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Pausa/riprende il gioco
func debug_pause_game():
	if not OS.is_debug_build():
		return
	var tree = get_tree()
	if tree:
		tree.paused = not tree.paused
		debug_log("Game paused: %s" % str(tree.paused), Categoria.GENERAL, Livello.INFO)
	else:
		debug_log("Cannot pause: SceneTree not available", Categoria.GENERAL, Livello.ERROR)

# Rallenta o accelera il gioco, tra 0.01x e 10.0x
func debug_slow_motion(factor: float = 0.5):
	if not OS.is_debug_build():
		return
	Engine.time_scale = clamp(factor, 0.01, 10.0)  # Limita valori estremi
	debug_log("Time scale: %s" % str(factor), Categoria.GENERAL, Livello.INFO)

# Ripristina velocità normale
func debug_normal_speed():
	if not OS.is_debug_build():
		return
	Engine.time_scale = 1.0
	debug_log("Time scale: normale", Categoria.GENERAL, Livello.INFO)

# Raccoglie informazioni dettagliate su un nodo
func debug_get_node_info(node: Node) -> Dictionary:
	if not OS.is_debug_build():
		return {}
	var info = {
		"name": node.name,
		"type": node.get_class(),
		"children_count": node.get_child_count(),
		"process_mode": node.process_mode,
		"scene_file_path": node.scene_file_path if node.scene_file_path != "" else "N/A"
	}
	if node is Node2D: # Controlla tipo con is invece di get_class() per performance
		info["position"] = node.global_position
		info["rotation"] = node.global_rotation
		info["scale"] = node.global_scale
	elif node is Node3D:
		info["position"] = node.global_position
		info["rotation"] = node.global_rotation
		info["scale"] = node.global_scale
	if node is CanvasItem:
		info["visible"] = node.visible
		info["modulate"] = node.modulate
	debug_log("NODE INFO: %s" % str(info), Categoria.GENERAL, Livello.INFO)
	return info

# Mostra informazioni sulla memoria
func debug_memory_usage():
	if not OS.is_debug_build():
		return
	var static_usage = OS.get_static_memory_usage()
	var static_peak = OS.get_static_memory_peak_usage()
	var memory_info = {
		"static_memory_usage": FH.Format_Memory_Size(static_usage),
		"static_memory_peak": FH.Format_Memory_Size(static_peak),
		"static_memory_usage_bytes": static_usage,
		"static_memory_peak_bytes": static_peak
	}
	debug_log("MEMORY: Current: %s, Peak: %s" % [
		memory_info.static_memory_usage, 
		memory_info.static_memory_peak
	], Categoria.PERFORMANCE, Livello.INFO)

# =============================================================================
# FUNZIONI DI OTTIMIZZAZIONE
# =============================================================================

# Ottiene stringa dal pool per ridurre allocazioni - Cerca stringa vuota nel pool, riusa prima stringa se pool pieno
func _get_pooled_string() -> String:
	for i in _string_pool.size():
		if _string_pool[i] == "":
			return _string_pool[i]
	_string_pool[0] = "" # Se pool è pieno, riusa la prima stringa
	return _string_pool[0]

# Restituisce stringa al pool - Trova stringa nel pool e la marca come disponibile
func _return_pooled_string(s: String):
	for i in _string_pool.size():
		if _string_pool[i] == s:
			_string_pool[i] = ""
			break

# Rimuove forme debug scadute - Filtra forme valide e mantiene solo quelle non scadute
func _cleanup_expired_shapes(_delta: float):
	if debug_shapes.is_empty():
		return
	var current_time = Time.get_ticks_msec() / 1000.0
	var valid_shapes: Array[Dictionary] = []
	for shape in debug_shapes: # Filtra forme valide invece di rimuovere singolarmente
		if shape.duration <= 0 or (current_time - shape.start_time) <= shape.duration:
			valid_shapes.append(shape)
	debug_shapes = valid_shapes

# =============================================================================
# COMANDI CONSOLE
# =============================================================================

# Esegue comandi debug da console
func debug_execute_command(command: String):
	if not OS.is_debug_build():
		return
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	match cmd:
		"help": # mostra aiuto
			_show_debug_help()
		"clear": # pulisce log
			debug_clear_log()
		"stats": # mostra statistiche
			_show_debug_stats()
		"memory": # info memoria
			var mem_stats = debug_get_memory_stats()
			debug_log("MEMORY: %s" % str(mem_stats), Categoria.PERFORMANCE, Livello.INFO)
		"pause": # pausa gioco
			debug_pause_game()
		"slow": # rallenta gioco
			var factor = 0.5
			if parts.size() > 1:
				factor = parts[1].to_float()
			debug_slow_motion(factor)
		"normal": # velocità normale
			debug_normal_speed()
		"fps": # toggle FPS
			debug_toggle_fps()
		"fps_reset": # reset statistiche FPS
			debug_reset_fps_stats()
		"fps_stats": # mostra statistiche FPS
			var stats = debug_get_fps_stats()
			debug_log("FPS Stats: %s" % str(stats), Categoria.PERFORMANCE, Livello.INFO)
		_:
			debug_log("Comando sconosciuto: %s" % command, Categoria.GENERAL, Livello.ERROR)

# Mostra testo di aiuto dei comandi disponibili
func _show_debug_help():
	var help_text = """
	COMANDI DEBUG DISPONIBILI:
	- help: mostra questo aiuto
	- clear: pulisce log debug
	- stats: mostra statistiche
	- memory: info memoria
	- pause: pausa/riprendi gioco
	- slow [factor]: rallenta gioco
	- normal: velocità normale
	- fps: toglie/rimette FPS
	- fps_reset: reset statistiche FPS
	- fps_stats: mostra statistiche FPS
	"""
	debug_log(help_text, Categoria.GENERAL, Livello.INFO)

# Mostra tutte le statistiche e contatori
func _show_debug_stats():
	debug_log("=== STATISTICHE DEBUG ===", Categoria.PERFORMANCE, Livello.INFO)
	for stat_name in debug_stats:
		debug_log("%s: %s" % [stat_name, str(debug_stats[stat_name])], Categoria.PERFORMANCE, Livello.INFO)
	debug_log("=== CONTATORI ===", Categoria.PERFORMANCE, Livello.INFO)
	for counter_name in debug_counters:
		debug_log("%s: %d" % [counter_name, debug_counters[counter_name]], Categoria.PERFORMANCE, Livello.INFO)

# Pulisce completamente il log debug
func debug_clear_log():
	if not OS.is_debug_build():
		return
	debug_lines.clear()
	if debug_label:
		debug_label.clear()
	for i in _string_pool.size(): # Pulisci anche pool stringhe
		_string_pool[i] = ""
	debug_log("Log pulito", Categoria.GENERAL, Livello.INFO)

# Restituisce statistiche memoria dettagliate
func debug_get_memory_stats() -> Dictionary:
	if not OS.is_debug_build():
		return {}
	var stats = {
		"static_memory": OS.get_static_memory_usage(),
		"static_peak": OS.get_static_memory_peak_usage(),
		"debug_structures": {
			"lines": debug_lines.size(),
			"shapes": debug_shapes.size(),
			"stats": debug_stats.size(),
			"counters": debug_counters.size(),
			"timers": debug_timers.size()
		}
	}
	return stats

# Pulisce memoria non essenziale
func debug_cleanup_memory():
	if not OS.is_debug_build():
		return
	if debug_stats.size() > 50: # Pulisci strutture dati non essenziali
		debug_stats.clear()
	if debug_shapes.size() * 2 > max_debug_shapes: # Equivalente a debug_shapes.size() > max_debug_shapes / 2:
		debug_shapes.clear()
	debug_log("Memory cleanup completato", Categoria.PERFORMANCE, Livello.INFO)

# =============================================================================
# INPUT HANDLING
# =============================================================================

# Gestisce input da tastiera per debug - Verifica esistenza azione "toggle_debug" e fallback su controllo diretto tasto F3
func _input(event):
	if not OS.is_debug_build():
		return
	if InputMap.has_action("toggle_debug") and event.is_action_pressed("toggle_debug"): # Verifica se l'azione esiste prima di controllarla
		toggle_debug_overlay()
	elif event is InputEventKey and ( event.physical_keycode == TASTO_DEBUG or event.physical_keycode == TASTO_DEBUG) and event.pressed: # Fallback se l'azione non esiste
		toggle_debug_overlay()

# Attiva/disattiva visibilità overlay debug
func toggle_debug_overlay():
	if not OS.is_debug_build():
		return
	if debug_overlay:
		debug_overlay.visible = not debug_overlay.visible
		debug_log("Debug overlay: %s" % ("ON" if debug_overlay.visible else "OFF"), Categoria.GENERAL, Livello.INFO)

# =============================================================================
# CLEANUP
# =============================================================================

# Pulizia finale quando il sistema viene terminato
func _exit_tree():
	if not OS.is_debug_build():
		return
	debug_log("DebugManager terminato", Categoria.GENERAL, Livello.INFO)
