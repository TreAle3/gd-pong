# abc_system.gd - iniziato 07/07/2025 - ultima modifica 10/07/2025 - versione 1.0
# AutoLoad script per rilevare sistema operativo e capacità della piattaforma
# Da aggiungere come AutoLoad in Project Settings > AutoLoad
# Nome: SY, Path: res://autoload_abc/abc_system.gd

# Rilevamento Piattaforma
# PlatformDetector.gd rileva:
#	Sistema operativo (Windows, Linux, macOS, Android, iOS)
#	Tipo dispositivo (desktop, mobile, tablet)
#	Permessi necessari (storage, network)
#	Percorsi di salvataggio corretti per ogni OS
# Rilevamento Grafico
# GraphicsDetector.gd rileva:
#	Risoluzione schermo nativa
#	DPI e scaling
#	Supporto per fullscreen
#	Capacità grafiche (OpenGL, Vulkan)
#	Orientamento (mobile)

# Funzionalità Implementate
#	Rilevamento Piattaforma
#		Rileva automaticamente Windows, Linux, macOS, Android, iOS, Web
#		Classifica come desktop, mobile o web
#		Identifica il tipo di dispositivo (desktop, mobile, tablet)
#	Rilevamento Capacità
#		Supporto fullscreen
#		Accesso al file system
#		Permessi di rete e storage
#		Capacità hardware di base
#	Percorsi di Sistema
#		Percorsi sicuri per salvataggio dati
#		Percorsi documenti, cache e temporanei
#		Gestione corretta per ogni piattaforma
#	Informazioni Hardware
#		Numero di core CPU
#		Stima memoria disponibile
#		Informazioni GPU quando disponibili
#	Gestione Permessi
#		Controllo permessi per piattaforme mobile
#		Gestione asincrona dei permessi
#	Rilevamento Display
#		Informazioni su tutti gli schermi disponibili
#		Risoluzione, DPI, refresh rate
#		Orientamento (importante per mobile)
#		Supporto multi-monitor
#	Rilevamento Capacità Grafiche
#		API grafica in uso (Vulkan/OpenGL3)
#		Informazioni GPU (nome, vendor, versione)
#		Dimensioni texture massime
#		Supporto compute shaders
#		Stima VRAM
#	Impostazioni Raccomandate
#		Qualità grafica ottimale basata su hardware
#		Risoluzione raccomandata
#		Impostazioni VSync, MSAA, FSR
#		Adattamento automatico per mobile/desktop
#	Gestione Display
#		Modalità finestra/fullscreen
#		Risoluzioni supportate
#		Aspect ratio e widescreen detection
#		Pixel density per high-DPI

# Utilizzo
# Nel project.godot, aggiungi come AutoLoad:
#	[autoload]
#	PlatformDetector="*res://script/abc_system.gd"

# Esempi di Utilizzo
#	# Controlla la piattaforma
#	if SY.is_platform(SY.Platform.ANDROID):
#		print("Siamo su Android")
#	# Ottieni percorso sicuro per salvataggio
#	var save_path = SY.get_safe_save_path()
#	# Controlla capacità
#	if SY.can_access_file_system():
#		# Salva file
#		pass
#	# Ottieni risoluzione raccomandata
#	var window_size = SY.get_recommended_window_size()
#	# Ottieni impostazioni raccomandate
#	var settings = SY.get_recommended_settings()
#	# Controlla supporto funzionalità
#	if SY.supports_fullscreen:
#		SY.set_display_mode(SY.DisplayMode.FULLSCREEN)
#	# Ottieni risoluzioni supportate
#	var resolutions = SY.get_supported_resolutions()
#	# Informazioni dettagliate
#	SY.print_graphics_info()


extends Node

# ================================
# SEGNALI
# ================================

## Emesso quando la rilevazione della piattaforma è completata
## Viene emesso una volta durante _ready() dopo aver rilevato SO, dispositivo e capacità
signal platform_detected

## Emesso quando il controllo dei permessi è completato
## Particolarmente utile su mobile dove i permessi sono asincroni
signal permissions_checked

## Emesso quando la rilevazione grafica è completata
## Viene emesso dopo aver rilevato capacità GPU, display e impostazioni raccomandate
signal graphics_detected

## Emesso quando avviene un cambiamento nel display
## Può essere emesso quando cambia risoluzione, modalità finestra o orientamento
signal display_changed

# ================================
# ENUMERAZIONI
# ================================

## Enumerazione per identificare la piattaforma/sistema operativo
enum Platform {
	WINDOWS,  ## Microsoft Windows
	LINUX,    ## Linux e varianti BSD
	MACOS,    ## Apple macOS
	ANDROID,  ## Google Android
	IOS,      ## Apple iOS
	WEB,      ## Browser web
	UNKNOWN   ## Piattaforma non riconosciuta
}

