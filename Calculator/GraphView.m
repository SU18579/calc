//
//  GraphView.m
//  Calculator
//
//  Created by Kenneth Bambridge on 1/11/13.
//
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define DEFAULT_SCALE 20

@interface GraphView()

@end

@implementation GraphView
{
    BOOL defOrigin;
}

@synthesize scale = _scale, origin = _origin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        defOrigin = YES;
    }
    return self;
}

- (void) setScale:(CGFloat)scale
{
    if (scale) {
        _scale = scale;
    }
    [self setNeedsDisplay];
}

-(CGFloat) scale
{
    if (_scale == 0) return _scale = DEFAULT_SCALE;
    return _scale;
}

- (void) setOrigin:(CGPoint)origin
{
    defOrigin = YES;
    _origin = origin;
}

-(void) pinch:(UIPinchGestureRecognizer *)gesture
{
    if ( (gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

-(void) pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newOrigin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        self.origin = newOrigin;
        [gesture setTranslation: CGPointZero inView:self];
        [self setNeedsDisplay];
    }
}

-(void) awakeFromNib
{
    [self setup];
}
-(void) setup
{
    self.contentMode = UIViewContentModeRedraw;
}
#define CENTER_X 160
#define CENTER_Y 240
#define ORIGIN_CONVERSION 320.0

- (void)drawRect:(CGRect)rect
{
    double pointsPerUnit = self.scale;
    CGSize bounds = rect.size;
    CGPoint offset = [(UIScrollView *) self.superview contentOffset];
    CGPoint origin;
    if (!defOrigin) {
        float output = [self.controller getOutput:0];
        int x = 0;
        do {
            double y1 = (!isnan([self.controller getOutput:++x])) ?[self.controller getOutput:x]: 0;
            double y2 = (!isnan([self.controller getOutput:-x])) ?[self.controller getOutput:-x]: 0;
            output = (y1 + y2) / 2;
        } while (output == INFINITY && output != 0);
        NSLog(@"%f", output);
        origin = self.origin = CGPointMake(self.center.x + offset.x, self.center.y + offset.y + output*pointsPerUnit);
    }
    else {
        origin = self.origin;
    }
    //NSUserDefaults *keys = [[NSUserDefaults alloc]initWithUser:[self.controller getFunctionName]];
    [AxesDrawer drawAxesInRect:rect originAtPoint:origin scale:pointsPerUnit ];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    //CGContextMoveToPoint(context, (0 - origin.x), -[self.controller getOutput:x] * pointsPerUnit + origin.y);
    BOOL move = NO;
    NSLog(@"scale: %f", pointsPerUnit);
    NSLog(@"origin: %f %f", origin.x, origin.y);
    for (float x= 0; x < bounds.width; x++) { //make the graph
        double val = (x - origin.x) / pointsPerUnit;
        double y = -[self.controller getOutput:val] * pointsPerUnit + origin.y;
        if ( abs(y) <= INFINITY ){
            CGPoint point = CGPointMake(x, y);
            if (CGRectContainsPoint(rect, point)) {
                if (!move) {
                    CGContextMoveToPoint(context, point.x, point.y);
                    move = YES;
                }
                else CGContextAddLineToPoint(context, point.x, point.y);
            }

        }
        else {
            move = NO;
        }
    }
    [[UIColor redColor] setStroke];
    CGContextStrokePath(context);
   
    
    
}



@end
