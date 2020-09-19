import h2d.Layers;
import h2d.Interactive;
import h2d.Graphics;

class MapTile extends h2d.Layers {

	public var cx : Int;
	public var cy : Int;
	public var level : Level;

	var whiteSelection : Graphics;
	var inter : Interactive;

	public var selected : Bool;

	var wrapper : Layers;
	var wrapperRotation : Layers;

	var roads : Array<Road> = [];

	public var ships : Array<Ship> = [];
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;
		
		wrapperRotation = new Layers(this);
		wrapper = new Layers(wrapperRotation);
		wrapper.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

		var bmp = new Graphics(wrapper);
		bmp.beginFill(0xFFFFFF);
		bmp.lineStyle(3, 0xcc0000);
		bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

		var rotationField = new Graphics(wrapper);
		rotationField.beginFill(0xff00ff, 0.5);
		rotationField.drawRect(0, 0, 10, 10);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);

		whiteSelection = new Graphics(this);
        whiteSelection.beginFill(0xffffff, 0.3);
		whiteSelection.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
		whiteSelection.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

        whiteSelection.visible = false;

		inter = new Interactive(Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE, wrapper);
        //inter.backgroundColor = 0x55ff00ff;
        
        inter.onClick = function(e) {
			if (selected) {
				unSelect();
				level.removeArrows(this);
			}
			else {
				select();
				if (!level.checkOtherTiles(this)) {
					level.addArrows(this);
				}
			}
		}
		
		// for (i in 0...2)
			createRoad();
	}

	function createRoad() {
		var from = getRandomEntryPoint();
		var to = getRandomEntryPoint(from);

		var r = new Road(from, to, this);
		roads.push(r);

		var gr = new h2d.Graphics(wrapper);
		gr.lineStyle(1);
		gr.moveTo(r.pointAX, r.pointAY);
		gr.lineTo(r.pointBX, r.pointBY);
	}

	function getRandomEntryPoint(differentFrom:Null<EP> = null) {
		var out : EP = null;
		while (out == null || (differentFrom != null && out.getName().split("_")[0] == differentFrom.getName().split("_")[0] )) {
			out = EP.createByIndex(Std.random(EP.createAll().length));
		}

		return out;
	}

	public function spawnShipOnEP(ep:EP) {
		var ship = new Ship(level);
		var road = getRoadOnEP(ep);
		for (road in roads) {
			addShipToRoad(ship, road, ep);
			break;
		}
	}

	public function addShipToRoad(ship:Ship, road:Road, from:EP) {
		ship.addToRoad(road, from);

		ship.currentMapTile.removeShip(ship);
		ships.push(ship);
	}

	public function removeShip(ship:Ship) {
		ships.remove(ship);
	}

	public function getRoadWith(ep:EP):Road {
		for (r in roads)
			if (ep == r.pointA || ep == r.pointB) {
				return r;
			}

		return null;
	}

	public function hasAnExternalEP():Null<EP> {
		var externalEPs = [];

		if (cy == 0) {
			for (road in roads) {
				if (road.pointA == North_1 || road.pointB == North_1)
					externalEPs.push(North_1);
				if (road.pointA == North_2 || road.pointB == North_2)
					externalEPs.push(North_2);
			}
		}
		if (cy == level.hei - 1) {
			for (road in roads) {
				if (road.pointA == South_1 || road.pointB == South_1)
					externalEPs.push(South_1);
				if (road.pointA == South_2 || road.pointB == South_2)
					externalEPs.push(South_2);
			}
		}
		if (cx == 0) {
			for (road in roads) {
				if (road.pointA == West_1 || road.pointB == West_1)
					externalEPs.push(West_1);
				if (road.pointA == West_2 || road.pointB == West_2)
					externalEPs.push(West_2);
			}
		}
		if (cy == level.wid - 1) {
			for (road in roads) {
				if (road.pointA == East_1 || road.pointB == East_1)
					externalEPs.push(East_1);
				if (road.pointA == East_2 || road.pointB == East_2)
					externalEPs.push(East_2);
			}
		}

		return externalEPs.length == 0 ? null : externalEPs[Std.random(externalEPs.length)];
	}

	function getRoadOnEP(ep:EP):Road {
		for (road in roads) {
			if (road.pointA == ep || road.pointB == ep)
				return road;
		}

		return null;
	}

	public function select() {
		selected = true;
		whiteSelection.visible = true;
	}

	public function unSelect() {
		selected = false;
		whiteSelection.visible = false;
	}

	public function rotateRight() {
		// Rotate roads

		for (r in roads) {
			r.onRotation(getNextRoadWhenRotateRight(r.pointA), getNextRoadWhenRotateRight(r.pointB));
		}

		// Rotate art
		wrapperRotation.rotate(0.5*Math.PI);
	}

	public function rotateLeft() {
		// Rotate roads

		for (r in roads) {
			r.onRotation(getNextRoadWhenRotateLeft(r.pointA), getNextRoadWhenRotateLeft(r.pointB));
		}

		// Rotate art
		wrapperRotation.rotate(-0.5*Math.PI);
	}

	function getNextRoadWhenRotateRight(ep:EP):EP {
		return switch (ep) {
			case North_1:East_1;
			case North_2:East_2;
			case South_1:West_1;
			case South_2:West_2;
			case West_1:North_2;
			case West_2:North_1;
			case East_1:South_2;
			case East_2:South_1;
		}
	}

	function getNextRoadWhenRotateLeft(ep:EP):EP {
		return switch (ep) {
			case North_1:West_2;
			case North_2:West_1;
			case South_1:East_2;
			case South_2:East_1;
			case West_1:South_1;
			case West_2:South_2;
			case East_1:North_1;
			case East_2:North_2;
		}
	}

}