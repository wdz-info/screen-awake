#import <Foundation/Foundation.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

@interface SleepHold : NSObject
@property(nonatomic, readonly) BOOL active;
@property(nonatomic, readonly) NSDate *deadline;
- (IOReturn)startWithSeconds:(NSTimeInterval)seconds;
- (void)stop;
@end
