//
//  NSMutableArray+HEXUtilityButtons.m
//  Hexagon
//
//  Created by Lauren on 3/15/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "NSMutableArray+HEXUtilityButtons.h"

@implementation NSMutableArray (HEXUtilityButtons)

- (void)hexAddUtilityButtonWithColor:(UIColor *)color
                               title:(NSString *)title {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = color;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self addObject:button];
}

- (void)hexAddUtilityButtonWithColor:(UIColor *)color
                                icon:(UIImage *)icon {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = color;
  [button setImage:icon forState:UIControlStateNormal];
  [self addObject:button];
}

- (void)hexInsertUtilityButtonWithColor:(UIColor *)color
                                  title:(NSString *)title
                                atIndex:(NSInteger)index {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = color;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self insertObject:button atIndex:index];
}

- (void)hexInsertUtilityButtonWithColor:(UIColor *)color
                                   icon:(UIImage *)icon
                                atIndex:(NSInteger)index {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = color;
  [button setImage:icon forState:UIControlStateNormal];
  [self insertObject:button atIndex:index];
}

@end
