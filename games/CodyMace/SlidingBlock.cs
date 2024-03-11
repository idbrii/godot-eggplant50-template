using Godot;
using System;

public class SlidingBlock : RigidBody2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    [Export]
    public float maxHorizontalSpeed;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        
    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
 public override void _Process(float delta)
 {
    Rotation = 0;
    if (LinearVelocity.x > maxHorizontalSpeed)
    {
        LinearVelocity = new Vector2(maxHorizontalSpeed, LinearVelocity.y);
    }
    if (LinearVelocity.x < -maxHorizontalSpeed)
    {
        LinearVelocity = new Vector2(-maxHorizontalSpeed, LinearVelocity.y);
    }
 }
}
