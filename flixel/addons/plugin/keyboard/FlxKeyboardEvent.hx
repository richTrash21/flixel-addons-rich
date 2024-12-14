package flixel.addons.plugin.keyboard;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class FlxKeyboardEvent implements IFlxDestroyable
{
	public var keyList:Array<FlxKey>;
	public var onPressed:KeyboardEventCallback;
	public var onReleased:KeyboardEventCallback;
	public var onJustPressed:KeyboardEventCallback;
	public var onJustReleased:KeyboardEventCallback;
	public var pressAllKeys:Bool;
	
	public function new(keyList:Array<FlxKey>, onPressed:KeyboardEventCallback, onJustPressed:KeyboardEventCallback, onReleased:KeyboardEventCallback,
			onJustReleased:KeyboardEventCallback, pressAllKeys:Bool)
	{
		this.keyList = keyList;
		this.onPressed = onPressed;
		this.onReleased = onReleased;
		this.onJustPressed = onJustPressed;
		this.onJustReleased = onJustReleased;
		this.pressAllKeys = pressAllKeys;
	}
	
	public function destroy()
	{
		keyList = null;
		onPressed = null;
		onReleased = null;
		onJustPressed = null;
		onJustReleased = null;
	}
}

typedef KeyboardEventCallback = (keyList:Array<FlxKey>)->Void;