## Enumerazione per identificare il tipo di dispositivo
enum DeviceType {
	DESKTOP,  ## Computer desktop/laptop
	MOBILE,   ## Smartphone
	TABLET,   ## Tablet
	UNKNOWN   ## Tipo non determinato
}

## Enumerazione per identificare l'API grafica in uso
enum GraphicsAPI {
	VULKAN,   ## Vulkan API (preferita su desktop)
	OPENGL3,  ## OpenGL 3.x (fallback)
	UNKNOWN   ## API non determinata
}

## Enumerazione per le modalità di display
enum DisplayMode {
	WINDOWED,              ## Modalità finestra
	FULLSCREEN,            ## Schermo intero esclusivo
	BORDERLESS_FULLSCREEN  ## Schermo intero senza bordi
}

## Enumerazione per i livelli di qualità grafica
enum GraphicsQuality {
	LOW,    ## Qualità bassa - per hardware limitato
	MEDIUM, ## Qualità media - bilanciamento performance/qualità
	HIGH,   ## Qualità alta - per hardware moderno
	ULTRA   ## Qualità ultra - per hardware top di gamma
}

# ================================
# VARIABILI PUBBLICHE - PIATTAFORMA
# ================================

## Piattaforma corrente rilevata (valore dall'enum Platform)
var current_platform: Platform

## Tipo di dispositivo corrente rilevato (valore dall'enum DeviceType)
var current_device_type: DeviceType

## Nome della piattaforma come stringa (es: "Windows", "Android")
var platform_name: String

## True se il dispositivo è mobile (Android/iOS)
var is_mobile: bool = false

## True se il dispositivo è desktop (Windows/Linux/macOS)
var is_desktop: bool = false

## True se l'applicazione gira in un browser web
var is_web: bool = false

## True se la piattaforma supporta l'accesso al file system
var supports_file_system: bool = false

## True se la piattaforma supporta le connessioni di rete
var supports_network: bool = false

## True se l'applicazione ha i permessi per accedere allo storage
var has_storage_permission: bool = false

## True se l'applicazione ha i permessi per accedere alla rete
var has_network_permission: bool = false

# ================================
# VARIABILI PUBBLICHE - PERCORSI
# ================================

## Percorso sicuro per salvare i dati utente dell'applicazione
var user_data_path: String

## Percorso alla cartella documenti dell'utente (se disponibile)
var documents_path: String

## Percorso alla cartella cache dell'applicazione
var cache_path: String

## Percorso alla cartella temporanea
var temp_path: String

# ================================
# VARIABILI PUBBLICHE - HARDWARE
# ================================

## Numero di core/thread della CPU
var cpu_count: int

## Quantità stimata di memoria RAM in MB
var memory_mb: int

## Nome della scheda grafica (es: "GeForce RTX 4090")
var gpu_name: String

## Produttore della scheda grafica (es: "NVIDIA", "AMD")
var gpu_vendor: String

# ================================
# VARIABILI PUBBLICHE - DISPLAY
# ================================

## Numero totale di schermi connessi
var screen_count: int

## Indice dello schermo primario (solitamente 0)
var primary_screen: int

## Risoluzione dello schermo primario in pixel
var screen_size: Vector2i

## Centro dello schermo primario in pixel (per non doverlo sempre calcolare)
var screen_center: Vector2i

# Risoluzione della finestra di gioco
var w_dim: Vector2i # Dimensioni
var w_cen: Vector2i # Centro finestra

# Risoluzione base della finestra settata nelle impostazioni (ignorando l'override)
var w_orig_dim: Vector2i
var w_orig_centro: Vector2i

# Calcola lo scale factor tra dimensioni finestra attuale e dimensioni base impostate
var w_scala: Vector2

## DPI (punti per pollice) dello schermo primario
var screen_dpi: int

## Frequenza di aggiornamento dello schermo in Hz
var screen_refresh_rate: float

## Orientamento dello schermo (importante per mobile)
var screen_orientation: DisplayServer.ScreenOrientation

## True se il sistema supporta configurazioni multi-monitor
var supports_multiple_screens: bool = false

# ================================
# VARIABILI PUBBLICHE - CAPACITÀ GRAFICHE
# ================================

## API grafica attualmente in uso (Vulkan o OpenGL)
var graphics_api: GraphicsAPI

## Versione dell'API grafica
var gpu_version: String

## Dimensione massima supportata per le texture in pixel
var max_texture_size: int

## True se la GPU supporta i compute shader
var supports_compute_shaders: bool = false

## True se la GPU supporta il rendering 3D
var supports_3d_rendering: bool = false

## Quantità stimata di VRAM in MB
var vram_mb: int = 0

