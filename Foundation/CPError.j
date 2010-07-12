
@import <Foundation/CPObject.j>
@import <Foundation/CPString.j>
@import <Foundation/CPDictionary.j>


CPUnderlyingErrorKey                    = "CPUnderlyingErrorKey";

CPLocalizedDescriptionKey               = "CPLocalizedDescriptionKey";
CPLocalizedFailureReasonErrorKey        = "CPLocalizedFailureReasonErrorKey";
CPLocalizedRecoverySuggestionErrorKey   = "CPLocalizedRecoverySuggestionErrorKey";
CPLocalizedRecoveryOptionsErrorKey      = "CPLocalizedRecoveryOptionsErrorKey";
CPRecoveryAttempterErrorKey             = "CPRecoveryAttempterErrorKey";

CPURLErrorKey                           = "CPURLErrorKey";
CPFilePathErrorKey                      = "CPFilePathErrorKey";

@implementation CPError : CPObject
{
    int             _code @accessors(readonly,property=code);
    CPDictionary    _userInfo @accessors(readonly,property=userInfo);
}

+ (id)errorWithCode:(int)code userInfo:(CPDictionary)dictionary
{
    return [[self alloc] initWithCode:code userInfo:dictionary];
}

- (id)initWithCode:(int)aCode userInfo:(CPDictionary)aDictionary
{
    self = [super init];
    
    if(self)
    {
        _code = aCode;
        _userInfo = aDictionary;
    }
    
    return self;
}

- (CPString)localizedDescription
{
    return [_userInfo objectForKey:CPLocalizedDescriptionKey];
}

/*!
    Returns an array with titles for buttons in an alert panel.
*/
- (CPArray)localizedRecoveryOptions
{
    return [_userInfo objectForKey:CPLocalizedRecoveryOptionsErrorKey];
}

/*!
    Returns a string giving a suggestion on what to do about the error.
*/
- (CPString)localizedRecoverySuggestion
{
    return [_userInfo objectForKey:CPLocalizedRecoverySuggestionErrorKey];
}

/*!
    Returns the reason for the error occuring.
*/
- (CPString)localizedFailureReason
{
    return [_userInfo objectForKey:CPLocalizedFailureReasonErrorKey];
}

/*!
    Returns an object responding to these messages:
    
        - (BOOL)attemptRecoveryFromError:(CPError)error optionIndex:(int)recoveryOptionIndex
        - (void)attemptRecoveryFromError:(CPError)error optionIndex:(int)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void)contextInfo
*/
- (id)recoveryAttempter
{
    return [_userInfo objectForKey:CPRecoveryAttempterErrorKey];
}

@end
