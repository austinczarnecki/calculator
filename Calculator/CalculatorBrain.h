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
- (double)performOperation:(NSString *)operation;
- (void)clearStack:(NSString *)clear;

@end
