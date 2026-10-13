#import "SleepHold.h"

@implementation SleepHold {
    IOPMAssertionID _assertionID;
    BOOL _hasAssertion;
    NSDate *_deadline;
}
- (BOOL)active {
    if (!_hasAssertion) return NO;
    CFDictionaryRef properties = IOPMAssertionCopyProperties(_assertionID);
    if (!properties) return NO;
    CFRelease(properties);
    return YES;
}
- (NSDate *)deadline { return _deadline; }
- (IOReturn)startWithSeconds:(NSTimeInterval)seconds {
    IOPMAssertionID newID;
    IOReturn result = IOPMAssertionCreateWithDescription(
        kIOPMAssertPreventUserIdleSystemSleep,
        CFSTR("ScreenAwake: keep system awake while display may sleep"),
        NULL, NULL, NULL, seconds, kIOPMAssertionTimeoutActionRelease, &newID);
    if (result != kIOReturnSuccess) return result;
    [self stop];
    _assertionID = newID;
    _hasAssertion = YES;
    _deadline = seconds > 0 ? [NSDate dateWithTimeIntervalSinceNow:seconds] : nil;
    return result;
}
- (void)stop {
    if (self.active) IOPMAssertionRelease(_assertionID);
    _hasAssertion = NO;
    _deadline = nil;
}
- (void)dealloc { [self stop]; }
@end
