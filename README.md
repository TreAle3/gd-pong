Pong fatto con Godot 4.5

Scritto in Luglio 2025

Un semplice gioco Pong realizzato in Godot 4 con GDScript, multipiattaforma per Windows, macOS, Linux, Android e iOS

Struttura del progetto
gd-pong/
├── Main.gd                 # Script principale del gioco
├── Background.gd           # Script per il nodo 2D dello sfondo
├── Main.tscn              # Scena principale
├── project.godot          # File di configurazione Godot
├── export_presets.cfg     # Presets per l'export multipiattaforma
├── icon.svg               # Icona del progetto (opzionale)
└── builds/                # Cartella per i build esportati
    ├── windows/
    ├── macos/
    ├── linux/
    ├── android/
    └── ios/
Configurazione
Risoluzione e Display

Risoluzione: 1280x768 pixel
Desktop (Windows/macOS/Linux): Finestra non ridimensionabile
Mobile (Android/iOS): Schermo intero


Impostazioni del progetto per sembrare anni '70
Project Settings > Rendering > Textures
	Canvas Textures → Filter su Off # Questo evita l'anti-aliasing e mantiene i pixel netti
Project Settings > Rendering > 2D
	Use Pixel Snap → Nearest # Questo allinea i pixel ed evita sub-pixel positioning
Project Settings > Display > Window
	Size → Viewport Width su 432
	Size → Viewport Height su 243
	Size → Window Width Override su 1280 (o la risoluzione desiderata)
	Size → Window Height Override su 720
	Stretch → Mode su viewport
	Stretch → Aspect su keep (per mantenere le proporzioni)

Configurazione avanzata
Per un controllo ancora maggiore, puoi anche:
	Stretch → Aspect su expand se vuoi riempire tutto lo schermo
Usare Scale invece di viewport se preferisci un approccio diverso al ridimensionamento

Sprite e texture
Per le tue texture e sprite:
	Import → Filter → Off per ogni texture
Oppure imposta globalmente in Project Settings → Rendering → Textures → Canvas Textures → Filter → Off


Caratteristiche attuali

Sfondo nero gestito da nodo 2D separato
Scritta "gd-pong" in giallo al centro dello schermo
Supporto per chiusura con ESC su desktop
Ottimizzato per tutte le piattaforme target
Struttura modulare pronta per aggiunta di sprite


Build per diverse piattaforme
Windows

Vai su Project → Export
Seleziona Windows Desktop
Clicca Export Project
Salva come builds/windows/gd-pong.exe

macOS

Vai su Project → Export
Seleziona macOS
Clicca Export Project
Salva come builds/macos/gd-pong.zip

Linux

Vai su Project → Export
Seleziona Linux/X11
Clicca Export Project
Salva come builds/linux/gd-pong

Android

Installa Android SDK e configura Godot
Vai su Project → Export
Seleziona Android
Configura keystore per il signing
Clicca Export Project
Salva come builds/android/gd-pong.apk

iOS

Richiede macOS e Xcode installato
Vai su Project → Export
Seleziona iOS
Configura certificati Apple Developer
Clicca Export Project
Salva come builds/ios/gd-pong.ipa

Note tecniche

Engine: Godot 4.2+
Linguaggio: GDScript
Renderer: GL Compatibility (per massima compatibilità)
Controlli: ESC per chiudere (solo desktop)


Requisiti di sistema
Desktop

Windows: Windows 10 o superiore
macOS: macOS 10.12 o superiore
Linux: Distribuzione moderna con supporto OpenGL

Mobile

Android: API level 21 (Android 5.0) o superiore
iOS: iOS 12.0 o superiore
