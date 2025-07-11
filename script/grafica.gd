extends Node2D

# Script per il nodo Background
# Gestisce il disegno dello sfondo e futuri sprite

# Riferimenti agli oggetti necessari definiti in gioco.gd
var ro_g: Node # Riferimento all'oggetto o_gioco
var ro_f: Node # Riferimento all'oggetto o_fisica

# Oggetti per il gioco
var pad_sinistro: Sprite2D
var pad_destro: Sprite2D
var palla: Sprite2D

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
	Pad_Aggiorna()
	Palla_Aggiorna()

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
	var paddle_texture = Crea_texture_rettangolare(ro_f.pad_dim_w, ro_f.pad_dim_h, Color.WHITE) # Crea la texture per le barre
	var ball_texture = Crea_texture_circolare(ro_f.palla_dim_w, Color.WHITE) # Crea la texture per la pallina (circolare)
	pad_sinistro = Sprite2D.new() # Crea la barra sinistra
	pad_sinistro.texture = paddle_texture
	pad_sinistro.position = ro_f.padS_pos
	add_child(pad_sinistro)
	pad_destro = Sprite2D.new() # Crea la barra destra
	pad_destro.texture = paddle_texture
	pad_destro.position = ro_f.padD_pos
	add_child(pad_destro)
	palla = Sprite2D.new() # Crea la pallina
	palla.texture = ball_texture
	palla.position = ro_f.palla_pos #schermo_base_centro
	add_child(palla)

# Aggiorna la posizione dei pad
func Pad_Aggiorna():
	if ro_f.padS_vet.y != 0:
		pad_sinistro.position = ro_f.padS_pos
		ro_f.padS_vet.y = 0
	if ro_f.padD_vet.y != 0:
		pad_destro.position = ro_f.padD_pos
		ro_f.padD_vet.y = 0

# Aggiorna la posizione dei pad
func Palla_Aggiorna():
	palla.position = ro_f.palla_pos

# Funzione per creare una texture rettangolare
func Crea_texture_rettangolare(width: int, height: int, color: Color) -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	image.set_pixel(5, 5, Color.AQUA)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture


# Funzione per creare una texture circolare
func Crea_texture_circolare(radius: int, color: Color) -> ImageTexture:
	var size = radius * 2
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Disegna un cerchio pixel per pixel
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x - radius, y - radius).length()
			if distance <= radius:
				image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture


# Funzioni aggiuntive per Sprite2D
func set_paddle_color(paddle: Sprite2D, color: Color):
	paddle.modulate = color

func set_ball_color(color: Color):
	palla.modulate = color
