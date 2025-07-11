# palla.gd - Classe per la logica della palla del gioco
class_name Palla_logica
extends RefCounted

# Costanti
const DIM_BASE = 2
const VELOCITA_BASE = 150.0

# Proprietà della palla
var posizione: Vector2
var velocita: float
var velocita_minima: float
var vettore: Vector2 = Vector2.ZERO
var dimensione: Vector2i

# Inizializzazione
func _init():
	dimensione = Vector2i(round(DIM_BASE * SY.w_scala.x),round(DIM_BASE * SY.w_scala.y))
	velocita_minima = VELOCITA_BASE * SY.w_scala.x
	velocita = velocita_minima
	resetta_posizione()

# Resetta la posizione al centro dello schermo
func resetta_posizione():
	posizione = SY.w_cen
	velocita = velocita_minima
	set_vettore_casuale()


# Assegna una direzione randomica alla palla
func set_vettore_casuale(forza_dir_x: float = 0):
	var dir_x: float
	if forza_dir_x > 0:		dir_x = 1.0
	elif forza_dir_x < 0:	dir_x = -1.0
	else: 					dir_x = -1.0 if FH.random_bool() else 1.0
	vettore = Vector2(dir_x, FH.random_float(-0.6, 0.6)).normalized()

# Inverte la componente x del vettore - usato per le collisioni con i pad
func inverti_vettore_x():
	vettore.x = - vettore.x

# Cambia l'angolazione della pallina come richiesto
func modifica_vettore_y(offset: float):
	var coef_offset = 0.8
	offset = FH.clamp_f(offset, -1.0, 1.0) # Verifica che il valore sia nel range corretto
	vettore.y = offset * coef_offset # Moltiplica per il coefficiente in modo da non avere mai una componente y troppo verticale
	vettore = vettore.normalized() # Rinormalizza il vettore

# Aumenta la velocità del fattore passato
func aumenta_velocita(fattore:float = 1.03):
	velocita = velocita * fattore
	print("velocita = " + str(velocita))

# Aggiorna la posizione della palla e verifica il rimbalzo sui bordi superiore e inferiore
func aggiorna_posizione(delta: float):
	posizione += vettore * (delta * velocita)
	#print("aggiorna_posizione palla = " + str(posizione.x) + "x" + str(posizione.y))
	# Rimbalzo sui bordi superiore e inferiore
	if posizione.y <= dimensione.y >> 1:
		vettore.y = -vettore.y
		posizione.y = dimensione.y >> 1
	elif posizione.y >= SY.w_dim.y - (dimensione.y >> 1):
		vettore.y = -vettore.y
		posizione.y = SY.w_dim.y - (dimensione.y >> 1)

# Ottiene il rettangolo della palla per le collisioni
func get_rect() -> Rect2:
	return Rect2(posizione - Vector2(dimensione.x >> 1, dimensione.y >> 1), Vector2(dimensione.x, dimensione.y))
