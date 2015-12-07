//
//  C_GAMEBOARD.m
//  LevelSaturday
//
//  Created by Gregoire Paris on 18/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C_GAMEBOARD.h"
#import "C_TILE.h"


#define ARC4RANDOM_MAX      0x100000000

@interface C_GAMEBOARD ()

@end

@implementation C_GAMEBOARD


/* **************************************** */
/* *                GETTERS               * */
/* **************************************** */
-(UIColor*) get_color_1
{
    return m_color_1;
}

-(UIColor*) get_color_2
{
    return m_color_2;
}

/* **************************************** */
/* *                METHODS               * */
/* **************************************** */

-(void) init_gameboard_tiles:(UIView*) i_superview inRect:(CGRect) i_gameboard_rect
{
    m_current_level   = 1;
    m_selected_tile   = nil;
    m_superview       = i_superview;
    m_gameboard_rect  = i_gameboard_rect;
    
//    m_color_1         = [UIColor blueColor];
//    m_color_2         = [UIColor redColor];
    
    m_color_1         = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1]; // PETER RIVER
    m_color_2         = [UIColor colorWithRed:236./255. green:240./255. blue:241./255. alpha:1]; // CLOUDS
    
    
    CGRect upper_right_tile;
    CGRect upper_left_tile;
    CGRect lower_right_tile;
    CGRect lower_left_tile;
    [C_TILE divide_rect_in_four_rects:m_gameboard_rect :&upper_left_tile :&upper_right_tile :&lower_left_tile :&lower_right_tile];
    
    m_tiles = [NSMutableArray array];
    [m_tiles addObject:[[C_TILE alloc] initWithFrame:upper_left_tile]];
    [m_tiles addObject:[[C_TILE alloc] initWithFrame:upper_right_tile]];
    [m_tiles addObject:[[C_TILE alloc] initWithFrame:lower_left_tile]];
    [m_tiles addObject:[[C_TILE alloc] initWithFrame:lower_right_tile]];
    
    [ [m_tiles objectAtIndex:0] setBackgroundColor:m_color_1];
    [ [m_tiles objectAtIndex:1] setBackgroundColor:m_color_2];
    [ [m_tiles objectAtIndex:2] setBackgroundColor:m_color_2];
    [ [m_tiles objectAtIndex:3] setBackgroundColor:m_color_1];

    
    NSEnumerator * tiles_enum      =  [m_tiles objectEnumerator];
    id tile;
    while (tile = [tiles_enum nextObject])
    {
        [tile set_gameboard:m_tiles];
        [tile set_c_gameboard:self];
    }
}

-(void) add_gameboard_tiles_to_superview
{
    NSEnumerator * tiles_enum      =  [m_tiles objectEnumerator];
    id tile;
    while (tile = [tiles_enum nextObject])
    {
        [m_superview addSubview:tile];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(request_swap:)];
        [tile addGestureRecognizer:singleFingerTap];
    }
}

-(void) delete_gameboard_tiles_from_superview
{
    // take pointer of the last tile
    C_TILE* last_tile = [[m_superview subviews] lastObject];
    
    if ( last_tile != nil )
    {
        /* the super view is not empty */
        
        NSUInteger remaining = [[m_superview subviews] count];
        while ( 4 < remaining )
        {
            /* delete while there is still tiles */
            [last_tile removeFromSuperview];
            last_tile = [[m_superview subviews] lastObject];
            remaining = [[m_superview subviews] count];
        }
    }
}


-(void) colorize_gameboard
{
    int nb_same_color_tiles_max = pow(2, 2*m_current_level-1);
    int nb_tiles_color_1        = 0;
    int nb_tiles_color_2        = 0;
    
    NSEnumerator * tiles_enum      =  [m_tiles objectEnumerator];
    id tile;
    
    while (tile = [tiles_enum nextObject])
    {
        UIColor * new_color;
        
        bool flag_rand              = ( ( (double)arc4random() / ARC4RANDOM_MAX) < 0.5 );
        bool flag_too_much_color_1  = ( nb_same_color_tiles_max <= nb_tiles_color_1 );
        bool flag_too_much_color_2  = ( nb_same_color_tiles_max <= nb_tiles_color_2  );
        
        if ( ( flag_rand && !flag_too_much_color_1 ) || flag_too_much_color_2 )
        {
            new_color = m_color_1;
            nb_tiles_color_1++;
        }
        else
        {
            new_color = m_color_2;
            nb_tiles_color_2++;
        }
        
        [tile setBackgroundColor:new_color];
    }
    
}

