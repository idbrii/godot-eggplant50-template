using Godot;
using System;

public class PuzzmosAdventure : Node2D
{
    [Export]
    public int testLevel = 0;
    int lettersCollected = 0;
    bool levelComplete = false;
    int currentLevel = 1;
	PackedScene level1 = GD.Load<PackedScene>("res://games/CodyMace/PuzzmosAdventure/Level1.tscn");
	PackedScene level2 = GD.Load<PackedScene>("res://games/CodyMace/PuzzmosAdventure/Level2.tscn");
	PackedScene level3 = GD.Load<PackedScene>("res://games/CodyMace/PuzzmosAdventure/Level3.tscn");
    Node2D player;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        var level = level1.Instance() as Node2D;
        currentLevel = GetCurrentLevel();
        if (testLevel > 0)
        {
            currentLevel = testLevel;
        }
        // ResetCurrentLevel();
        LoadCurrentLevel();
    }

    void LoadCurrentLevel()
    {
        var level = level1.Instance() as Node2D;
        switch (currentLevel)
        {
            case 1:
                break;
            case 2:
                level = level2.Instance() as Node2D;
                break;
            case 3:
                level = level3.Instance() as Node2D;
                break;
        }
        AddChild(level);
        GD.Print("Current Level: " + currentLevel);

        (GetNode<Node2D>("Level").GetNode<Node2D>("LetterW") as Letter).Connect("LetterCollectedEventHandler", this, nameof(LetterCollected));
        (GetNode<Node2D>("Level").GetNode<Node2D>("LetterO") as Letter).Connect("LetterCollectedEventHandler", this, nameof(LetterCollected));
        (GetNode<Node2D>("Level").GetNode<Node2D>("LetterR") as Letter).Connect("LetterCollectedEventHandler", this, nameof(LetterCollected));
        (GetNode<Node2D>("Level").GetNode<Node2D>("LetterD") as Letter).Connect("LetterCollectedEventHandler", this, nameof(LetterCollected));
        (GetNode<Node2D>("Level").GetNode<Node2D>("Puzzmo") as Puzzmo).Connect("BodyHitRed", this, nameof(BodyHitRed));
    }

    async void LetterCollected()
    {
        lettersCollected++;
        GetNode<AudioStreamPlayer>("AudioStreamPlayer").Play();
        GD.Print("Letters Collected: " + lettersCollected);
        if (lettersCollected == 4)
        {
            Node2D word = GetNode<Node2D>("Word");
            MoveChild(word, GetChildCount() - 1);
            word.Visible = true;
            levelComplete = true;
            var puzzmo = GetNode<Node2D>("Level").GetNode<Node2D>("Puzzmo") as Puzzmo;
            puzzmo.canMove = false;

            await ToSignal(GetTree().CreateTimer(1), "timeout");
            StartNextLevel();
        }
    }

    async void BodyHitRed()
    {
        await ToSignal(GetTree().CreateTimer(0.2f), "timeout");
        GetTree().ReloadCurrentScene();
    }

    async void StartNextLevel()
    {
        GetNode<Node2D>("Level").QueueFree();

        await ToSignal(GetTree().CreateTimer(0.1f), "timeout");

        currentLevel++;
        LoadCurrentLevel();
        SaveCurrentLevel(currentLevel);
        lettersCollected = 0;
        Node2D word = GetNode<Node2D>("Word");
        word.Visible = false;
        MoveChild(word, GetChildCount() - 1);
        levelComplete = false;
    }

    void SaveCurrentLevel(int level)
    {
        var config = new ConfigFile();
        config.SetValue("user", "level", level);
        config.Save("user://puzzmosadventure.cfg");
    }

    int GetCurrentLevel()
    {
        var config = new ConfigFile();
        if (config.Load("user://puzzmosadventure.cfg") == Error.Ok)
        {
            return (int)config.GetValue("user", "level");
        }
        return 1;
    }

    void ResetCurrentLevel()
    {
        SaveCurrentLevel(1);
        currentLevel = 1;
    }
}
