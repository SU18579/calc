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
@synthesize inMiddleOfEnteringNumber = _inMiddleOfEnteringNumber;
@synthesize display = _display;
@synthesize brain = _brain;
@synthesize log = _log;
@synthesize varNames = _varNames;

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
    self.title = @"Calculator";
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
