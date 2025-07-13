# pad.gd - Classe per i pad del gioco
class_name Pad_logica
extends RefCounted

# Tipi di pad (dove sono posizionati, sinistra o destra)
enum TipiPad {
	SIN,
	DES,
	SIN2, # Per il secondo giocatore sinistro
	DES2, # Per il secondo giocatore destro
}


# Costanti
const DIMW_BASE = 5
const DIMH_BASE = 20
const MARGINE_BASE = 10
const VELOCITA_BASE = 200

# Proprietà del pad
var posizione: Vector2
var velocita: float
var vettore: Vector2 = Vector2.ZERO # Vettore di movimento
var dimensione: Vector2i
var margine: int # Margine dal lato dello schermo
var y_min: float # Minima Y raggiungibile
var y_max: float # Massima Y raggiungibile
var tipo: TipiPad # Sinistro o destro
var punti: int # Punteggio
var punti_vittoria: int = 15; # Punti da raggiungere per conseguire la vittoria

# Segnali
# Punteggio cambiato

# Inizializzazione
func _init(tipopad: TipiPad = TipiPad.SIN):
	tipo = tipopad
	dimensione = Vector2i(round(DIMW_BASE * SY.w_scala.x),round(DIMH_BASE * SY.w_scala.y))
	margine = round(MARGINE_BASE * SY.w_scala.x)
	velocita = VELOCITA_BASE * SY.w_scala.y
	y_min = 0 + (dimensione.y >> 1)
	y_max = SY.w_dim.y - (dimensione.y >> 1)
	resetta_posizione()

# Resetta la posizione del pad
func resetta_posizione():
	if tipo == TipiPad.SIN:
		posizione = Vector2(margine + (dimensione.x >> 1), SY.w_cen.y) # / 2)
	elif tipo == TipiPad.DES:
		posizione = Vector2(SY.w_dim.x - margine - (dimensione.x >> 1), SY.w_cen.y) # * 1.5)
	vettore = Vector2.ZERO

# Muovi il pad verso l'alto
func muovi_su(delta: float):
	vettore.y = velocita * delta
	posizione.y -= vettore.y
	posizione.y = FH.clamp_f(posizione.y, y_min, y_max)


# Muovi il pad verso il basso
func muovi_giu(delta: float):
	vettore.y = velocita * delta
	posizione.y += vettore.y
	posizione.y = FH.clamp_f(posizione.y, y_min, y_max)


# Ottiene il rettangolo del pad per le collisioni
func get_rect() -> Rect2:
	return Rect2(posizione - Vector2(dimensione.x >> 1, dimensione.y >> 1), Vector2(dimensione.x, dimensione.y))

# Verfica la collisione con un altro Rect2 passato
func verifica_collisione(corpo: Rect2) -> bool:
	var RecPad: Rect2 = Rect2(posizione - Vector2(dimensione.x >> 1, dimensione.y >> 1), Vector2(dimensione.x, dimensione.y))
	if (RecPad.intersects(corpo)): return true
	return false

# ===== PUNTEGGI =====

# Resetta il punteggio
func punti_resetta() -> void:
	punti = 0

# Controlla se il punteggio ha raggiunto la vittoria
func punti_controlla_vittoria() -> bool:
	return punti >= punti_vittoria
