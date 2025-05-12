# Structural Overview

<img src="Assets/screenshots/main_structure.png">

Godot 4.4 allows for Modular programming that this project takes advantage of. By seperating the program into seperate slices, code has been easier to read and understand. Heavenly Havoc relies on emiting and recieving signals across different scenes in order to form a more cohesive game. 
The bulk of these are defined in an auto-loade global script found in `global.gd`, which, indicated by its namesake provides global variables and signals which scripts can reference and pass along.

# Main Scene
This section discusses the sections of code found within the main scene. This includes the battling scene, the ending panel and the other scripts these scenes heavily reference.
## Battle Manager

Managing a battle in this case comes down to a few processes in this order:
- establishing signals to listen for
- initalizing the battle
- sorting battlers into turn orders
- updating turns
- attacking
- changing turns

## End Panel


# Stats, Actions and Resources
## Battlers
## Spells


