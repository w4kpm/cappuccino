/*
 * CPControl.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import "CPFont.j"
@import "CPShadow.j"
@import "CPView.j"
@import "CPKeyValueBinding.j"

#include "CoreGraphics/CGGeometry.h"
#include "Platform/Platform.h"

CPLeftTextAlignment             = 0;
CPRightTextAlignment            = 1;
CPCenterTextAlignment           = 2;
CPJustifiedTextAlignment        = 3;
CPNaturalTextAlignment          = 4;

CPRegularControlSize            = 0;
CPSmallControlSize              = 1;
CPMiniControlSize               = 2;

CPLineBreakByWordWrapping       = 0;
CPLineBreakByCharWrapping       = 1;
CPLineBreakByClipping           = 2;
CPLineBreakByTruncatingHead     = 3;
CPLineBreakByTruncatingTail     = 4;
CPLineBreakByTruncatingMiddle   = 5;

CPTopVerticalTextAlignment      = 1,
CPCenterVerticalTextAlignment   = 2,
CPBottomVerticalTextAlignment   = 3;

CPScaleProportionally   = 0;
CPScaleToFit            = 1;
CPScaleNone             = 2;

CPNoImage       = 0;
CPImageOnly     = 1;
CPImageLeft     = 2;
CPImageRight    = 3;
CPImageBelow    = 4;
CPImageAbove    = 5;
CPImageOverlaps = 6;

CPOnState                       = 1;
CPOffState                      = 0;
CPMixedState                    = -1;

CPControlNormalBackgroundColor      = "CPControlNormalBackgroundColor";
CPControlSelectedBackgroundColor    = "CPControlSelectedBackgroundColor";
CPControlHighlightedBackgroundColor = "CPControlHighlightedBackgroundColor";
CPControlDisabledBackgroundColor    = "CPControlDisabledBackgroundColor";

CPControlTextDidBeginEditingNotification    = "CPControlTextDidBeginEditingNotification";
CPControlTextDidChangeNotification          = "CPControlTextDidChangeNotification";
CPControlTextDidEndEditingNotification      = "CPControlTextDidEndEditingNotification";

var CPControlBlackColor     = [CPColor blackColor];

/*!
    @ingroup appkit
    @class CPControl

    CPControl is an abstract superclass used to implement user interface elements. As a subclass of CPView and CPResponder it has the ability to handle screen drawing and handling user input.
*/
@implementation CPControl : CPView
{
    id                  _value;

    // Target-Action Support
    id                  _target;
    SEL                 _action;
    int                 _sendActionOn;
    BOOL                _sendsActionOnEndEditing @accessors(property=sendsActionOnEndEditing);

    // Mouse Tracking Support
    BOOL                _continuousTracking;
    BOOL                _trackingWasWithinFrame;
    unsigned            _trackingMouseDownFlags;
    CGPoint             _previousTrackingLocation;

    CPString            _toolTip;
    
    CPFormatter         _formatter @accessors(property=formatter);
}

+ (CPDictionary)themeAttributes
{
    return [CPDictionary dictionaryWithObjects:[CPLeftTextAlignment,
                                                CPTopVerticalTextAlignment,
                                                CPLineBreakByClipping,
                                                [CPColor blackColor],
                                                [CPFont systemFontOfSize:12.0],
                                                [CPNull null],
                                                _CGSizeMakeZero(),
                                                CPImageLeft,
                                                CPScaleToFit,
                                                _CGSizeMakeZero(),
                                                _CGSizeMake(-1.0, -1.0)]
                                       forKeys:[@"alignment",
                                                @"vertical-alignment",
                                                @"line-break-mode",
                                                @"text-color",
                                                @"font",
                                                @"text-shadow-color",
                                                @"text-shadow-offset",
                                                @"image-position",
                                                @"image-scaling",
                                                @"min-size",
                                                @"max-size"]];
}

