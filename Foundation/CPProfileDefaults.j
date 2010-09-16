/*
 * CPProfileDefaults.j
 * Foundation
 *
 * Created by Andreas Falk.
 * Copyright 2010, Andreas Falk.
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


@import "CPObject.j"
@import "CPString.j"
@import "CPArray.j"
@import "CPDictionary.j"
@import "CPData.j"
@import "CPURL.j"
@import "CPKeyedArchiver.j"
@import "CPKeyedUnarchiver.j"


var CPArgumentDomain = @"CPArgumentDomain",
    CPApplicationDomain = @"CPApplicationDomain",
    CPRegistrationDomain = @"CPRegistrationDomain";

var CPProfileDefaultsDidChangeNotification = @"CPProfileDefaultsDidChangeNotification";

var sharedInstance = nil;

@implementation CPProfileDefaults : CPObject
{
    CPString _profile @accessors(readonly,property=profile);
    
    CPArray _defaultsDomains;
    
    CPDictionary _persistentDomainNames;
    CPDictionary _volatileDomainNames;
}

+ (CPProfileDefaults)standardProfileDefaults
{
    if(!sharedInstance)
        sharedInstance = [[CPProfileDefaults alloc] init];
    
    return sharedInstance;
}

+ (void)resetStandardProfileDefaults
{
    if(!sharedInstance)
        return;
    
    [sharedInstance synchronize];
    sharedInstance = nil;
}


- (id)init
{
    return [self initWithProfile:@"standard"];
}

- (id)initWithProfile:(CPString)profilename
{
    self = [super init];
    
    if(self)
    {
        _profile = profilename;
        
        _defaultsDomains = [CPArray array];
        
        _persistentDomainNames = [CPDictionary dictionary];
        _volatileDomainNames = [CPDictionary dictionary];
        
        // Create argument domain
        [_defaultsDomains insertObject:[CPDictionary dictionary] atIndex:0];
        [_volatileDomainNames setObject:0 forKey:CPArgumentDomain];
        
        // @todo load the arguments from #
        
        // Create application domain
        [_defaultsDomains insertObject:[CPDictionary dictionary] atIndex:1];
        [_persistentDomainNames setObject:1 forKey:CPApplicationDomain];
        
        [self _loadPersistentDomainWithName:CPApplicationDomain];
        
        // Create registration domain
        [_defaultsDomains insertObject:[CPDictionary dictionary] atIndex:2];
        [_volatileDomainNames setObject:2 forKey:CPRegistrationDomain];
    }
    
    return self;
}


- (id)objectForKey:(CPString)defaultName
{
    return [[self _firstDomainForDefaultWithName:defaultName] objectForKey:defaultName];
}

- (void)setObject:(id)value forKey:(CPString)defaultName
{
    [[_defaultsDomains objectAtIndex:1] setObject:value forKey:defaultName];
}

- (void)removeObjectForKey:(CPString)defaultName
{
    var domainEnumerator = [_defaultsDomains objectEnumerator],
        domain = nil;
    
    while(domain = [domainEnumerator nextObject])
    {
        [domain removeObjectForKey:defaultName];
    }
}


- (CPDictionary)_firstDomainForDefaultWithName:(CPString)defaultName
{
    var count = [_defaultsDomains count];
    
    for(var i = 0; i < count; i++)
    {
        var domain = [_defaultsDomains objectAtIndex:i];
        
        if([domain objectForKey:defaultName])
            return domain;
    }
    
    return nil;
}


/*
//
// Convenience getters
//
- (CPString)stringForKey:(CPString)defaultName
{
}

- (CPArray)arrayForKey:(CPString)defaultName
{
}

- (CPDictionary)dictionaryForKey:(CPString)defaultName
{
}

- (CPData)dataForKey:(CPString)defaultName
{
}

- (CPArray)stringArrayForKey:(CPString)defaultName
{
}

- (int)integerForKey:(CPString)defaultName
{
}

- (float)floatForKey:(CPString)defaultName
{
}

- (double)doubleForKey:(CPString)defaultName
{
}

- (BOOL)boolForKey:(CPString)defaultName
{
}

- (CPURL)URLForKey:(CPString)defaultName
{
}
*/

