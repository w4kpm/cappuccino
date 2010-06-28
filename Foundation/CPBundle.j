/*
 * CPBundle.j
 * Foundation
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

@import "CPDictionary.j"
@import "CPObject.j"
@import "CPNotification.j"
@import "CPNotificationCenter.j"
@import "CPError.j"


CPBundleLoadError           = 1;

CPBundleDidLoadNotification = "CPBundleDidLoadNotification";

/*!
    @class CPBundle
    @ingroup foundation
    @brief Groups information about an application's code & resources.
*/

var CPBundlesForURLStrings = { };

@implementation CPBundle : CPObject
{
    CFBundle    _bundle;
    
    id          _delegate;
    
    Function    _didFinishHandler;
    Function    _errorHandler;
}

+ (CPBundle)bundleWithURL:(CPURL)aURL
{
    return [[self alloc] initWithURL:aURL];
}

+ (CPBundle)bundleWithPath:(CPString)aPath
{
    return [self bundleWithURL:aPath];
}

+ (CPBundle)bundleForClass:(Class)aClass
{
    return [self bundleWithURL:CFBundle.bundleForClass(aClass).bundleURL()];
}

+ (CPBundle)mainBundle
{
    return [CPBundle bundleWithPath:CFBundle.mainBundle().bundleURL()];
}

- (id)initWithURL:(CPURL)aURL
{
    aURL = new CFURL(aURL);

    var URLString = aURL.absoluteString(),
        existingBundle = CPBundlesForURLStrings[URLString];

    if (existingBundle)
        return existingBundle;

    self = [super init];

    if (self)
    {
        _bundle = new CFBundle(aURL);
        CPBundlesForURLStrings[URLString] = self;
    }

    return self;
}

- (id)initWithPath:(CPString)aPath
{
    return [self initWithURL:aPath];
}

- (Class)classNamed:(CPString)aString
{
    // ???
}

- (CPURL)bundleURL
{
    return _bundle.bundleURL();
}

- (CPString)bundlePath
{
    return [[self bundleURL] path];
}

- (CPString)resourcePath
{
    return [[self resourceURL] path];
}

- (CPURL)resourceURL
{
    return _bundle.resourcesDirectoryURL();
}

- (Class)principalClass
{
    var className = [self objectForInfoDictionaryKey:@"CPPrincipalClass"];

    //[self load];

    return className ? CPClassFromString(className) : Nil;
}

- (CPString)bundleIdentifier
{
    return [self objectForInfoDictionaryKey:@"CPBundleIdentifier"];
}

- (BOOL)isLoaded
{
    return _bundle.isLoaded();
}

- (CPString)pathForResource:(CPString)aFilename
{
    return _bundle.pathForResource(aFilename);
}

- (CPDictionary)infoDictionary
{
    return _bundle.infoDictionary();
}

- (id)objectForInfoDictionaryKey:(CPString)aKey
{
    return _bundle.valueForInfoDictionaryKey(aKey);
}

- (void)_loadAsync
{
    _bundle.addEventListener("load", function()
    {
        // userInfo should contain a list of all classes loaded from this bundle. When writing this there
        // seems to be no efficient way to get it though.
        [[CPNotificationCenter defaultCenter] postNotificationName:CPBundleDidLoadNotification object:self userInfo:nil];
        
        if(_didFinishHandler)
            _didFinishHandler(self);
        else if(_delegate && [_delegate respondsToSelector:@selector(bundleDidFinishLoading:)])
            [_delegate bundleDidFinishLoading:self];
    });

    _bundle.addEventListener("error", function(info)
    {
        var errorInfo = [CPDictionary dictionary];
        [errorInfo setObject:info["error"] forKey:CPLocalizedDescriptionKey];
        [errorInfo setObject:info["bundle"].bundleURL() forKey:CPURLErrorKey];
        
        var error = [CPError errorWithCode:CPBundleLoadError userInfo:errorInfo];
        
        if(_errorHandler)
            _errorHandler(self, error);
        else if(_delegate && [_delegate respondsToSelector:@selector(bundle:didFailWithError:)])
            [_delegate bundle:self didFailWithError:error];
    });

    _bundle.load(YES);
}

- (void)loadWithDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    [self _loadAsync];
}

- (void)loadWithCompletionHandler:(Function)aCompletionHandler andErrorHandler:(Function)anErrorHandler
{
    _didFinishHandler = aCompletionHandler;
    _errorHandler = anErrorHandler;
    
    [self _loadAsync];
}

- (CPArray)staticResourceURLs
{
    var staticResourceURLs = [],
        staticResources = _bundle.staticResources(),
        index = 0,
        count = [staticResources count];

    for (; index < count; ++index)
        [staticResourceURLs addObject:staticResources[index].URL()];

    return staticResourceURLs;
}

- (CPArray)environments
{
    return _bundle.environments();
}

- (CPString)mostEligibleEnvironment
{
    return _bundle.mostEligibleEnvironment();
}

- (CPString)description
{
    return [super description] + "(" + [self bundlePath] + ")";
}

@end
