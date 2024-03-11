using Godot;
using System;

public class PuzzmoTileMap : TileMap
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    [Export]
    int tile_index_1;
    [Export]
    int tile_index_2;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        var cells = GetUsedCells();
        foreach (Godot.Vector2 cell in cells)
        {
            if ((cell.x + cell.y) % 2 == 0)
            {
                SetCellv(cell, tile_index_1);
            } else {
                SetCellv(cell, tile_index_2);
            }
        }
    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