# ================================
# VARIABILI PUBBLICHE - IMPOSTAZIONI RACCOMANDATE
# ================================

## Livello di qualità grafica raccomandato per questo hardware
var recommended_quality: GraphicsQuality

## Risoluzione raccomandata per le migliori performance
var recommended_resolution: Vector2i

## True se è raccomandato abilitare il VSync
var recommended_vsync: bool

## Livello di anti-aliasing MSAA raccomandato (1=off, 2=2x, 4=4x, 8=8x)
var recommended_msaa: int

## True se è raccomandato abilitare FSR (FidelityFX Super Resolution)
var recommended_fsr: bool

# ================================
# VARIABILI PUBBLICHE - SUPPORTO FUNZIONALITÀ
# ================================

## True se la piattaforma supporta la modalità schermo intero
var supports_fullscreen: bool

## True se la piattaforma supporta il VSync
var supports_vsync: bool

## True se la piattaforma supporta l'HDR
var supports_hdr: bool

## True se la piattaforma supporta schermi ad alta risoluzione (high-DPI)
var supports_high_dpi: bool

# ================================
# METODI PRINCIPALI
# ================================

## Metodo chiamato automaticamente quando il nodo entra nell'albero delle scene
## Esegue tutti i rilevamenti e inizializza le variabili pubbliche
func _ready():
	detect_platform()           # Rileva SO e piattaforma
	detect_device_type()        # Determina tipo dispositivo
	detect_capabilities()       # Rileva capacità piattaforma
	detect_system_paths()       # Trova percorsi di sistema
	detect_hardware_info()      # Rileva info hardware
	check_permissions()         # Controlla permessi
	platform_detected.emit()   # Emette segnale completamento
	detect_display_info()       # Rileva info display
	detect_graphics_capabilities() # Rileva capacità grafiche
	detect_supported_features() # Rileva funzionalità supportate
	calculate_recommended_settings() # Calcola impostazioni ottimali
	graphics_detected.emit()    # Emette segnale completamento grafica

## Rileva la piattaforma/sistema operativo corrente
## Imposta current_platform, platform_name, is_mobile, is_desktop, is_web
func detect_platform():
	var os_name = OS.get_name()
	platform_name = os_name
	
	match os_name:
		"Windows":
			current_platform = Platform.WINDOWS
			is_desktop = true
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			current_platform = Platform.LINUX
			is_desktop = true
		"macOS":
			current_platform = Platform.MACOS
			is_desktop = true
		"Android":
			current_platform = Platform.ANDROID
			is_mobile = true
		"iOS":
			current_platform = Platform.IOS
			is_mobile = true
		"Web":
			current_platform = Platform.WEB
			is_web = true
		_:
			current_platform = Platform.UNKNOWN

## Rileva il tipo di dispositivo basandosi su piattaforma e risoluzione
## Su mobile distingue tra tablet e smartphone usando aspect ratio e dimensioni
func detect_device_type():
	if is_mobile:
		# Su mobile, rileva se è tablet o telefono basandosi sulla risoluzione
		var m_screen_size = DisplayServer.screen_get_size()
		var min_size = min(m_screen_size.x, m_screen_size.y)
		var max_size = max(m_screen_size.x, m_screen_size.y)
		var aspect_ratio = float(max_size) / float(min_size)
		
		# Tablet solitamente hanno aspect ratio più vicino a 4:3
		if min_size >= 768 and aspect_ratio < 1.8:
			current_device_type = DeviceType.TABLET
		else:
			current_device_type = DeviceType.MOBILE
	elif is_desktop:
		current_device_type = DeviceType.DESKTOP
	else:
		current_device_type = DeviceType.UNKNOWN

## Rileva le capacità supportate dalla piattaforma corrente
## Determina supporto per fullscreen, file system, network e permessi
func detect_capabilities():
	# Fullscreen supportato su desktop e web
	supports_fullscreen = is_desktop or current_platform == Platform.WEB
	
	# File system non disponibile su web
	supports_file_system = not is_web
	
	# Network supportato su tutte le piattaforme
	supports_network = true
	
	# Permessi specifici per mobile
	if is_mobile:
		has_storage_permission = _check_storage_permission()
		has_network_permission = _check_network_permission()
	else:
		has_storage_permission = true
		has_network_permission = true

## Rileva e imposta i percorsi di sistema appropriati per ogni piattaforma
## Trova percorsi sicuri per dati utente, documenti, cache e file temporanei
func detect_system_paths():
	# Percorso dati utente (sempre disponibile)
	user_data_path = OS.get_user_data_dir()
	
	# Percorso cache
	cache_path = OS.get_cache_dir()
	
	# Percorso temporaneo
	temp_path = user_data_path
	
	# Percorso documenti (se disponibile)
	if supports_file_system:
		match current_platform:
			Platform.WINDOWS:
				documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			Platform.LINUX:
				documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			Platform.MACOS:
				documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			Platform.ANDROID:
				documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			_:
				documents_path = user_data_path
	else:
		documents_path = user_data_path

