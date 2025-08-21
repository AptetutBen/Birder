# Godot 4.4 Template Project

This is a Godot 4.4 template project designed to kickstart your game development with essential systems and features. It includes:

- **Audio Manager**: Easily manage and play sound effects and music.
- **Flow Controller**: Handle scene transitions and game flow.
- **Save System**: Save and load game data with ease.
- **Custom Terminal**: Debug and interact with the game using a built-in terminal.
- **Loading Scene**: Smooth transitions between scenes with a loading screen.
- **Main Menu**: A fully functional main menu with options.
- **Splash Screen**: A customizable splash screen for your game.

---

## Features

Godot Audio Manager Plugin
A robust audio management system for Godot 4

Simplify SFX, music, 3D audio, and dynamic footstep sounds with pooling, fading, and volume controls.

Features ✨
Audio Pooling - Pre-allocated 2D/3D/music players

Dynamic Footsteps - Terrain-based sounds (grass/water/rock)

Smooth Fades - Crossfade music, fade-in/out effects

Volume Control - Master/SFX/Music sliders with saving

Auto File Scanning - Organizes SFX/Music/Footsteps

3D Audio - Positional sound effects

Place any audio files in the **Audio** folder.

    Supported formats: .wav, .mp3, .ogg

Sound effects in the **SFX** folder (sub folders supported)
Music in the **Music** folder
And Footsteps in the **Footsteps** sub folders
- Each sub folder can hold a number of sound effects that will be chosen at random when requesting an audio clip to be played.
- More material folders can be added and adjusted in the code

```
Audio/  
├── SFX/  
├── Music/  
└── Footsteps/  
    ├── Dirt/  
    ├── Grass/  
    ├── Rock/  
    ├── Sand/  
    └── Water/
```
    
Tutorials 🎓
1. Basic SFX Playback

explosion.wav → Use as "explosion"
forest_theme.mp3 → Use as "forest_theme"

# Play explosion sound at 80% volume
```
gdscript
AudioManager.play_sfx("explosion", volume=0.8)
```
2. Music with Fade Transition

When a request to play a song is made, any current song playing will be faded out over 1 second (by default)
```
gdscript

# Start playing music 
AudioManager.play_music("menu_theme")

# Start music with 2-second fade-in
AudioManager.play_music("main_theme", fade_duration=2.0)

# Fade out current music over 1.5 seconds
AudioManager.fade_current_song()
```
3. 3D Positional Audio
```
gdscript
# Play laser sound at (5,0,10) in 3D space
AudioManager.play_sfx_at_position("laser", Vector3(5, 0, 10))
```

4. Footstep System
```
gdscript
Copy
# Play grass footstep (index 2) at 50% volume
AudioManager.play_footstep_sound(2, 0.5)
```

5. Adjust volume levels
```
# Set volumes (0.0-1.0 range)
AudioManager.set_master_volume(0.8)
AudioManager.set_sfx_volume(0.7)
AudioManager.set_music_volume(0.6)
```


### 2. **Flow Controller**
   - Handle scene transitions and game flow.
   - Load scenes asynchronously with a loading screen.
   - Loads all scenes in the Scenes folder into a Dictionary so you can change the scene with just the scene name, with or without a loading screen
   - Example usage:
     ```gdscript
     FlowController.load_scene("Level 3")
     FlowController.load_scene("Level 1",false)
     ```

### 3. **Save System**
   - Save and load game data to/from a file.
   - Supports etheral data that does not get saved and clears when the game is quit
   - Supports saving, Strings, Floats, Ints and Bools
   - Also saves Game Settings in a seperate file such as volume, screen size, fullscreen, vsync
   - Getting saved variables can be provided a default value that will be returned if the value isn't set 
   - Example usage:
     ```gdscript
     SaveController.set_value("key","value")
     SaveController.get_value("key","default value")
     SaveController.set_value_bool("key",true)
     SaveController.get_value_bool("key",true)
     SaveController.set_value_float("key",5.4)
     SaveController.get_value_float("key",1.5)
     SaveController.set_value_int("key",2)
     SaveController.get_value_int("key",1)

     SaveController.set_etheral_value("key","value")
     SaveController.get_etheral_value("key","default value")
     SaveController.set_etheral_value_bool("key",true)
     SaveController.get_etheral_value_bool("key",true)
     SaveController.set_etheral_value_float("key",5.4)
     SaveController.get_etheral_value_float("key",1.5)
     SaveController.set_etheral_value_int("key",2)
     SaveController.get_etheral_value_int("key",1)
     ```

### 4. **Loading Scene**
   - A customizable loading screen
   - When a scene is loaded with a 'Use Loading Screen' argument is provided (default) this scene will show.
   - This scene can be updated whoever you wish

### 5. **Splash Screen**
   - A customizable splash screen to display your game's logo or branding.
   - This scene can be updated whoever you wish

### 6. **Debug Terminal**
   - A Terminal that loads over the whole game to allow for custom commands to be entered.

Default button is **'~'** to hide and show the terminal

To add your own commands, duplicate the **CommandExample.gd** script and enter your own command details, this command will automatically get picked up when the game starts.

current commands:

**help** - shows a list of commands
**clr** - clears the terminal
**clear-data** - clears the save data
**font-size** - sets the consoles font size
**fullscreen** - toggles the game to fullscreen
**load** - loads a level
**quit** -- quits the game

