//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Kenneth Bambridge on 1/4/13.
//
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

- (NSMutableArray *) programStack //lazy instantiation
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc]init];
    }
    return _programStack;
}

-(void) pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(double) performOperation:(NSString *)operation
{
    if (operation) [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}
- (id) program{
    return [self.programStack copy];
}

+ (NSString *) postfixToInfix: (NSMutableArray *) stack withCount: (int) count withPriority: (BOOL) p
{
    NSString *result;
    id topOfStack = [stack lastObject];
    if (topOfStack){[stack removeLastObject]; count--;}
    else topOfStack = [[NSNumber alloc]initWithInt:0 ];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]){
        result = [(NSNumber *)topOfStack stringValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        switch ([[CalculatorBrain isOperation:(NSString *)topOfStack] characterAtIndex:0]) {
            case'+': case'-': case'*': case'/':
            {
                NSString *arg2 = [self postfixToInfix: stack withCount: count withPriority:NO];
                if (p) result = [NSString stringWithFormat:@"(%@ %@ %@)", [self postfixToInfix:stack withCount:count withPriority:[self priority:(NSString *)topOfStack]], topOfStack , arg2];
                else result = [NSString stringWithFormat:@"%@ %@ %@", [self postfixToInfix:stack withCount:count withPriority:[self priority:(NSString *)topOfStack]], topOfStack, arg2];
                break;
            }
            case 'E':
                result = [self postfixToInfix:stack withCount:count withPriority:p];
                break;
            case 112: case 0:
                result = topOfStack;
                break;
            default:
                result = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self postfixToInfix:stack withCount:count withPriority:p]];
                break;
        }
    }
    return result;
}

+ (BOOL) priority: (NSString *) s
{
    if ([s isEqualToString:@"+"] || [s isEqualToString:@"-"])
        return NO;
    return YES;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSString *result = [[NSString alloc]init];
    while ([stack count]) {
        result = [NSString stringWithFormat:@"%@, %@", [self postfixToInfix:stack withCount:[stack count] withPriority:NO], result];
    }
    return result;
}

+ (double) popOperandOffStack: (NSMutableArray *) stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if ([@"-" isEqualToString:operation]) {
            result = -[self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([@"/" isEqualToString:operation]) {
            result = 1 / [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack]);
        }
        else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack]);
        }
        else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        }
        else if ([@"sqrt" isEqualToString:operation]) {
            result = pow([self popOperandOffStack:stack], .5);
        }
    }
    
    return result;
}

+ (double) runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}
+ (double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    NSSet *vars = [CalculatorBrain variablesUsedInProgram:program];
    stack = [program mutableCopy];
    if ([program isKindOfClass:[NSArray class]] && vars) {
        for (NSUInteger n = 0; n < [stack count]; n++) //replace variable values in copy of stack with numerical values
        {
            NSString *i = [stack objectAtIndex: n];
            if ([vars containsObject:i]){
                id var = [variableValues objectForKey:i];
                if ([var isKindOfClass:[NSNumber class]])[stack replaceObjectAtIndex:n withObject:var];
                else [stack replaceObjectAtIndex:n withObject:[[NSNumber alloc]initWithBool:NO]];
            }
        }
    }
    
    return [self popOperandOffStack:stack];
}
+ (NSSet *) variablesUsedInProgram:(id)program
{
    NSSet *vars;
    if ([program isKindOfClass:[NSArray class]]) {
        NSMutableArray *stack = [[NSMutableArray alloc]init];
        for (id i in program) {
            if ([i isKindOfClass:[NSString class] ] && ![CalculatorBrain isOperation:i])
                [stack addObject:i];
        
        }
        if ([stack count]) vars = [NSSet setWithArray:stack];
    }
    return (vars) ? vars : nil;
}

+(NSString *) isOperation: (NSString *) i{
    if ([i isEqualToString:@"+"]) return i;
    else if ([i isEqualToString:@"-"]) return i;
    else if ([i isEqualToString:@"*"]) return i;
    else if ([i isEqualToString:@"/"]) return i;
    else if ([i isEqualToString:@"sin"]) return i;
    else if ([i isEqualToString:@"cos"]) return i;
    else if ([i isEqualToString:@"π"]) return @"p";
    else if ([i isEqualToString:@"sqrt"]) return i;
    else return 0;
}
-(void) removeOperand
{
    [self.programStack removeLastObject];
}

- (void) clear {
    [self.programStack removeAllObjects];
}
-(NSString *) description {
    return [CalculatorBrain descriptionOfProgram:self.program];
}

@end
