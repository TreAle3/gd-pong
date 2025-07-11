# abc_funzioni_helper.gd - iniziato 07/07/2025 - ultima modifica 10/07/2025 - versione 1.0
# Funzioni che possono essere utili ad altri script
# Aggiungere come Autoload con nome "FH"
# Vai in Project → Project Settings → Autoload → Aggiungi il file con nome "FH"
# Nome: FH, Path: res://autoload_abc/abc_funzioni_helper.gd

# Caratteristiche principali:
#	Gestione matematica avanzata con funzioni sicure e ottimizzate
#	Generazione procedurale con funzioni random versatili
#	Gestione scene e nodi con controlli di sicurezza
#	Sistema di timer sia bloccante che non bloccante
#	Formattazione e utilità per display e debugging
#	Ottimizzazione performance con memoizzazione e gestione memoria
#	Funzioni di validazione per prevenire errori comuni
# Vantaggi dell'utilizzo:
#	Riduce la duplicazione di codice comune
#	Fornisce implementazioni sicure e ottimizzate
#	Gestisce automaticamente la pulizia della memoria
#	Offre funzionalità sia sincrone che asincrone per timer
#	Include controlli di validazione per prevenire crash

# Esempi d'uso:
#	# Cambia scena
#	FH.change_scene("res://levels/Level1.tscn")
#	# Numero casuale
#	var damage = FH.random_int(10, 20)
#	# Delay non bloccante
#	FH.delay(2.0, func(): print("Eseguito dopo 2 secondi"))
#	# Attesa bloccante
#	await FH.wait_seconds(1.5)
#	# Formattazione
#	var time_str = FH.format_time(125.5)  # "02:05"
#	var size_str = FH.Format_Memory_Size(1024000)  # "1.00 MB"
#	# Matematica
#	var mapped = FH.map_range(75, 0, 100, 0, 1)  # 0.75
#	var distance = FH.distance_2d(Vector2(0,0), Vector2(3,4))  # 5.0
#	# Array
#	var unique_items = FH.remove_duplicates([1,2,2,3,3,3])  # [1,2,3]
#	var shuffled = FH.shuffle_array([1,2,3,4,5])
#	# Pulizia memoria
#	FH.cleanup_memory()

extends Node

# === FUNZIONI MATEMATICHE ===

# Costanti pre-calcolate
const EPSILON = 0.0001
const HALF_PI = PI * 0.5
const TWO_PI = PI * 2.0

# Calcola la distanza euclidea tra due punti 2D
func distance_2d(point1: Vector2, point2: Vector2) -> float:
	return point1.distance_to(point2)

# Calcola la distanza euclidea tra due punti 3D
func distance_3d(point1: Vector3, point2: Vector3) -> float:
	return point1.distance_to(point2)

# Mappa un valore da un intervallo a un altro
# Esempio: mappare un valore da 0-100 a 0-1 → map_range(50, 0, 100, 0, 1) → 0.5
func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

# Normalizza un vettore 2D con controllo per evitare divisioni per zero
func safe_normalize(vector: Vector2) -> Vector2:
	var length_sq = vector.length_squared()
	return vector / sqrt(length_sq) if length_sq > EPSILON else Vector2.ZERO

# Normalizza un vettore 3D con controllo per evitare divisioni per zero
func safe_normalize_3d(vector: Vector3) -> Vector3:
	var length_sq = vector.length_squared()
	return vector / sqrt(length_sq) if length_sq > EPSILON else Vector3.ZERO

