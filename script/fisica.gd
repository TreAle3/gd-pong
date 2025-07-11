# fisica.gd - Script per la fisica del gioco e le collisioni

extends Node

# Riferimenti agli oggetti necessari definiti in gioco.gd
var ro_g: Node # Riferimento all'oggetto o_gioco

func _ready():
	
	pass

# Imposta le referenze agli altri oggetti degli script esterni che servono in questo script
# Da richiamare in gioco.gd dopo che sono stati inizializzati gli oggetti da inoltrare
func Imposta_Referenze(ogg_gioco: Node):
	ro_g = ogg_gioco

func Inizializza():
	pass
	#Punti_Resetta() # Resetta i punteggi
	#Palla_Resetta_Posizione() # Inizializza la palla al centro
	#Pad_Resetta_Posizione() # Resetta la posizione dei pad
	#Palla_set_Vettore() # Imposta un vettore randomico per la palla

func _process(delta):
	if ro_g and ro_g.Stato_Gioco_Get() == ro_g.StatiGioco.PLAYING:
		ro_g.palla.data.aggiorna_posizione(delta)
		gestione_collisioni()
		gestione_gol()

func gestione_collisioni():
	var Collisione = false
	var CorpoPalla = ro_g.palla.data.get_rect()
	var CentroYPad:float; # Usati per cambiare la componente y del vettore della pallina rimbalzata
	var DimYPad:int;
	if ro_g.padS.data.verifica_collisione(CorpoPalla): # Collisione con paddle sinistro
		Collisione = true
		ro_g.palla.data.posizione.x = ro_g.padS.data.posizione.x + (ro_g.padS.data.dimensione.x >> 1) + (ro_g.palla.data.dimensione.x >> 1) + 1
		CentroYPad = ro_g.padS.data.posizione.y
		DimYPad = ro_g.padS.data.dimensione.y
	if ro_g.padD.data.verifica_collisione(CorpoPalla): # Collisione con paddle destro
		Collisione = true
		ro_g.palla.data.posizione.x = ro_g.padD.data.posizione.x - (ro_g.padD.data.dimensione.x >> 1) - (ro_g.palla.data.dimensione.x >> 1) - 1
		CentroYPad = ro_g.padD.data.posizione.y
		DimYPad = ro_g.padD.data.dimensione.y
	if Collisione:
		ro_g.palla.data.inverti_vettore_x()
		ro_g.palla.data.aumenta_velocita()
		# imposta anche un cambio nel vettore y della palla, a seconda di che punto del pad impatta
		var CentroYPalla = ro_g.palla.data.posizione.y
		var offset = (CentroYPalla - CentroYPad) / (DimYPad >> 1)
		ro_g.palla.data.modifica_vettore_y(offset)

# Controllo goal
func gestione_gol():
	var Gol = false
	if ro_g.palla.data.posizione.x < 0: # Goal per player 2
		#print("Goal per player 2")
		ro_g.padD.data.punti += 1
		ro_g.padD.data.punti_aggiornato = true
		Gol = true
	elif ro_g.palla.data.posizione.x > SY.w_dim.x: # Goal per player 1
		#print("Goal per player 1")
		ro_g.padS.data.punti += 1
		ro_g.padS.data.punti_aggiornato = true
		Gol = true
	if Gol:
		ro_g.palla.data.resetta_posizione()
		ro_g.Stato_Gioco_Set(ro_g.StatiGioco.SCORED)
