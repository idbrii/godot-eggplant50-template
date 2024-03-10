# [Eggplant50](https://itch.io/jam/eggplant-50)

We're trying to pack a bunch of games together!

This repo is a starting point, project structure, and the destination for all games merged into one megagame.

# Theme

📐 Finding Poetry in Geometry

This is for the UFO 50 fan jam or Jamuary as @docky has so aptly dubbed it. We
voted and selected this theme. More details on the
[Jam Page](https://itch.io/jam/eggplant-50).


# Adding your game

1. Fork this repo so you have the same project structure.
2. Install Godot 3.5 .NET so you can run the mega project with both .NET and gdscript  games.
2. Create your game in res://games/your-name-here That way all our games are isolated, so it should be easier to merge them back together.
3. Create a GameDef as res://games/your-name-here/game_yourname.tres
4. Add your GameDef to res://games/eggplant_games.tres

Once you complete your game, rebase onto latest and submit a PR. Make sure not
to include any commits that remove files from the template or change project
settings since these will cause conflicts. You can accept yours for
eggplant_games.tres conflicts since we'll just re-add everyone's GameDefs
before.

## Additional Setup

### Pause Screen

We have an easy to setup pause screen that shows your inputs:
![Pause Screen - keyboard](https://github.com/idbrii/godot-eggplant50-template/assets/43559/d916f8be-c370-4712-99eb-36332e75d161) ![Pause Screen - gamepad](https://github.com/idbrii/godot-eggplant50-template/assets/43559/afbef0ad-5213-44f1-893e-b4a824654819)

1. Open your game scene
1. Create a CanvasLayer node
    * This makes the PauseMenu layout to the screen instead of the world.
1. Drag `res://shared/menu_pause/PauseMenu.tscn` under it. See `res://games/movement2/World/World.tscn` for an example.
    * The PauseMenu automatically detects when the pause button is hit.
    * It **will not** show inputs if you launch your game scene directly. There's some necessary hookup in the main menu, so don't worry about it.
1. (Optional) Fill in the "Help" fields on the PauseMenu you added to your scene.
    * This will add a Help button to pause to explain to players how to play.
1. Update the GameDef you created above (`res://games/your-name-here/game_yourname.tres`) with the correct input labels (`input_primary_action`, etc). Clear any input labels that don't apply to your game and they'll be hidden.
1. Launch your game from the main scene `res://mainmenu/mainmenu.tscn` and see your inputs appear on the loading screen and in the pause screen (press Enter or Start to pause)!



## Examples

There are two example games:

1. games/movement2/ - a gdscript game with a decent tunable player controller
2. games/CodyMace/ - a C# game with sound that uses movement2's Player.gd player controller

Feel free to delete these and work in your own folder. If you want to use them
as a starting point, make sure you **duplicate** and delete the original so
godot drops any connections between files when we put the projects together.


## Inputs

Use the `move_` inputs for movement:

	# Using get_vector will have a circular deadzone.
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	print(move.x, move.y)

	# Using get_axis will have a cross deadzone.
	var move_x := Input.get_axis("move_left", "move_right")
	var move_y := Input.get_axis("move_up", "move_down")

Use `action1` and `action2` for actions:

	var jumped = Input.is_action_just_pressed("action1")
	var grabbing = Input.is_action_pressed("action2")


The input mapping is modelled after [pico-8](https://iiviigames.github.io/pico8-api/img/input.png):

* primary action: Z,C,N,Space keys or A,Y buttons
* secondary action: X,V,M keys or X,B buttons
* pause: Enter,p keys or Start,Select buttons


## Returning to Menu

Add games/movement2/ui/GameMenu.tscn to your scene for a pause menu that
includes options to 'Restart' and 'Quit to Menu'. If you want to customize this
menu, be sure to **duplicate** it into your game.

To return to main menu from code, call:

    Eggplant.return_to_menu()


## Deploy to itch.io

You should ensure your game works in a web build. The template includes a
script to simplify build creation and itch.io upload.

1. Create an itch.io project called `eggplant50`. Make sure to [enable SharedArrayBuffer](https://itch.io/t/2025776/experimental-sharedarraybuffer-support).
2. To auto-upload to itch.io:
    1. Edit `ci/pushbuild.py` and change "idbrii" to your itch.io name.
    2. [Install and setup butler](https://itch.io/docs/butler/)
2. To manually upload to itch.io:
    1. Edit `ci/pushbuild.py` and set `itch_project = False`
    1. `export_path` will be where to find your files to upload to itch.io.
4. Run pushbuild:

```
pip install -r ci/requirements.txt
python ci/pushbuild.py
```

## Help me get started!

Godot has some [great example projects for Godot 3.5](https://github.com/godotengine/godot-demo-projects/tree/3.5 ) to help get you started on different features/genres (use the 3.5 branch and not master).
Download them all as a zip: [3.5.zip](https://github.com/godotengine/godot-demo-projects/archive/3.5.zip)
It's often helpful just see a working example.


## Troubleshooting

### _load: No loader found for resource: res://games/CodyMace/ShapeSwitch.cs

You're probably not using the .NET version of godot, so any games with .cs will fail to load. We are using Godot v3.5.3.stable.mono.official [6c814135b]

You can either:
* [Download Godot 3 for Windows](https://godotengine.org/download/3.x/windows/) click on **Godot Engine - .NET**
* Remove other games from the `eggplant_games.tres` resource

