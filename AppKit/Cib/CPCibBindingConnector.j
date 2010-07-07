
@import <Foundation/CPString.j>
@import <Foundation/CPCoder.j>

@import "CPCibConnector.j"


var CPCibBindingConnectorBindingKey     = "CPCibBindingConnectorBindingKey",
    CPCibBindingConnectorKeyPathKey     = "CPCibBindingConnectorKeyPathKey";

@implementation CPCibBindingConnector : CPCibConnector
{
    CPString _binding @accessors(property=binding);
    CPString _keyPath @accessors(property=keyPath);
}

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];
    
    if(self)
    {
        _binding = [aCoder decodeObjectForKey:CPCibBindingConnectorBindingKey];
        _keyPath = [aCoder decodeObjectForKey:CPCibBindingConnectorKeyPathKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_binding forKey:CPCibBindingConnectorBindingKey];
    [aCoder encodeObject:_keyPath forKey:CPCibBindingConnectorKeyPathKey];
}

- (void)establishConnection
{
    [[self source] bind:[self binding] toObject:[self destination] withKeyPath:[self keyPath] options:nil];
}

@end