+ (void)initialize
{
    if (self === [CPControl class])
    {
        [self exposeBinding:@"value"];
        [self exposeBinding:@"objectValue"];
        [self exposeBinding:@"stringValue"];
        [self exposeBinding:@"integerValue"];
        [self exposeBinding:@"intValue"];
        [self exposeBinding:@"doubleValue"];
        [self exposeBinding:@"floatValue"];

        [self exposeBinding:@"enabled"];
    }
}

- (void)_reverseSetBinding
{
    var theBinding = [CPKeyValueBinding getBinding:CPValueBinding forObject:self];
    [theBinding reverseSetValueFor:@"objectValue"];
}

- (void)_replacementKeyPathForBinding:(CPString)aBinding
{
    if (aBinding === @"value")
        return @"objectValue";

    return [super _replacementKeyPathForBinding:aBinding];
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _sendActionOn = CPLeftMouseUpMask;
        _trackingMouseDownFlags = 0;
    }

    return self;
}

/*!
    Sets the receiver's target action
    @param anAction Sets the action message that gets sent to the target.
*/
- (void)setAction:(SEL)anAction
{
    _action = anAction;
}

/*!
    Returns the receiver's target action
*/
- (SEL)action
{
    return _action;
}

/*!
    Sets the receiver's target. The target receives action messages from the receiver.
    @param aTarget the object that will receive the message specified by action
*/
- (void)setTarget:(id)aTarget
{
    _target = aTarget;
}

/*!
    Returns the receiver's target. The target receives action messages from the receiver.
*/
- (id)target
{
    return _target;
}

/*!
    Causes \c anAction to be sent to \c anObject.
    @param anAction the action to send
    @param anObject the object to which the action will be sent
*/
- (void)sendAction:(SEL)anAction to:(id)anObject
{
    [self _reverseSetBinding];
    [CPApp sendAction:anAction to:anObject from:self];
}

- (int)sendActionOn:(int)mask
{
    var previousMask = _sendActionOn;

    _sendActionOn = mask;

    return previousMask;
}

/*!
    Sets the tooltip for the receiver.
    @param aToolTip the tooltip
*/
/*
-(void)setToolTip:(CPString)aToolTip
{
    if (_toolTip == aToolTip)
        return;

    _toolTip = aToolTip;

#if PLATFORM(DOM)
    _DOMElement.title = aToolTip;
#endif
}
*/
/*!
    Returns the receiver's tooltip
*/
/*
-(CPString)toolTip
{
    return _toolTip;
}
*/

/*!
    Returns whether the control can continuously send its action messages.
*/
- (BOOL)isContinuous
{
    // Some subclasses should redefine this with CPLeftMouseDraggedMask
    return (_sendActionOn & CPPeriodicMask) !== 0;
}

/*!
    Sets whether the cell can continuously send its action messages.
 */
- (void)setContinuous:(BOOL)flag
{
    // Some subclasses should redefine this with CPLeftMouseDraggedMask
    if (flag)
        _sendActionOn |= CPPeriodicMask;
    else
        _sendActionOn &= ~CPPeriodicMask;
}

- (BOOL)tracksMouseOutsideOfFrame
{
    return NO;
}