## Rileva informazioni hardware di base (CPU, RAM, GPU)
## Ottiene numero core CPU, stima memoria e informazioni scheda grafica
func detect_hardware_info():
	# Numero di core CPU
	cpu_count = OS.get_processor_count()
	
	# Memoria (approssimativa, non sempre disponibile)
	memory_mb = _estimate_memory()
	
	# Informazioni GPU (se disponibili)
	var rendering_device = RenderingServer.get_rendering_device()
	if rendering_device:
		gpu_name = RenderingServer.get_video_adapter_name()
		gpu_vendor = RenderingServer.get_video_adapter_vendor()
	else:
		gpu_name = "Unknown"
		gpu_vendor = "Unknown"

## Controlla e richiede i permessi necessari (principalmente per mobile)
## Su desktop i permessi sono sempre garantiti, su mobile gestiti in modo asincrono
func check_permissions():
	if is_mobile:
		# Su mobile, i permessi vengono controllati in modo asincrono
		_request_permissions()
	else:
		# Su desktop, i permessi sono sempre garantiti
		has_storage_permission = true
		has_network_permission = true
		permissions_checked.emit()


# ================================
# METODI DI UTILITÀ PUBBLICA
# ================================

## Restituisce il nome della piattaforma come stringa
## @return Nome della piattaforma (es: "Windows", "Android")
func get_platform_name() -> String:
	return platform_name

## Restituisce il percorso sicuro per salvare i dati dell'applicazione
## @return Percorso assoluto alla cartella dati utente
func get_safe_save_path() -> String:
	return user_data_path

## Restituisce il percorso alla cartella documenti dell'utente
## @return Percorso assoluto alla cartella documenti (o user_data_path se non disponibile)
func get_documents_path() -> String:
	return documents_path

## Restituisce il percorso alla cartella cache dell'applicazione
## @return Percorso assoluto alla cartella cache
func get_cache_path() -> String:
	return cache_path

## Controlla se la piattaforma corrente corrisponde a quella specificata
## @param platform Piattaforma da confrontare
## @return True se corrisponde alla piattaforma corrente
func is_platform(platform: Platform) -> bool:
	return current_platform == platform

## Controlla se il dispositivo corrente corrisponde al tipo specificato
## @param device_type Tipo di dispositivo da confrontare
## @return True se corrisponde al tipo di dispositivo corrente
func is_device_type(device_type: DeviceType) -> bool:
	return current_device_type == device_type

## Controlla se l'applicazione può accedere al file system
## @return True se supporta file system e ha i permessi necessari
func can_access_file_system() -> bool:
	return supports_file_system and has_storage_permission

## Controlla se l'applicazione può accedere alla rete
## @return True se supporta network e ha i permessi necessari
func can_access_network() -> bool:
	return supports_network and has_network_permission

## Calcola la dimensione raccomandata per la finestra dell'applicazione
## @return Dimensioni raccomandate per la finestra in pixel
func get_recommended_window_size() -> Vector2i:
	var w_screen_size = DisplayServer.screen_get_size()
	
	if is_mobile:
		# Su mobile, usa la risoluzione completa
		return w_screen_size
	else:
		# Su desktop, usa l'80% della risoluzione dello schermo
		return Vector2i(
			int(w_screen_size.x * 0.8),
			int(w_screen_size.y * 0.8)
		)

## Restituisce un dizionario con tutte le informazioni di sistema
## @return Dictionary con informazioni complete su piattaforma, hardware e capacità
func get_system_info() -> Dictionary:
	return {
		"platform": Platform.keys()[current_platform],
		"device_type": DeviceType.keys()[current_device_type],
		"platform_name": platform_name,
		"is_mobile": is_mobile,
		"is_desktop": is_desktop,
		"is_web": is_web,
		"supports_fullscreen": supports_fullscreen,
		"supports_file_system": supports_file_system,
		"cpu_count": cpu_count,
		"memory_mb": memory_mb,
		"gpu_name": gpu_name,
		"gpu_vendor": gpu_vendor,
		"user_data_path": user_data_path,
		"documents_path": documents_path,
		"cache_path": cache_path
	}

# ================================
# METODI PRIVATI
# ================================

## Controlla se l'applicazione ha i permessi per accedere allo storage (mobile)
## @return True se i permessi sono disponibili
func _check_storage_permission() -> bool:
	# Su Android, controlla i permessi di storage
	if current_platform == Platform.ANDROID:
		return OS.request_permissions()
	return true

