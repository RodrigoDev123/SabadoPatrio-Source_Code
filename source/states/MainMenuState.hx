package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;
	public var currentOptions:Options;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var gfDance:Character;

	#if !switch
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'options', 'credits'];
	#else
	var optionShit:Array<String> = ['story_mode', 'freeplay'];
	#end

	var magenta:FlxSprite;

	function onMouseDown(object:FlxObject){
		if(!selectedSomethin){
			if(object==gfDance){
				var anims = ["singUP","singLEFT","singRIGHT","singDOWN"];
				var sounds = ["GF_1","GF_2","GF_3","GF_4"];
				var anim = FlxG.random.int(0,3);
				gfDance.holdTimer=0;
				gfDance.playAnim(anims[anim]);
				FlxG.sound.play(Paths.sound(sounds[anim]));
			}else{
				for(obj in menuItems.members){
					if(obj==object){
						accept();
						break;
					}
				}
			}
		}
	}

	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...menuItems.members.length){
				var obj = menuItems.members[idx];
				if(obj==object){
					if(idx!=curSelected){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(idx,true);
					}
				}
			}
		}
	}

	function onMouseOut(object:FlxObject){

	}

	function accept(){
		if (optionShit[curSelected] == 'donate')
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
			#else
			FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
			#end
		}
		else
		{
			if(!currentOptions.oldMenus)
			{
				gfDance.playAnim('hey');
			}
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if(OptionUtils.options.menuFlash){
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story_mode':
									FlxG.switchState(new StoryMenuState());
									trace("Story Menu Selected");
								case 'freeplay':
									FlxG.switchState(new FreeplayState());
									trace("Freeplay Menu Selected");

								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}else{
						new FlxTimer().start(1, function(tmr:FlxTimer){
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story_mode':
									FlxG.switchState(new StoryMenuState());
									trace("Story Menu Selected");
								case 'freeplay':
									FlxG.switchState(new FreeplayState());
									trace("Freeplay Menu Selected");

								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}
				}
			});
		}
	}

	override function create()
	{
		super.create();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		currentOptions = OptionUtils.options;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG_new'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.13;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		var thing = new FNFSprite(FlxG.width * 0.002 + 20,0).loadGraphic(Paths.image('menucoso'));
		thing.screenCenter(Y);
		thing.updateHitbox();
		thing.antialiasing = true;

		// magenta.scrollFactor.set();

		if(!currentOptions.oldMenus){

			gfDance = new Character(FlxG.width * 0.07 + 20, FlxG.height * 0.07,"bf-mex",true);
			gfDance.antialiasing = true;
			gfDance.scrollFactor.set();
			add(gfDance);

			gfDance.playAnim('idle');

			FlxMouseEventManager.add(gfDance,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}
		add(thing);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		if(currentOptions.oldMenus)
		{
			var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

			for (i in 0...optionShit.length)
				{
					var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
					menuItem.frames = tex;
					menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
					menuItem.animation.play('idle');
					menuItem.ID = i;
					menuItem.screenCenter(X);
					menuItems.add(menuItem);
					menuItem.scrollFactor.set();
					menuItem.antialiasing = true;

					FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
				}
		}
		else
		{
			for (i in 0...optionShit.length)
				{
					var menuItem:FlxSprite = new FlxSprite(FlxG.width - 760, ((i) * 160));
					menuItem.loadGraphic(Paths.image("menu_"+optionShit[i]));
					//menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
					//menuItem.animation.addByPrefix('selected', optionShit[i] + " alt", 24);
					//menuItem.animation.play('idle');
					menuItem.ID = i;
					//menuItem.screenCenter(X);
					menuItem.x -= 85 * i;
					menuItem.setGraphicSize(Std.int(menuItem.width *0.75));
					menuItems.add(menuItem);
					menuItem.y -= 150;
					menuItem.updateHitbox();
					menuItem.scrollFactor.set();
					menuItem.antialiasing = true;

					FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
				}
		}

        var logoBl = new FlxSprite(-270, 270);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();  
		logoBl.alpha = 0.8;
		logoBl.setGraphicSize(Std.int(logoBl.width*0.4));
		add(logoBl);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 1, 0, "v" + Application.current.meta.get('version') + " - Andromeda Engine PR1", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

	}

	var selectedSomethin:Bool = false;
	override function beatHit(){
		super.beatHit();
		if(gfDance!=null){
			if (gfDance.isSinging && gfDance.animation.curAnim.name!="cheer")
			 	 gfDance.dance();
		}
	}
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.mouse.visible=true;

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				accept();
			}
		}

		super.update(elapsed);

		if(currentOptions.oldMenus)
			{
				menuItems.forEach(function(spr:FlxSprite)
					{
						spr.screenCenter(X);
					});
			}
	}

	var timeOnSelection:Float = 0.0;
	function changeItem(huh:Int = 0,force:Bool=false)
	{
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.scale.set(0.75,0.75);
			spr.color = 0xFFA9B1C2;
			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.scale.set(0.8,0.8);
				spr.color = FlxColor.WHITE;
			}

			spr.updateHitbox();
		});
	}
}
