//
//  ViewController.h
//  LevelSaturday
//
//  Created by Gregoire Paris on 11/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "C_GAMEBOARD.h"

@interface ViewController : UIViewController
{
    UIView *            m_master_button;
    UIView *            m_lower_button;
    UIColor *           m_color_button;

    C_GAMEBOARD *       m_gameboard;
    CGRect              m_slice_for_gameboard;
    
}



@end

