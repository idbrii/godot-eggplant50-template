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
	ShapeType playerShapeType = ShapeType.Square;

	Node2D player;
	Node2D life1;
	Node2D life2;
	Node2D life3;
	RichTextLabel scoreLabel;

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
			await Task.Delay(delay);
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
		if (shapeType != ShapeType.Heart && shapeType != playerShapeType)
		{
			life -= 1;
			playerShapeType = shapeType;
		} else {
			score += 1;
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
		}
		if (life <= 0)
		{
			// game over
			life = 0;
		}
		if (life > 3)
		{
			life = 3;
		}
		UpdateUI();
	}

	void UpdateUI()
	{
		life1.Visible = life >= 1;
		life2.Visible = life >= 2;
		life3.Visible = life >= 3;
		scoreLabel.Text = $"Score: {score}";
	}
}
