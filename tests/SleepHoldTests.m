#import "SleepHold.h"
#include <assert.h>
#include <unistd.h>

static NSArray *ownAssertions(void) {
    CFDictionaryRef raw = NULL;
    IOReturn result = IOPMCopyAssertionsByProcess(&raw);
    assert(result == kIOReturnSuccess && raw != NULL);
    NSDictionary *byProcess = CFBridgingRelease(raw);
    return byProcess[@(getpid())] ?: @[];
}

int main(void) {
    @autoreleasepool {
        SleepHold *hold = [SleepHold new];
        assert(!hold.active);
        assert([hold startWithSeconds:5] == kIOReturnSuccess);
        assert(hold.active);
        NSArray *assertions = ownAssertions();
        assert(assertions.count == 1);
        NSString *type = assertions[0][(__bridge NSString *)kIOPMAssertionTypeKey];
        assert([type isEqualToString:(__bridge NSString *)kIOPMAssertPreventUserIdleSystemSleep]);
        puts("PASS: system idle sleep prevented; display sleep allowed");

        assert([hold startWithSeconds:0] == kIOReturnSuccess);
        assert(hold.active && hold.deadline == nil);
        assert(ownAssertions().count == 1);
        [hold stop];
        assert(!hold.active && ownAssertions().count == 0);
        [hold stop];
        puts("PASS: switching sessions keeps one assertion; stop releases it");

        assert([hold startWithSeconds:1] == kIOReturnSuccess);
        [NSThread sleepForTimeInterval:2.5];
        assert(!hold.active && ownAssertions().count == 0);
        [hold stop];
        puts("PASS: timed assertion released by macOS without an app timer");

        @autoreleasepool {
            SleepHold *disposable = [SleepHold new];
            assert([disposable startWithSeconds:0] == kIOReturnSuccess);
            assert(ownAssertions().count == 1);
            disposable = nil;
        }
        assert(ownAssertions().count == 0);
        puts("PASS: destruction releases the assertion");
    }
    return 0;
}
