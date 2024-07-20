package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var enemyGroup:FlxTypedGroup<Enemy>;

	var barHealth:FlxBar;
	var barSecond:FlxBar;

	var bounds:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		super.create();

		FlxG.debugger.drawDebug = true;

		bounds = new FlxTypedGroup<FlxSprite>(4);
		var wall = new FlxSprite(0, 0);
		wall.makeGraphic(30, FlxG.height * 2, FlxColor.GREEN);
		wall.immovable = true;
		bounds.add(wall);
		wall = new FlxSprite((FlxG.width * 2) - 30, 0);
		wall.makeGraphic(30, FlxG.height * 2, FlxColor.GREEN);
		wall.immovable = true;
		bounds.add(wall);
		wall = new FlxSprite(0, FlxG.height * 2);
		wall.makeGraphic(FlxG.width * 2, 30, FlxColor.GREEN);
		wall.immovable = true;
		bounds.add(wall);
		wall = new FlxSprite(0, -30);
		wall.makeGraphic(FlxG.width * 2, 30, FlxColor.GREEN);
		wall.immovable = true;
		bounds.add(wall);
		add(bounds);

		var bg = new FlxStarField2D(0, 0, FlxG.width * 2, FlxG.height * 2, 200);
		add(bg);

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.Sexy1__ogg, 0.15, true);
			FlxG.sound.music.fadeIn(3, 0, 0.15);
		}

		Reg.player = new Player(0, 0, this);
		Reg.player.health = Reg.player.maxHealth;
		Reg.player.staminaMP = Reg.player.maxStaminaMP;
		Reg.player.screenCenter();
		add(Reg.player);

		var uiCamera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		barSecond = new FlxBar(10, 25, LEFT_TO_RIGHT, 50, 10, Reg.player, "staminaMP", 0, Reg.player.maxStaminaMP);
		barSecond.createFilledBar(0xff001253, 0xff0037ff);
		barSecond.scrollFactor.set(0, 0);
		barSecond.cameras = [uiCamera];
		add(barSecond);

		FlxG.cameras.add(uiCamera, false);

		FlxG.camera.follow(Reg.player, TOPDOWN);
		FlxG.worldBounds.set(-FlxG.width, -FlxG.height, FlxG.width * 4, FlxG.height * 4);

		enemyGroup = new FlxTypedGroup<Enemy>();
		add(enemyGroup);
		for (i in 0...1)
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

		handleCamera();
		handleCollisions();
	}

	function handleCamera()
	{
		if (Reg.player.inAttackState)
		{
			if (FlxG.camera.zoom < 1.15)
				FlxG.camera.zoom += 0.01;
		}
		else
		{
			if (FlxG.camera.zoom > 1)
				FlxG.camera.zoom -= 0.01;
		}
	}

	function handleCollisions()
	{
		if (!Reg.player.playerDashing)
			FlxG.collide(Reg.player, enemyGroup, Reg.player.damageTaken);

		FlxG.overlap(enemyGroup, Reg.playerDashHitbox, handleOverlap);
		FlxG.overlap(enemyGroup, Reg.playerAtkHitbox, handleAttackOverlap);

		FlxG.collide(enemyGroup, bounds);
		FlxG.collide(Reg.player, bounds);
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

	public static var comboFirstTime:Bool = false;

	function handleAttackOverlap(enemy:Enemy, hitbox:FlxObject)
	{
		if (enemy.knockedBack)
			return;

		if (!comboFirstTime)
		{
			comboFirstTime = true;
			Reg.player.moveTowardsWithForce(Reg.player, enemy, -1000, -1000);
			new FlxTimer().start(0.05, function(timer:FlxTimer)
			{
				comboFirstTime = false;
			});
		}

		enemy.damageTaken(enemy, Reg.player);

		new FlxTimer().start(0.15, function(timer:FlxTimer)
		{
			enemy.knockedBack = false;
		});

		enemy.knockedBack = true;
	}
}
