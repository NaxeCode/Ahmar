package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var player:Player;
	var enemyGroup:FlxTypedGroup<Enemy>;

	var barHealth:FlxBar;
	var barSecond:FlxBar;

	override public function create()
	{
		super.create();

		FlxG.debugger.drawDebug = true;

		player = new Player(0, 0);
		player.health = player.maxHealth;
		player.staminaMP = player.maxStaminaMP;
		player.screenCenter();
		add(player);

		barHealth = new FlxBar(10, 10, LEFT_TO_RIGHT, 100, 10, player, "health", 0, player.maxHealth);
		barHealth.scrollFactor.set(0, 0);
		add(barHealth);

		barSecond = new FlxBar(10, 25, LEFT_TO_RIGHT, 50, 10, player, "staminaMP", 0, player.maxStaminaMP);
		barSecond.createFilledBar(0xff001253, 0xff0037ff);
		barSecond.scrollFactor.set(0, 0);
		add(barSecond);

		FlxG.camera.follow(player, TOPDOWN);
		FlxG.worldBounds.set(-FlxG.width, -FlxG.height, FlxG.width * 4, FlxG.height * 4);

		enemyGroup = new FlxTypedGroup<Enemy>();
		add(enemyGroup);
		for (i in 0...5)
		{
			var w = FlxG.random.int(50, FlxG.width - 50);
			var h = FlxG.random.int(FlxG.height - 50, 50);
			var enemy:Enemy = new Enemy(w, h);
			enemyGroup.add(enemy);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!player.playerDashing)
			FlxG.collide(player, enemyGroup);
	}
}
