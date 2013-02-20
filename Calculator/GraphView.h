//
//  GraphView.h
//  Calculator
//
//  Created by Kenneth Bambridge on 1/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GraphDataSource.h"

@interface GraphView : UIView

@property id <GraphDataSource> controller;
@property (nonatomic)CGFloat scale;
@property (nonatomic) CGPoint origin;

-(void) pinch:(UIPinchGestureRecognizer *) gesture;
-(void) pan:(UIPanGestureRecognizer *) gesture;

@end
