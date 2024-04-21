package;

import flixel.FlxSprite;

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
	var dmgPower:Int = 1;
	var defPower:Int = 1;

	public function new(X:Int, Y:Int)
	{
		super(X, Y);
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

	function knockBack(sprite:FlxSprite):Void {}

	function moveTowardsWithForce(objCurrent:FlxSprite, objTarget:FlxSprite, forceX:Int, forceY:Int)
	{
		var xDiff = (objCurrent.x + objCurrent.origin.x) - (objTarget.x + objTarget.origin.x);
		var yDiff = (objCurrent.y + objCurrent.origin.y) - (objTarget.y + objTarget.origin.y);

		var angle = Math.atan2(yDiff, xDiff);

		objCurrent.velocity.set(Math.cos(angle) * forceX, Math.sin(angle) * forceY);
	}
}
