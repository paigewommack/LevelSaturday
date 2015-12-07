//
//  C_TILE.h
//  LevelSaturday
//
//  Created by Gregoire Paris on 14/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#ifndef LevelSaturday_C_TILE_h
#define LevelSaturday_C_TILE_h

#import <UIKit/UIKit.h>

#import "C_GAMEBOARD.h"


@class C_GAMEBOARD;


@interface C_TILE: UIView
{
    C_GAMEBOARD*    m_c_gameboard;
    CGPoint         m_lastLocation;
    NSMutableArray* m_gameboard;
    CGPoint         m_tile_position_on_gameboard;
    
    /* variables specific to translation, maybe put in a independent object ? */
    bool            m_flag_translation_ongoing;
    NSMutableArray* m_moving_tiles;
    NSMutableArray* m_tiles_replaced;
    UIColor *       m_tile_color_at_translation;
    UIColor *       m_tile_ante_color_at_translation;
}

/* SETTERS */
- (void) set_gameboard:(NSMutableArray*) i_gameboard;
- (void) set_c_gameboard:(C_GAMEBOARD*) i_c_gameboard;
- (void) set_tile_position_on_gameboard:(int) i_row : (int) i_col;

/* GETTERS */
- (CGPoint) get_tile_position_on_gameboard;

/* METHODS */
+ (void) divide_rect_in_four_rects:(CGRect) i_base : (CGRect*) o_top_left : (CGRect*) o_top_right : (CGRect*) o_bottom_left : (CGRect*) o_bottom_right;
+ (void) swapColor: (C_TILE*) i_tile_1 with: (C_TILE*) i_tile_2;
- (CGPoint) transform_in_translation_int: (CGPoint)translation;

- (void) translate_tiles:(CGPoint) i_translation_int;

- (void) find_adjacent_tiles:(NSMutableArray*) o_adjacent_tiles for_translation:(CGPoint) i_translation;
//- (void) find_adjacent_tiles:(NSMutableArray*) o_adjacent_tiles for_translation:(CGPoint) i_translation for_color:(UIColor*) i_color;
- (void) find_front_tile:(C_TILE**) o_front_tile and_last_tile:(C_TILE**) o_last_tile for_translation:(CGPoint) i_translation;

@end

#endif
