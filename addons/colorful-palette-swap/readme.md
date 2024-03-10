# Colorful Swap

A way to make palette swaps while authoring your base palette in full colour.

Adds entries to the Project > Tools menu:
1. Extract Palette
2. Create Swap Palettes
3. Recolor Image


# Extract Palette

Take an image (pixel art, non pixel art, anything) and extract a palette from
it by examining the pixels. Operates with one of three Colour Filters:
* All - Use all colours. Good only for pixel art using a limited palette.
* GreyValue - Select colours based on their grey value. When your input image
  uses many colours, this filters those colours to ones with significantly
  different **average** values.
* Hue - Select colours based on their hue value. For many colours in input,
  filters those colours to ones with significantly different **hue** values.


# Create Swap Palettes

This is based on [blippinbits' post about palette
swaps](https://www.reddit.com/r/godot/comments/pqtqmh/palette_swaps_without_making_every_sprite/).
Given a base palette (that your art is authored in) and a folder full of
palettes to make swaps from, it generates palettes to use with the included
[res://addons/colorful-palette-swap/code/palette_swap.shader](addons/colorful-palette-swap/code/palette_swap.shader).

At runtime, you can set the palette field in the material for that shader and
it will swap to that palette.

## [blippinbits post explaining how it works](https://www.reddit.com/r/godot/comments/pqtqmh/palette_swaps_without_making_every_sprite/)
Hey there!

I was always interested in palette swaps, especially for out current game in
development, as it has a small palette.

The basic idea behind palette swaps is usually this: Take a color value from
the original texture, do some math on it and use it to look up color in a swap
palette, to use that color instead. So for example, you see a pixel with a red
value of 0.6, and then sample from the goal palette at uv=(0.6, 0.0) to get
your swap color.

All examples i found required the sprites to be in greyscale (or do strange
things you don't want to do in shaders, like tons of if clauses). This is the
easiest to do, because you can control the base colors well by evenly
distributing the color values.

I didn't like this, because i don't think any pixel artist likes to pixel in
greyscale, or likes the additional work saving everything as grey. On the other
hand, i don't like having grey sprites everywhere either, or having to run a
converter program after getting a new sprite.

However, the problem with having your base palette not as evenly distributed
greyscale is that the lookup on the swap texture can get the wrong color. So
for example with a 5 color palette, your might not have red values of 0.0,
0.25, 0.5, 0.75 and 1.0, but rather 0.4, 0.45, 0.6, 0.66 and 0.89. That would
mean the lookup on the goal palette would probably hit the same swap color for
multiple base colors.

I'm not sure if this is common knowledge, but i found a way around it (which
might be obvious after this introduction): the swap palettes don't need to be
evenly distributed, but can distribute their colors in a way to make the lookup
from the base palette always hit correctly.

I wrote a small program that takes a base palette that is used for all your
sprites and a goal palette. It the calculates a new goal palette, so that the
color value lookups from the base palette always hit the right color. The
"doing some math on it" in this case is just taking the average across all
color channels (= the grey value). This is the program
[https://pastebin.com/LDHQVzV7](https://pastebin.com/LDHQVzV7)

The result will look something like this:
[https://imgur.com/a/khDsmIf](https://imgur.com/a/khDsmIf) You'll notice the
colors are not evenly distributed, but take the space exactly so that the
"uneven" lookup from the base color does hit the right swap color.

The palettes are also wider than, for example, 8 pixels for 8 colors, so the
colors can actually be unevenly distributed and no strange edge cases happen
with the lookup. This can the be used in a shader, to swap all colors to the
goal palette, while the sprite itself is made in the base palette. The shader
is simple [https://pastebin.com/qsxnrXjt](https://pastebin.com/qsxnrXjt)

This can be applied to every sprite. I do have another script that does that
for every sprite automatically, so the sprite doesn't need to take care of
that. Additionally, i save all the color values separately, to adjust things
like gradients, font colors or line colors.

The result you can see in the video - i can dynamically swap between different
palettes. No need to reload a scene or anything.

I also experimented a bit with screen space swaps, but those don't play nice
with UI or anything else that has transparency. So in general, per Node swaps
seem to be working better.

Oh, if anyone want's to know what game it is :D  A roguelike mining game with
monsters attacking your dome cyclically
[https://store.steampowered.com/app/1637320/Dome\_Romantik/](https://store.steampowered.com/app/1637320/Dome_Romantik/)

I fear this was all gibberish and doesn't help anyone. Let me know if i can
clarify something, or if that is something everyone knows and i was just too
stupid to find :D

-blippinbits


# Recolor Image

Select an image, pick a source and destination colour, and change all pixels
(perserving alpha) to match. Allows you to make simple colour changes in pixel
art. Not very useful in images with many colours.

You can also select a palette to make choosing colours easier (but it doesn't
automatically do anything with the palette).
