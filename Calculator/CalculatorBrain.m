//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Austin Czarnecki on 8/7/13.
//  Copyright (c) 2013 Austin Czarnecki. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}
- (void)removeLastItemFromStack
{
    [self.programStack removeLastObject];
}
- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (NSString *)getDescription
{
    return [CalculatorBrain descriptionOfProgram:self.program];
}
//setter for the program @property
- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *result = @"";
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    while ([stack count] > 0) {
        NSString *temp = [self descriptionOfTopOfStack:stack];
        if ([temp hasPrefix:@"("] && [temp hasSuffix:@")"]) {
            temp = [temp substringWithRange:NSMakeRange(1, [temp length] - 2)];
        }
        result = [result stringByAppendingString:temp];
        if ([stack count]>0) result = [result stringByAppendingString:@", "];
    }
    return result;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *result = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isOperation:topOfStack]) {
            NSString *operation = topOfStack;
            if ([operation isEqual: @"sin"] || [operation isEqual: @"cos"] || [operation isEqual: @"sqrt"]) {
                NSString *operand = [self descriptionOfTopOfStack:stack];
                if ([operand hasPrefix:@"("]) {
                    result = [operation stringByAppendingFormat:@"%@", operand];
                } else {
                    result = [operation stringByAppendingFormat:@"(%@)", operand];
                }
            } else if ([operation isEqual:@"/"]||[operation isEqual:@"*"]||[operation isEqual:@"-"]||[operation isEqual:@"+"]) {
                NSString *temp = [self descriptionOfTopOfStack:stack];
                NSString *temp2 = [self descriptionOfTopOfStack:stack];
                if (![self isOperation:[stack lastObject]] && ![operation isEqual:@"*"]) {
                    result = [result stringByAppendingFormat:@"(%@ %@ %@)", temp2, operation, temp];
                } else {
                    result = [result stringByAppendingFormat:@"%@ %@ %@", temp2, operation, temp];
                }
            } else if ([operation isEqual:@"π"]) {
                result = @"π";
            }
        } else if ([self isVariable:topOfStack]) {
            result = topOfStack;
        }
    }
    return result;
}
+ (BOOL)isOperation:(NSString *)input
{
    NSSet *operations = [NSSet setWithObjects:@"/", @"+", @"-", @"*", @"sin", @"cos", @"π", @"sqrt", nil];
    if ([operations containsObject:input]) {
        return true;
    } else {
        return false;
    }
}
+ (BOOL)isVariable:(NSString *)input
{
    NSSet *variables = [NSSet setWithObjects:@"a", @"b", @"x", nil];
    if ([variables containsObject:input]) {
        return true;
    } else {
        return false;
    }
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"π"]) {
            result = (double)22 / 7;
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffStack:stack]);
        } else {
            result = 0; //any unrecognized string is read as the integer 0
        }
    }
    return result;
}
+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    for (int i = 0; i < [stack count]; i = i+1) {
        id topOfStack = [stack objectAtIndex:i];
        if ([topOfStack isKindOfClass:[NSNumber class]]) {
            [stack replaceObjectAtIndex:i withObject:topOfStack];
        } else if ([topOfStack isKindOfClass:[NSString class]]) {
            if ([variableValues objectForKey:topOfStack]) {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:topOfStack]];
            } else {
                [stack replaceObjectAtIndex:i withObject:topOfStack];
            }
        }
    }
    return [self runProgram:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variables = [[NSMutableSet alloc] init];
    NSArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = program;
    }
    NSSet *vars = [NSSet setWithObjects:@"a", @"b", @"x", nil];
    for (NSString *var in vars) {
        if ([stack containsObject:var]) {
            [variables addObject:[var copy]];
        }
    }
    if ([variables count] == 0) {
        variables = nil;
    }
    return [variables copy];
}

- (void)clearStack
{
    [self.programStack removeAllObjects];
}
@end
