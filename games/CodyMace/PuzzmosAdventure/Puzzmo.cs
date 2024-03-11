using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Permissions;

public class Puzzmo : Node2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    public RigidBody2D body;
    public RigidBody2D leftHand;
    public RigidBody2D rightHand;
    Line2D leftArm;
    Line2D rightArm;
    float armLength = 10000;
    float maxHandVelocity = 400;
    float bodyVelocity = 300;
    float armAcceleration = 20;
    float rightHandUpVelocity = 0;
    float rightHandDownVelocity = 0;
    float rightHandLeftVelocity = 0;
    float rightHandRightVelocity = 0;
    float leftHandUpVelocity = 0;
    float leftHandDownVelocity = 0;
    float leftHandLeftVelocity = 0;
    float leftHandRightVelocity = 0;

    public bool canMove = true;
    [Signal]
    public delegate void BodyHitRed();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        body = GetNode<RigidBody2D>("Body");
        leftHand = GetNode<RigidBody2D>("LeftHand");
        rightHand = GetNode<RigidBody2D>("RightHand");
        leftArm = GetNode<Line2D>("LeftArmLine");
        rightArm = GetNode<Line2D>("RightArmLine");    
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        if (isReset) {
            return;
        }
        Vector2 bodyPosLeft = new Vector2(body.Position.x - 10, body.Position.y);
        Vector2 bodyPosRight = new Vector2(body.Position.x + 10, body.Position.y);
        Vector2 leftHandPos = new Vector2(leftHand.Position.x, leftHand.Position.y);
        Vector2 rightHandPos = new Vector2(rightHand.Position.x, rightHand.Position.y);
        leftArm.Points = new Vector2[] { bodyPosLeft, leftHandPos };
        rightArm.Points = new Vector2[] { bodyPosRight, rightHandPos };
    }

    public override void _PhysicsProcess(float delta)
    {
        if (isReset) {
            return;
        }
        Rotation = 0;
        body.Rotation = 0;
        if (!canMove) {
            return;
        }
        if (Input.IsActionJustReleased("move_up"))
        {
            rightHandUpVelocity = 0;
            leftHandUpVelocity = 0;
        }
        if (Input.IsActionJustReleased("move_down"))
        {
            rightHandDownVelocity = 0;
            leftHandDownVelocity = 0;
        }
        if (Input.IsActionJustReleased("move_left"))
        {
            rightHandLeftVelocity = 0;
            leftHandLeftVelocity = 0;
        }
        if (Input.IsActionJustReleased("move_right"))
        {
            rightHandRightVelocity = 0;
            leftHandRightVelocity = 0;
        }

        if (body.Position.DistanceTo(leftHand.Position) < armLength)
        {
            // detect and display which hand can be used
            var rightDown = Input.IsActionPressed("action2");
            var leftDown = Input.IsActionPressed("action1");
            rightHand.GetNode<Sprite>("Outline").Visible = rightDown;
            leftHand.GetNode<Sprite>("Outline").Visible = leftDown;
            body.GetNode<Sprite>("Outline").Visible = false;

            if (Input.IsActionPressed("move_up"))
            {
                if (rightDown)
                {
                    if (rightHandUpVelocity > -maxHandVelocity) {
                        rightHandUpVelocity -= armAcceleration;
                    }
                    rightHand.LinearVelocity = new Vector2(rightHand.LinearVelocity.x, rightHandUpVelocity);
                }
                if (leftDown)
                {
                    if (leftHandUpVelocity > -maxHandVelocity) {
                        leftHandUpVelocity -= armAcceleration;
                    }
                    leftHand.LinearVelocity = new Vector2(leftHand.LinearVelocity.x, leftHandUpVelocity);
                }
                if (!rightDown && !leftDown)
                {
                    body.LinearVelocity = new Vector2(body.LinearVelocity.x, -bodyVelocity);
                    body.GetNode<Sprite>("Outline").Visible = true;
                }
            }
            if (Input.IsActionPressed("move_down"))
            {
                if (rightDown)
                {
                    if (rightHandDownVelocity < maxHandVelocity) {
                        rightHandDownVelocity += armAcceleration;
                    }
                    rightHand.LinearVelocity = new Vector2(rightHand.LinearVelocity.x, rightHandDownVelocity);
                }
                if (leftDown)
                {
                    if (leftHandDownVelocity < maxHandVelocity) {
                        leftHandDownVelocity += armAcceleration;
                    }
                    leftHand.LinearVelocity = new Vector2(leftHand.LinearVelocity.x, leftHandDownVelocity);
                }
                if (!rightDown && !leftDown)
                {
                    body.LinearVelocity = new Vector2(body.LinearVelocity.x, bodyVelocity);
                    body.GetNode<Sprite>("Outline").Visible = true;
                }
            }
            if (Input.IsActionPressed("move_left"))
            {
                if (rightDown)
                {
                    if (rightHandLeftVelocity > -maxHandVelocity) {
                        rightHandLeftVelocity -= armAcceleration;
                    }
                    rightHand.LinearVelocity = new Vector2(rightHandLeftVelocity, rightHand.LinearVelocity.y);
                }
                if (leftDown)
                {
                    if (leftHandLeftVelocity > -maxHandVelocity) {
                        leftHandLeftVelocity -= armAcceleration;
                    }
                    leftHand.LinearVelocity = new Vector2(leftHandLeftVelocity, leftHand.LinearVelocity.y);
                }
                if (!rightDown && !leftDown)
                {
                    body.LinearVelocity = new Vector2(-bodyVelocity, body.LinearVelocity.y);
                    body.GetNode<Sprite>("Outline").Visible = true;
                }
            }
            if (Input.IsActionPressed("move_right"))
            {
                if (rightDown)
                {
                    if (rightHandRightVelocity < maxHandVelocity) {
                        rightHandRightVelocity += armAcceleration;
                    }
                    rightHand.LinearVelocity = new Vector2(rightHandRightVelocity, rightHand.LinearVelocity.y);
                }
                if (leftDown)
                {
                    if (leftHandRightVelocity < maxHandVelocity) {
                        leftHandRightVelocity += armAcceleration;
                    }
                    leftHand.LinearVelocity = new Vector2(leftHandRightVelocity, leftHand.LinearVelocity.y);
                }
                if (!rightDown && !leftDown)
                {
                    body.LinearVelocity = new Vector2(bodyVelocity, body.LinearVelocity.y);
                    body.GetNode<Sprite>("Outline").Visible = true;
                }
            }
        }
    }
    bool isReset = false;
    public void ResetBodyAndArms() {
        isReset = true;
        GD.Print("do stuff here");
        body.LinearVelocity = new Vector2(0, 0);
        leftHand.LinearVelocity = new Vector2(0, 0);
        rightHand.LinearVelocity = new Vector2(0, 0);
        body.Position = new Vector2(0, 0);
        leftHand.Position = new Vector2(body.Position.x - 50, body.Position.y);
        rightHand.Position = new Vector2(body.Position.x + 50, body.Position.y);
    }

    void OnBodyEntered(Node2D node) {
        if (node.Name == "RedTileMap") {
            EmitSignal(nameof(BodyHitRed));
            QueueFree();
        }
    }
}
