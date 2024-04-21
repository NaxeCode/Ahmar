package;

import flixel.FlxBasic;
import flixel.FlxG;
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

		Reg.player = new Player(0, 0);
		Reg.player.health = Reg.player.maxHealth;
		Reg.player.staminaMP = Reg.player.maxStaminaMP;
		Reg.player.screenCenter();
		add(Reg.player);

		barHealth = new FlxBar(10, 10, LEFT_TO_RIGHT, 100, 10, Reg.player, "health", 0, Reg.player.maxHealth);
		barHealth.scrollFactor.set(0, 0);
		add(barHealth);

		barSecond = new FlxBar(10, 25, LEFT_TO_RIGHT, 50, 10, Reg.player, "staminaMP", 0, Reg.player.maxStaminaMP);
		barSecond.createFilledBar(0xff001253, 0xff0037ff);
		barSecond.scrollFactor.set(0, 0);
		add(barSecond);

		FlxG.camera.follow(Reg.player, TOPDOWN);
		FlxG.worldBounds.set(-FlxG.width, -FlxG.height, FlxG.width * 4, FlxG.height * 4);

		enemyGroup = new FlxTypedGroup<Enemy>();
		add(enemyGroup);
		for (i in 0...1)
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

		FlxG.collide(Reg.player, enemyGroup, Reg.player.damageTaken);
	}
}
