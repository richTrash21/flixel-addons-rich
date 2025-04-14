package flixel.addons.effects;

// import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
#if (flixel < version("5.7.0"))
import flixel.group.FlxSpriteGroup;
#else
import flixel.group.FlxSpriteContainer;
#end
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

/**
 * Nothing too fancy, just a handy little class to attach a trail effect to a FlxSprite.
 * Inspired by the way "Buck" from the inofficial #flixel IRC channel
 * creates a trail effect for the character in his game.
 * Feel free to use this class and adjust it to your needs.
 * @author Gama11
 */
class FlxTrail extends #if (flixel < version("5.7.0")) FlxSpriteGroup #else FlxSpriteContainer #end
{
	/**
	 * Stores the FlxSprite the trail is attached to.
	 */
	public var target(default, null):FlxSprite;
	
	/**
	 * How often to update the trail.
	 */
	public var interval:Float;
	
	/**
	 * How often to update the trail.
	 */
	@:deprecated("delay is deprecated, use interval instead")
	public var delay(default, set):Int;
	
	/**
	 * Whether to check for X changes or not.
	 */
	public var xEnabled:Bool = true;
	
	/**
	 * Whether to check for Y changes or not.
	 */
	public var yEnabled:Bool = true;
	
	/**
	 * Whether to check for angle changes or not.
	 */
	public var rotationsEnabled:Bool = true;
	
	/**
	 * Whether to check for scale changes or not.
	 */
	public var scalesEnabled:Bool = true;
	
	/**
	 * Whether to check for frame changes of the "parent" FlxSprite or not.
	 */
	public var framesEnabled:Bool = true;
	
	/**
	 * Counts the time passed.
	 */
	var _timer:Float;
	
	/**
	 * Counts the frames passed.
	 */
	// var _counter:Int = 0;
	
	/**
	 * How long is the trail?
	 */
	// var _trailLength:Int = 0;
	
	/**
	 * How many trail frames were added.
	 */
	var _trailFrames:Int = 0;
	
	/**
	 * Stores the trailsprite image.
	 */
	var _graphic:FlxGraphicAsset;
	
	/**
	 * The alpha value for the next trailsprite.
	 */
	var _transp:Float = 1;
	
	/**
	 * How much lower the alpha value of the next trailsprite is.
	 */
	var _difference:Float;
	
	var _recentPositions:Array<FlxPoint> = [];
	var _recentAngles:Array<Float> = [];
	var _recentOrigins:Array<FlxPoint> = [];
	var _recentScales:Array<FlxPoint> = [];
	var _recentFrames:Array<Int> = [];
	var _recentFlipX:Array<Bool> = [];
	var _recentFlipY:Array<Bool> = [];
	// var _recentAnimations:Array<String> = []; // FlxAnimation
	
	/**
	 * Stores the sprite origin (rotation axis)
	 */
	// var _spriteOrigin:FlxPoint;
	
	/**
	 * Creates a new FlxTrail effect for a specific FlxSprite.
	 *
	 * @param   target   The FlxSprite the trail is attached to.
	 * @param   graphic  The image to use for the trailsprites. Optional, uses the sprite's graphic if null.
	 * @param   length   The amount of trailsprites to create.
	 * @param   delay    How often to update the trail. 0 updates every frame.
	 * @param   alpha    The alpha value for the very first trailsprite.
	 * @param   diff     How much lower the alpha of the next trailsprite is.
	 */
	public function new(target:FlxSprite, ?graphic:FlxGraphicAsset, length = 10, delay = 3, alpha = 0.4, diff = 0.05):Void
	{
		super();
		
		// _spriteOrigin = FlxPoint.get().copyFrom(target.origin);
		
		// Sync the vars
		this.target = target;
		// TODO: replace delay in constructor with interval?
		this.delay = delay;
		_graphic = graphic;
		_transp = alpha;
		_difference = diff;
		
		// Create the initial trailsprites
		increaseLength(length);
		solid = false;
	}
	
	override public function destroy():Void
	{
		_recentPositions = FlxDestroyUtil.putArray(_recentPositions);
		_recentScales = FlxDestroyUtil.putArray(_recentScales);
		_recentOrigins = FlxDestroyUtil.putArray(_recentOrigins);
		
		_recentAngles = null;
		_recentFrames = null;
		_recentFlipX = null;
		_recentFlipY = null;
		// _recentAnimations = null;
		
		// _spriteOrigin = FlxDestroyUtil.put(_spriteOrigin);
		
		target = null;
		_graphic = null;
		
		super.destroy();
	}
	
	/**
	 * Updates positions and other values according to the delay that has been set.
	 */
	override public function update(elapsed:Float):Void
	{
		// Count the frames
		_timer += elapsed; // _counter++;
		
		// Update the trail in case the interval and there actually is one.
		if (_timer >= interval && length > 0) // (_counter >= delay && _trailLength >= 1)
		{
			// _counter = 0;
			_timer -= interval;
			addTrailFrame();
			
			// Now we need to update the all the Trailsprites' values
			redrawTrailSprites();
		}
		
		super.update(elapsed);
	}
	