## Controlla se l'applicazione ha i permessi per accedere alla rete (mobile)
## @return True se i permessi sono disponibili
func _check_network_permission() -> bool:
	# Su iOS e Android, controlla i permessi di rete
	if is_mobile:
		return OS.request_permissions()
	return true

# Richiede i permessi necessari per le piattaforme mobile
# Gestisce in modo asincrono la richiesta di permessi di storage e network
# Per Android e iOS, imposta i permessi come garantiti (devono essere configurati nel manifest/Info.plist)
# Emette il segnale permissions_checked quando completato
func _request_permissions():
	# Richiede i permessi necessari per mobile
	if current_platform == Platform.ANDROID:
		# Su Android, richiede permessi di storage e network
		var permissions = []
		permissions.append("android.permission.WRITE_EXTERNAL_STORAGE")
		permissions.append("android.permission.READ_EXTERNAL_STORAGE")
		permissions.append("android.permission.INTERNET")
		permissions.append("android.permission.ACCESS_NETWORK_STATE")
		
		# Nota: In Godot 4, OS.request_permissions() è deprecato
		# I permessi devono essere gestiti nel manifest Android
		has_storage_permission = true
		has_network_permission = true
	elif current_platform == Platform.IOS:
		# Su iOS, i permessi sono gestiti tramite Info.plist
		has_storage_permission = true
		has_network_permission = true
	
	# Emette il segnale per notificare che i permessi sono stati controllati
	permissions_checked.emit()

# Stima la memoria RAM disponibile in MB basandosi sulla piattaforma
# Ritorna un valore approssimativo in megabytes
# @return int: Memoria stimata in MB
func _estimate_memory() -> int:
	# Stima approssimativa della memoria disponibile
	# Godot non fornisce un modo diretto per ottenerla
	match current_platform:
		Platform.WINDOWS, Platform.LINUX, Platform.MACOS:
			return 8192  # Assume 8GB come default per desktop
		Platform.ANDROID:
			return 4096  # Assume 4GB come default per Android
		Platform.IOS:
			return 4096  # Assume 4GB come default per iOS
		_:
			return 2048  # Default conservativo

#===== GRAFICA =====

# Rileva e memorizza informazioni complete sui display disponibili
# Raccoglie dati su schermi multipli, risoluzione, DPI, refresh rate e orientamento
# Determina il supporto per high DPI e schermi multipli
func detect_display_info():
	# Numero di schermi collegati al sistema
	screen_count = DisplayServer.get_screen_count()
	# Determina se il sistema supporta configurazioni multi-monitor
	supports_multiple_screens = screen_count > 1
	
	# Identifica lo schermo primario (sempre 0 in Godot)
	primary_screen = 0
	
	# Ottiene le dimensioni in pixel dello schermo primario
	screen_size = DisplayServer.screen_get_size(primary_screen)
	screen_center = Vector2i(screen_size.x >> 1,screen_size.y >> 1) # Calcola il centro dello schermo in modo da non doverlo calcolare tutte le volte
	
	# Ottiene le dimensioni in pixel della finestra (dimensioni attuali)
	w_dim = DisplayServer.window_get_size()
	w_cen = Vector2i(w_dim.x >> 1,w_dim.y >> 1)

	# Ottiene le dimensioni in pixel della finestra impostata prima dell'override (dimensioni originali)
	w_orig_dim = Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
	w_orig_centro = Vector2i(w_orig_dim.x >> 1,w_orig_dim.y >> 1)
	
	# Calcola lo scale factor
	w_scala = Vector2(w_dim.x/w_orig_dim.x,w_dim.y/w_orig_dim.y)
	
	# Rileva i DPI (dots per inch) dello schermo
	screen_dpi = DisplayServer.screen_get_dpi(primary_screen)
	
	# Ottiene la frequenza di aggiornamento in Hz
	screen_refresh_rate = DisplayServer.screen_get_refresh_rate(primary_screen)
	
	# Rileva l'orientamento dello schermo (importante per mobile)
	screen_orientation = DisplayServer.screen_get_orientation(primary_screen)
	
	# Determina se lo schermo supporta high DPI (>96 DPI standard)
	supports_high_dpi = screen_dpi > 96

