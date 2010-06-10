/*
 * CPFormatter.j
 * Foundation
 *
 * Created by Andreas Falk
 * Copyright 2009, Andreas Falk
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

@import <Foundation/CPObject.j>
@import <Foundation/CPAttributedString.j>
@import <Foundation/CPDictionary.j>
@import <Foundation/CPString.j>
@import <Foundation/CPException.j>


CPFormattingFailedException = "CPFormattingFailedException";

/*!
    @class CPFormatter
    @ingroup foundation
    @brief Interface for objects that handle the text representation of other objects
    
    CPFormatter declares an interface for objects that create, interpret and 
    validate the text representation of other objects.
 */
@implementation CPFormatter : CPObject
{
}

/*!
    Should return a styled text representation of anObject. The default
    implementation returns nil to indicate that it doesn't support styled text.
    
    @param anObject The object to get the text representation for
    @param attributes Default attributes to use for the attributed string
    @return The text representation of anObject as an CPAttributedString
 */
- (CPAttributedString)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(CPDictionary)attributes
{
    return nil;
}

/*!
    Should return the text used to edit the object value the formatter
    provides a text representation for. The default implementation just
    calls stringForObjectValue:.
    
    @param The object to get a text representation for
    @return The text representation for anObject used to edit it
 */
- (CPString)editingStringForObjectValue:(id)anObject
{
    return [self stringForObjectValue:anObject];
}

/*!
    Tries to get the object for aString. If it fails you should raise a 
    CPFormatterFailedException. The default implementation raises 
    CPInvalidArgumentException.
    
    @param aString The string to parse
    @throws CPFormattingFailedException If the formatting of aString failed
    @return The object or nil if the conversion was succesful, otherwise nil
*/
- (id)objectValueForString:(CPString)aString
{
    [CPException raise:CPInvalidArgumentException reason:@"-objectValueForString not implemented. You have to implement it in your subclass."];
}

/*!
    Returns a string representation of anObject. Default implementation throws 
    an exception.
    
    @param anObject The objects whose string representation needed
    @return A string representation of anObject
*/
- (CPString)stringForObjectValue:(id)anObject
{
    [CPException raise:CPInvalidArgumentException reason:@"-stringForObjectValue: not implemented. You have to implement it in your subclass."];
}

@end
