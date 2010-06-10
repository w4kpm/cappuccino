
@import <Foundation/CPFormatter.j>


@implementation CPFormatterTest : OJTestCase
{
    CPFormatter _formatter;
}

- (void)setUp
{
    _formatter = [[CPFormatter alloc] init];
}

- (void)testAttributedStringForObjectValueReturnsNil
{
    [self assert:[_formatter attributedStringForObjectValue:@"testString" withDefaultAttributes:nil] equals:nil];
}

- (void)testEditingStringForObjectValue
{
    [self assertThrows:function() {[_formatter editingStringForObjectValue:@"testObject"]}];
}

- (void)testObjectValueForString
{
    [self assertThrows:function() {[_formatter objectValueForString:@"testString"]}];
}

- (void)testStringForObjectValue
{
    [self assertThrows:function() {[_formatter stringForObjectValue:@"testObject"]}];
}

@end