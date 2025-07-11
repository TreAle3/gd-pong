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

var script_fisica = preload("res://script/fisica.gd")
var script_grafica = preload("res://script/grafica.gd")
var script_ui = preload("res://script/ui.gd")

# Oggetti globali
var o_grafica: Node2D;
var o_fisica: Node;
var o_ui:Control;

# Funzione di inizializzazionr
func _ready():
	setup_fisica()
	setup_grafica()
	setup_ui() # Chiamare per ultimo, in modo che compaia al top
	o_fisica.Imposta_Referenze(self) # Imposta le referenze per o_grafica
	o_fisica.Inizializza() # Inizializza tutti gli oggetti fisici
	o_grafica.Imposta_Referenze(self, o_fisica) # Imposta le referenze per o_grafica
	o_grafica.Inizializza() # Inizializza tutti gli oggetti grafici
	o_ui.Imposta_Referenze(self, o_fisica) # Imposta le referenze per o_ui
	o_ui.Inizializza() # Inizializza tutti gli oggetti della ui

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

func Stato_Gioco_Inizia():
	if Stato_Attuale == StatiGioco.MENU or Stato_Attuale == StatiGioco.GAME_OVER:
		o_fisica.Inizializza()
		o_ui.Punteggi_Visibili(false)
		Stato_Gioco_Set(StatiGioco.PLAYING)

func Stato_Gioco_Pausa_Switch():
	if Stato_Attuale == StatiGioco.PLAYING:
		Stato_Gioco_Set(StatiGioco.PAUSED)
	elif Stato_Attuale == StatiGioco.PAUSED:
		Stato_Gioco_Set(StatiGioco.PLAYING)
