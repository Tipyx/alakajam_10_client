import ui.EndCampaignScreen;
import ui.Hud;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var fx : Fx;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var hud : ui.Hud;

	public var score(default, null): Float;

	var isCampaign : Bool = true;

	var levelsToDo : Array<Data.Campaign> = [];

	public function new(levelsToDo:Array<Data.Campaign>, isCampaign:Bool) {
		super(Main.ME);
		ME = this;

		this.levelsToDo = levelsToDo;
		this.isCampaign = isCampaign;

		score = 0;

		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		goToNextLevel();

		onResize();
	}

	public function goToNextLevel() {
		Assets.FADE_MUSIC_VOLUME(1);
		level = new Level(levelsToDo.shift());
		fx = new Fx();
		hud = new ui.Hud(level.wid, level.hei);
	}

	public function levelVictory() {
		Assets.FADE_MUSIC_VOLUME(0.25);
		if (Popup.ME != null)
			Popup.ME.destroy();
		score += level.currentScore;
		hud.destroy();
		if (!isCampaign) {
			new ui.EndSoloLevelScreen();
		}
		else {
			if (levelsToDo.length > 0)
				new ui.EndLevelScreen();
			else
				new ui.EndCampaignScreen();
		}
		level.destroy();
	}

	public function onCdbReload() {
	}

	public function showPopup(str:String) {
		new Popup(str);
	}

	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();

 		fx.destroy();

		ME = null;
	}

	override function update() {
		super.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( Key.isPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end
		}
	}
}

