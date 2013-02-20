//
//  GraphViewController.h
//  Calculator
//
//  Created by Kenneth Bambridge on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "GraphDataSource.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <GraphDataSource, SplitViewBarButtonItemPresenter>

@property id graph;
-(double) getOutput: (double) x;
-(void) update;
@end
