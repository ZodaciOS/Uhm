#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface DragCircle : UIView
@end

@implementation DragCircle {
    CGPoint offset;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = frame.size.width/2;
    self.userInteractionEnabled = YES;
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];
    offset = p;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self.superview];
    self.center = CGPointMake(p.x - offset.x + self.bounds.size.width/2,
                              p.y - offset.y + self.bounds.size.height/2);
}
@end

static void (*orig_viewDidAppear)(id, SEL, BOOL);

static void replaced_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    orig_viewDidAppear(self, _cmd, animated);
    UIViewController *vc = (UIViewController *)self;
    if ([vc.view viewWithTag:77777] != nil) return;
    DragCircle *circle = [[DragCircle alloc] initWithFrame:CGRectMake(100, 200, 80, 80)];
    circle.tag = 77777;
    [vc.view addSubview:circle];
    [vc.view bringSubviewToFront:circle];
}

__attribute__((constructor))
static void ctor() {
    Class cls = objc_getClass("UIViewController");
    Method m = class_getInstanceMethod(cls, @selector(viewDidAppear:));
    orig_viewDidAppear = reinterpret_cast<void (*)(id, SEL, BOOL)>(method_getImplementation(m));
    method_setImplementation(m, (IMP)replaced_viewDidAppear);
}