- (void)trackMouse:(CPEvent)anEvent
{
    var type = [anEvent type],
        currentLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];
        isWithinFrame = [self tracksMouseOutsideOfFrame] || CGRectContainsPoint([self bounds], currentLocation);

    if (type === CPLeftMouseUp)
    {
        [self stopTracking:_previousTrackingLocation at:currentLocation mouseIsUp:YES];

        _trackingMouseDownFlags = 0;
    }

    else
    {
        if (type === CPLeftMouseDown)
        {
            _trackingMouseDownFlags = [anEvent modifierFlags];
            _continuousTracking = [self startTrackingAt:currentLocation];
        }
        else if (type === CPLeftMouseDragged)
        {
            if (isWithinFrame)
            {
                if (!_trackingWasWithinFrame)
                    _continuousTracking = [self startTrackingAt:currentLocation];

                else if (_continuousTracking)
                    _continuousTracking = [self continueTracking:_previousTrackingLocation at:currentLocation];
            }
            else
                [self stopTracking:_previousTrackingLocation at:currentLocation mouseIsUp:NO];
        }

        [CPApp setTarget:self selector:@selector(trackMouse:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
    }

    if ((_sendActionOn & (1 << type)) && isWithinFrame)
        [self sendAction:_action to:_target];

    _trackingWasWithinFrame = isWithinFrame;
    _previousTrackingLocation = currentLocation;
}

- (void)setState:(int)state
{
}

- (int)nextState
{
    return 0;
}

- (void)performClick:(id)sender
{
    if (![self isEnabled])
        return;

    [self highlight:YES];
    [self setState:[self nextState]];
    [self sendAction:[self action] to:[self target]];

    [CPTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(unhighlightButtonTimerDidFinish:) userInfo:nil repeats:NO];
}

- (void)unhighlightButtonTimerDidFinish:(id)sender
{
    [self highlight:NO];
}

- (unsigned)mouseDownFlags
{
    return _trackingMouseDownFlags;
}

- (BOOL)startTrackingAt:(CGPoint)aPoint
{
    [self highlight:YES];

    return (_sendActionOn & CPPeriodicMask) || (_sendActionOn & CPLeftMouseDraggedMask);
}

- (BOOL)continueTracking:(CGPoint)lastPoint at:(CGPoint)aPoint
{
    return (_sendActionOn & CPPeriodicMask) || (_sendActionOn & CPLeftMouseDraggedMask);
}

- (void)stopTracking:(CGPoint)lastPoint at:(CGPoint)aPoint mouseIsUp:(BOOL)mouseIsUp
{
    [self highlight:NO];
}

- (void)mouseDown:(CPEvent)anEvent
{
    if (![self isEnabled])
        return;

    [self trackMouse:anEvent];
}

/*!
    Returns the receiver's object value
*/
- (id)objectValue
{
    return _value;
}

/*!
    Set's the receiver's object value
*/
- (void)setObjectValue:(id)anObject
{
    _value = anObject;

    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

/*!
    Returns the receiver's float value
*/
- (float)floatValue
{
    var floatValue = parseFloat(_value, 10);
    return isNaN(floatValue) ? 0.0 : floatValue;
}

/*!
    Sets the receiver's float value
*/
- (void)setFloatValue:(float)aValue
{
    [self setObjectValue:aValue];
}

/*!
    Returns the receiver's double value
*/
- (double)doubleValue
{
    var doubleValue = parseFloat(_value, 10);
    return isNaN(doubleValue) ? 0.0 : doubleValue;
}

/*!
    Set's the receiver's double value
*/
- (void)setDoubleValue:(double)anObject
{
    [self setObjectValue:anObject];
}

/*!
    Returns the receiver's int value
*/
- (int)intValue
{
    var intValue = parseInt(_value, 10);
    return isNaN(intValue) ? 0.0 : intValue;
}

/*!
    Set's the receiver's int value
*/
- (void)setIntValue:(int)anObject
{
    [self setObjectValue:anObject];
}

/*!
    Returns the receiver's int value
*/
- (int)integerValue
{
    var intValue = parseInt(_value, 10);
    return isNaN(intValue) ? 0.0 : intValue;
}

/*!
    Set's the receiver's int value
*/
- (void)setIntegerValue:(int)anObject
{
    [self setObjectValue:anObject];
}

/*!
    Returns the receiver's string value
*/
- (CPString)stringValue
{
    var objectValue = [self objectValue];
    
    if([self formatter])
        [[self formatter] stringForObjectValue:objectValue];
    else
        return (objectValue === undefined || objectValue === nil) ? "" : String(objectValue);
}

/*!
    Set's the receiver's string value
*/
- (void)setStringValue:(CPString)aString
{
    if([self formatter])
        [self setObjectValue:[[self formatter] objectValueForString:aString]];
    else
        [self setObjectValue:aString];
}

- (void)takeDoubleValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(doubleValue)])
        [self setDoubleValue:[sender doubleValue]];
}


