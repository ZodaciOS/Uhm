#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface OverlayViewController : UIViewController
@end

@implementation OverlayViewController {
    UIView *overlay;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (overlay) return;

    CGRect screen = [UIScreen mainScreen].bounds;

    overlay = [[UIView alloc] initWithFrame:screen];
    overlay.backgroundColor = [UIColor whiteColor];
    overlay.userInteractionEnabled = YES;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screen.size.width, 100)];
    label.text = @"Hello";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:40];
    label.center = CGPointMake(screen.size.width/2, screen.size.height/2 - 40);

    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    okBtn.frame = CGRectMake(0, 0, 200, 50);
    okBtn.center = CGPointMake(screen.size.width/2, screen.size.height - 120);
    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightSemibold];
    [okBtn addTarget:self action:@selector(hideOverlay) forControlEvents:UIControlEventTouchUpInside];

    [overlay addSubview:label];
    [overlay addSubview:okBtn];

    [self.view addSubview:overlay];
}

- (void)hideOverlay {
    [overlay removeFromSuperview];
    overlay = nil;
}

@end


static void (*orig_viewDidAppear)(id, SEL, BOOL);

static void replaced_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    orig_viewDidAppear(self, _cmd, animated);

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        OverlayViewController *overlay = [OverlayViewController new];
        [self presentViewController:overlay animated:NO completion:nil];
    });
}

__attribute__((constructor))
static void init_dylib() {
    Class vc = NSClassFromString(@"UIViewController");
    Method m = class_getInstanceMethod(vc, @selector(viewDidAppear:));
    orig_viewDidAppear = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)replaced_viewDidAppear);
}
