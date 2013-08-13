//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Austin Czarnecki on 8/7/13.
//  Copyright (c) 2013 Austin Czarnecki. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userHasAlreadyEnteredADecimalPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stackDisplay = _stackDisplay;
@synthesize variableDisplay = _variableDisplay;
@synthesize testVariableValues = _testVariableValues;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userHasAlreadyEnteredADecimalPoint = _userHasAlreadyEnteredADecimalPoint;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userHasAlreadyEnteredADecimalPoint && [digit isEqual:@"."]) {
        return;
    } else if ([digit isEqual: @"."]) {
        self.userHasAlreadyEnteredADecimalPoint = YES;
    }
    if(self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}
- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    [self updateDisplays];
}
- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasAlreadyEnteredADecimalPoint = NO;
    [self updateDisplays];
}
- (IBAction)clear
{
    [self.brain clearStack];
    [self updateDisplays];
}
- (IBAction)variablePressed:(UIButton *)sender {
    [self.brain pushVariable:sender.currentTitle];
    [self updateDisplays];
}

- (void)updateDisplays
{
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.variableDisplay.text = @"";
    for (NSString *key in self.testVariableValues) {
        if ([[CalculatorBrain variablesUsedInProgram:self.brain.program] containsObject:key]) {
            if (![self.variableDisplay.text isEqual:@""]) {
                self.variableDisplay.text = [self.variableDisplay.text stringByAppendingString:@", "];
            }
            self.variableDisplay.text = [self.variableDisplay.text stringByAppendingFormat:@"%@ = %@", key, [self.testVariableValues objectForKey:key]];
        }
    }
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.stackDisplay.text = [self.brain getDescription];
}
- (IBAction)variableSetPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqual:@"Var1"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2], @"a", [NSNumber numberWithDouble:3], @"b", [NSNumber numberWithDouble:4], @"x", nil];
    } else if ([sender.currentTitle isEqual:@"Var2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2.4], @"a", [NSNumber numberWithDouble:-2], @"b", [NSNumber numberWithDouble:.5], @"x", nil];
    } else if ([sender.currentTitle isEqual:@"Var3"]) {
        self.testVariableValues = nil;
    } else if ([sender.currentTitle isEqual:@"Var4"]) {
        self.testVariableValues = nil;
    }
    [self updateDisplays];
}
- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([[self.display.text substringFromIndex:[self.display.text length] - 1] isEqualToString:@"."]) self.userHasAlreadyEnteredADecimalPoint = NO;
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        if ([self.display.text length] == 0) self.userIsInTheMiddleOfEnteringANumber = NO;
    } else {
        [self.brain removeLastItemFromStack];
        [self updateDisplays];
    }
}

@end
