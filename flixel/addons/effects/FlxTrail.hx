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
 * @author edited by richTrash21
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
	@:deprecated("delay is deprecated, use interval, instead")
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
	 * Have no effect if custom graphic is set.
	 */
	public var framesEnabled:Bool = true;
	
	/**
	 * Counts the time passed.
	 */
	var _timer:Float;
	
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
	var _transp:Float;
	
	/**
	 * How much lower the alpha value of the next trailsprite is.
	 */
	var _difference:Float;
	
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
		
		// Sync the vars
		this.target = target;
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
		_timer += elapsed;
		
		// Update the trail in case the interval and there actually is one.
		if (_timer >= interval && length > 0)
		{
			_timer -= interval;
			addTrailFrame();
			
			// Now we need to update the all the Trailsprites' values
			redrawTrailSprites();
		}
		
		super.update(elapsed);
	}
	
	function addTrailFrame()
	{
		var trailSprite = getFirst((basic)->!basic.exists);
		if (trailSprite == null)
		{
			trailSprite = members.shift();
			add(trailSprite);
		}
		
		if (xEnabled)
			trailSprite.x = target.x - target.offset.x;
		if (yEnabled)
			trailSprite.y = target.y - target.offset.y;
		
		if (rotationsEnabled)
			trailSprite.angle = target.angle;
		
		trailSprite.origin.copyFrom(target.origin);
		
		if (scalesEnabled)
			trailSprite.scale.copyFrom(target.scale);
		
		if (framesEnabled && _graphic == null)
		{
			trailSprite.animation.frameIndex = target.animation.frameIndex;
			trailSprite.flipX = target.flipX;
			trailSprite.flipY = target.flipY;
		}
		
		_trailFrames = FlxMath.minInt(_trailFrames + 1, length);
	}
	
	function redrawTrailSprites()
	{
		for (i in 0..._trailFrames)
		{
			final trailSprite = members[i];
			trailSprite.alpha = _transp - _difference * i;
			
			// Is the trailsprite even visible?
			trailSprite.exists = true;
		}
	}
	
	public function resetTrail():Void
	{
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
			
			trailSprite.solid = solid;
			trailSprite.exists = false;
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
	 * In case you want to change the trailsprite target in runtime...
	 *
	 * @param  target  The new target to follow.
	 * @param  reset   Should trail reset on target change?
	 */
	public function changeTarget(target:FlxSprite, reset = true):Void
	{
		this.target = target;
		
		if (graphic == null)
		{
			for (trailSprite in members)
				trailSprite.loadGraphicFromSprite(target);
		}
		
		if (reset)
			resetTrail();
	}
	
	/**
	 * Change transparency of the trail.
	 * 
	 * @param   alpha  The alpha value for the very first trailsprite.
	 * @param   diff   How much lower the alpha of the next trailsprite is.
	 */
	public function changeTransparency(alpha = 0.4, diff = 0.05):Void
	{
		_transp = alpha;
		_difference = diff;
		
		redrawTrailSprites();
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