# Rileva e analizza le capacità grafiche hardware del sistema
# Identifica l'API grafica, informazioni GPU, limiti texture e supporto compute
# Stima la VRAM disponibile
func detect_graphics_capabilities():
	# Determina quale API grafica è attualmente in uso
	var rendering_device = RenderingServer.get_rendering_device()
	if rendering_device:
		# Se abbiamo un rendering device, probabilmente è Vulkan
		graphics_api = GraphicsAPI.VULKAN
	else:
		# Fallback a OpenGL se Vulkan non è disponibile
		graphics_api = GraphicsAPI.OPENGL3
	
	# Raccoglie informazioni dettagliate sulla GPU
	gpu_name = RenderingServer.get_video_adapter_name()
	gpu_vendor = RenderingServer.get_video_adapter_vendor()
	gpu_version = RenderingServer.get_video_adapter_api_version()
	
	# Determina la dimensione massima supportata per le texture 2D
	max_texture_size = RenderingServer.get_rendering_device().limit_get(RenderingDevice.LIMIT_MAX_TEXTURE_SIZE_2D) if RenderingServer.get_rendering_device() else 4096
	
	# Verifica il supporto per compute shaders (disponibile solo con Vulkan)
	supports_compute_shaders = RenderingServer.get_rendering_device() != null
	
	# Conferma il supporto per rendering 3D (sempre true in Godot 4)
	supports_3d_rendering = true  # Godot 4 supporta sempre il 3D
	
	# Calcola una stima della VRAM disponibile
	vram_mb = _estimate_vram()

# Rileva le funzionalità grafiche supportate dalla piattaforma
# Controlla supporto per VSync, HDR e altre caratteristiche avanzate
func detect_supported_features():
	# VSync supportato su tutte le piattaforme eccetto web
	supports_vsync = not is_web  # Web ha limitazioni VSync
	
	# Controlla il supporto HDR
	supports_hdr = _check_hdr_support()
	
	# High DPI già rilevato in detect_display_info()

# Calcola le impostazioni grafiche ottimali per l'hardware rilevato
# Determina qualità, risoluzione, VSync, MSAA e FSR raccomandati
func calculate_recommended_settings():
	# Determina il preset di qualità ottimale basato su GPU e risoluzione
	recommended_quality = _calculate_quality_preset()
	
	# Calcola la risoluzione raccomandata per le prestazioni
	recommended_resolution = _calculate_recommended_resolution()
	
	# Determina se VSync dovrebbe essere abilitato
	recommended_vsync = supports_vsync and not is_mobile
	
	# Calcola il livello MSAA appropriato
	recommended_msaa = _calculate_recommended_msaa()
	
	# Determina se FSR dovrebbe essere utilizzato
	recommended_fsr = _should_use_fsr()

# Ottiene informazioni dettagliate su un display specifico
# @param screen_id: ID dello schermo (default: 0 per schermo primario)
# @return Dictionary: Informazioni complete sul display
func get_screen_info(screen_id: int = 0) -> Dictionary:
	# Valida l'ID dello schermo, usa primario se non valido
	if screen_id >= screen_count:
		screen_id = 0
	
	# Ritorna un dizionario con tutte le informazioni del display
	return {
		"size": DisplayServer.screen_get_size(screen_id),           # Dimensioni in pixel
		"dpi": DisplayServer.screen_get_dpi(screen_id),             # DPI del display
		"refresh_rate": DisplayServer.screen_get_refresh_rate(screen_id), # Frequenza Hz
		"orientation": DisplayServer.screen_get_orientation(screen_id),   # Orientamento
		"position": DisplayServer.screen_get_position(screen_id),   # Posizione nello spazio desktop
		"usable_rect": DisplayServer.screen_get_usable_rect(screen_id)    # Area utilizzabile (escluse barre)
	}

# Ottiene informazioni complete sulle capacità grafiche del sistema
# @return Dictionary: Dati dettagliati su GPU, API e limiti hardware
func get_graphics_info() -> Dictionary:
	return {
		"api": GraphicsAPI.keys()[graphics_api],        # API grafica in uso
		"gpu_name": gpu_name,                          # Nome della GPU
		"gpu_vendor": gpu_vendor,                      # Produttore GPU
		"gpu_version": gpu_version,                    # Versione driver/API
		"max_texture_size": max_texture_size,          # Dimensione massima texture
		"supports_compute": supports_compute_shaders,  # Supporto compute shaders
		"supports_3d": supports_3d_rendering,          # Supporto rendering 3D
		"vram_mb": vram_mb                            # VRAM stimata in MB
	}

# Ottiene le impostazioni grafiche raccomandate per l'hardware corrente
# @return Dictionary: Impostazioni ottimali calcolate automaticamente
func get_recommended_settings() -> Dictionary:
	return {
		"quality": GraphicsQuality.keys()[recommended_quality], # Preset qualità
		"resolution": recommended_resolution,                   # Risoluzione consigliata
		"vsync": recommended_vsync,                            # VSync raccomandato
		"msaa": recommended_msaa,                              # Livello MSAA
		"fsr": recommended_fsr                                 # Utilizzo FSR
	}

