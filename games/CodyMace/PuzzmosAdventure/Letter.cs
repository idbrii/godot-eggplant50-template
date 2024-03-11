using Godot;
using System;

public class Letter : Node2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    [Export]
    public string letterName = "W";
    [Signal]
    public delegate void LetterCollectedEventHandler();

    Vector2 startPos;
    Node2D text;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        text = GetNode<Node2D>("Text");
        text.GetNode<RichTextLabel>("Label").BbcodeText = $"[center]{letterName}[/center]";
        text.GetNode<RichTextLabel>("background").BbcodeText = $"[center]{letterName}[/center]";
        startPos = Position;
    }

    public override void _Process(float delta)
    {
    }

    public override void _PhysicsProcess(float delta)
    {
        Rotation = 0;
        // Position = new Vector2(startPos.x, Position.y);
    }

    void BodyEntered(Node2D body)
    {
        if (body.Name is "Body")
        {
            EmitSignal(nameof(LetterCollectedEventHandler));
            QueueFree();
        }
    }
}