# Combina l'interpolazione lineare (lerp) con la funzione smoothstep per creare transizioni più naturali e fluide
# Differenze con lerp normale: lerp->Interpolazione lineare costante (velocità uniforme) / smooth_lerp -> Interpolazione con accelerazione graduale all'inizio e decelerazione alla fine
# Curva di smoothstep: Da 0.0 a ~0.3: Accelerazione graduale (partenza lenta) - Da ~0.3 a ~0.7: Velocità più costante (fase centrale) - Da ~0.7 a 1.0: Decelerazione graduale (arrivo morbido)
# Quando usarla: Animazioni di UI (fade, scale, movement), Transizioni di volume audio, Movimenti di camera, Qualsiasi animazione che deve sembrare più naturale e meno robotica
func smooth_lerp(from: float, to: float, t: float) -> float:
	var smooth_t = smoothstep(0.0, 1.0, t)
	return lerp(from, to, smooth_t)


# === FUNZIONI GENERAZIONI RANDOMICHE ===

# Genera numero casuale float nell'intervallo specificato min_val / max_val
func random_float(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)

# Genera numero casuale intero nell'intervallo specificato min_val / max_val
func random_int(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)

# Genera un booleano casuale (50% probabilità)
func random_bool() -> bool:
	return randf() < 0.5

# Sceglie un elemento casuale da un array. Restituisce null se array vuoto
func random_array_choice(array: Array):
	if array.is_empty():
		return null
	return array[randi() % array.size()]

# === FUNZIONI INTERPOLAZIONE ===

# Interpola tra due colori includendo il canale alpha
func lerp_color_alpha(from: Color, to: Color, t: float) -> Color:
	return Color(
		lerp(from.r, to.r, t),
		lerp(from.g, to.g, t),
		lerp(from.b, to.b, t),
		lerp(from.a, to.a, t)
	)

# Interpolazione con effetto bounce (andata e ritorno)
func bounce_lerp(from: float, to: float, t: float) -> float:
	if t < 0.5:
		return lerp(from, to, t * 2.0)
	else:
		return lerp(to, from, (t - 0.5) * 2.0)

# === FUNZIONI VALIDAZIONE ===

# Versione migliorata della funzione clamp standard che include controlli di validità per evitare errori logici comuni
# Previene crash e comportamenti indefiniti
# Situazioni tipiche dove serve: Sistemi di salute/mana con valori dinamici, Sliders UI con range configurabili, Sistemi di livelli con progressione variabile, Calcoli di percentuali con denominatori variabili
func clamp_i(value: int, min_val: int, max_val: int) -> int:
	if min_val > max_val:
		push_warning("clamp_i: min_val > max_val")
		return value
	return clampi(value, min_val, max_val)

# Versione per i float
func clamp_f(value: float, min_val: float, max_val: float) -> float:
	if min_val > max_val:
		push_warning("clamp_f: min_val > max_val")
		return value
	return clampf(value, min_val, max_val)

# Controlla se un numero è potenza di 2
func is_power_of_two(n: int) -> bool:
	return n > 0 and (n & (n - 1)) == 0

# === FUNZIONI STRINGA ===

# Capitalizza la prima lettera e rende minuscole le altre
func capitalize_first(text: String) -> String:
	if text.is_empty():
		return text
	return text[0].to_upper() + text.substr(1).to_lower()

# Conta le occorrenze di una sottostringa nel testo
func count_occurrences(text: String, substring: String) -> int:
	if substring.is_empty():
		return 0
	var count = 0
	var pos = 0
	var substring_len = substring.length()
	while true:
		pos = text.find(substring, pos)
		if pos == -1:
			break
		count += 1
		pos += substring_len
	return count

# Rimuove spazi dall'inizio e fine della stringa
func trim_string(text: String) -> String:
	return text.strip_edges()

# === FUNZIONI ARRAY ===

# Usa typed arrays quando possibile per performance
func create_typed_array(type: int, size: int) -> Array:
	var arr: Array
	match type:
		TYPE_INT:
			arr = Array([], TYPE_INT, "", null)
		TYPE_FLOAT:
			arr = Array([], TYPE_FLOAT, "", null)
		TYPE_STRING:
			arr = Array([], TYPE_STRING, "", null)
		TYPE_BOOL:
			arr = Array([], TYPE_BOOL, "", null)
		TYPE_VECTOR2:
			arr = Array([], TYPE_VECTOR2, "", null)
		TYPE_VECTOR3:
			arr = Array([], TYPE_VECTOR3, "", null)
		_:
			arr = []
	arr.resize(size)
	return arr

