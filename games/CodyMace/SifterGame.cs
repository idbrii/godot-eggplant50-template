using Godot;
using System;
using System.Threading.Tasks;

public class SifterGame : Node2D
{
	PackedScene shapeScene = GD.Load<PackedScene>("res://games/CodyMace/FallingShape.tscn");
    bool dropShapes = false;
    float timeSinceFrame = 0;

    public override void _Ready()
    {
    }

    public override void _Input(InputEvent @event)
    {
        if (@event.IsActionPressed("action1"))
        {
            dropShapes = true;
        }
        if (@event.IsActionReleased("action1"))
        {
            dropShapes = false;
        }
    }
    public override void _Process(float delta)
    {
        timeSinceFrame += delta;
        if (timeSinceFrame > 0.1f)
        {
            timeSinceFrame = 0;
            if (dropShapes)
            {
                AddShape();
            }
        }
    }

    private void AddShape()
	{
		var shape = shapeScene.Instance() as FallingShape;
		AddChild(shape);
		var newX = GD.RandRange(-80, 80);
		shape.Position = new Vector2((float)newX, -160f);
	}
}
