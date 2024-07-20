package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PrototypeState extends FlxState
{
	var enemyGroup:FlxTypedGroup<Enemy>;

	var barHealth:FlxBar;
	var barSecond:FlxBar;

	var bounds:FlxTypedGroup<FlxSprite>;

	var level_w:Int = 5760;
	var level_h:Int = 3240;

	override public function create()
	{
		super.create();

		FlxG.debugger.drawDebug = true;

		level_create();

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.Sexy1__ogg, 0.15, true);
			FlxG.sound.music.fadeIn(3, 0, 0.15);
		}

		var uiCamera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		barSecond = new FlxBar(10, 25, LEFT_TO_RIGHT, 50, 10, Reg.player, "staminaMP", 0, Reg.player.maxStaminaMP);
		barSecond.createFilledBar(0xff001253, 0xff0037ff);
		barSecond.scrollFactor.set(0, 0);
		barSecond.cameras = [uiCamera];
		add(barSecond);

		FlxG.cameras.add(uiCamera, false);

		FlxG.camera.follow(Reg.player, TOPDOWN);
		FlxG.worldBounds.set(0, 0, level_w, level_h);
		FlxG.camera.setScrollBounds(0, level_w, 0, level_h);
		FlxG.camera.antialiasing = true;

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

	function level_create()
	{
		// Background Color
		FlxG.camera.bgColor = FlxColor.fromRGB(126, 126, 126);

		// Floor
		var floor = new FlxSprite(0, 0);
		floor.loadGraphic(AssetPaths.floor__png);
		add(floor);

		// Background / Pillars / Ropes / Entrance + Exit
		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.background__png);
		add(background);

		// Player
		addPlayer();

		// Foreground Pillars
		var fg_pillars = new FlxSprite();
		fg_pillars.loadGraphic(AssetPaths.fg_pillars__png);
		add(fg_pillars);
	}

	function addPlayer()
	{
		Reg.player = new Player(0, 0, this);
		Reg.player.health = Reg.player.maxHealth;
		Reg.player.staminaMP = Reg.player.maxStaminaMP;
		Reg.player.screenCenter();
		add(Reg.player);
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