# Rimuove elementi duplicati da un array mantenendo l'ordine
func remove_duplicates(array: Array) -> Array:
	if array.is_empty():
		return []
	
	var seen = {}
	var result = []
	result.resize(array.size()) # Pre-alloca per evitare reallocazioni
	var write_index = 0
	
	for item in array:
		if not seen.has(item):
			seen[item] = true
			result[write_index] = item
			write_index += 1
	
	result.resize(write_index) # Ridimensiona alla dimensione effettiva
	return result

# Restituisce una copia mescolata dell'array originale
func shuffle_array(array: Array) -> Array:
	if array.is_empty():
		return []
	var shuffled = array.duplicate()
	shuffled.shuffle()
	return shuffled

# Mescola l'array direttamente modificando quello originale
func shuffle_array_in_place(array: Array) -> Array:
	array.shuffle()
	return array

# Trova l'indice di un elemento nell'array (-1 se non trovato)
func find_index(array: Array, item) -> int:
	return array.find(item)

# Controlla se un array contiene un elemento specifico
func contains(array: Array, item) -> bool:
	return item in array

# === FUNZIONI SCENA ===

# Ottiene riferimento alla scena corrente
func get_current_scene() -> Node:
	return get_tree().current_scene

# Ottiene il nome del file della scena corrente
func get_current_scene_name() -> String:
	return get_tree().current_scene.scene_file_path.get_file().get_basename()

# Cambia scena in modo sicuro con gestione errori.
# 'path' è il percorso della scena - Esempio: FH.change_scene("res://scenes/Menu.tscn")
func change_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Impossibile cambiare scena a: ", path, " Errore: ", error)
		# Qui potresti aggiungere una logica per gestire l'errore,
		# come mostrare un messaggio all'utente o tornare al menu principale.

# Ricarica la scena corrente
func reload_current_scene():
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path:
		change_scene(current_scene_path)
	else:
		push_error("Impossibile ricaricare la scena: nessuna scena corrente trovata o non salvata.")

# === FUNZIONI NODI ===

# Cache per ricerche frequenti di nodi
var _node_cache = {}

# Trova il nodo figlio con il nome specificato in un dato nodo.
func find_child_by_name(parent_node: Node, child_name: String) -> Node:
	var cache_key = str(parent_node.get_instance_id()) + ":" + child_name
	
	if _node_cache.has(cache_key):
		var cached_node = _node_cache[cache_key]
		if is_instance_valid(cached_node):
			return cached_node
		else:
			_node_cache.erase(cache_key)
	
	var node = parent_node.find_child(child_name)
	if node:
		_node_cache[cache_key] = node
	return node

# Rimuove e libera un nodo dalla memoria in modo sicuro
func remove_and_free_node(node_to_free: Node):
	if is_instance_valid(node_to_free):
		node_to_free.queue_free()

# Trova il primo nodo figlio di un tipo specifico (più efficiente di get_children())
func find_node_by_type(parent: Node, type: String) -> Node:
	for child in parent.get_children():
		if child.get_class() == type:
			return child
	return null

# Trova tutti i nodi figli di un tipo specifico
func find_all_nodes_by_type(parent: Node, type: String) -> Array[Node]:
	var result: Array[Node] = []
	_find_nodes_recursive(parent, type, result)
	return result

