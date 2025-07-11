# pad_grafica.gd - Classe per la grafica dei pad del gioco
class_name Pad
extends Sprite2D

var data: Pad_logica
var imgtexture: ImageTexture
var colore: Color = Color.WHITE

# Inizializzazione
func _init(tipopad: Pad_logica.TipiPad = Pad_logica.TipiPad.SIN):
	data = Pad_logica.new(tipopad)

func _ready():
	# Configura texture, shader, ecc.
	imgtexture = texture_crea(data.dimensione, colore) # Crea la texture per la pallina (circolare)
	texture = imgtexture
	position = data.posizione #schermo_base_centro


# Funzione per creare una texture rettangolare
func texture_crea(dimensione: Vector2, color: Color) -> ImageTexture:
	var img = Image.create(int(dimensione.x), int(dimensione.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	#image.set_pixel(5, 5, Color.AQUA)
	var txtr = ImageTexture.new()
	txtr.set_image(img)
	return txtr


func aggiorna_visual():
	position = data.posizione

func set_colore(nuovo_colore: Color):
	modulate = nuovo_colore