# Ottiene le modalità di visualizzazione supportate dalla piattaforma
# @return Array[DisplayMode]: Array delle modalità disponibili
func get_display_modes() -> Array[DisplayMode]:
	var modes: Array[DisplayMode] = []
	# Modalità finestra sempre disponibile
	modes.append(DisplayMode.WINDOWED)
	
	# Modalità fullscreen solo se supportate
	if supports_fullscreen:
		modes.append(DisplayMode.FULLSCREEN)
		modes.append(DisplayMode.BORDERLESS_FULLSCREEN)
	
	return modes

# Imposta la modalità di visualizzazione della finestra
# @param mode: Modalità da applicare (windowed, fullscreen, borderless)
func set_display_mode(mode: DisplayMode):
	match mode:
		DisplayMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayMode.BORDERLESS_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

# Ottiene un array delle risoluzioni supportate dal sistema
# Include la risoluzione nativa e risoluzioni standard comuni
# @return Array[Vector2i]: Risoluzioni ordinate per dimensione decrescente
func get_supported_resolutions() -> Array[Vector2i]:
	var resolutions: Array[Vector2i] = []
	
	# Aggiunge sempre la risoluzione nativa
	resolutions.append(screen_size)
	
	# Lista di risoluzioni standard comuni
	var common_resolutions = [
		Vector2i(1920, 1080),  # Full HD
		Vector2i(1680, 1050),  # WSXGA+
		Vector2i(1600, 900),   # HD+
		Vector2i(1440, 900),   # WXGA+
		Vector2i(1366, 768),   # WXGA
		Vector2i(1280, 720),   # HD
		Vector2i(1024, 768),   # XGA
		Vector2i(800, 600)     # SVGA
	]
	
	# Filtra le risoluzioni che non superano quella nativa
	for res in common_resolutions:
		if res.x <= screen_size.x and res.y <= screen_size.y and res not in resolutions:
			resolutions.append(res)
	
	# Ordina le risoluzioni per area decrescente
	resolutions.sort_custom(func(a, b): return a.x * a.y > b.x * b.y)
	
	return resolutions

# Verifica se una risoluzione specifica è supportata dal sistema
# @param resolution: Risoluzione da verificare
# @return bool: true se supportata, false altrimenti
func is_resolution_supported(resolution: Vector2i) -> bool:
	return resolution.x <= screen_size.x and resolution.y <= screen_size.y

# Calcola l'aspect ratio dello schermo corrente
# @return float: Rapporto larghezza/altezza
func get_aspect_ratio() -> float:
	return float(screen_size.x) / float(screen_size.y)

# Determina se lo schermo ha un aspect ratio widescreen
# @return bool: true se widescreen (>1.6), false altrimenti
func is_widescreen() -> bool:
	return get_aspect_ratio() > 1.6

# Calcola la densità dei pixel relativa allo standard
# @return float: Densità pixel (1.0 = 96 DPI standard)
func get_pixel_density() -> float:
	return screen_dpi / 96.0  # 96 DPI è lo standard

# Callback per gestire i cambiamenti della modalità finestra
# Dovrebbe essere chiamato manualmente quando si cambia la modalità
# Emette il segnale display_changed per notificare i cambiamenti
func _on_window_mode_changed():
	display_changed.emit()

# Controlla se ci sono stati cambiamenti nella configurazione display
# Utile per monitorare cambiamenti di risoluzione o connessione/disconnessione monitor
# Dovrebbe essere chiamato periodicamente tramite Timer se necessario
func check_for_display_changes():
	var current_size = DisplayServer.screen_get_size(primary_screen)
	if current_size != screen_size:
		screen_size = current_size
		display_changed.emit()

# Metodi privati per calcoli interni

# Stima la quantità di VRAM disponibile basandosi sul nome della GPU
# Utilizza un database di GPU comuni per fornire stime conservative
# @return int: VRAM stimata in MB
func _estimate_vram() -> int:
	# Stima VRAM basata su GPU e piattaforma
	var gpu_lower = gpu_name.to_lower()
	
	# Stime conservative basate su GPU comuni
	if "rtx 4090" in gpu_lower or "rx 7900" in gpu_lower:
		return 16384  # 16GB per GPU di fascia alta
	elif "rtx 4080" in gpu_lower or "rtx 4070" in gpu_lower or "rx 7800" in gpu_lower:
		return 12288  # 12GB per GPU di fascia medio-alta
	elif "rtx 4060" in gpu_lower or "rtx 3070" in gpu_lower or "rx 6700" in gpu_lower:
		return 8192   # 8GB per GPU di fascia media
	elif "rtx 3060" in gpu_lower or "gtx 1660" in gpu_lower or "rx 580" in gpu_lower:
		return 6144   # 6GB per GPU di fascia medio-bassa
	elif "gtx 1050" in gpu_lower or "rx 560" in gpu_lower:
		return 4096   # 4GB per GPU di fascia bassa
	elif is_mobile:
		return 2048   # 2GB per dispositivi mobile
	else:
		return 4096   # Default conservativo 4GB

