package flixel.addons.plugin.keyboard;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.addons.plugin.keyboard.FlxKeyboardEvent.FlxKeyboardEventCallback;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

/**
 * Simple class for managing keyboard key presses.
 * Mostly used for managing key combinations (CTRL + C, CTRL + V, etc.).
 *
 * TODO: gamepad input manager or smth like this
 * TODO: docs
 *
 * @author richTrash21
 */
class FlxKeyboardEventManager extends FlxBasic
{
	var list:Array<FlxKeyboardEvent> = [];
	var pressedList:Array<FlxKeyboardEvent> = [];
	var releasedList:Array<FlxKeyboardEvent> = [];
	
	public function new()
	{
		super();
		// skip draw calls
		visible = false;
		FlxG.signals.preStateSwitch.add(removeAll);
	}
	
	override public function destroy():Void
	{
		pressedList = null;
		releasedList = null;
		list = FlxDestroyUtil.destroyArray(list);
		FlxG.signals.preStateSwitch.remove(removeAll);
		super.destroy();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (!isActive())
			return;
			
		var currentPressedList:Array<FlxKeyboardEvent> = [];
		var currentReleasedList:Array<FlxKeyboardEvent> = [];
		
		for (event in list)
		{
			if (checkStatus(event))
				currentPressedList.push(event);
			else
				currentReleasedList.push(event);
		}
		
		for (pressed in pressedList)
		{
			// key combination was just released
			if (pressed.onJustReleased != null && currentPressedList.indexOf(pressed) == -1)
				pressed.onJustReleased(pressed.keyList, JUST_RELEASED);
		}
		
		for (released in releasedList)
		{
			// key combination was just pressed
			if (released.onJustPressed != null && currentReleasedList.indexOf(released) == -1)
				released.onJustPressed(released.keyList, JUST_PRESSED);
		}
		
		for (currentPressed in currentPressedList)
		{
			// key combination is currently pressed
			if (currentPressed.onPressed != null)
				currentPressed.onPressed(currentPressed.keyList, PRESSED);
		}
		
		for (currentReleased in currentReleasedList)
		{
			// key combination is currently released
			if (currentReleased.onReleased != null)
				currentReleased.onReleased(currentReleased.keyList, RELEASED);
		}
		
		pressedList = currentPressedList;
		releasedList = currentReleasedList;
	}
	
	/**
	 * Adds the key combination event to the FlxMouseEventManager registry.
	 *
	 * @param   keyList          List of keys that dispatches this event.
	 * @param   onPressed        Callback when key combination is pressed.
	 * @param   onJustPressed    Callback when key combination was just pressed.
	 * @param   onReleased       Callback when key combination is released.
	 * @param   onJustReleased   Callback when key combination was just released.
	 * @return  Added event.
	 */
	public function add(keyList:Array<FlxKey>, ?onPressed:FlxKeyboardEventCallback, ?onJustPressed:FlxKeyboardEventCallback,
			?onReleased:FlxKeyboardEventCallback, ?onJustReleased:FlxKeyboardEventCallback):FlxKeyboardEvent
	{
		var event = new FlxKeyboardEvent(keyList, onPressed, onJustPressed, onReleased, onJustReleased);
		list.push(event);
		return event;
	}
	
	/**
	 *
	 */
	public function remove(keyList:Array<FlxKey>):Void
	{
		for (event in list)
		{
			if (checkKeys(event, keyList))
			{
				event.destroy();
				list.remove(event);
			}
		}
	}
	
	/**
	 *
	 */
	public function removeAll():Void
	{
		FlxDestroyUtil.destroyArray(list);
		pressedList.splice(0, pressedList.length);
		releasedList.splice(0, releasedList.length);
	}
	
	/**
	 *
	 */
	public function setPressedCallback(keyList:Array<FlxKey>, onPressed:FlxKeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onPressed = onPressed;
	}
	
	/**
	 *
	 */
	public function setJustPressedCallback(keyList:Array<FlxKey>, onJustPressed:FlxKeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onJustPressed = onJustPressed;
	}
	
	/**
	 *
	 */
	public function setReleasedCallback(keyList:Array<FlxKey>, onReleased:FlxKeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onReleased = onReleased;
	}
	
	/**
	 *
	 */
	public function setJustReleasedCallback(keyList:Array<FlxKey>, onJustReleased:FlxKeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onJustReleased = onJustReleased;
	}
	
	function get(keyList:Array<FlxKey>):FlxKeyboardEvent
	{
		for (event in list)
			if (checkKeys(event, keyList))
				return event;
				
		return null;
	}
	
	function checkStatus(event:FlxKeyboardEvent):Bool
	{
		var result = false;
		
		#if FLX_KEYBOARD
		for (key in event.keyList)
		{
			if (isKeyPressed(key))
			{
				result = true;
			}
			else
			{
				result = false;
				break;
			}
		}
		#end
		
		return result;
	}
	
	// TODO: override for gamepad button manager
	function isKeyPressed(key:FlxKey)
	{
		#if FLX_KEYBOARD
		return FlxG.keys.checkStatus(key, PRESSED);
		#else
		return false;
		#end
	}
	
	// TODO: override for gamepad button manager
	function isActive()
	{
		#if FLX_KEYBOARD
		return FlxG.keys.enabled;
		#else
		return false;
		#end
	}
	
	inline function checkKeys(event:FlxKeyboardEvent, keyList:Array<FlxKey>)
	{
		return FlxArrayUtil.equals(event.keyList, keyList);
	}
}
