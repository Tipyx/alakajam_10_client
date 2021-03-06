class Road {

	public var pointA(default, null) : EP;
	public var pointB(default, null) : EP;

	public var pointAX(get, never) : Float; inline function get_pointAX() return dn.Lib.getEnumMetaFloat(pointA, "x") * Const.MAP_TILE_SIZE;
	public var pointAY(get, never) : Float; inline function get_pointAY() return dn.Lib.getEnumMetaFloat(pointA, "y") * Const.MAP_TILE_SIZE;
	public var pointBX(get, never) : Float; inline function get_pointBX() return dn.Lib.getEnumMetaFloat(pointB, "x") * Const.MAP_TILE_SIZE;
	public var pointBY(get, never) : Float; inline function get_pointBY() return dn.Lib.getEnumMetaFloat(pointB, "y") * Const.MAP_TILE_SIZE;

	public var mapTile : MapTile;

	public var distance(get, never) : Float; inline function get_distance() return M.dist(pointAX, pointAY, pointBX, pointBY);

	public function new(pointA:EP, pointB:EP, mapTile:MapTile) {
		this.pointA = pointA;
		this.pointB = pointB;

		this.mapTile = mapTile;
	}

	public function modifyPoints(newPointA:EP, newPointB:EP) {
		for (ship in mapTile.level.ships) {
			if (ship.from == pointA) {
				ship.from = newPointA;
				ship.to = newPointB;
			}
			else if (ship.to == pointA) {
				ship.to = newPointA;
				ship.from = newPointB;
			}
		}

		pointA = newPointA;
		pointB = newPointB;
	}

	public static inline function getEpX(ep:EP) return dn.Lib.getEnumMetaFloat(ep, "x") * Const.MAP_TILE_SIZE; 
	public static inline function getEpY(ep:EP) return dn.Lib.getEnumMetaFloat(ep, "y") * Const.MAP_TILE_SIZE; 
}