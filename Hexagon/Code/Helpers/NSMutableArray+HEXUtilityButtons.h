//
//  NSMutableArray+HEXUtilityButtons.h
//  Hexagon
//
//  Created by Lauren on 3/15/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (HEXUtilityButtons)

- (void)hexAddUtilityButtonWithColor:(UIColor *)color
                               title:(NSString *)title;

- (void)hexAddUtilityButtonWithColor:(UIColor *)color
                                icon:(UIImage *)icon;

- (void)hexInsertUtilityButtonWithColor:(UIColor *)color
                                  title:(NSString *)title
                                atIndex:(NSInteger)index;

- (void)hexInsertUtilityButtonWithColor:(UIColor *)color
                                   icon:(UIImage *)icon
                                atIndex:(NSInteger)index;

@end
