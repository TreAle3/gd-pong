# ui.gd - Script per gd-pong
# UI: Gestisce tutti gli input e l'interfaccia

# Da caricare ed inizializzare in gioco.gd
# Da gioco.gd gopo che è stato inizializzato, richiamare la funzione Imposta_Referenze e passare gli oggetti necessari
# Registrare le azioni di input in Impostazioni → Mappa di Input

extends Control

# Riferimenti agli oggetti necessari definiti in gioco.gd
var ro_g: Node # Riferimento all'oggetto o_gioco
var ro_f: Node # Riferimento all'oggetto o_fisica

# Carica il font una volta sola
var custom_font = preload("res://data/font/PressStart2P.ttf")

# Label
var lbl_puntipl_Sin: Label # Punti player (in alto a sinistra)
var lbl_puntipl_Des: Label # Punti player (in alto a destra)
var lbl_punti_Sin: Label # Punti player (al centro a sinistra)
var lbl_punti_Des: Label # Punti player (al centro a destra)

# Nomi azioni per gli Input di gioco → Da registrare in Impostazioni → Mappa di Input
const k_inizia:String = "k_inizia"
const k_pausa:String = "k_pausa"
const k_padS_su:String = "k_padS_su"
const k_padS_giu:String = "k_padS_giu"
const k_padD_su:String = "k_padD_su"
const k_padD_giu:String = "k_padD_giu"

# Funzione di inizializzazionr
func _ready():
	name = "UI"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # Dimensiona a tutto schermo
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = true  # Visibile di default
	setup_title_label()


func _process(delta):
	Gestisci_Input(delta)
	#Punteggi_Aggiorna()

# Imposta le referenze agli altri oggetti degli script esterni che servono in questo script
# Da richiamare in gioco.gd dopo che sono stati inizializzati gli oggetti da inoltrare
func Imposta_Referenze(ogg_gioco: Node, ogg_fisica: Node):
	ro_g = ogg_gioco
	ro_f = ogg_fisica

func Inizializza():
	Punteggi_Setup()
	ro_g.s_inizio_partita.connect(on_inizio_partita)
	ro_g.s_inizio_scambio.connect(on_inizio_scambio)
	ro_g.s_gol_segnato.connect(on_gol_segnato)

func on_inizio_partita():
	Punteggi_Visibili(false)

func on_inizio_scambio():
	Punteggi_Visibili(false)

func on_gol_segnato(marcatore):
	Punteggi_Aggiorna()
	Punteggi_Visibili(true)

# Crea e configura la label del titolo
func setup_title_label():
	# Crea una label per il titolo
	var title_label = Label.new()
	title_label.name = "Test_Benvenuto"
	title_label.text = "gd-pong"
	title_label.add_theme_font_override("font", custom_font) # Assegna il font personalizzato
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	title_label.add_theme_font_size_override("font_size", 32) # Imposta un font più grande per il titolo
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE # Rende il display trasparente al mouse
	add_child(title_label) # Aggiungi la label alla scena
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP) # Posiziona in alto a destra
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Centra il testo all'interno della label
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# Crea e configura la label del titolo
func Punteggi_Setup() -> void:
	lbl_puntipl_Sin = Label_crea("p1-puntipl","Player1: " + str(ro_g.padS.data.punti),16,Color.WHITE)
	lbl_puntipl_Sin.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,0,10) # Posiziona in alto a destra, con margine 10
	lbl_puntipl_Sin.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Centra il testo all'interno della label
	lbl_puntipl_Sin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_puntipl_Des = Label_crea("p2-puntipl","Player2: " + str(ro_g.padD.data.punti),16,Color.WHITE)
	lbl_puntipl_Des.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT,0,10) # Posiziona in alto a destra, con margine 10
	lbl_puntipl_Des.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT # Centra il testo all'interno della label
	lbl_puntipl_Des.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_punti_Sin = Label_crea("p1-punti",str(ro_g.padS.data.punti),64,Color.WHITE)
	lbl_punti_Sin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Centra il testo all'interno della label
	lbl_punti_Sin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Label_set_anchor(lbl_punti_Sin,0.35,0.5,0.0,0.75)
	lbl_punti_Des = Label_crea("p2-punti",str(ro_g.padD.data.punti),64,Color.WHITE)
	lbl_punti_Des.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Centra il testo all'interno della label
	lbl_punti_Des.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Label_set_anchor(lbl_punti_Des,0.5,0.65,0.0,0.75)

# Aggiorna le label dei punteggi
func Punteggi_Aggiorna() -> void:
	lbl_puntipl_Sin.text = "Player1: " + str(ro_g.padS.data.punti)
	lbl_punti_Sin.text = str(ro_g.padS.data.punti)
	lbl_puntipl_Des.text = "Player2: " + str(ro_g.padD.data.punti)
	lbl_punti_Des.text = str(ro_g.padD.data.punti)


# Aggiorna la visibilità dei punteggi
func Punteggi_Visibili(visibili: bool = true) -> void:
	lbl_punti_Sin.visible = visibili
	lbl_punti_Des.visible = visibili


# Crea una label e assegna i parametri passati
func Label_crea(nome: String, testo: String, fsize: int = 16, colore: Color = Color.WHITE) -> Label:
	var Lbl = Label.new()
	Lbl.name = nome
	Lbl.text = testo
	Lbl.add_theme_font_override("font", custom_font) # Assegna il font personalizzato
	Lbl.add_theme_color_override("font_color", colore)
	Lbl.add_theme_font_size_override("font_size", fsize) # Imposta un font più grande per il titolo
	Lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE # Rende il display trasparente al mouse
	add_child(Lbl) # Aggiungi la label alla scena
	return Lbl

# Imposta i punti di ancoraggio di una Label
func Label_set_anchor(lbl: Label, left: float = 0.0, right: float = 1.0, top: float = 0.0, bottom: float = 1.0) -> void:
	lbl.anchor_left = left
	lbl.anchor_right = right
	lbl.anchor_top = top
	lbl.anchor_bottom = bottom

# Gestisce gli input per il gioco
func Gestisci_Input(delta):
	# Controlla gli input solo se il gioco è in stato PLAYING
	if ro_g and ro_g.Stato_Gioco_Get() != ro_g.StatiGioco.PLAYING:
		return
	# Controlli per il paddle sinistro
	if Input.is_action_pressed("k_padS_su"):
		ro_g.padS.data.muovi_su(delta)
	elif Input.is_action_pressed("k_padS_giu"):
		ro_g.padS.data.muovi_giu(delta)
	if Input.is_action_pressed("k_padD_su"):
		ro_g.padD.data.muovi_su(delta)
	elif Input.is_action_pressed("k_padD_giu"):
		ro_g.padD.data.muovi_giu(delta)


# Gestisce gli input
func _input(event):
	var SG = ro_g.Stato_Gioco_Get()
	# Gestisce l'input per chiudere il gioco (ESC su desktop)
	if event.is_action_pressed("ui_cancel"):
		if OS.get_name() in ["Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD"]:
			get_tree().quit()
	# Gestisce la pausa con il tasto P (opzionale - richiede di mappare l'azione "pause")
	if event.is_action_pressed("k_pausa") and ro_g:
		ro_g.Stato_Gioco_Pausa_Switch()
	# Gestisce l'inizio partita
	if event.is_action_pressed("k_inizia") and ro_g:
		ro_g.Tasto_Inizia()
