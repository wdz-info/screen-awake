#import <AppKit/AppKit.h>
#import "SleepHold.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property(nonatomic) SleepHold *hold;
@property(nonatomic) NSStatusItem *statusItem;
@property(nonatomic) NSMenuItem *statusLine;
@property(nonatomic) NSMenuItem *stopItem;
@property(nonatomic) NSTimer *timer;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.hold = [SleepHold new];
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    NSMenu *menu = [NSMenu new];
    menu.autoenablesItems = NO;
    menu.delegate = self;
    self.statusLine = [[NSMenuItem alloc] initWithTitle:@"保活未开启" action:NULL keyEquivalent:@""];
    self.statusLine.enabled = NO;
    [menu addItem:self.statusLine];
    [menu addItem:NSMenuItem.separatorItem];
    NSArray *titles = @[@"开启 30 分钟", @"开启 1 小时", @"开启 2 小时", @"开启 4 小时", @"持续开启，直到手动关闭"];
    NSArray *minutes = @[@30, @60, @120, @240, @0];
    for (NSUInteger i = 0; i < titles.count; i++) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[i] action:@selector(startHold:) keyEquivalent:@""];
        item.target = self;
        item.tag = [minutes[i] integerValue];
        [menu addItem:item];
    }
    self.stopItem = [[NSMenuItem alloc] initWithTitle:@"关闭保活，恢复自动睡眠" action:@selector(stopHold:) keyEquivalent:@""];
    self.stopItem.target = self;
    [menu addItem:self.stopItem];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *help = [[NSMenuItem alloc] initWithTitle:@"使用说明…" action:@selector(showHelp:) keyEquivalent:@""];
    help.target = self;
    [menu addItem:help];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"退出" action:@selector(quitApp:) keyEquivalent:@"q"];
    quit.target = self;
    [menu addItem:quit];
    self.statusItem.menu = menu;
    [self refresh];
    __weak AppDelegate *weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:10 repeats:YES block:^(NSTimer *timer) { [weakSelf refresh]; }];
    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)menuWillOpen:(NSMenu *)menu { [self refresh]; }
- (void)startHold:(NSMenuItem *)sender {
    IOReturn result = [self.hold startWithSeconds:sender.tag * 60.0];
    if (result != kIOReturnSuccess) {
        [NSApp activateIgnoringOtherApps:YES];
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"无法开启保活";
        alert.informativeText = [NSString stringWithFormat:@"macOS 返回错误：%d。请重新打开工具后再试。", result];
        [alert runModal];
    }
    [self refresh];
}
- (void)stopHold:(id)sender { [self.hold stop]; [self refresh]; }
- (void)refresh {
    BOOL active = self.hold.active;
    self.statusItem.button.title = active ? @"保活 ●" : @"保活 ○";
    self.stopItem.enabled = active;
    if (active && self.hold.deadline) {
        NSInteger minutes = MAX(1, (NSInteger)ceil(self.hold.deadline.timeIntervalSinceNow / 60));
        self.statusLine.title = [NSString stringWithFormat:@"已开启 · 剩余约 %ld 分钟", (long)minutes];
    } else {
        self.statusLine.title = active ? @"已开启 · 直到手动关闭" : @"保活未开启";
    }
    self.statusItem.button.toolTip = [self.statusLine.title stringByAppendingString:@"；屏幕可以正常熄灭"];
}
- (void)showHelp:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"熄屏保活";
    alert.informativeText = @"点击菜单栏的“保活 ○”，选择开启时长。开启后显示“保活 ●”。\n\n屏幕仍可自动熄灭或锁定，电脑继续运行，适合下载和后台任务。到期、关闭保活或退出后恢复正常睡眠。\n\n合盖、手动睡眠和低电量仍可能让电脑睡眠；本工具不能解决 Wi-Fi 或 VPN 自身的断线问题。\n\n电池供电时也有效，但会增加耗电。建议选定时开启，用完关闭。重新打开工具默认关闭。";
    [alert addButtonWithTitle:@"知道了"];
    [alert runModal];
}
- (void)quitApp:(id)sender { [NSApp terminate:nil]; }
- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.timer invalidate];
    [self.hold stop];
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
