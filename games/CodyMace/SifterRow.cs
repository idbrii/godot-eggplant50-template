using Godot;
using System;

public class SifterRow : Node2D
{
    [Export]
    float leftLimit;
    [Export]
    float rightLimit;
    [Export]
    float speed;
    [Export]
    bool movingRight = true;

    bool up = false;
    int frame = 0;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Randomize(); 
    }

    public override void _Process(float delta)
    {
        frame++;
        if (Position.x <= leftLimit)
        {
            movingRight = true;
        }
        else if (Position.x >= rightLimit)
        {
            movingRight = false;
        }
        if (movingRight) {
            Position = new Vector2(Position.x + speed * delta, Position.y);
        } else {
            Position = new Vector2(Position.x - speed * delta, Position.y);
        }
        if (frame % 20 == 0) {
            up = !up;
        }
        if (up) {
            Position = new Vector2(Position.x, Position.y + 0.2f);
        } else {
            Position = new Vector2(Position.x, Position.y - 0.2f);
        }
    }
}
