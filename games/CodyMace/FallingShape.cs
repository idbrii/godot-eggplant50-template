using Godot;
using System;

public class FallingShape : RigidBody2D
{
    [Export]
    public Color[] colors;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Randomize();
        int rand = (int)GD.RandRange(0, 4);
        var node = GetNode<Node2D>("Circle");
        if (rand == 0) {
            node = GetNode<CollisionShape2D>("Circle");
            GetNode<CollisionShape2D>("Square").Disabled = true;
            GetNode<CollisionPolygon2D>("Triangle").Disabled = true;
            GetNode<CollisionPolygon2D>("Heart").Disabled = true;
        } else if (rand == 1) {
            node = GetNode<CollisionShape2D>("Square");
            GetNode<CollisionShape2D>("Circle").Disabled = true;
            GetNode<CollisionPolygon2D>("Triangle").Disabled = true;
            GetNode<CollisionPolygon2D>("Heart").Disabled = true;
        } else if (rand == 2) {
            node = GetNode<CollisionPolygon2D>("Triangle");
            GetNode<CollisionShape2D>("Circle").Disabled = true;
            GetNode<CollisionShape2D>("Square").Disabled = true;
            GetNode<CollisionPolygon2D>("Heart").Disabled = true;
        } else if (rand == 3) {
            node = GetNode<CollisionPolygon2D>("Heart");
            GetNode<CollisionShape2D>("Circle").Disabled = true;
            GetNode<CollisionShape2D>("Square").Disabled = true;
            GetNode<CollisionPolygon2D>("Triangle").Disabled = true;
        }
        int sizeSpread = (int)GD.RandRange(0, 10);
        float randomScale;
        if (sizeSpread < 5) {
            randomScale = (float)GD.RandRange(0.1f, 0.4f);
        } else if (sizeSpread < 9) {
            randomScale = (float)GD.RandRange(0.4f, 0.7f);
        } else {
            randomScale = (float)GD.RandRange(0.9f, 1.2f);
        }
        node.Visible = true;
        int colorIndex = (int)GD.RandRange(0, colors.Length);
        node.GetNode<Sprite>("Sprite").Modulate = colors[colorIndex];
        node.Scale = new Vector2(randomScale, randomScale);
    }
}
