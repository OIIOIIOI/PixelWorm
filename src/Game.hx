package ;

import com.m.geom.IntPoint;
import com.m.Random;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import haxe.Timer;
import mt.deepnight.Color;

/**
 * ...
 * @author 01101101
 */

class Game extends Sprite {
	
	static var R:Random;
	static var DIRS:Array<IntPoint>;
	
	static var STEP:Int = 2;
	static var SPEED:Int = 10;
	static var SINGLE_PATH:Bool = true;
	static var START_AT_CENTER:Bool = false;
	
	static var GROUND_COLOR:UInt = 0x2C4152;
	static var START_COLOR:UInt = 0xFFFFFF;
	static var END_COLOR:UInt = 0x000000;
	static var PATH_COLOR:UInt = 0x457C9A;
	static var BRANCH_COLOR:UInt = 0x8CA8C4;
	
	var map:BitmapData;
	var palette:BitmapData;
	var paletteIndex:Int;
	var from:IntPoint;
	var history:Array<IntPoint>;
	
	public function new () {
		super();
		
		R = new Random(6543210);
		
		DIRS = new Array<IntPoint>();
		DIRS.push(new IntPoint(0, 1));
		DIRS.push(new IntPoint(0, -1));
		DIRS.push(new IntPoint(1, 0));
		DIRS.push(new IntPoint( -1, 0));
		
		map = new BitmapData(64, 64, false, GROUND_COLOR);
		var bm = new Bitmap(map);
		bm.scaleX = bm.scaleY = 8;
		addChild(bm);
		this.addEventListener(MouseEvent.CLICK, eventHandler);
		
		palette = new BitmapData(64, 20, false, GROUND_COLOR);
		bm = new Bitmap(palette);
		bm.scaleX = bm.scaleY = 8;
		bm.y = 65 * 8;
		addChild(bm);
		
		paletteIndex = 0;
		
		history = new Array<IntPoint>();
		
		start();
	}
	
	function eventHandler (e:Event) {
		switch (e.type) {
			case MouseEvent.CLICK:
				start();
		}
	}
	
	function start () {
		// clear map
		map.fillRect(map.rect, GROUND_COLOR);
		// clear palette
		palette.fillRect(palette.rect, GROUND_COLOR);
		paletteIndex = 0;
		// clear history
		while (history.length > 0)	history.pop();
		PATH_COLOR = 0x457C9A;
		// choose starting point
		if (START_AT_CENTER) {
			from = new IntPoint(Std.int(map.width / 2), Std.int(map.height / 2));
			R.random(Std.int(map.width / STEP));
			R.random(Std.int(map.height / STEP));
		}
		else {
			from = new IntPoint(R.random(Std.int(map.width / STEP)) * STEP + Std.int(STEP / 2), R.random(Std.int(map.height / STEP)) * STEP + Std.int(STEP / 2));
		}
		map.setPixel(from.x, from.y, START_COLOR);
		// start
		step();
	}
	
	function step () {
		var point = nextDir();
		if (point == null)	return;
		
		for (i in 1...(STEP + 1)) {
			map.setPixel(from.x + i * point.x, from.y + i * point.y, PATH_COLOR);
		}
		from.x += point.x * STEP;
		from.y += point.y * STEP;
		
		history.push(from.clone());
		
		PATH_COLOR = Color.rgbToInt(Color.hue(Color.intToRgb(PATH_COLOR), 0.001));
		
		palette.setPixel(paletteIndex % palette.width, Math.floor(paletteIndex / palette.width), PATH_COLOR);
		paletteIndex++;
		
		if (SPEED > 0)		Timer.delay(step, SPEED);
		else				step();
	}
	
	function nextDir (back:Bool = false) :IntPoint {
		var found = false;
		var point:IntPoint = new IntPoint();
		var dirs = new Array<IntPoint>().concat(DIRS);
		
		do {
			point = dirs.splice(R.random(dirs.length), 1)[0].clone();
			if (map.getPixel(from.x + point.x * STEP, from.y + point.y * STEP) == GROUND_COLOR)	found = true;
			else																				point.x = point.y = 0;
		}
		while (!found && dirs.length > 0);
		
		if (found) {
			if (back) {
				PATH_COLOR = map.getPixel(from.x, from.y);
				map.setPixel(from.x, from.y, PATH_COLOR + 0x222222);
			}
			return point;
		} else {
			if (!back)	map.setPixel(from.x, from.y, END_COLOR);
			
			if (!SINGLE_PATH && history.length > 0) {
				from = history.pop();
				return nextDir(true);
			} else {
				return null;
			}
		}
	}
	
}
