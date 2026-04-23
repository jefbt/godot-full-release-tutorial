# godot-full-release-tutorial

Godot Tutorial from nothing to a released game

## Installation

1. Ensure you have [Godot Engine](https://godotengine.org/) installed (version 4.6.X recommended).
2. Clone this repository: `git clone https://github.com/yourusername/godot-full-release-tutorial.git`
3. Open Godot and import the project by selecting the cloned directory.
4. Run the project from the Godot editor.

## Modifying the Project

This project is structured as a complete Godot game tutorial. Key areas for modification:

- **Scenes**: Located in the `levels/` directory. Edit `.tscn` files to modify level layouts.
- **Scripts**: All GDScript files are in `scripts/`, `player/`, `creatures/`, and `levels/` directories.
- **Assets**: Sprites, sounds, and other assets are in the project directory.
- **Game Logic**: Main game management is in `scripts/game_manager.gd`.

To add new levels:
1. Duplicate `Levels/level_000.tscn` and change it's name.
2. It will be added automatically to the game levels `scripts/game_manager.gd`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT License allows you to:
- Use the code for personal and commercial projects
- Modify and distribute the code
- Include the code in proprietary software

However, you must include the original copyright notice and license text.

## Credits

This project uses the following assets:

- **Pixel Operator Font** by Pixel Operator  
  https://www.dafont.com/pixel-operator.font?l[]=10&l[]=1

- **GPPack** by FIsherG  
  https://fisherg.itch.io/gppack

- **Platform Metroidvania Pixel Art Asset Pack** by o_lobster  
  https://o-lobster.itch.io/platformmetroidvania-pixel-art-asset-pack

- **Assets Pack Cute Platform Game** by OmelPixela  
  https://omelpixela.itch.io/assets-pack-cute-platform-game
