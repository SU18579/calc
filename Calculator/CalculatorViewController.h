//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Kenneth Bambridge on 1/3/13.
//
//

#import <UIKit/UIKit.h>


@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *log;
@end
