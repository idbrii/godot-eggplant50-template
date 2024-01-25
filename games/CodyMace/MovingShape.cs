using Godot;
using System;
using System.Diagnostics;

public enum ShapeType
{
    Circle,
    Square,
    Triangle,
    Heart,
    Jam
}

public class MovingShape : Area2D
{
    [Export]
    public Color circleColor;
    [Export]
    public Color triangleColor;
    [Export]
    public Color squareColor;
    [Export]
    public Color heartColor;
    [Export]
    public Color jamColor;

    [Signal]
    public delegate void ShapeHitEventHandler(ShapeType shapeType);

    [Export]
    public float velocity = 0;
    bool popped = false;

    ShapeType shapeType = ShapeType.Circle;
    Sprite sprite;
    CPUParticles2D explosion;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        explosion = GetNode<CPUParticles2D>("Explosion");

        GD.Randomize();
        shapeType = (ShapeType)(GD.Randi() % 3);
        sprite = GetNode<Sprite>("Sprite");
        int heartChance = (int)GD.RandRange(0, 7);
        if (heartChance == 1) {
            shapeType = ShapeType.Heart;
        }
        int jamChance = (int)GD.RandRange(0, 20);
        if (jamChance == 1) {
            shapeType = ShapeType.Jam;
        }

        switch (shapeType) {
            case ShapeType.Circle:
                sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/circle.png");
                sprite.Modulate = circleColor;
                break;
            case ShapeType.Square:
                sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/square.png");
                sprite.Modulate = squareColor;
                break;
            case ShapeType.Triangle:
                sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/triangle.png");
                sprite.Modulate = triangleColor;
                break;
            case ShapeType.Heart:
                sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/heart.png");
                sprite.Modulate = heartColor;
                break;
            case ShapeType.Jam:
                sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/eggplant-jam-bordered.png");
                sprite.Modulate = new Color(1, 1, 1, 1);
                break;
        }
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        Position = new Vector2(Position.x, Position.y - velocity * delta);
    }

    public void OnPlayerBodyEntered(Node body)
    {
        if (body.Name == "Player" && !popped) {
            popped = true;
            GetNode<AudioStreamPlayer>("PopSound").Play();
            velocity = 0;
            sprite.Visible = false;
            GetNode<CollisionShape2D>("CollisionShape2D").Disabled = true;
            EmitSignal(nameof(ShapeHitEventHandler), shapeType);
            explosion.Emitting = true;
            explosion.Color = sprite.Modulate;
            if (shapeType == ShapeType.Jam) {
                explosion.Color = jamColor;
            }
            Timer timer = new Timer
            {
                WaitTime = 1.0f,
                OneShot = true
            };
            AddChild(timer);
            timer.Start();
            timer.Connect("timeout", this, nameof(OnExplosionFinished));
        }
    }

    void OnExplosionFinished()
    {
        QueueFree();
    }

    void GameOverDude()
    {
        GD.Print("Game over dude");
    }
}
