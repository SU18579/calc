//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Kenneth Bambridge on 1/4/13.
//
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void) pushOperand: (double) operand;
- (double) performOperation: (NSString *) operation;
- (void) removeOperand;
- (void) clear;

@property (readonly) id program;

+(double) runProgram: (id)program;
+ (double) runProgram: (id) program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *) descriptionOfProgram:(id) program;
+ (NSSet *) variablesUsedInProgram: (id) program;

@end