- (void)takeFloatValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(floatValue)])
        [self setFloatValue:[sender floatValue]];
}


- (void)takeIntegerValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(integerValue)])
        [self setIntegerValue:[sender integerValue]];
}


- (void)takeIntValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(intValue)])
        [self setIntValue:[sender intValue]];
}


- (void)takeObjectValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(objectValue)])
        [self setObjectValue:[sender objectValue]];
}

- (void)takeStringValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(stringValue)])
        [self setStringValue:[sender stringValue]];
}

- (void)textDidBeginEditing:(CPNotification)note
{
    //this looks to prevent false propagation of notifications for other objects
    if([note object] != self)
        return;

    [[CPNotificationCenter defaultCenter] postNotificationName:CPControlTextDidBeginEditingNotification object:self userInfo:[CPDictionary dictionaryWithObject:[note object] forKey:"CPFieldEditor"]];
}

- (void)textDidChange:(CPNotification)note
{
    //this looks to prevent false propagation of notifications for other objects
    if([note object] != self)
        return;

    [[CPNotificationCenter defaultCenter] postNotificationName:CPControlTextDidChangeNotification object:self userInfo:[CPDictionary dictionaryWithObject:[note object] forKey:"CPFieldEditor"]];
}

- (void)textDidEndEditing:(CPNotification)note
{
    //this looks to prevent false propagation of notifications for other objects
    if([note object] != self)
        return;

    [self _reverseSetBinding];
    [[CPNotificationCenter defaultCenter] postNotificationName:CPControlTextDidEndEditingNotification object:self userInfo:[CPDictionary dictionaryWithObject:[note object] forKey:"CPFieldEditor"]];
}

#define BRIDGE(UPPERCASE, LOWERCASE, ATTRIBUTENAME) \
/*! Sets the value for ATTRIBUTENAME */\
- (void)set##UPPERCASE:(id)aValue\
{\
[self setValue:aValue forThemeAttribute:ATTRIBUTENAME];\
}\
/*! Returns the current value for ATTRIBUTENAME */\
- (id)LOWERCASE\
{\
return [self valueForThemeAttribute:ATTRIBUTENAME];\
}

BRIDGE(Alignment, alignment, "alignment")
BRIDGE(VerticalAlignment, verticalAlignment, "vertical-alignment")
BRIDGE(LineBreakMode, lineBreakMode, "line-break-mode")
BRIDGE(TextColor, textColor, "text-color")
BRIDGE(Font, font, "font")
BRIDGE(TextShadowColor, textShadowColor, "text-shadow-color")
BRIDGE(TextShadowOffset, textShadowOffset, "text-shadow-offset")
BRIDGE(ImagePosition, imagePosition, "image-position")
BRIDGE(ImageScaling, imageScaling, "image-scaling")

- (void)setEnabled:(BOOL)isEnabled
{
    if (isEnabled)
        [self unsetThemeState:CPThemeStateDisabled];
    else
        [self setThemeState:CPThemeStateDisabled];
}

- (BOOL)isEnabled
{
    return ![self hasThemeState:CPThemeStateDisabled];
}

- (void)highlight:(BOOL)shouldHighlight
{
    [self setHighlighted:shouldHighlight];
}

- (void)setHighlighted:(BOOL)isHighlighted
{
    if (isHighlighted)
        [self setThemeState:CPThemeStateHighlighted];
    else
        [self unsetThemeState:CPThemeStateHighlighted];
}

