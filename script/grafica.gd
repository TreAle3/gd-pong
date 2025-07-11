extends Node2D

# Script per il nodo Background
# Gestisce il disegno dello sfondo e futuri sprite

# Riferimenti agli oggetti necessari definiti in gioco.gd
var ro_g: Node # Riferimento all'oggetto o_gioco
var ro_f: Node # Riferimento all'oggetto o_fisica

# Oggetti per il gioco
var pad_sinistro: Sprite2D
var pad_destro: Sprite2D

func _ready():
	# Imposta il colore di sfondo a nero
	#RenderingServer.set_default_clear_color(Color.BLACK)
	RenderingServer.set_default_clear_color(Color("282d34ff")) # Colore 40,45,52,255

# Imposta le referenze agli altri oggetti degli script esterni che servono in questo script
# Da richiamare in gioco.gd dopo che sono stati inizializzati gli oggetti da inoltrare
func Imposta_Referenze(ogg_gioco: Node, ogg_fisica: Node):
	ro_g = ogg_gioco
	ro_f = ogg_fisica

func Inizializza():
	Crea_Oggetti_Di_Gioco()

func _process(_delta):
	#update_ball(delta)
	#check_collisions()
	#Pad_Aggiorna()
	if ro_g.Stato_Attuale == ro_g.StatiGioco.PLAYING:
		ro_g.palla.aggiorna_visual() #Palla_Aggiorna()
		ro_g.padS.aggiorna_visual()
		ro_g.padD.aggiorna_visual()

#func _draw():
	# Disegna uno sfondo nero che copre tutto lo schermo
	#var screen_size = get_viewport().get_visible_rect().size
	#draw_rect(Rect2(Vector2.ZERO, screen_size), Color.BLACK)
	# Qui in futuro si possono aggiungere altri elementi grafici
	# come linee del campo, decorazioni, etc.


# Aggiunge gli oggetti di gioco (barre, pallina)
func Crea_Oggetti_Di_Gioco():
	#print ("Crea oggetti grafici - pos x palla = " + str(ro_f.palla_pos.x))
	#print ("screen_size = " + str(SY.w_dim.x) + "x" + str(SY.w_dim.y))
	#print ("screen_center = " + str(SY.w_cen.x) + "x" + str(SY.w_cen.y))
	add_child(ro_g.palla)
	add_child(ro_g.padS)
	add_child(ro_g.padD)
