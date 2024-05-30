package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

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

	public var maxHealth:Int = 25;

	public var maxStaminaMP:Int = 50;
	public var staminaMP:Int = 50;

	var dmgPower:Int = 3;
	var defPower:Int = 1;

	public var knockBackPower:Int = 300;

	public var knockedBack:Bool = false;
	public var knockBackCooldown:Float = 1.0;

	public function new(X:Int, Y:Int, state:FlxState)
	{
		super(X, Y);
		addHealthBar(state);
	}

	function addHealthBar(currentState:FlxState)
	{
		barHealth = new FlxBar(0, 0, LEFT_TO_RIGHT, 50, 3, this, "health", 0, maxHealth);
		barHealth.trackParent(-13, -10);
		currentState.add(barHealth);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		flashOnKnockback(elapsed);
	}

	function flashOnKnockback(elapsed:Float)
	{
		if (knockedBack)
		{
			if (this.alpha == 1)
				this.alpha = 0.25;
			else
				this.alpha = 1;
		}
		else
			this.alpha = 1;
	}

	public function handleOverlap(enemy:Enemy, hitbox:FlxObject)
	{
		if (enemy.knockedBack)
			return;

		enemy.damageTaken(enemy, Reg.player);

		damageCooldown();
	}

	public function damageTaken(objTakingDmg:Entity, objGivingDmg:Entity):Void
	{
		if (knockedBack)
			return;
		objTakingDmg.health -= objGivingDmg.dmgPower;

		if (objTakingDmg.health <= 0)
			objTakingDmg.kill();

		knockBackFrom(objTakingDmg, objGivingDmg);
		damageCooldown();

		FlxG.sound.play(AssetPaths.hurt__wav, 2.0);
	}

	function damageCooldown()
	{
		new FlxTimer().start(knockBackCooldown, function(timer:FlxTimer)
		{
			knockedBack = false;
		});

		knockedBack = true;
	}

	function knockBackFrom(objEffected:Entity, objMovingAwayFrom:Entity):Void
	{
		moveTowardsWithForce(objEffected, objMovingAwayFrom, objMovingAwayFrom.knockBackPower, objMovingAwayFrom.knockBackPower);
	}

	public function moveTowardsWithForce(objCurrent:FlxSprite, objTarget:FlxSprite, forceX:Int, forceY:Int)
	{
		var xDiff = (objCurrent.x + objCurrent.origin.x) - (objTarget.x + objTarget.origin.x);
		var yDiff = (objCurrent.y + objCurrent.origin.y) - (objTarget.y + objTarget.origin.y);

		var angle = Math.atan2(yDiff, xDiff);

		objCurrent.velocity.set(Math.cos(angle) * forceX, Math.sin(angle) * forceY);
	}
}
