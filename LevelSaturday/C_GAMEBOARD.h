//
//  C_GAMEBOARD.h
//  LevelSaturday
//
//  Created by Gregoire Paris on 18/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#ifndef LevelSaturday_C_GAMEBOARD_h
#define LevelSaturday_C_GAMEBOARD_h

#import "C_TILE.h"


@class C_TILE;

@interface C_GAMEBOARD: NSObject
{
    NSMutableArray *    m_tiles;
    C_TILE *            m_selected_tile;
    CGRect              m_gameboard_rect;
    int                 m_current_level;
    UIColor *           m_color_1;
    UIColor *           m_color_2;
    UIView *            m_superview;
}

/* SETTERS */

/* GETTERS */
-(UIColor*) get_color_1;
-(UIColor*) get_color_2;

/* METHODS */
-(void) init_gameboard_tiles:(UIView*) i_superview inRect:(CGRect) i_gameboard_rect;

-(void) add_gameboard_tiles_to_superview;
-(void) delete_gameboard_tiles_from_superview;

-(void) colorize_gameboard;
-(bool) check_solution;
-(void) go_next_level;

-(void) swap_random_tiles;

/* CALLBACKS */
-(void) request_swap:(UITapGestureRecognizer *)gestureRecognizer;



@end

#endif
