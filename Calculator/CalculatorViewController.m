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

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stackDisplay = _stackDisplay;
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
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    self.stackDisplay.text = [self.stackDisplay.text stringByAppendingString:@" "];
    self.stackDisplay.text = [self.stackDisplay.text stringByAppendingString:sender.currentTitle];
}
- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasAlreadyEnteredADecimalPoint = NO;
    self.stackDisplay.text = [self.stackDisplay.text stringByAppendingString:@" "];
    self.stackDisplay.text = [self.stackDisplay.text stringByAppendingString:self.display.text];
}
- (IBAction)clear {
    self.display.text = @"0";
    self.stackDisplay.text = @"";
}

@end
