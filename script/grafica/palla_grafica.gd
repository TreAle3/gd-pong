# palla_grafica.gd - Classe per la grafica della palla del gioco
class_name Palla
extends Sprite2D

var data: Palla_logica
var imgtexture: ImageTexture
var colore: Color = Color.WHITE

func _ready():
	data = Palla_logica.new()
	# Configura texture, shader, ecc.
	imgtexture = texture_crea(data.dimensione.x, colore) # Crea la texture per la pallina (circolare)
	texture = imgtexture
	position = data.posizione #schermo_base_centro
	#add_child(palla)

func aggiorna_visual():
	position = data.posizione
	#position = palla_data.posizione
	# Altri aggiornamenti visivi


# Funzione per creare una texture circolare
func texture_crea(radius: int, color: Color) -> ImageTexture:
	var size = radius * 2
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	# Disegna un cerchio pixel per pixel
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x - radius, y - radius).length()
			if distance <= radius:
				img.set_pixel(x, y, color)
	var txtr = ImageTexture.new()
	txtr.set_image(img)
	return txtr


func set_colore(nuovo_colore: Color):
	modulate = nuovo_colore

# Imposta la visibilità della pallina
func set_visibile(visibile: bool = true):
	visible = visibile
