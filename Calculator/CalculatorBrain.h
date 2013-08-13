//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Austin Czarnecki on 8/7/13.
//  Copyright (c) 2013 Austin Czarnecki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperation:(NSString *)operation;
- (void)pushVariable:(NSString *)variable;
- (void)removeLastItemFromStack;
- (void)clearStack;
- (NSString *)getDescription;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
