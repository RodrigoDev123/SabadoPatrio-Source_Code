package ui;

import flixel.FlxSprite;

class FNFSprite extends FlxSprite {
  public var z:Float = 0;
  public var zIndex:Float = 0;
  public var dyn:Dynamic = {}; 

  override function update(elapsed:Float) {
     super.update(elapsed);
     if (dyn.update != null){
          dyn.update(elapsed);
     }
  }
}
