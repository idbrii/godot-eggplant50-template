using Godot;
using System;

public class ShakeableCamera : Camera2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    Vector2 startPosition;
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        startPosition = Position;
    }

    async public void Shake()
    {
        for (int i = 0; i < 10; i++)
        {
            Position = startPosition + new Vector2((float)GD.RandRange(-5, 5), (float)GD.RandRange(-5, 5));
            await ToSignal(GetTree().CreateTimer(0.01f), "timeout");
        }
        Position = startPosition;
    }
}