- (bool)check_solution
{
    NSEnumerator * tiles_enum =  [m_tiles objectEnumerator];
    id tile;
    
    int nb_row    = pow(2,m_current_level);
    int nb_column = pow(2,m_current_level);
    
    for (int row = 0; row < nb_row; row++)
    {
        for (int column = 0; column < nb_column; column++)
        {
            tile = [tiles_enum nextObject];
            
            if ( ( (double)row / ((double)nb_row-1.) ) < 0.5 )
            {
                if ( ! ([[tile backgroundColor] isEqual:m_color_1]) )
                {
                    return false;
                }
            }
            else
            {
                if ( ! ([[tile backgroundColor] isEqual:m_color_2]) )
                {
                    return false;
                }
            }
        }
    }
    
    return true;
}



-(void) go_next_level
{
    // update level
    m_current_level+=1;
    
    // delete old m_tiles
    [self delete_gameboard_tiles_from_superview];
    [m_tiles removeAllObjects];
    
    // compute tile size
    float nb_tiles_per_side = pow(2, m_current_level);
    
    float tile_side = CGRectGetWidth(m_gameboard_rect) / nb_tiles_per_side;
    float current_x = CGRectGetMinX(m_gameboard_rect);
    float current_y = CGRectGetMinY(m_gameboard_rect);
    
    for ( int row=0; row < nb_tiles_per_side; row++ )
    {
        for ( int col=0; col < nb_tiles_per_side; col++ )
        {
            CGRect tile_frame = CGRectMake ( current_x, current_y, tile_side, tile_side );
            C_TILE * tile = [[C_TILE alloc] initWithFrame:tile_frame];
            [tile set_gameboard:m_tiles];
            [tile set_c_gameboard:self];
            [tile set_tile_position_on_gameboard:col :row];
            [m_tiles addObject:tile];
            
            current_x += tile_side;
        }
        
        current_x = 0;
        current_y += tile_side;
    }
    
    [self add_gameboard_tiles_to_superview];
    [self colorize_gameboard];
}

-(void) swap_random_tiles
{
    // select tile 1
    
    int random_index_1 = ( ( (double) arc4random() / ARC4RANDOM_MAX) * [m_tiles count] );
    C_TILE * tile_1 = [m_tiles objectAtIndex:random_index_1];
    
    // select tile 2
    int random_index_2 = ( ( (double) arc4random() / ARC4RANDOM_MAX) * [m_tiles count] );
    C_TILE * tile_2 = [m_tiles objectAtIndex:random_index_2];
    
    [C_TILE swapColor:tile_1 with:tile_2];
}


/* ****************************************** */
/* *                CALLBACKS               * */
/* ****************************************** */

-(void) request_swap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGFloat transformation_scale = 1.05;
    
    if ( m_selected_tile == nil )
    {
        /* il n'y a pas de tile selected, on en select une sans swap */
        
        // select this tile and others
        m_selected_tile = (C_TILE*)gestureRecognizer.view;
        
        // Promote the touched view
        [m_selected_tile.superview bringSubviewToFront:m_selected_tile];
        
        // animate
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.13];
        
        m_selected_tile.transform = CGAffineTransformScale(m_selected_tile.transform, transformation_scale, transformation_scale);
        
        [UIView commitAnimations];
        
        m_selected_tile.layer.shadowOffset = CGSizeMake(-2, 4);
        m_selected_tile.layer.shadowRadius = 8;
        m_selected_tile.layer.shadowOpacity = 1;
        
    }
    else
    {
        // back to normal
        m_selected_tile.transform = CGAffineTransformScale(m_selected_tile.transform, 1./transformation_scale, 1./transformation_scale);
        m_selected_tile.layer.shadowOffset = CGSizeMake(0, 0);
        m_selected_tile.layer.shadowRadius = 0;
        m_selected_tile.layer.shadowOpacity = 0;
        
        
        /* il y a une tile selected, on swap et check la solution */
        //Get the current View
        C_TILE * current_tile = (C_TILE*)gestureRecognizer.view;
        [C_TILE swapColor:current_tile with:m_selected_tile];
        
        m_selected_tile = nil;
        
        if ( [self check_solution] )
        {
            /* level resolved, go next level */
            [self go_next_level];
        }
    }
}



@end