- (BOOL)isHighlighted
{
    return [self hasThemeState:CPThemeStateHighlighted];
}

@end

var CPControlValueKey           = "CPControlValueKey",
    CPControlControlStateKey    = @"CPControlControlStateKey",
    CPControlIsEnabledKey       = "CPControlIsEnabledKey",

    CPControlTargetKey          = "CPControlTargetKey",
    CPControlActionKey          = "CPControlActionKey",
    CPControlSendActionOnKey    = "CPControlSendActionOnKey",

    CPControlSendsActionOnEndEditingKey = "CPControlSendsActionOnEndEditingKey";

var __Deprecated__CPImageViewImageKey   = @"CPImageViewImageKey";

@implementation CPControl (CPCoding)

/*
    Initializes the control by unarchiving it from a coder.
    @param aCoder the coder from which to unarchive the control
    @return the initialized control
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self setObjectValue:[aCoder decodeObjectForKey:CPControlValueKey]];

        [self setTarget:[aCoder decodeObjectForKey:CPControlTargetKey]];
        [self setAction:[aCoder decodeObjectForKey:CPControlActionKey]];

        [self sendActionOn:[aCoder decodeIntForKey:CPControlSendActionOnKey]];
        [self setSendsActionOnEndEditing:[aCoder decodeBoolForKey:CPControlSendsActionOnEndEditingKey]];
    }

    return self;
}

/*
    Archives the control to the provided coder.
    @param aCoder the coder to which the control will be archived.
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    if (_sendsActionOnEndEditing)
        [aCoder encodeBool:_sendsActionOnEndEditing forKey:CPControlSendsActionOnEndEditingKey];

    if (_value !== nil)
        [aCoder encodeObject:_value forKey:CPControlValueKey];

    if (_target !== nil)
        [aCoder encodeConditionalObject:_target forKey:CPControlTargetKey];

    if (_action !== NULL)
        [aCoder encodeObject:_action forKey:CPControlActionKey];

    [aCoder encodeInt:_sendActionOn forKey:CPControlSendActionOnKey];
}

@end

var _CPControlSizeIdentifiers               = [],
    _CPControlCachedColorWithPatternImages  = {},
    _CPControlCachedThreePartImagePattern   = {};

_CPControlSizeIdentifiers[CPRegularControlSize] = "Regular";
_CPControlSizeIdentifiers[CPSmallControlSize]   = "Small";
_CPControlSizeIdentifiers[CPMiniControlSize]    = "Mini";

function _CPControlIdentifierForControlSize(aControlSize)
{
    return _CPControlSizeIdentifiers[aControlSize];
}

function _CPControlColorWithPatternImage(sizes, aClassName)
{
    var index = 1,
        count = arguments.length,
        identifier = "";

    for (; index < count; ++index)
        identifier += arguments[index];

    var color = _CPControlCachedColorWithPatternImages[identifier];

    if (!color)
    {
        var bundle = [CPBundle bundleForClass:[CPControl class]];

        color = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:aClassName + "/" + identifier + ".png"] size:sizes[identifier]]];

        _CPControlCachedColorWithPatternImages[identifier] = color;
    }

    return color;
}

function _CPControlThreePartImagePattern(isVertical, sizes, aClassName)
{
    var index = 2,
        count = arguments.length,
        identifier = "";

    for (; index < count; ++index)
        identifier += arguments[index];

    var color = _CPControlCachedThreePartImagePattern[identifier];

    if (!color)
    {
        var bundle = [CPBundle bundleForClass:[CPControl class]],
            path = aClassName + "/" + identifier;

        sizes = sizes[identifier];

        color = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
                    [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:path + "0.png"] size:sizes[0]],
                    [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:path + "1.png"] size:sizes[1]],
                    [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:path + "2.png"] size:sizes[2]]
                ] isVertical:isVertical]];

        _CPControlCachedThreePartImagePattern[identifier] = color;
    }

    return color;
}
