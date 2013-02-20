//
//  GraphDataSource.h
//  Calculator
//
//  Created by Kenneth Bambridge on 1/19/13.
//
//

#import <Foundation/Foundation.h>

@protocol GraphDataSource <NSObject>

-(double) getOutput: (double) x;
-(NSString *) getFunctionName;

@end