# Funzione ricorsiva per trovare tutti i nodi di un tipo specifico nell'albero delle scene
# Attraversa ricorsivamente tutti i nodi figli a partire dal nodo specificato
# Parametri:
# - node: Node - Il nodo radice da cui iniziare la ricerca
# - type: StringName - Il tipo/classe di nodo da cercare (es. "RigidBody2D", "Label", etc.)
# - result: Array[Node] - Array che viene modificato in-place per contenere i risultati
# Nota: Questa funzione modifica l'array 'result' direttamente invece di restituire un nuovo array
# ESEMPIO D'USO:
#	# Trova tutti i RigidBody2D nella scena
#	var rigid_bodies: Array[Node] = []
#	find_nodes_recursive(get_tree().current_scene, "RigidBody2D", rigid_bodies)
#	print("Trovati ", rigid_bodies.size(), " RigidBody2D")
#	# Trova tutte le Label in un menu specifico
#	var labels: Array[Node] = []
#	var menu_node = get_node("UI/Menu")
#	find_nodes_recursive(menu_node, "Label", labels)
func _find_nodes_recursive(node: Node, type: StringName, result: Array[Node], max_depth: int = -1, current_depth: int = 0):
	# Controllo di sicurezza per nodo nullo
	if node == null:
		return
	# Controllo profondità massima (se specificata)
	if max_depth > 0 and current_depth > max_depth:
		return
	# Controlla se il nodo corrente è del tipo cercato
	if node.get_class() == type:
		result.append(node)
	# Ricerca ricorsiva nei figli
	for child in node.get_children():
		_find_nodes_recursive(child, type, result, max_depth, current_depth + 1)

# Rimuove tutti i nodi figli di un nodo
func clear_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()

# === FUNZIONI CURVE E ANIMAZIONI ===

# Curva di easing quadratica in entrata
func ease_in_quad(t: float) -> float:
	return t * t

# Curva di easing quadratica in uscita
func ease_out_quad(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)

# Curva di easing quadratica in entrata e uscita
func ease_in_out_quad(t: float) -> float:
	return 2.0 * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0

# === FUNZIONI TIMER ===

# Pool di timer per evitare allocazioni continue
var _timer_pool: Array[Timer] = []
var _active_timers: Array[Timer] = []

# Crea un timer personalizzato con callback
func create_timer(duration: float, callback: Callable, one_shot: bool = true) -> Timer:
	var timer: Timer
	
	# Riusa timer dal pool se disponibile
	if not _timer_pool.is_empty():
		timer = _timer_pool.pop_back()
	else:
		timer = Timer.new()
		get_tree().current_scene.add_child(timer)
	
	timer.wait_time = duration
	timer.one_shot = one_shot
	timer.timeout.connect(callback)
	
	if one_shot:
		timer.timeout.connect(_return_timer_to_pool.bind(timer))
	
	_active_timers.append(timer)
	timer.start()
	return timer

# Ritorna timer al pool
func _return_timer_to_pool(timer: Timer):
	timer.stop()
	# Disconnetti tutti i segnali
	for connection in timer.timeout.get_connections():
		timer.timeout.disconnect(connection.callable)
	
	_active_timers.erase(timer)
	_timer_pool.append(timer)

# Esegue un callback dopo un ritardo specificato (non bloccante)
# Delay con callback - Non bloccante: la funzione ritorna immediatamente
# Asincrona: il callback viene eseguito in background dopo il ritardo
# Obbligatorio: il callback deve essere fornito
# Concorrente: puoi chiamare delay() multiple volte senza bloccare l'esecuzione
# Usare quando si vuole continuare l'esecuzione e fare qualcos'altro in parallelo
func delay(duration: float, callback: Callable):
	create_timer(duration, callback, true)

# Attende un certo numero di secondi prima di eseguire una funzione (bloccante con await)
# Utile per ritardi o animazioni.
# Bloccante: ferma l'esecuzione della funzione chiamante fino al completamento del timer
# Sincrona: usa await per aspettare il completamento
# Callback opzionale: può funzionare anche senza callback
# Sequenziale: se chiami wait_seconds() più volte, vengono eseguite in sequenza
# Usare quando si deve aspettare il completamento prima di procedere con il codice successivo
func wait_seconds(seconds: float, callback: Callable = Callable()):
	await get_tree().create_timer(seconds).timeout
	if callback.is_valid():
		callback.call()

