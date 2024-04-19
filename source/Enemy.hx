package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class Enemy extends FlxSprite
{
	var maxHealth:Int = 3;

	public function new(X:Int = 0, Y:Int = 0)
	{
		super(X, Y);

		makeGraphic(16, 16, 0xff00ff00);
		health = maxHealth;

		this.drag.set(200, 200);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		checkFlxRect();
	}

	public function checkFlxRect()
	{
		// trace(ID + " ID = " + FlxMath.pointInFlxRect(this.x, this.y, Reg.playerRect));
		if (FlxG.overlap(this, Reg.playerRectObject))
		{
			// trace("Enemy ID " + ID + " is dead");
			this.kill();
		}
		if (FlxG.overlap(this, Reg.playerAtkHitbox))
		{
			// trace("Enemy ID " + ID + " HP is " + health);
			// health--;
			if (health <= 0)
				this.kill();

			var xDiff = this.x - Reg.playerPos.x;
			var yDiff = this.y - Reg.playerPos.y;

			var angle = Math.atan2(yDiff, xDiff);
			trace(angle);

			velocity.y = Math.sin(angle) * 100;
			velocity.x = Math.cos(angle) * 100;

			Reg.playerAtkHitbox.kill();
		}
	}
}
