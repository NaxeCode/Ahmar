package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

enum EnemyType
{
	Rock;
	Paper;
	Scissors;
}

enum EnemyState
{
	Idle;
	Chase;
	Attack;
}

class Enemy extends FlxSprite
{
	var maxHealth:Int = 3;
	var currentState:EnemyState = EnemyState.Idle;

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
		updateEnemyState();
		updateEnemyBehaviour();
		checkFlxRect();
		debugEnemy();
	}

	function debugEnemy()
	{
		trace("currentState = " + currentState);
		trace("attackInProgress = " + attackInProgress);
	}

	var chaseDistance:Int = 150;
	var attackDistance:Int = 50;

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
				chasePlayer();
			case EnemyState.Attack:
				telegraphAttack();
		}
	}

	function stayIdle()
	{
		this.velocity.set(0, 0);
	}

	function chasePlayer()
	{
		moveTowardsPlayer(-50, -50);
	}

	var attackInProgress:Bool = false;
	var attackCooldown:Float = 3.0;

	function telegraphAttack()
	{
		if (attackInProgress)
			return;

		FlxSpriteUtil.flashTint(this, FlxColor.RED, 0.5);
		new FlxTimer().start(0.5, function(timer:FlxTimer)
		{
			attackPlayer();
			attackInProgress = true;
		});
	}

	function attackPlayer()
	{
		moveTowardsPlayer(-250, -250);

		// Attack cooldown
		new FlxTimer().start(attackCooldown, function(timer:FlxTimer)
		{
			attackInProgress = false;
		});
	}

	public function checkFlxRect()
	{
		if (FlxG.overlap(this, Reg.playerRectObject))
			this.kill();

		if (FlxG.overlap(this, Reg.playerAtkHitbox))
		{
			// health--;
			if (health <= 0)
				this.kill();

			moveTowardsPlayer(100, 100);

			Reg.playerAtkHitbox.kill();
		}
	}

	function moveTowardsPlayer(forceX:Int, forceY:Int)
	{
		var xDiff = this.x + this.origin.x - Reg.playerPos.x;
		var yDiff = this.y + this.origin.y - Reg.playerPos.y;

		var angle = Math.atan2(yDiff, xDiff);

		this.velocity.set(Math.cos(angle) * forceX, Math.sin(angle) * forceY);
	}
}
