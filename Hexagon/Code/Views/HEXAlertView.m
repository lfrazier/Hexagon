//
//  HEXAlertView.m
//  Hexagon
//
//  Created by Lauren on 3/28/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXAlertView.h"

@implementation HEXAlertView

+ (HEXAlertView *)defaultAlertWithError:(NSError *)error {
  return [[HEXAlertView alloc] initWithTitle:error.localizedDescription
                                     message:error.localizedRecoverySuggestion
                                    delegate:nil
                           cancelButtonTitle:[HEXCommonStrings cancel]
                           otherButtonTitles:nil];
}

@end
