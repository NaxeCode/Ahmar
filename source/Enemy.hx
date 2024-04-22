package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

enum EnemyState
{
	Idle;
	Chase;
	Attack;
}

class Enemy extends Entity
{
	public var damage:Int = 1;

	var currentState:EnemyState = EnemyState.Idle;

	var chaseForce:Int = -50;
	var attackForce:Int = -250;
	var knockBackForce:Int = 300;

	public function new(X:Int = 0, Y:Int = 0, state:FlxState)
	{
		super(X, Y, state);

		makeGraphic(16, 16, 0xff00ff00);
		health = maxHealth;

		this.drag.set(200, 200);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateEnemyState();
		updateEnemyBehaviour();
		checkKnockBack();
		debugEnemy();
	}

	function debugEnemy()
	{
		trace("currentState = " + currentState);
		trace("attackInProgress = " + attackInProgress);
	}

	var chaseDistance:Int = 175;
	var attackDistance:Int = 100;

	function updateEnemyState()
	{
		// Check distance between player and enemy
		if (FlxMath.distanceToPoint(this, Reg.playerPos) <= chaseDistance)
		{
			currentState = EnemyState.Chase;

			if (FlxMath.distanceToPoint(this, Reg.playerPos) <= attackDistance)
			{
				currentState = EnemyState.Attack;
			}
		}
		else
		{
			currentState = EnemyState.Idle;
		}
	}

	function updateEnemyBehaviour()
	{
		switch (currentState)
		{
			case EnemyState.Idle:
				stayIdle();
			case EnemyState.Chase:
				if (!knockedBack)
					chasePlayer();
			case EnemyState.Attack:
				if (!knockedBack)
					telegraphAttack();
		}
	}

	function stayIdle()
	{
		this.velocity.set(0, 0);
	}

	function chasePlayer()
	{
		moveTowardsWithForce(this, Reg.player, chaseForce, chaseForce);
	}

	var attackInProgress:Bool = false;
	var attackCooldown:Float = 3.0;

	function telegraphAttack()
	{
		if (attackInProgress)
			return;

		// FlxSpriteUtil.flashTint(this, FlxColor.RED, 0.5);
		new FlxTimer().start(0.5, function(timer:FlxTimer)
		{
			attackPlayer();
			attackInProgress = true;
		});
	}

	function attackPlayer()
	{
		moveTowardsWithForce(this, Reg.player, attackForce, attackForce);

		// Attack cooldown
		new FlxTimer().start(attackCooldown, function(timer:FlxTimer)
		{
			attackInProgress = false;
		});
	}

	var knockBackCooldown:Float = 2.0;
	var knockedBack:Bool = false;

	public function checkKnockBack()
	{
		if (FlxG.overlap(this, Reg.playerRectObject))
		{
			moveTowardsWithForce(this, Reg.player, knockBackForce * 2, knockBackForce * 2);
			// FlxSpriteUtil.flashTint(this, FlxColor.YELLOW, 0.1);
			new FlxTimer().start(knockBackCooldown, function(timer:FlxTimer)
			{
				knockedBack = false;
			});

			knockedBack = true;
		}

		if (FlxG.overlap(this, Reg.playerAtkHitbox))
		{
			takeDamage(1);

			this.velocity.set(0, 0);
			moveTowardsWithForce(this, Reg.player, knockBackForce, knockBackForce);

			new FlxTimer().start(knockBackCooldown, function(timer:FlxTimer)
			{
				knockedBack = false;
			});

			knockedBack = true;
		}
	}
}
