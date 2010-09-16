
@import <Foundation/CPObject.j>
@import <Foundation/CPDictionary.j>
@import <Foundation/CPError.j>
@import <Foundation/CPURL.j>


@implementation CPErrorTest : OJTestCase
{
    CPError error;
    CPDictionary userInfo;
    
    CPObject recoveryAttempter;
}

- (void)setUp
{
    userInfo = [CPDictionary dictionary];
    
    [userInfo setObject:[CPError new] forKey:CPUnderlyingErrorKey];
    
    [userInfo setObject:"lorem" forKey:CPLocalizedDescriptionKey];
    [userInfo setObject:"ipsum" forKey:CPLocalizedFailureReasonErrorKey];
    [userInfo setObject:"dolor" forKey:CPLocalizedRecoverySuggestionErrorKey];
    [userInfo setObject:["sit", "amet"] forKey:CPLocalizedRecoveryOptionsErrorKey];
    
    recoveryAttempter = [CPObject new];
    [userInfo setObject:recoveryAttempter forKey:CPRecoveryAttempterErrorKey];
    
    [userInfo setObject:[CPURL URLWithString:"http://cappuccino.org/"] forKey:CPURLErrorKey];
    [userInfo setObject:"/tmp/cperror.txt" forKey:CPFilePathErrorKey];
    
    
    error = [[CPError alloc] initWithCode:1 userInfo:userInfo];
}

- (void)testErrorConstructed
{
    [self assertNotNull:error];
}

- (void)testDescription
{
    [self assert:"lorem" equals:[error localizedDescription]];
}

- (void)testRecoveryOptions
{
    [self assert:["sit", "amet"] equals:[error localizedRecoveryOptions]];
}

- (void)testRecoverySuggestion
{
    [self assert:"dolor" equals:[error localizedRecoverySuggestion]];
}

- (void)testFailureReason
{
    [self assert:"ipsum" equals:[error localizedFailureReason]];
}

- (void)testRecoveryAttempter
{
    [self assert:recoveryAttempter same:[error recoveryAttempter]];
}

- (void)testCode
{
    [self assert:1 equals:[error code]];
}

- (void)testUserInfo
{
    [self assert:userInfo equals:[error userInfo]];
}

@end
