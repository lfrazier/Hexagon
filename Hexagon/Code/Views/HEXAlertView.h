//
//  HEXAlertView.h
//  Hexagon
//
//  Created by Lauren on 3/28/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEXAlertView : UIAlertView

+ (HEXAlertView *)defaultAlertWithError:(NSError *)error;

@end
