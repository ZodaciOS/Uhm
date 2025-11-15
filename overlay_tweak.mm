#import <UIKit/UIKit.h>

static UIView *dot;
static UIView *menu;
static BOOL isDragging = NO;
static CGPoint dragOffset;

@interface OverlayWindow : UIWindow
@end

@implementation OverlayWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (menu && !menu.hidden) {
        if (!CGRectContainsPoint(menu.frame, point) && !CGRectContainsPoint(dot.frame, point)) {
            menu.hidden = YES;
        }
    }
    return [super hitTest:point withEvent:event];
}
@end

@interface OverlayController : UIViewController
@end

@implementation OverlayController

- (void)viewDidLoad {
    [super viewDidLoad];

    dot = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    dot.backgroundColor = [UIColor redColor];
    dot.layer.cornerRadius = 30;
    dot.userInteractionEnabled = YES;
    [self.view addSubview:dot];

    UITapGestureRecognizer *tapDot = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    [dot addGestureRecognizer:tapDot];

    UIPanGestureRecognizer *dragDot = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragDot:)];
    [dot addGestureRecognizer:dragDot];

    menu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 60)];
    menu.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    menu.layer.cornerRadius = 10;
    menu.hidden = YES;
    menu.userInteractionEnabled = YES;
    [self.view addSubview:menu];

    UIButton *yes = [UIButton buttonWithType:UIButtonTypeSystem];
    yes.frame = CGRectMake(10, 10, 40, 40);
    [yes setTitle:@"Yes" forState:UIControlStateNormal];
    [menu addSubview:yes];

    UIButton *no = [UIButton buttonWithType:UIButtonTypeSystem];
    no.frame = CGRectMake(70, 10, 40, 40);
    [no setTitle:@"No" forState:UIControlStateNormal];
    [menu addSubview:no];

    UIPanGestureRecognizer *dragMenu = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
    [menu addGestureRecognizer:dragMenu];
}

- (void)openMenu {
    if (isDragging) return;
    menu.hidden = NO;
    menu.center = CGPointMake(dot.center.x + 90, dot.center.y);
}

- (void)dragDot:(UIPanGestureRecognizer *)g {
    CGPoint p = [g locationInView:self.view];
    if (g.state == UIGestureRecognizerStateBegan) {
        isDragging = YES;
        dragOffset = CGPointMake(p.x - dot.center.x, p.y - dot.center.y);
    }
    if (g.state == UIGestureRecognizerStateChanged) {
        dot.center = CGPointMake(p.x - dragOffset.x, p.y - dragOffset.y);
    }
    if (g.state == UIGestureRecognizerStateEnded) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100000000), dispatch_get_main_queue(), ^{
            isDragging = NO;
        });
    }
}

- (void)dragMenu:(UIPanGestureRecognizer *)g {
    CGPoint p = [g translationInView:self.view];
    menu.center = CGPointMake(menu.center.x + p.x, menu.center.y + p.y);
    [g setTranslation:CGPointZero inView:self.view];
}

@end

static UIWindow *overlayWindow;

__attribute__((constructor))
static void startOverlay() {
    dispatch_async(dispatch_get_main_queue(), ^{
        overlayWindow = [[OverlayWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = [OverlayController new];
        [overlayWindow makeKeyAndVisible];
    });
}
