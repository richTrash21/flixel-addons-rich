package flixel.addons.plugin.keyboard;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class FlxKeyboardEvent implements IFlxDestroyable
{
	public static var globalManager:FlxKeyboardEventManager;
	
	public var keyList:Array<FlxKey>;
	public var onPressed:FlxKeyboardEventCallback;
	public var onReleased:FlxKeyboardEventCallback;
	public var onJustPressed:FlxKeyboardEventCallback;
	public var onJustReleased:FlxKeyboardEventCallback;
	
	public function new(keyList:Array<FlxKey>, onPressed:FlxKeyboardEventCallback, onJustPressed:FlxKeyboardEventCallback,
			onReleased:FlxKeyboardEventCallback, onJustReleased:FlxKeyboardEventCallback)
	{
		this.keyList = keyList;
		this.onPressed = onPressed;
		this.onReleased = onReleased;
		this.onJustPressed = onJustPressed;
		this.onJustReleased = onJustReleased;
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

typedef FlxKeyboardEventCallback = (keyList:Array<FlxKey>, status:FlxInputState) -> Void;
