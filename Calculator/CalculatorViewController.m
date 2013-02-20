//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Kenneth Bambridge on 1/3/13.
//
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL inMiddleOfEnteringNumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *varNames;
@property (nonatomic) BOOL varUsed;
@property (nonatomic) BOOL decUsed;
@end

@implementation CalculatorViewController
{
    NSMutableDictionary *buttons; //A dictionary to store all the buttons, 0-9 are digits, 10-13 are ops, 14-15 sin/cos
    //16 enter, 17 graph
    NSArray *buttonnamesL;
    NSArray *buttonnames;
    CGRect portraitlocs[sizeof(CGRect)*19];
    CGRect landscapelocs[sizeof(CGRect)*19];
}

@synthesize inMiddleOfEnteringNumber = _inMiddleOfEnteringNumber;
@synthesize display = _display;
@synthesize brain = _brain;
@synthesize log = _log;
@synthesize varNames = _varNames;

#define makeButton(title) UIButton *title = [UIButton buttonWithType:UIButtonTypeRoundedRect]

-(void) setTarget: (UIButton *) but
{
    NSString *title = but.currentTitle;
    if ([title isEqualToString:@"+"] || [title isEqualToString:@"-"] || [title isEqualToString:@"*"] || [title isEqualToString:@"/"] || [title isEqualToString:@"π"]) {
        [but addTarget:self action:@selector(operationPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"x"])
    {
        [but addTarget:self action:@selector(varPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"Enter"])
    {
        [but addTarget:self action:@selector(enterPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"sin"] || [title isEqualToString:@"cos"])
    {
        [but addTarget:self action:@selector(sinPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"."]) {
        [but addTarget:self  action:@selector(enterDecimal:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"sqrt"])
    {
        [but addTarget:self action:@selector(sqrtPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title isEqualToString:@"Graph"])
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [but addTarget: self action:@selector(graph2) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [but addTarget:self action:@selector(graph) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if ([title isEqualToString:@"Clear"])
    {
        [but addTarget:self action:@selector(clearPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([title intValue] < 10){
        [but addTarget:self action:@selector(digitPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
#define LEFT_BUTTON_X 20
#define Y_INCREMENT 55
#define X_INCREMENT 72
#define X_INCREMENTH 75
#define INITIAL_Y 80
#define BUTTON_W 65
#define BUTTON_WL 70
#define BUTTON_H 45

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    self.title = @"Calculator";
    self.splitViewController.presentsWithGesture = NO;
    
    buttons = [[NSMutableDictionary alloc]init];
    buttonnames = [NSArray arrayWithObjects: @"1", @"2", @"3", @"+", @"4", @"5", @"6",@"-", @"7", @"8", @"9", @"*", @".", @"0", @"π", @"/", @"sin", @"cos",@"sqrt", @"x", @"Undo" ,@"Enter", @"Clear",@"Graph", nil];
    buttonnamesL = [NSArray arrayWithObjects: @"1", @"2", @"3",  @"+", @"sin",@"Undo" ,@"4",  @"5", @"6", @"-", @"cos", @"Enter", @"7", @"8", @"9", @"*", @"sqrt", @"Clear",@".", @"0", @"π", @"/", @"x", @"Graph", nil];
    
    portraitlocs[0] = CGRectMake(LEFT_BUTTON_X, INITIAL_Y, BUTTON_W, BUTTON_H);
    for (int i = 0; i < [buttonnames count]; i++)
         portraitlocs[i+1] = ((portraitlocs[i].origin.x + X_INCREMENT) < 280) ? CGRectMake(portraitlocs[i].origin.x + X_INCREMENT, portraitlocs[i].origin.y, BUTTON_W, BUTTON_H) : CGRectMake(LEFT_BUTTON_X, portraitlocs[i].origin.y + Y_INCREMENT, BUTTON_W, BUTTON_H);
    
    landscapelocs[0] = CGRectMake(LEFT_BUTTON_X, INITIAL_Y, BUTTON_WL, BUTTON_H);
    for (int i = 0; i < [buttonnames count]; i++)
        landscapelocs[i+1] = ((landscapelocs[i].origin.x + X_INCREMENTH) < 450) ? CGRectMake(landscapelocs[i].origin.x + X_INCREMENTH, landscapelocs[i].origin.y, BUTTON_WL, BUTTON_H) : CGRectMake(LEFT_BUTTON_X, landscapelocs[i].origin.y + Y_INCREMENT, BUTTON_WL, BUTTON_H);
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && (![UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) [self loadButtons:buttonnamesL toLocs: landscapelocs];
    else [self loadButtons:buttonnames toLocs: portraitlocs];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden  = YES;
//    [self.view setNeedsDisplay];
}

-(CalculatorBrain *) brain {
    if (!_brain) {
        return _brain = [[CalculatorBrain alloc]init];
    }
    return _brain;
}
-(NSDictionary *) varNames
{
    if (!_varNames) {
        NSArray *vars = [[NSArray alloc] initWithObjects:@"x", @"y", @"z", @"foo", nil];
        NSArray *values = [[NSArray alloc] initWithObjects: [NSNumber numberWithDouble:3], [NSNumber numberWithDouble:4], [NSNumber numberWithDouble:5], [NSNumber numberWithDouble:24.23], nil];
        return _varNames = [[NSDictionary alloc]initWithObjects:values forKeys:vars];
    }
    return _varNames;
}
- (IBAction)digitPressed:(UIButton *)sender {
    if (self.inMiddleOfEnteringNumber) {
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    }
    else {
        self.display.text = sender.currentTitle;
        self.inMiddleOfEnteringNumber = YES;
    }
}
- (IBAction)enterDecimal:(UIButton *)sender {
    if (!self.inMiddleOfEnteringNumber) {
        self.display.text = @"0.";
        self.inMiddleOfEnteringNumber = YES;
        self.decUsed = YES;
        return;
    }
    if (!self.decUsed) {
        self.decUsed = YES;
        double value = [self.display.text doubleValue];
        int intvalue = (int) value;
        if (value == 0 || value/intvalue == 1.0000) {
            self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
        }
    }
    
}
- (IBAction)enterPressed {

    double value = [self.display.text doubleValue];

    if (self.inMiddleOfEnteringNumber) {
        [self.brain pushOperand: value];
        self.log.text = [self.brain description];
    }
    self.inMiddleOfEnteringNumber = NO;
    self.decUsed = NO;
    
    
}
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.inMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    [self updateDisplay:sender];
    
}
- (IBAction)sinPressed:(UIButton *)sender {
    if (self.inMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    [self updateDisplay:sender];
}
- (IBAction)sqrtPressed:(UIButton *)sender {
    if (self.inMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    [self updateDisplay:sender];
}

- (IBAction)piPressed:(UIButton *)sender {
    if (self.inMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    [self updateDisplay:sender];
}

- (IBAction)clearPressed:(UIButton *)sender {
    self.display.text = [NSString string];
    self.log.text = [NSString string];
    self.varUsed = NO;
    self.decUsed =NO;
    self.inMiddleOfEnteringNumber = NO;
    [self.brain clear];
}
- (IBAction)varPressed:(UIButton *)sender {
    self.varUsed = YES;
    if (self.inMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    [self updateDisplay:sender];
}
-(void) updateDisplay: (UIButton *) sender{
    if (!self.varUsed) {
        self.display.text = [NSString stringWithFormat:@"%lf",[self.brain performOperation:sender.currentTitle]];
    }
    else {
        [self.brain performOperation:sender.currentTitle];
        self.display.text = [[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.varNames]] description];
    }
    self.log.text = [self.brain description];
}
-(IBAction)undo:(id)sender {
    if (self.inMiddleOfEnteringNumber) {
        self.display.text = [self.display.text substringToIndex:self.display.text.length -1];
        if (self.display.text== [NSString string]) self.inMiddleOfEnteringNumber = NO;
    }
    else {
        [self.brain removeOperand];
        [self updateDisplay:nil];
    }
}
- (IBAction)graph {
    if (self.inMiddleOfEnteringNumber) [self enterPressed];
    [self performSegueWithIdentifier:@"Graphed" sender:self];
}

- (IBAction)graph2 {
    if (self.inMiddleOfEnteringNumber) [self enterPressed];
    GraphViewController *graphview = [[self.splitViewController viewControllers] lastObject];
    [graphview setGraph: self.brain.program];
    [graphview setTitle:self.log.text];
    [graphview update];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setGraph:self.brain.program];
    [segue.destinationViewController setTitle:self.log.text];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad))
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            [self moveButtons:buttonnamesL toLocs:landscapelocs];
        }
        else [self moveButtons:buttonnames toLocs:portraitlocs];
    }
    
}

-(void) moveButtons: (NSArray *) buttonNames toLocs: (CGRect *) locs
{
    for (int i = 0; i < [buttonNames count]; i++)
    {
        UIButton *temp = [buttons objectForKey:[buttonNames objectAtIndex: i]];
        temp.frame = locs[i];
    }

}



-(void) loadButtons: (NSArray *) buttonNames toLocs: (CGRect *) locs
{
    for (int i = 0; i < [buttonNames count]; i++)
    {
        UIButton *temp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [temp setTitle: [buttonNames objectAtIndex:i] forState:UIControlStateNormal ];
        temp.frame = locs[i];
        [self setTarget: temp];
        [buttons setObject: temp forKey:[buttonNames objectAtIndex: i]];
        [self.view addSubview:temp];
        
        
    }
}
#pragma mark SplitViewController delegate

- (id <SplitViewBarButtonItemPresenter>)splitViewBarItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)])
        detailVC = nil;
    return detailVC;
}

-(BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
    [self splitViewBarItemPresenter].splitViewBarButtonItem = barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarItemPresenter].splitViewBarButtonItem = nil;
}
@end
