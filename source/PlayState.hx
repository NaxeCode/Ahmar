package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var enemyGroup:FlxTypedGroup<Enemy>;

	var barHealth:FlxBar;
	var barSecond:FlxBar;

	override public function create()
	{
		super.create();

		FlxG.debugger.drawDebug = true;

		Reg.player = new Player(0, 0, this);
		Reg.player.health = Reg.player.maxHealth;
		Reg.player.staminaMP = Reg.player.maxStaminaMP;
		Reg.player.screenCenter();
		add(Reg.player);

		barSecond = new FlxBar(10, 25, LEFT_TO_RIGHT, 50, 10, Reg.player, "staminaMP", 0, Reg.player.maxStaminaMP);
		barSecond.createFilledBar(0xff001253, 0xff0037ff);
		barSecond.scrollFactor.set(0, 0);
		add(barSecond);

		FlxG.camera.follow(Reg.player, TOPDOWN);
		FlxG.worldBounds.set(-FlxG.width, -FlxG.height, FlxG.width * 4, FlxG.height * 4);

		enemyGroup = new FlxTypedGroup<Enemy>();
		add(enemyGroup);
		for (i in 0...4)
		{
			var w = FlxG.random.int(50, FlxG.width - 50);
			var h = FlxG.random.int(FlxG.height - 50, 50);
			var enemy:Enemy = new Enemy(w, h, this);
			enemyGroup.add(enemy);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		handleCollisions();
	}

	function handleCollisions()
	{
		if (!Reg.player.playerDashing)
			FlxG.collide(Reg.player, enemyGroup, Reg.player.damageTaken);

		FlxG.overlap(enemyGroup, Reg.playerDashHitbox, handleOverlap);
		FlxG.overlap(enemyGroup, Reg.playerAtkHitbox, handleOverlap);
	}

	function handleOverlap(enemy:Enemy, hitbox:FlxObject)
	{
		if (enemy.knockedBack)
			return;

		enemy.damageTaken(enemy, Reg.player);

		new FlxTimer().start(2.5, function(timer:FlxTimer)
		{
			enemy.knockedBack = false;
		});

		enemy.knockedBack = true;
	}
}
