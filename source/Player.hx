package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	public var maxHealth:Int = 100;

	public var maxStaminaMP:Int = 50;
	public var staminaMP:Int = 50;

	static inline var MOVEMENT_SPEED:Int = 2;

	static var actions:FlxActionManager;

	var up:FlxActionDigital;
	var down:FlxActionDigital;
	var left:FlxActionDigital;
	var right:FlxActionDigital;

	var dash:FlxActionDigital;
	var attack:FlxActionDigital;

	var moveAnalog:FlxActionAnalog;

	var trigger1:FlxActionAnalog;
	var trigger2:FlxActionAnalog;

	var move:FlxActionAnalog;

	var _virtualPad:FlxVirtualPad;

	var moveX:Float = 0;
	var moveY:Float = 0;

	var maxVel_X:Int = 200;
	var maxVel_Y:Int = 220;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		makeGraphic(24, 34, 0xffaa1111);

		maxVelocity.set(maxVel_X, maxVel_Y);
		drag.set(maxVelocity.x * 4, maxVelocity.y * 4);

		this.setFacingFlip(LEFT, true, false);
		this.setFacingFlip(RIGHT, false, false);

		Reg.playerPos = new FlxPoint(X + this.origin.x, Y + this.origin.y);
		Reg.playerAtkHitbox = new FlxObject(0, 0, 0, 0);
		Reg.playerRectObject = new FlxObject(0, 0, 0, 0);
		FlxG.state.add(Reg.playerAtkHitbox);
		FlxG.state.add(Reg.playerRectObject);
		Reg.playerAtkHitbox.kill();
		Reg.playerRectObject.kill();

		addInputs();

		new FlxTimer().start(0.15, function(timer:FlxTimer)
		{
			if (this.staminaMP < this.maxStaminaMP)
				this.staminaMP += 1;
		}, 0);
	}

	function addInputs():Void
	{
		// Add on screen virtual pad to demonstrate UI buttons tied to actions
		_virtualPad = new FlxVirtualPad(FULL, NONE);
		_virtualPad.alpha = 0.15;
		_virtualPad.x += 10;
		_virtualPad.y -= 10;
		FlxG.state.add(_virtualPad);

		// digital actions allow for on/off directional movement
		up = new FlxActionDigital();
		down = new FlxActionDigital();
		left = new FlxActionDigital();
		right = new FlxActionDigital();

		// For Dash
		dash = new FlxActionDigital();

		// Attack
		attack = new FlxActionDigital();

		// these actions don't do anything, but their values are exposed in the analog visualizer
		trigger1 = new FlxActionAnalog();
		trigger2 = new FlxActionAnalog();

		// this analog action allows for smooth movement
		move = new FlxActionAnalog();

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([up, down, left, right, dash, attack, trigger1, trigger2, move]);

		// Add keyboard inputs
		up.addKey(UP, PRESSED);
		up.addKey(W, PRESSED);
		down.addKey(DOWN, PRESSED);
		down.addKey(S, PRESSED);
		left.addKey(LEFT, PRESSED);
		left.addKey(A, PRESSED);
		right.addKey(RIGHT, PRESSED);
		right.addKey(D, PRESSED);
		dash.addKey(SPACE, JUST_PRESSED);
		attack.addKey(Z, JUST_PRESSED);

		// Add virtual pad (on-screen button) inputs
		up.addInput(_virtualPad.buttonUp, PRESSED);
		down.addInput(_virtualPad.buttonDown, PRESSED);
		left.addInput(_virtualPad.buttonLeft, PRESSED);
		right.addInput(_virtualPad.buttonRight, PRESSED);

		// Add gamepad DPAD inputs
		up.addGamepad(DPAD_UP, PRESSED);
		down.addGamepad(DPAD_DOWN, PRESSED);
		left.addGamepad(DPAD_LEFT, PRESSED);
		right.addGamepad(DPAD_RIGHT, PRESSED);

		// Add gamepad analog stick (as simulated DPAD) inputs
		up.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED);
		down.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED);
		left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);
		right.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED);

		// Add gamepad analog trigger inputs
		trigger1.addGamepad(LEFT_TRIGGER, MOVED);
		trigger2.addGamepad(RIGHT_TRIGGER, MOVED);

		// Add gamepad analog stick (as actual analog value) motion input
		move.addGamepad(RIGHT_ANALOG_STICK, MOVED, EITHER);

		FlxG.mouse.visible = true;
		FlxG.watch.add(this, "velocity", "Velocity");
	}

	public override function update(elapsed:Float):Void
	{
		acceleration.set(0, 0);

		updateDigital();
		updateAnalog();
		Reg.playerPos.set(this.x + this.origin.x, this.y + this.origin.y);

		super.update(elapsed);
	}

	function updateDigital():Void
	{
		_virtualPad.buttonUp.color = FlxColor.WHITE;
		_virtualPad.buttonDown.color = FlxColor.WHITE;
		_virtualPad.buttonLeft.color = FlxColor.WHITE;
		_virtualPad.buttonRight.color = FlxColor.WHITE;

		if (up.triggered && down.triggered)
			moveY = 0;
		else if (up.triggered)
		{
			_virtualPad.buttonUp.color = FlxColor.LIME;
			doCommand(Up);
		}
		else if (down.triggered)
		{
			_virtualPad.buttonDown.color = FlxColor.LIME;
			doCommand(Down);
		}
		else
		{
			moveY = 0;
		}

		if (left.triggered && right.triggered)
			moveX = 0;
		else if (left.triggered)
		{
			_virtualPad.buttonLeft.color = FlxColor.LIME;
			doCommand(Left);
		}
		else if (right.triggered)
		{
			_virtualPad.buttonRight.color = FlxColor.LIME;
			doCommand(Right);
		}
		else
		{
			moveX = 0;
		}

		if (dash.triggered)
		{
			doCommand(Dash);
		}

		if (attack.triggered)
		{
			doCommand(Attack);
		}
	}

	function updateAnalog():Void
	{
		// _analogWidget.setValues(move.x, move.y);
		// _analogWidget.l = trigger1.x;
		// _analogWidget.r = trigger2.x;

		if (Math.abs(moveX) < 0.001)
			moveX = move.x;

		// if (Math.abs(moveY) < 0.001)
		// moveY = move.y;
	}

	function doCommand(cmmnd:Command)
	{
		switch (cmmnd)
		{
			case Command.Up:
				facing = UP;
				moveY = -1;
				acceleration.y = -maxVelocity.y * 4;
			case Command.Down:
				facing = DOWN;
				moveY = 1;
				acceleration.y = maxVelocity.y * 4;
			case Command.Left:
				facing = LEFT;
				moveX = -1;
				acceleration.x = -maxVelocity.x * 4;
			case Command.Right:
				facing = RIGHT;
				moveX = 1;
				acceleration.x = maxVelocity.x * 4;
			case Command.Dash:
				goDash();
			case Command.Attack:
				goAttack();
		}
	}

	var pointA_X:Float = 0;
	var pointA_Y:Float = 0;
	var pointB_X:Float = 0;
	var pointB_Y:Float = 0;

	function goDash()
	{
		if (staminaMP <= 0 || moveX == 0 && moveY == 0)
			return;
		else
			staminaMP -= 15;
		pointA_X = this.x;
		pointA_Y = this.y;
		var dashSpeed:Int = 7000;
		var dashDuration:Float = 0.1;

		var dashDirection:FlxPoint = new FlxPoint(0, 0);

		// if moving left or up, update pointA_X and pointA_Y

		if (moveX != 0)
			dashDirection.x = moveX;
		if (moveY != 0)
			dashDirection.y = moveY;

		velocity.x = dashDirection.x * dashSpeed;
		velocity.y = dashDirection.y * dashSpeed;

		FlxG.camera.shake(0.01, dashDuration, function() {});
		new FlxTimer().start(0.15, function(timer:FlxTimer)
		{
			pointB_X = this.x;
			pointB_Y = this.y;

			// What is the formula for the distance between pointA and pointB?
			// sqrt((x2 - x1)^2 + (y2 - y1)^2)
			var w = distanceNoBias(pointA_X, pointB_X);
			var h = distanceNoBias(pointA_Y, pointB_Y);
			// Reg.playerRect.set(pointA_X, pointA_Y, w, h);
			if (moveX < 0)
				pointA_X = this.x;
			if (moveY < 0)
				pointA_Y = this.y;
			Reg.playerRectObject.reset(pointA_X, pointA_Y);
			Reg.playerRectObject.setSize(w + width, h + height);
			// FlxG.state.add(new FlxSprite(pointA_X, pointA_Y).makeGraphic(w, h, 0x500000ff));
		});
	}

	function distanceNoBias(num1:Float, num2:Float):Int
	{
		var dx:Float = (num1) - (num2);
		return Std.int(Math.sqrt(dx * dx));
	}

	function distanceToPoint(Base:FlxPoint, Target:FlxPoint):Int
	{
		var dx:Float = (Base.x) - Target.x;
		var dy:Float = (Base.y) - Target.y;
		Target.putWeak();
		return Std.int(FlxMath.vectorLength(dx, dy));
	}

	function goAttack()
	{
		if (staminaMP <= 0)
			return;
		else
			staminaMP -= 5;

		trace("attack direction: " + this.facing.toString());

		var posX:Float = this.x;
		var posY:Float = this.y;

		var h:Float = this.height;
		var w:Float = this.width;

		switch (this.facing)
		{
			case UP:
				posY -= h;
			case DOWN:
				posY += h;
			case LEFT:
				posX -= w;
			case RIGHT:
				posX += w;
			case _:
				null;
		}
		Reg.playerAtkHitbox.reset(posX, posY);
		Reg.playerAtkHitbox.setSize(w, h);
	}
}

enum Command
{
	Up;
	Down;
	Left;
	Right;
	Dash;
	Attack;
}
