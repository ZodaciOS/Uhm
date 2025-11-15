#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface HelloOverlay : UIView
@end
@implementation HelloOverlay
@end

static void (*orig_viewDidAppear)(id, SEL, BOOL);

static void replaced_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    orig_viewDidAppear(self, _cmd, animated);
    UIViewController *vc = (UIViewController *)self;
    if ([vc.view viewWithTag:99999] != nil) return;
    CGRect frame = vc.view.bounds;
    HelloOverlay *overlay = [[HelloOverlay alloc] initWithFrame:frame];
    overlay.backgroundColor = [UIColor whiteColor];
    overlay.tag = 99999;
    overlay.userInteractionEnabled = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)];
    label.text = @"Hello";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:40];
    label.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 50);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(frame.size.width/2 - 100, frame.size.height - 150, 200, 50);
    [button setTitle:@"OK" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = 10;
    [button addTarget:overlay action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:label];
    [overlay addSubview:button];
    [vc.view addSubview:overlay];
    [vc.view bringSubviewToFront:overlay];
}

__attribute__((constructor))
static void ctor() {
    Class cls = objc_getClass("UIViewController");
    Method m = class_getInstanceMethod(cls, @selector(viewDidAppear:));
    orig_viewDidAppear = reinterpret_cast<void (*)(id, SEL, BOOL)>(method_getImplementation(m));
    method_setImplementation(m, (IMP)replaced_viewDidAppear);
}
