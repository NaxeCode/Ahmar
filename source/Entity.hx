package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxBar;

/**
	* Things all entities in the game will have in common.
	- Take Damage
	- Can Knockback
	- Damage Power
	- Defense Power
 */
enum EntityType
{
	Rock;
	Paper;
	Scissors;
}

class Entity extends FlxSprite
{
	var barHealth:FlxBar;

	public var maxHealth:Int = 100;

	public var maxStaminaMP:Int = 50;
	public var staminaMP:Int = 50;

	var dmgPower:Int = 1;
	var defPower:Int = 1;

	public function new(X:Int, Y:Int, state:FlxState)
	{
		super(X, Y);

		addHealthBar(state);
	}

	function addHealthBar(currentState:FlxState)
	{
		barHealth = new FlxBar(10, 10, LEFT_TO_RIGHT, 100, 10, Reg.player, "health", 0, maxHealth);
		barHealth.scrollFactor.set(0, 0);
		currentState.add(barHealth);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function takeDamage(damage:Int)
	{
		health -= damage;
		if (health <= 0)
			this.kill();
	}

	function knockBackFrom(sprite:FlxSprite):Void
	{
		moveTowardsWithForce(this, sprite, 300, 300);
	}

	function moveTowardsWithForce(objCurrent:FlxSprite, objTarget:FlxSprite, forceX:Int, forceY:Int)
	{
		var xDiff = (objCurrent.x + objCurrent.origin.x) - (objTarget.x + objTarget.origin.x);
		var yDiff = (objCurrent.y + objCurrent.origin.y) - (objTarget.y + objTarget.origin.y);

		var angle = Math.atan2(yDiff, xDiff);

		objCurrent.velocity.set(Math.cos(angle) * forceX, Math.sin(angle) * forceY);
	}
}
