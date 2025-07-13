# gioco.gd - iniziato 09/07/2025 - ultima modifica 09/07/2025 - versione 0.1

# Script per la scena del gioco
# Richiama grafica.gd per la parte grafica, ui.gd per la parte dell'interfaccia

extends Node

# Stati di gioco
enum StatiGioco {
	MENU,
	PLAYING,
	SCORED,
	PAUSED,
	GAME_OVER
}

var Stato_Attuale: StatiGioco = StatiGioco.MENU

# Preload degli script
var script_palla_l = preload("res://script/oggetti/palla_logica.gd")
var script_palla_g = preload("res://script/grafica/palla_grafica.gd")
var script_pad_l = preload("res://script/oggetti/pad_logica.gd")
var script_pad_g = preload("res://script/grafica/pad_grafica.gd")
var script_fisica = preload("res://script/fisica.gd")
var script_grafica = preload("res://script/grafica.gd")
var script_ui = preload("res://script/ui.gd")

# Oggetti globali
var palla: Palla
var padS: Pad
var padD: Pad

var o_grafica: Node2D;
var o_fisica: Node;
var o_ui:Control;

# Segnali
signal s_inizio_partita() # Azzerare il punteggio, posizionare al centro i pad, lanciare la palla
signal s_inizio_scambio() # lanciare la palla
signal s_gol_segnato(pad: Pad_logica.TipiPad) # Aggiorna i punteggi, nasconde la palla, lancia il timer per l'inizio scambio
signal s_fine_partita() # Visualizza i punteggi, imposta il game over

# Timer
var t_inizio_nuovo_scambio: Timer

# Funzione di inizializzazionr
func _ready():
	setup_oggetti_di_gioco()
	setup_fisica()
	setup_grafica()
	setup_ui() # Chiamare per ultimo, in modo che compaia al top
	o_fisica.Imposta_Referenze(self) # Imposta le referenze per o_grafica
	o_fisica.Inizializza() # Inizializza tutti gli oggetti fisici
	o_grafica.Imposta_Referenze(self, o_fisica) # Imposta le referenze per o_grafica
	o_grafica.Inizializza() # Inizializza tutti gli oggetti grafici
	o_ui.Imposta_Referenze(self, o_fisica) # Imposta le referenze per o_ui
	o_ui.Inizializza() # Inizializza tutti gli oggetti della ui
	setup_timer_inizio_nuovo_scambio()
	s_gol_segnato.connect(_on_gol_segnato)

# Imposta gli oggetti di gioco
func setup_oggetti_di_gioco() -> void:
	palla = Palla.new()
	padS = Pad.new()
	padD = Pad.new(Pad_logica.TipiPad.DES)

# Imposta la fisica
func setup_fisica() -> void:
	o_fisica = Node.new()
	o_fisica.name = "Grafica"
	o_fisica.set_script(script_fisica)
	add_child(o_fisica)

# Imposta la grafica
func setup_grafica() -> void:
	o_grafica = Node2D.new()
	o_grafica.name = "Grafica"
	o_grafica.set_script(script_grafica)
	add_child(o_grafica)

# Imposta la UI
func setup_ui() -> void:
	o_ui = Control.new()
	o_ui.name = "UI"
	o_ui.set_script(script_ui)
	add_child(o_ui)


# Aggiungi queste nuove funzioni:
func Stato_Gioco_Set(new_state: StatiGioco):
	Stato_Attuale = new_state
	match Stato_Attuale:
		StatiGioco.MENU:
			print("Stato: MENU")
		StatiGioco.PLAYING:
			print("Stato: PLAYING")
		StatiGioco.SCORED:
			print("Stato: SCORED")
		StatiGioco.PAUSED:
			print("Stato: PAUSED")
		StatiGioco.GAME_OVER:
			print("Stato: GAME_OVER")

func Stato_Gioco_Get() -> StatiGioco:
	return Stato_Attuale


func Tasto_Inizia():
	if Stato_Attuale == StatiGioco.MENU or Stato_Attuale == StatiGioco.GAME_OVER:
		s_inizio_partita.emit()
		Stato_Gioco_Set(StatiGioco.PLAYING)

func Stato_Gioco_Pausa_Switch():
	if Stato_Attuale == StatiGioco.PLAYING:
		Stato_Gioco_Set(StatiGioco.PAUSED)
	elif Stato_Attuale == StatiGioco.PAUSED:
		Stato_Gioco_Set(StatiGioco.PLAYING)


# Aggiungi questa funzione nella sezione setup
func setup_timer_inizio_nuovo_scambio():
	t_inizio_nuovo_scambio = Timer.new()
	t_inizio_nuovo_scambio.wait_time = 1.0
	t_inizio_nuovo_scambio.one_shot = true
	t_inizio_nuovo_scambio.timeout.connect(_on_timer_inizio_nuovo_scambio_timeout)
	add_child(t_inizio_nuovo_scambio)

# Funzione chiamata quando il timer scade
func _on_timer_inizio_nuovo_scambio_timeout():
	print("Timer scaduto - Inizia nuovo punto")
	s_inizio_scambio.emit()
	Stato_Gioco_Set(StatiGioco.PLAYING)


func _on_gol_segnato(_marcatore):
	t_inizio_nuovo_scambio.start() # Avvia il timer per il nuovo scambio
