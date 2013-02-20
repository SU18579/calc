//
//  GraphViewController.m
//  Calculator
//
//  Created by Kenneth Bambridge on 1/11/13.
//
//

#import "GraphViewController.h"

#import "CalculatorBrain.h"

@interface GraphViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet GraphView *graphView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation GraphViewController
{
    float prevscale;
}
@synthesize toolBar = _toolBar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom Initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
    self.graphView.controller = self;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    self.scrollView.contentSize = self.graphView.bounds.size;
    [self.graphView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(double)getOutput:(double)x
{
    NSNumber *var = [[NSNumber alloc]initWithDouble:x];
    NSDictionary *xValues = [[NSDictionary alloc]initWithObjectsAndKeys:var, @"x", nil];
    return [CalculatorBrain runProgram:self.graph usingVariableValues:xValues];
}

-(NSString *) getFunctionName
{
    return [CalculatorBrain descriptionOfProgram:self.graph];
}

#pragma mark UIScrollViewDelegate

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphView;
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    /*#warning fix this
    if (prevscale > scrollView.zoomScale){
        self.graphView.scale -= 0.1;
    }
    else self.graphView.scale += 0.1;
    prevscale = scrollView.zoomScale;*/
}

#pragma mark SplitViewBarButtonItemPresenter

-(void) handleSplitViewBarButtonItem: (UIBarButtonItem *) splitViewBarButtonItem
{
    NSMutableArray *toolBarItems = [self.toolBar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolBarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolBarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolBar.items = toolBarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

-(void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

-(void) update
{
    [self.graphView setNeedsDisplay];
}


@end
