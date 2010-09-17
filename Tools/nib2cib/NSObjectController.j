/*
 * NSObjectController.j
 * nib2cib
 *
 * Created by Andreas Falk.
 * Copyright 2010, Andreas Falk
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

@import <AppKit/CPObjectController.j>


@implementation CPObjectController (NSCoding)

- (id)NS_initWithCoder:(CPCoder)aCoder
{

    self = [super init];
    
    if (self)
    {
        CPLog.info("decoding" + [self className]);
        var objectClassName = [aCoder decodeObjectForKey:"NSObjectClassName"],
            objectClass = CPClassFromString(objectClassName);

	if (objectClassName === null)
	  objectClassName = [self className];
	
        // TODO: Ugly, objectClassName should be objectClass but since we don't load any 
        // user classes the class lookup will fail and always be CPMutableDictionary.
        // Should find some nice way to load user classes.
        _objectClass = objectClassName ? objectClassName : CPMutableDictionary;
        
        if(_objectClass == CPMutableDictionary)
            CPLog.warn("objectClass for " + self + " decoded as " + CPMutableDictionary);
        
        _isEditable = [aCoder decodeBoolForKey:"NSEditable"];
        _automaticallyPreparesContent = [aCoder decodeBoolForKey:"NSAutomaticallyPreparesContent"] || NO;
    }
    
    return self;
}

@end

@implementation NSObjectController : CPObjectController
{
}

- (id)initWithCoder:(CPCoder)aCoder
{
    return [self NS_initWithCoder:aCoder];
}

- (Class)classForKeyedArchiver
{
    return [CPObjectController class];
}

@end