# === FUNZIONI FORMATTAZIONE ===

# Formatta le dimensioni della memoria in formato leggibile (B, KB, MB, GB)
func Format_Memory_Size(bytes: int) -> String:
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))

# Formatta il tempo in formato MM:SS
func format_time(seconds: float) -> String:
	var minutes = floori(seconds / 60)
	var secs = floori(fmod(seconds, 60))
	return "%02d:%02d" % [minutes, secs]

# Formatta un numero con separatori delle migliaia (punto)
func format_number(number: int) -> String:
	var text = str(number)
	var result = ""
	for i in range(text.length()):
		if i > 0 and (text.length() - i) % 3 == 0:
			result += "."
		result += text[i]
	return result

# === FUNZIONI INPUT ===

# Controlla se una specifica azione di input è stata appena premuta
func is_action_just_pressed_global(action_name: String) -> bool:
	return Input.is_action_just_pressed(action_name)

# Controlla se una specifica azione di input è attualmente premuta
func is_action_pressed_global(action_name: String) -> bool:
	return Input.is_action_pressed(action_name)

# === FUNZIONI SEGNALI ===

# Connetti segnale con auto-disconnect
func connect_once(signal_obj: Signal, callable: Callable):
	var disconnect_wrapper = func():
		callable.call()
		if signal_obj.is_connected(callable):
			signal_obj.disconnect(callable)
	
	signal_obj.connect(disconnect_wrapper)

# Gestione migliorata dei segnali in Godot 4
func connect_signal_safe(signal_obj: Signal, callable: Callable, flags: int = 0):
	if not signal_obj.is_connected(callable):
		signal_obj.connect(callable, flags)

# === FUNZIONI PERFORMANCE ===

# Cache per funzioni costose
var _memoize_function_cache = {}
const MAX_CACHE_SIZE = 100

# Memoization migliorata con LRU
var _cache_usage_order = []

# Memorizza il risultato di una funzione costosa per evitare ricalcoli quando vengono richiesti con gli stessi parametri
# Casi d'uso pratici in Godot
#	1. Calcoli di Pathfinding costosi
#	# Invece di ricalcolare ogni volta il percorso tra due punti
#	func get_path_between_points(from: Vector2, to: Vector2) -> Array:
#		var key = "path_%s_%s" % [from, to]
#		return FH.memoize(key, func(): return calculate_expensive_path(from, to))
#	2. Generazione di mesh procedurali
#	# Evita di rigenerare mesh identiche
#	func generate_terrain_mesh(seed: int, size: int) -> Mesh:
#		var key = "terrain_%d_%d" % [seed, size]
#		return FH.memoize(key, func(): return create_terrain_mesh(seed, size))
#	3. Calcoli di fisica complessi
#	# Calcoli di traiettorie balistiche
#	func calculate_projectile_path(velocity: Vector2, gravity: float, time: float) -> Array:
#		var key = "projectile_%s_%f_%f" % [velocity, gravity, time]
#		return FH.memoize(key, func(): return compute_trajectory(velocity, gravity, time))
#	4. Elaborazione di texture
#	# Filtri o effetti su texture
#	func apply_blur_effect(texture: Texture2D, radius: float) -> Texture2D:
#		var key = "blur_%s_%f" % [texture.get_rid(), radius]
#		return FH.memoize(key, func(): return create_blurred_texture(texture, radius))
#	5. Calcoli di illuminazione
#	# Calcoli di lightmaps o shadow maps
#	func calculate_lighting(position: Vector3, normal: Vector3, light_sources: Array) -> Color:
#		var key = "lighting_%s_%s_%s" % [position, normal, light_sources.hash()]
#		return FH.memoize(key, func(): return compute_lighting(position, normal, light_sources))
#	6. Algoritmi ricorsivi
#	# Fibonacci con memoization
#	func fibonacci(n: int) -> int:
#		var key = "fib_%d" % n
#		return FH.memoize(key, func(): 
#			if n <= 1: return n
#			return fibonacci(n-1) + fibonacci(n-2)
#		)
func memoize(key: String, callable: Callable):
	if _memoize_function_cache.has(key):
		# Aggiorna ordine di utilizzo
		_cache_usage_order.erase(key)
		_cache_usage_order.append(key)
		return _memoize_function_cache[key]
	
	# Calcola e memorizza risultato
	var result = callable.call()
	_memoize_function_cache[key] = result
	_cache_usage_order.append(key)
	
	# Rimuovi elementi più vecchi se necessario
	if _memoize_function_cache.size() > MAX_CACHE_SIZE:
		var oldest_key = _cache_usage_order.pop_front()
		_memoize_function_cache.erase(oldest_key)
	
	return result

