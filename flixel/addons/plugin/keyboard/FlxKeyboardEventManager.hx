package flixel.addons.plugin.keyboard;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.addons.plugin.keyboard.FlxKeyboardEvent.KeyboardEventCallback;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

/**
 * Simple keyboard event registry.
 * Mostly used for managing key combinations such as CTRL + C, CTRL + V, etc.
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
		
		#if FLX_KEYBOARD
		if (!FlxG.keys.enabled)
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
				pressed.onJustReleased(pressed.keyList);
		}
		
		for (released in releasedList)
		{
			// key combination was just pressed
			if (released.onJustPressed != null && currentReleasedList.indexOf(released) == -1)
				released.onJustPressed(released.keyList);
		}
		
		for (currentPressed in currentPressedList)
		{
			// key combination is currently pressed
			if (currentPressed.onPressed != null)
				currentPressed.onPressed(currentPressed.keyList);
		}
		
		for (currentReleased in currentReleasedList)
		{
			// key combination is currently released
			if (currentReleased.onReleased != null)
				currentReleased.onReleased(currentReleased.keyList);
		}
		
		pressedList = currentPressedList;
		releasedList = currentReleasedList;
		#end
	}
	
	/**
	 * Adds the key combination event to `this` registry.
	 *
	 * @param   keyList          List of keys that dispatches this event.
	 * @param   onPressed        Callback when key combination is pressed.
	 * @param   onJustPressed    Callback when key combination was just pressed.
	 * @param   onReleased       Callback when key combination is released.
	 * @param   onJustReleased   Callback when key combination was just released.
	 * @param   pressAllKeys     If true, all keys need to be pressed to trigger `onPressed`
	 *                           and `onJustPressed` callbacks.
	 */
	public function add(keyList:Array<FlxKey>, ?onPressed:KeyboardEventCallback, ?onJustPressed:KeyboardEventCallback, ?onReleased:KeyboardEventCallback,
			?onJustReleased:KeyboardEventCallback, pressAllKeys = true):Void
	{
		var event = new FlxKeyboardEvent(keyList, onPressed, onJustPressed, onReleased, onJustReleased, pressAllKeys);
		list.push(event);
	}
	
	/**
	 * Removes the key combination from `this` registry.
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
	 * Removes all registered key combinations from `this` registry.
	 */
	public function removeAll():Void
	{
		FlxDestroyUtil.destroyArray(list);
		pressedList.splice(0, pressedList.length);
		releasedList.splice(0, releasedList.length);
	}
	
	/**
	 * Sets the onPressed callback associated with the key combination.
	 *
	 * @param   onPressed   Callback when the key combination is pressed.
	 *                      Must have key combination list as argument - e.g. `onPressed(keyList:Array<FlxKey>)`.
	 */
	public function setPressedCallback(keyList:Array<FlxKey>, onPressed:KeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onPressed = onPressed;
	}
	
	/**
	 * Sets the onJustPressed callback associated with the key combination.
	 *
	 * @param   onJustPressed   Callback when the key combination was just pressed.
	 *                          Must have key combination list as argument - e.g. `onJustPressed(keyList:Array<FlxKey>)`.
	 */
	public function setJustPressedCallback(keyList:Array<FlxKey>, onJustPressed:KeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onJustPressed = onJustPressed;
	}
	
	/**
	 * Sets the onReleased callback associated with the key combination.
	 *
	 * @param   onReleased   Callback when the key combination is released.
	 *                       Must have key combination list as argument - e.g. `onReleased(keyList:Array<FlxKey>)`.
	 */
	public function setReleasedCallback(keyList:Array<FlxKey>, onReleased:KeyboardEventCallback):Void
	{
		var event = get(keyList);
		if (event != null)
			event.onReleased = onReleased;
	}
	
	/**
	 * Sets the onJustReleased callback associated with the key combination.
	 *
	 * @param   onJustReleased   Callback when the key combination was just released.
	 *                           Must have key combination list as argument - e.g. `onJustReleased(keyList:Array<FlxKey>)`.
	 */
	public function setJustReleasedCallback(keyList:Array<FlxKey>, onJustReleased:KeyboardEventCallback):Void
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
			if (FlxG.keys.checkStatus(key, PRESSED))
			{
				result = true;
				// leave the loop if only one the keys should be pressed
				if (!event.pressAllKeys)
					break;
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
	
	inline function checkKeys(event:FlxKeyboardEvent, keyList:Array<FlxKey>):Bool
		return FlxArrayUtil.equals(event.keyList, keyList);
}
