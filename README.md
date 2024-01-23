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

* primary action: Z,C,N,Space keys or X,B buttons
* secondary action: X,V,M keys or A,Y buttons
* pause: Enter,p keys or Start,Select buttons


## Returning to Menu

To return to main menu from your game, call:

    Eggplant.return_to_menu()

You could do this from the `pause` input (see games/movement2/World/World.gd)
or something more sophisticated.


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

## Troubleshooting

### _load: No loader found for resource: res://games/CodyMace/ShapeSwitch.cs

You're probably not using the .NET version of godot, so any games with .cs will fail to load. We are using Godot v3.5.3.stable.mono.official [6c814135b]

You can either:
* [Download Godot 3 for Windows](https://godotengine.org/download/3.x/windows/) click on **Godot Engine - .NET**
* Remove other games from the `eggplant_games.tres` resource

