# fisica.gd - Script per la fisica del gioco e le collisioni

extends Node

# Riferimenti agli oggetti necessari definiti in gioco.gd
var ro_g: Node # Riferimento all'oggetto o_gioco

# Variabili e costanti per la palla
const PALLA_DIM_BASE = 2 # Dimensione base della palla
const PALLA_VELOCITA_BASE = 150.0
var palla_pos: Vector2 # Posizione della palla
var palla_vel: float = 0 # Velocità della palla
var palla_vet: Vector2 = Vector2.ZERO # Vettore della palla
var palla_dim_w: int = round(PALLA_DIM_BASE * SY.w_scala.x) # Dimensione reale
var palla_dim_h: int = round(PALLA_DIM_BASE * SY.w_scala.y) # Dimensione reale

# Variabili e costanti per i pad
const PAD_DIMW_BASE = 5
const PAD_DIMH_BASE = 20
const PAD_MARGINE_BASE = 10 # Distanza tra la barra e il lato dello schermo
const PAD_VELOCITA_BASE = 200 # Velocità a cui muoviamo il pad, va moltiplicato per il delta del _process
var pad_dim_w: int = round(PAD_DIMW_BASE * SY.w_scala.x) # Larghezza dei pad
var pad_dim_h: int = round(PAD_DIMH_BASE * SY.w_scala.y) # Altezza dei pad
var pad_margine: int = round(PAD_MARGINE_BASE * SY.w_scala.x) # Distanziamento sallo schermo
var pad_vel: float = 0 # Velocità della palla
var pad_Ymin: float = 0 # Minimo valore per il movimento del pad
var pad_Ymax: float = 0 # Minimo valore per il movimento del pad
var padS_pos: Vector2 # Posizione del pad sinistro
var padS_vet: Vector2 = Vector2.ZERO # Vettore del pad sinistro
var padD_pos: Vector2 # Posizione del pad destro
var padD_vet: Vector2 = Vector2.ZERO # Vettore del pad destro

# Variabili per il punteggio
var Sin_punti: int = 0
var Des_punti: int = 0
var Punti_Aggiornati: bool = false

func _ready():
	# Calcola le velocità scalate
	palla_vel = PALLA_VELOCITA_BASE * SY.w_scala.x
	pad_vel = PAD_VELOCITA_BASE * SY.w_scala.y
	pad_Ymin = 0 + (pad_dim_h >> 1)
	pad_Ymax = SY.w_dim.y - (pad_dim_h >> 1)

# Imposta le referenze agli altri oggetti degli script esterni che servono in questo script
# Da richiamare in gioco.gd dopo che sono stati inizializzati gli oggetti da inoltrare
func Imposta_Referenze(ogg_gioco: Node):
	ro_g = ogg_gioco

func Inizializza():
	Punti_Resetta() # Resetta i punteggi
	Palla_Resetta_Posizione() # Inizializza la palla al centro
	Pad_Resetta_Posizione() # Resetta la posizione dei pad
	Palla_set_Vettore() # Imposta un vettore randomico per la palla

func _process(delta):
	if ro_g and ro_g.Stato_Gioco_Get() == ro_g.StatiGioco.PLAYING:
		Palla_aggiorna_posizione(delta)
		check_collisions()

func PadS_Muovi_Su(delta):
	padS_vet.y = pad_vel * delta
	padS_pos.y -= padS_vet.y
	padS_pos.y = FH.clamp_f(padS_pos.y,pad_Ymin,pad_Ymax)

func PadS_Muovi_Giu(delta):
	padS_vet.y = pad_vel * delta
	padS_pos.y += padS_vet.y
	padS_pos.y = FH.clamp_f(padS_pos.y,pad_Ymin,pad_Ymax)
	
func PadD_Muovi_Su(delta):
	padD_vet.y = pad_vel * delta
	padD_pos.y -= padD_vet.y
	padD_pos.y = FH.clamp_f(padD_pos.y,pad_Ymin,pad_Ymax)

func PadD_Muovi_Giu(delta):
	padD_vet.y = pad_vel * delta
	padD_pos.y += padD_vet.y
	padD_pos.y = FH.clamp_f(padD_pos.y,pad_Ymin,pad_Ymax)

func Palla_aggiorna_posizione(delta):
	# Aggiorna la posizione della palla
	palla_pos += palla_vet * (delta * palla_vel)
	# Rimbalzo sui bordi superiore e inferiore
	if palla_pos.y <= palla_dim_h >> 1:
		palla_vet.y = -palla_vet.y
		palla_pos.y = palla_dim_h >> 1
	elif palla_pos.y >= SY.w_dim.y - palla_dim_h >> 1:
		palla_vet.y = -palla_vet.y
		palla_pos.y = SY.w_dim.y - palla_dim_h >> 1


func check_collisions():
	pass
	# Collisione con paddle sinistro
	#if ball_rect.intersects(paddle_left_rect) and ball_velocity.x < 0:
		#ball_velocity.x = -ball_velocity.x
		#ball_position.x = paddle_left_rect.position.x + paddle_left_rect.size.x + ball_rect.size.x / 2
	# Collisione con paddle destro
	#if ball_rect.intersects(paddle_right_rect) and ball_velocity.x > 0:
		#ball_velocity.x = -ball_velocity.x
		#ball_position.x = paddle_right_rect.position.x - ball_rect.size.x / 2
	# Controllo goal
	#if ball_position.x < 0:
		# Goal per player 2
		#ui_ref.add_point_player2()
		#reset_ball()
	#elif ball_position.x > SY.w_dim.x:
		# Goal per player 1
		#ui_ref.add_point_player1()
		#reset_ball()

func Palla_Resetta_Posizione():
	palla_pos = SY.w_cen
	Palla_set_Vettore() # Direzione casuale


# Assegna una direzione randomica alla palla
func Palla_set_Vettore(ForzaDirX:float = 0):
	var DirX: float
	if ForzaDirX > 0:	DirX = 1.0
	elif ForzaDirX < 0:	DirX = -1.0
	else:				DirX = -1.0 if FH.random_bool() else 1.0
	palla_vet = Vector2(DirX, FH.random_float(-0.6,0.6)).normalized()


func Pad_Resetta_Posizione():
	padS_pos = Vector2(pad_margine + (pad_dim_w >> 1), SY.w_cen.y / 2)
	padD_pos = Vector2(SY.w_dim.x - pad_margine - (pad_dim_w >> 1), SY.w_cen.y * 1.5)
	padS_vet = Vector2.ZERO
	padD_vet = Vector2.ZERO

# ===== PUNTEGGI =====

# Resetta il punteggio
func Punti_Resetta() -> void:
	Sin_punti = 0
	Des_punti = 0
	Punti_Aggiornati = true
