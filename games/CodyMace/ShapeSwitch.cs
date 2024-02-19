using Godot;
using System;
using System.Threading.Tasks;

public class ShapeSwitch : Node2D
{
	PackedScene shapeScene = GD.Load<PackedScene>("res://games/CodyMace/MovingShape.tscn");
	int delay = 700;
	int minDelay = 400;
	float velocity = 70;
	int lastPos = 0;
	int life = 3;
	int score = 0;
	bool switchOnHit = true;
	ShapeType playerShapeType = ShapeType.Square;

	Node2D player;
	Node2D life1;
	Node2D life2;
	Node2D life3;
	RichTextLabel scoreLabel;

    [Signal]
    public delegate void GameOverEventHandler();

	public override async void _Ready()
	{
		player = GetNode<Node2D>("Player");
		life1 = GetNode<Node2D>("Life1");
		life2 = GetNode<Node2D>("Life2");
		life3 = GetNode<Node2D>("Life3");
		scoreLabel = GetNode<RichTextLabel>("Score");

		GD.Randomize();
		while (true) {
			AddShape();
			if (delay > minDelay) {
				delay -= 4;
				velocity += 0.5f;
			}
		    await ToSignal(GetTree().CreateTimer(delay / 1000.0f), "timeout");
			if (!Godot.Object.IsInstanceValid(this))
			{
				// If we changed scenes, this object no longer exists and we
				// need to abort the coroutine. Not sure why this isn't
				// automatic.
				return;
			}
		}
	}

	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("action2"))
		{
            GetNode<AudioStreamPlayer>("ChangeSound").Play();
			SwitchShape();
		}
	}

	private void AddShape()
	{
		var shape = shapeScene.Instance() as MovingShape;
		AddChild(shape);
		var newX = (int)GD.RandRange(-3, 3) * 50;
		while (newX == lastPos) {
			newX = (int)GD.RandRange(-3, 3) * 50;
		}
		shape.Position = new Vector2(newX, 200);
		shape.velocity = velocity;
		lastPos = newX;
		shape.Connect("ShapeHitEventHandler", this, nameof(ShapeHitEventHandler));
	}

	private void ShapeHitEventHandler(ShapeType shapeType)
	{
		if (shapeType != ShapeType.Heart && shapeType != ShapeType.Jam && shapeType != playerShapeType)
		{
			life -= 1;
			// screen shake
			GetNode<ShakeableCamera>("Camera2D").Shake();
			// play hit sound
            GetNode<AudioStreamPlayer>("HitSound").Play();
			if (switchOnHit) {
				playerShapeType = shapeType;
			}
		} else {
			score += 1;
			// play point sound
            GetNode<AudioStreamPlayer>("PointSound").Play();
		}
		Sprite sprite = player.GetNode<Node2D>("SpriteContainer").GetNode<Sprite>("Sprite");
		switch (shapeType)
		{
			case ShapeType.Circle:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/circle.png");
				break;
			case ShapeType.Square:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/square.png");
				break;
			case ShapeType.Triangle:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/triangle.png");
				break;
			case ShapeType.Heart:
				life += 1;
				score += 4;
				break;
			case ShapeType.Jam:
				life = 3;
				score += 10;
				break;
		}
		if (life <= 0)
		{
			// game over
			// destroy player
			player.QueueFree();
			life = 0;
			HandleGameOver();
		}
		if (life > 3)
		{
			life = 3;
		}
		UpdateUI();
		var nextShapeType = playerShapeType + 1;
		if (nextShapeType == ShapeType.Heart)
		{
			nextShapeType = ShapeType.Circle;
		}
		UpdateNextShapeUI(nextShapeType);
	}

	async void HandleGameOver()
	{
		await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
		EmitSignal(nameof(GameOverEventHandler));
	}

	void SwitchShape()
	{
		playerShapeType = playerShapeType + 1;
		var nextShapeType = playerShapeType + 1;
		if (playerShapeType == ShapeType.Heart)
		{
			playerShapeType = ShapeType.Circle;
		}
		if (nextShapeType == ShapeType.Heart)
		{
			nextShapeType = ShapeType.Circle;
		}
		Sprite sprite = player.GetNode<Node2D>("SpriteContainer").GetNode<Sprite>("Sprite");
		switch (playerShapeType)
		{
			case ShapeType.Circle:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/circle.png");
				break;
			case ShapeType.Square:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/square.png");
				break;
			case ShapeType.Triangle:
				sprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/triangle.png");
				break;
		}
		UpdateNextShapeUI(nextShapeType);
	}

	void UpdateNextShapeUI(ShapeType nextShapeType)
	{
		Sprite nextShapeSprite = GetNode<Sprite>("NextShape");
		switch (nextShapeType)
		{
			case ShapeType.Circle:
				nextShapeSprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/circle.png");
				break;
			case ShapeType.Square:
				nextShapeSprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/square.png");
				break;
			case ShapeType.Triangle:
				nextShapeSprite.Texture = GD.Load<Texture>("res://games/CodyMace/Assets/triangle.png");
				break;
		}
	}

	void UpdateUI()
	{
		life1.Visible = life >= 1;
		life2.Visible = life >= 2;
		life3.Visible = life >= 3;
		scoreLabel.Text = $"Score: {score}";
	}
}
