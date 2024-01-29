using Godot;
using System;

public class FallingShape : RigidBody2D
{
    [Export]
    public Color[] colors;

    int sizeClass = 0;

    AudioStreamPlayer lightHitSound;
    AudioStreamPlayer mediumHitSound;
    AudioStreamPlayer heavyHitSound;
    float scale = 1;

    float timeSinceHit = 0;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        lightHitSound = GetNode<AudioStreamPlayer>("LightHit");
        mediumHitSound = GetNode<AudioStreamPlayer>("MediumHit");
        heavyHitSound = GetNode<AudioStreamPlayer>("HeavyHit");
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
            sizeClass = 0;
        } else if (sizeSpread < 9) {
            randomScale = (float)GD.RandRange(0.4f, 0.7f);
            sizeClass = 1;
        } else {
            randomScale = (float)GD.RandRange(0.9f, 1.2f);
            sizeClass = 2;
        }
        node.Visible = true;
        int colorIndex = (int)GD.RandRange(0, colors.Length);
        node.GetNode<Sprite>("Sprite").Modulate = colors[colorIndex];
        node.Scale = new Vector2(randomScale, randomScale);
        scale = randomScale;
    }

    void BodyEntered(Node node) {
        // if (LinearVelocity.y < 10) {
        //     return;
        // }
        var velocity = Mathf.Sqrt(Mathf.Pow(LinearVelocity.x, 2) + Mathf.Pow(LinearVelocity.y, 2));
        var timeOfHit = Time.GetTicksMsec();
        if (timeOfHit - timeSinceHit < 1500) {
            return;
        }
        var volume = velocity / 10 - 35;
        timeSinceHit = timeOfHit;
        if (sizeClass == 0) {
            lightHitSound.PitchScale = 1.2f - scale;
            lightHitSound.VolumeDb = volume;
            lightHitSound.Play();
        } else if (sizeClass == 1) {
            mediumHitSound.PitchScale = 1.2f - scale;
            mediumHitSound.VolumeDb = volume;
            mediumHitSound.Play();
        } else if (sizeClass == 2) {
            heavyHitSound.PitchScale = 1.2f - scale;
            heavyHitSound.VolumeDb = volume;
            heavyHitSound.Play();
        }
    }
}