	inline function recyclePoint(list:Array<FlxPoint>, x:Float, y:Float)
	{
		final pos = if (list.length >= length) // _trailLength
			list.pop().set(x, y);
		else
			FlxPoint.get(x, y);
		
		list.unshift(pos);
	}
	
	function addTrailFrame()
	{
		// Push the current position into the positons array and drop one.
		if (xEnabled || yEnabled)
			recyclePoint(_recentPositions, target.x - target.offset.x, target.y - target.offset.y);
		
		// Also do the same thing for the Sprites angle if rotationsEnabled
		if (rotationsEnabled)
			cacheValue(_recentAngles, target.angle);
		
		recyclePoint(_recentOrigins, target.origin.x, target.origin.y);
		
		// Again the same thing for Sprites scales if scalesEnabled
		if (scalesEnabled)
			recyclePoint(_recentScales, target.scale.x, target.scale.y);
		
		// Again the same thing for Sprites frames if framesEnabled
		if (framesEnabled && _graphic == null)
		{
			cacheValue(_recentFrames, target.animation.frameIndex);
			cacheValue(_recentFlipX, target.flipX);
			cacheValue(_recentFlipY, target.flipY);
			// cacheValue(_recentAnimations, target.animation.curAnim.name);
		}
		
		_trailFrames = FlxMath.minInt(_trailFrames + 1, length);
	}
	
	function redrawTrailSprites()
	{
		for (i in 0..._trailFrames)
		{
			final trailSprite = members[i];
			trailSprite.x = xEnabled ? _recentPositions[i].x : target.x - target.offset.x;
			trailSprite.y = yEnabled ? _recentPositions[i].y : target.y - target.offset.y;
			
			// And the angle...
			if (rotationsEnabled)
				trailSprite.angle = _recentAngles[i];
			
			trailSprite.origin.copyFrom(_recentOrigins[i]); // _spriteOrigin;
			
			// the scale...
			if (scalesEnabled)
				trailSprite.scale.copyFrom(_recentScales[i]);
			
			// and frame...
			if (framesEnabled && _graphic == null)
			{
				trailSprite.animation.frameIndex = _recentFrames[i];
				trailSprite.flipX = _recentFlipX[i];
				trailSprite.flipY = _recentFlipY[i];
				// trailSprite.animation.curAnim = trailSprite.animation.getByName(_recentAnimations[i]);
			}
			
			// Is the trailsprite even visible?
			trailSprite.exists = true;
		}
	}
	
	function cacheValue<T>(array:Array<T>, value:T)
	{
		array.unshift(value);
		if (array.length > length) // _trailLength
			array.resize(length); // _trailLength
	}
	
	public function resetTrail():Void
	{
		FlxDestroyUtil.putArray(_recentPositions);
		FlxDestroyUtil.putArray(_recentScales);
		FlxDestroyUtil.putArray(_recentOrigins);
		
		_recentAngles.resize(0);
		_recentFrames.resize(0);
		_recentFlipX.resize(0);
		_recentFlipY.resize(0);
		// _recentAnimations.resize(0);
		
		for (trailSprite in members)
			trailSprite.exists = false;
		
		_trailFrames = 0;
	}
	
	/**
	 * A function to add a specific number of sprites to the trail to increase its length.
	 *
	 * @param   amount  The amount of sprites to add to the trail.
	 */
	public function increaseLength(amount:Int):Void
	{
		// Can't create less than 1 sprite obviously
		if (amount < 1)
			return;
		
		// _trailLength += amount;
		
		// Create the trail sprites
		for (i in 0...amount)
		{
			final trailSprite = new FlxSprite();
			
			if (_graphic == null)
				trailSprite.loadGraphicFromSprite(target);
			else
				trailSprite.loadGraphic(_graphic);
			
			trailSprite.active = false;
			add(trailSprite);
			
			trailSprite.alpha = _transp;
			_transp -= _difference;
			trailSprite.solid = solid;
			trailSprite.exists = false; // trailSprite.alpha != 0
		}
	}
	
	/**
	 * In case you want to change the trailsprite image in runtime...
	 *
	 * @param  graphic  The image the sprites should load.
	 */
	public function changeGraphic(graphic:FlxGraphicAsset):Void
	{
		_graphic = graphic;
		
		if (graphic != null)
		{
			for (trailSprite in members)
				trailSprite.loadGraphic(graphic);
		}
	}
	
	/**
	 * Handy little function to change which events affect the trail.
	 *
	 * @param   angle  Whether the trail reacts to angle changes or not.
	 * @param   x      Whether the trail reacts to x changes or not.
	 * @param   y      Whether the trail reacts to y changes or not.
	 * @param   scale  Wheater the trail reacts to scale changes or not.
	 * @param   frame  Wheater the trail reacts to frame changes or not.
	 */
	public function changeValuesEnabled(angle:Bool, x = true, y = true, scale = true, frame = true):Void
	{
		rotationsEnabled = angle;
		xEnabled = x;
		yEnabled = y;
		scalesEnabled = scale;
		framesEnabled = frame;
	}
	
	@:noCompletion
	inline function set_delay(value:Int):Int
	{
		interval = value / 60;
		return delay = value;
	}
}