# Pulisce la cache delle funzioni memoizzate
func clear_memoize_cache():
	_memoize_function_cache.clear()

# === FUNZIONI MEMORIA ===

# Esegue una pulizia completa della memoria: Forza garbage collection, Pulisce cache interna, Pulisce pool di stringhe ResourceLoader
func cleanup_memory():
	# Pulisci cache con limite
	if _memoize_function_cache.size() * 2 > MAX_CACHE_SIZE: # Equivalente a _memoize_function_cache.size() > MAX_CACHE_SIZE / 2
		var keys_to_remove = _cache_usage_order.slice(0, _cache_usage_order.size() >> 1) # Equivalente a _cache_usage_order.size() / 2
		for key in keys_to_remove:
			_memoize_function_cache.erase(key)
		_cache_usage_order = _cache_usage_order.slice(_cache_usage_order.size() >> 1) # Equivalente a _cache_usage_order.size() / 2
	
	# Pulisci cache nodi invalidi
	for key in _node_cache.keys():
		if not is_instance_valid(_node_cache[key]):
			_node_cache.erase(key)
	
	# Pulisci timer pool
	for timer in _timer_pool:
		if not is_instance_valid(timer):
			_timer_pool.erase(timer)
	# Forza garbage collection (se disponibile)
	if Engine.has_method("force_gc"):
		Engine.call("force_gc")
	
	# Godot 4: Gestione cache ResourceLoader migliorata
	# In Godot 4, ResourceLoader gestisce automaticamente la cache
	# Ma possiamo comunque pulire la cache manualmente se necessario
	if ResourceLoader.has_method("clear_cache"):
		ResourceLoader.call("clear_cache")
	
	# Godot 4: Pulisci cache texture se disponibile
	if RenderingServer.has_method("free_rid"):
		# La gestione delle texture è più automatica in Godot 4
		pass
	
	# Godot 4: Suggerisci al motore di liberare memoria non utilizzata
	if OS.has_method("request_attention"):
		# Questo è un placeholder - in Godot 4 la gestione memoria è più automatica
		pass

# === OVERRIDE _EXIT_TREE PER CLEANUP ===

# Pulizia automatica quando il nodo viene rimosso dall'albero della scena
# RIMOSSO perchè il cleanup automatico alla chiusura dell'app è superfluo e potenzialmente problematico
#func _exit_tree():
#	# Pulisci timer attivi
#	for timer in _active_timers:
#		if is_instance_valid(timer):
#			timer.queue_free()
#	_active_timers.clear()
#	# Pulisci pool timer
#	for timer in _timer_pool:
#		if is_instance_valid(timer):
#			timer.queue_free()
#	_timer_pool.clear()
#	# Pulisci cache
#	_memoize_function_cache.clear()
#	_cache_usage_order.clear()
#	_node_cache.clear()