# Calcola il preset di qualità ottimale basato su hardware e risoluzione
# Considera VRAM disponibile, risoluzione schermo e tipo di dispositivo
# @return GraphicsQuality: Preset di qualità raccomandato
func _calculate_quality_preset() -> GraphicsQuality:
	var pixel_count = screen_size.x * screen_size.y
	
	if is_mobile:
		# Su mobile, qualità più conservativa per preservare batteria
		if pixel_count > 2073600:  # > 1440p
			return GraphicsQuality.MEDIUM
		else:
			return GraphicsQuality.HIGH
	else:
		# Su desktop, basato su VRAM disponibile e risoluzione
		if vram_mb >= 8192 and pixel_count <= 2073600:  # 8GB+ VRAM, <= 1440p
			return GraphicsQuality.ULTRA
		elif vram_mb >= 6144 and pixel_count <= 2073600:  # 6GB+ VRAM, <= 1440p
			return GraphicsQuality.HIGH
		elif vram_mb >= 4096:  # 4GB+ VRAM
			return GraphicsQuality.MEDIUM
		else:
			return GraphicsQuality.LOW

# Calcola la risoluzione raccomandata per le prestazioni ottimali
# Considera il preset di qualità e le limitazioni hardware
# @return Vector2i: Risoluzione raccomandata
func _calculate_recommended_resolution() -> Vector2i:
	if is_mobile:
		# Su mobile, usa sempre la risoluzione nativa per UI ottimale
		return screen_size
	else:
		# Su desktop, potrebbe essere ridotta per migliorare le prestazioni
		match recommended_quality:
			GraphicsQuality.LOW:
				return Vector2i(min(screen_size.x, 1280), min(screen_size.y, 720))
			GraphicsQuality.MEDIUM:
				return Vector2i(min(screen_size.x, 1600), min(screen_size.y, 900))
			_:
				return screen_size

# Calcola il livello MSAA appropriato basato sul preset di qualità
# Bilancia qualità visiva e prestazioni
# @return int: Moltiplicatore MSAA (1=disabilitato, 2,4,8=livelli)
func _calculate_recommended_msaa() -> int:
	match recommended_quality:
		GraphicsQuality.LOW:
			return 1  # No MSAA per preservare prestazioni
		GraphicsQuality.MEDIUM:
			return 2  # 2x MSAA per bilanciare qualità/prestazioni
		GraphicsQuality.HIGH:
			return 4  # 4x MSAA per buona qualità
		GraphicsQuality.ULTRA:
			return 8  # 8x MSAA per qualità massima
		_:
			return 2  # Default sicuro

# Determina se FSR (FidelityFX Super Resolution) dovrebbe essere utilizzato
# FSR è utile per risoluzioni alte con GPU di fascia media/bassa
# @return bool: true se FSR è raccomandato
func _should_use_fsr() -> bool:
	# FSR raccomandato per risoluzioni alte con GPU meno potenti
	var pixel_count = screen_size.x * screen_size.y
	return pixel_count > 2073600 and vram_mb < 8192  # > 1440p con < 8GB VRAM

# Verifica il supporto HDR basato su piattaforma e hardware
# HDR è supportato principalmente su desktop moderni con display appropriati
# @return bool: true se HDR è supportato
func _check_hdr_support() -> bool:
	# HDR supportato principalmente su desktop moderni con high-DPI
	return is_desktop and screen_dpi > 96

#===== DEBUG =====

# Stampa nella console tutte le informazioni di sistema rilevate
# Utile per debug e diagnostica durante lo sviluppo
func print_system_info():
	print("=== PLATFORM DETECTOR INFO ===")
	var info = get_system_info()
	for key in info.keys():
		print(key, ": ", info[key])
	print("===============================")

# Stampa nella console tutte le informazioni grafiche rilevate
# Include dettagli su display, GPU, capacità e impostazioni raccomandate
func print_graphics_info():
	print("=== GRAPHICS DETECTOR INFO ===")
	print("Screen Size: ", screen_size)
	print("Screen DPI: ", screen_dpi)
	print("Screen Refresh Rate: ", screen_refresh_rate)
	print("Graphics API: ", GraphicsAPI.keys()[graphics_api])
	print("GPU: ", gpu_name)
	print("GPU Vendor: ", gpu_vendor)
	print("Max Texture Size: ", max_texture_size)
	print("Estimated VRAM: ", vram_mb, "MB")
	print("Recommended Quality: ", GraphicsQuality.keys()[recommended_quality])
	print("Recommended Resolution: ", recommended_resolution)
	print("Supports Fullscreen: ", supports_fullscreen)
	print("Supports VSync: ", supports_vsync)
	print("Supports HDR: ", supports_hdr)
	print("==============================")
