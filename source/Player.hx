package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

enum Command
{
	Up;
	Down;
	Left;
	Right;
	Dash;
	Attack;
}

class Player extends Entity
{
	public var inAttackState:Bool = false;

	var attackStateTimer:FlxTimer;

	static inline var MOVEMENT_SPEED:Int = 6;

	public var playerDashing:Bool = false;

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

	var maxVel_X:Int = 400;
	var maxVel_Y:Int = 420;

	// In seconds...
	var staminaRegenEvery:Float = 0.5;
	var staminaRegenAmount:Int = 5;

	public function new(X:Int, Y:Int, state:FlxState)
	{
		super(X, Y, state);

		renderPlayer();
		setPhysics();
		initPlayerReg();
		startStaminaRegen();
		addInputs();
		addHealthBar(state, this);
	}

	function renderPlayer()
	{
		makeGraphic(200, 200, 0xffaa1111);
		this.setFacingFlip(LEFT, true, false);
		this.setFacingFlip(RIGHT, false, false);
	}

	function setPhysics()
	{
		knockBackPower = 200;
		maxVelocity.set(maxVel_X, maxVel_Y);
		drag.set(maxVelocity.x * 4, maxVelocity.y * 4);
		this.immovable = true;
	}

	function initPlayerReg()
	{
		Reg.playerPos = new FlxPoint(this.x + this.origin.x, this.y + this.origin.y);
		Reg.playerAtkHitbox = new FlxObject(0, 0, 0, 0);
		Reg.playerDashHitbox = new FlxObject(0, 0, 0, 0);
		FlxG.state.add(Reg.playerAtkHitbox);
		FlxG.state.add(Reg.playerDashHitbox);
		Reg.playerAtkHitbox.kill();
		Reg.playerDashHitbox.kill();
	}

	function startStaminaRegen()
	{
		new FlxTimer().start(staminaRegenEvery, function(timer:FlxTimer)
		{
			if (this.staminaMP < this.maxStaminaMP)
				this.staminaMP += staminaRegenAmount;
		}, 0);
	}

	function addInputs():Void
	{
		#if mobile
		// Add on screen virtual pad to demonstrate UI buttons tied to actions
		_virtualPad = new FlxVirtualPad(FULL, NONE);
		_virtualPad.alpha = 0.15;
		_virtualPad.x += 10;
		_virtualPad.y -= 10;
		FlxG.state.add(_virtualPad);
		#end

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

		#if mobile
		// Add virtual pad (on-screen button) inputs
		up.addInput(_virtualPad.buttonUp, PRESSED);
		down.addInput(_virtualPad.buttonDown, PRESSED);
		left.addInput(_virtualPad.buttonLeft, PRESSED);
		right.addInput(_virtualPad.buttonRight, PRESSED);
		#end

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
		updateMovement();
		updateDigital();
		updateAnalog();
		updateReg();

		super.update(elapsed);
	}

	function updateMovement():Void
	{
		acceleration.set(0, 0);
	}

	function updateDigital():Void
	{
		#if mobile
		_virtualPad.buttonUp.color = FlxColor.WHITE;
		_virtualPad.buttonDown.color = FlxColor.WHITE;
		_virtualPad.buttonLeft.color = FlxColor.WHITE;
		_virtualPad.buttonRight.color = FlxColor.WHITE;
		#end

		if (up.triggered && down.triggered)
			moveY = 0;
		else if (up.triggered)
		{
			#if mobile
			_virtualPad.buttonUp.color = FlxColor.LIME;
			#end
			doCommand(Up);
		}
		else if (down.triggered)
		{
			#if mobile
			_virtualPad.buttonDown.color = FlxColor.LIME;
			#end
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
			#if mobile
			_virtualPad.buttonLeft.color = FlxColor.LIME;
			#end
			doCommand(Left);
		}
		else if (right.triggered)
		{
			#if mobile
			_virtualPad.buttonRight.color = FlxColor.LIME;
			#end
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

	function updateReg():Void
	{
		Reg.playerPos.set(this.x + this.origin.x, this.y + this.origin.y);
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

	function goDash()
	{
		var pointA_X:Float = 0;
		var pointA_Y:Float = 0;
		var pointB_X:Float = 0;
		var pointB_Y:Float = 0;

		playerDashing = true;

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

		FlxG.camera.shake(0.01, dashDuration);
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
			Reg.playerDashHitbox.reset(pointA_X, pointA_Y);
			Reg.playerDashHitbox.setSize(w + width, h + height);
			// FlxG.state.add(new FlxSprite(pointA_X, pointA_Y).makeGraphic(w, h, 0x500000ff));
			new FlxTimer().start(dashDuration, function(timer:FlxTimer)
			{
				Reg.playerDashHitbox.kill();
			});
			playerDashing = false;
		});
	}

	function distanceNoBias(num1:Float, num2:Float):Int
	{
		var dx:Float = (num1) - (num2);
		return Std.int(Math.sqrt(dx * dx));
	}

	function goAttack()
	{
		if (staminaMP <= 0)
			return;
		else
			staminaMP -= 5;

		trace("attack direction: " + this.facing.toString());

		if (attackStateTimer == null)
		{
			inAttackState = true;
			attackStateTimer = new FlxTimer().start(2, function(timer:FlxTimer)
			{
				inAttackState = false;
			});
		}
		else
		{
			inAttackState = true;
			attackStateTimer.reset(2);
		}

		var posX:Float = this.x;
		var posY:Float = this.y;

		var h:Float = this.height;
		var w:Float = this.width;

		switch (this.facing)
		{
			case UP:
				posY -= h;
				posX -= w / 2;
				w *= 2;
			case DOWN:
				posY += h;
				posX -= w / 2;
				w *= 2;
			case LEFT:
				posX -= w;
				posY -= h / 2;
				h *= 2;
			case RIGHT:
				posX += w;
				posY -= h / 2;
				h *= 2;
			case _:
				null;
		}
		Reg.playerAtkHitbox.reset(posX, posY);
		Reg.playerAtkHitbox.setSize(w, h);

		new FlxTimer().start(0.10, function(timer:FlxTimer)
		{
			Reg.playerAtkHitbox.kill();
		});

		triggerSFX();
	}

	override function damageTaken(obj1:Entity, obj2:Entity)
	{
		super.damageTaken(obj1, obj2);
	}

	function triggerSFX()
	{
		FlxG.sound.play(AssetPaths.attack__wav, 2);
	}
}