/*
//
// Convenience setters
//
- (void)setInteger:(int)value forKey:(CPString)defaultName
{
}

- (void)setFloat:(float)value forKey:(CPString)defaultName
{
}

- (void)setDouble:(double)value forKey:(CPString)defaultName
{
}

- (void)setBool:(BOOL)value forKey:(CPString)defaultName
{
}

- (void)setURL:(CPURL)url forKey:(CPString)defaultName
{
}
*/


- (void)registerDefaults:(CPDictionary)registrationDictionary
{
    [[_defaultsDomains objectAtIndex:[_defaultsDomains count] - 1] addEntriesFromDictionary:registrationDictionary];
}


/*
    Suite preferences are added between the “Current Application” domains and the “Any Application” 
    domains. If you add multiple suite preferences to one application, the order of the suites in 
    the search chain is non-deterministic.
*/
/*
- (void)addSuiteNamed:(CPString)suiteName
{
}

- (void)removeSuiteNamed:(CPString)suiteName
{
}


- (CPDictionary)dictionaryRepresentation
{
}
*/


- (CPArray)volatileDomainNames
{
    return [_volatileDomainNames allKeys];
}

- (CPDictionary)volatileDomainForName:(CPString)domainName
{
    return [_defaultsDomains objectAtIndex:[_volatileDomainNames objectForKey:domainName]];
}

// Should create a new volatile domain if it doesn't exist yet
- (void)setVolatileDomain:(CPDictionary)domain forName:(CPString)domainName
{
}

- (void)removeVolatileDomainForName:(CPString)domainName
{
    [_defaultsDomains removeObjectAtIndex:[_volatileDomainNames objectForKey:domainName]];
    [_volatileDomainNames removeObjectForKey:domainName];
}


- (CPArray)persistentDomainNames
{
    return [_persistentDomainNames allKeys];
}

- (CPDictionary)persistentDomainForName:(CPString)domainName
{
    return [_defaultsDomains objectAtIndex:[_persistentDomainNames objectForKey:domainName]];
}

// Should not create a new domain if it doesn't exist yet. Shouldn't cause
// any errors if it doesn't exist either.
- (void)setPersistentDomain:(CPDictionary)domain forName:(CPString)domainName
{
    var domainIndex = [_persistentDomainNames objectForKey:domainName];
    [_defaultsDomains replaceObjectAtIndex:domainIndex withObject:domain];
}

- (void)removePersistentDomainForName:(CPString)domainName
{
    [_defaultsDomains removeObjectAtIndex:[_persistentDomainNames objectForKey:domainName]];
    [_persistentDomainNames removeObjectForKey:domainName];
}

- (void)_loadPersistentDomainWithName:(CPString)aName
{
    var stringData = localStorage.getItem("defaults." + _profile + "." + aName),
        domain = nil;
    
    // @todo unarchiveObjectWithData goes on down to CFData.prototype.encodedString to unarchive
    // the data and there and error is thrown if the data is empty (fields are null). Should it really be that 
    // way?... Shouldn't it just create an empty dictionary instead?
    
    if(stringData === nil)
        domain = [CPDictionary dictionary];
    else
        domain = [CPKeyedUnarchiver unarchiveObjectWithData:[CPData dataWithRawString:stringData]];
    
    [self setPersistentDomain:domain forName:aName];
}


- (BOOL)synchronize
{
    var keyEnumerator = [_persistentDomainNames keyEnumerator],
        key = nil;
    
    while(key = [keyEnumerator nextObject])
    {
        var data = [CPKeyedArchiver archivedDataWithRootObject:[_defaultsDomains objectAtIndex:[_persistentDomainNames objectForKey:key]]];
        localStorage.setItem("defaults." + _profile + "." + key, [data rawString]);
    }
}


/*
- (BOOL)objectIsForcedForKey:(CPString)key
{
}

- (BOOL)objectIsForcedForKey:(CPString)key inDomain:(CPString)domain
{
}
*/

@end
