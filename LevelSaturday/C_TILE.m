//
//  C_TILE.h
//  LevelSaturday
//
//  Created by Gregoire Paris on 14/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C_TILE.h"
#import "C_GAMEBOARD.h"

@interface C_TILE ()

@end

@implementation C_TILE



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
        self.gestureRecognizers = @[panRecognizer];
        
        m_flag_translation_ongoing = 0;
    }
    
    return self;
}

- (void) set_gameboard:(NSMutableArray*) i_gameboard
{
    m_gameboard     = i_gameboard;
}

- (void) set_c_gameboard:(C_GAMEBOARD*) i_c_gameboard
{
    m_c_gameboard   = i_c_gameboard;
}

- (void) set_tile_position_on_gameboard:(int)i_col :(int)i_row
{
    m_tile_position_on_gameboard = CGPointMake(i_col,i_row);
}


- (CGPoint) get_tile_position_on_gameboard
{
    return m_tile_position_on_gameboard;
}


- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    // recuperation de la translation
    CGPoint translation = [uiPanGestureRecognizer translationInView:self.superview];
    
    // transformation en translation en nb de tuile
    CGPoint translation_int = [self transform_in_translation_int:translation];
    
//    NSLog(@" %f %f | %f %f", translation.x, translation_int.x, translation.y, translation_int.y);
    
    if ( !m_flag_translation_ongoing )
    {
        /*  Translation begin, we enter here just once, but we have do compute some variables
            once only, so we do need this specific thing.
            Maybe the correct implementation is to consider translation as a abstract objetc,
            as it is not dependent to one tile, but a bunch of tile.                            */
        
        m_flag_translation_ongoing = true;
        
        m_tile_color_at_translation      = [self backgroundColor];
        m_tile_ante_color_at_translation = [m_tile_color_at_translation isEqual:[m_c_gameboard get_color_1]] ? [m_c_gameboard get_color_2] : [m_c_gameboard get_color_1];
        
        //tiles color selected that may move
        [m_moving_tiles   removeAllObjects];
        m_moving_tiles  = [NSMutableArray array];
        [self find_adjacent_tiles:m_moving_tiles for_translation:translation];
        
        
        {
//            NSEnumerator * selected_tiles_enum      =  [m_moving_tiles objectEnumerator];
//            id tile;
//            while (tile = [selected_tiles_enum nextObject])
//            {
//                [self.superview bringSubviewToFront:tile];
//                //                [tile translate:translation];
//                [tile setBackgroundColor:[UIColor purpleColor]];
//            }
        }

        // tiles to be replaced
        [m_tiles_replaced   removeAllObjects];
        m_tiles_replaced  = [NSMutableArray array];
        [self find_tiles_to_be_replaced:m_tiles_replaced for_translation:translation];
    
//    NSLog(@"tiles_to_be_replaced %d", (int)[tiles_to_be_replaced count]);
        {
//            NSEnumerator * selected_tiles_enum      =  [m_tiles_replaced objectEnumerator];
//            id tile;
//            while (tile = [selected_tiles_enum nextObject])
//            {
//                [self.superview bringSubviewToFront:tile];
//                //                [tile translate:translation];
//                [tile setBackgroundColor:[UIColor yellowColor]];
//            }
        }
        

        
        [self translate_tiles: translation_int];
    }
    else
    {
        translation_int.x = MIN( translation_int.x, [m_tiles_replaced count] );
        translation_int.y = MIN( translation_int.y, [m_tiles_replaced count] );
        
        [self translate_tiles: translation_int];
    }
    

    if (uiPanGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        m_flag_translation_ongoing = false;
        
        if ( [m_c_gameboard check_solution] )
        {
            /* level resolved, go next level */
            [m_c_gameboard go_next_level];
        }
        else
        {
            [m_c_gameboard swap_random_tiles];
        }
    }
}



- (void) find_adjacent_tiles:(NSMutableArray*) o_adjacent_tiles for_translation:(CGPoint) i_translation
{
    int nb_tile_per_side = sqrt( (double) [m_gameboard count] );
    
    if ( i_translation.x != 0 )
    {
        /* la translation est suivant x,  on ajoute les tuiles adjacentes sur la même ligne */
        
        bool stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x-1; 0 <= pos_x && !stop; pos_x-- )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                [o_adjacent_tiles insertObject:[m_gameboard objectAtIndex:index] atIndex:0];
            else
                stop = true;
        }
        
        [o_adjacent_tiles addObject:self];
        
        stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x+1; pos_x < nb_tile_per_side && !stop; pos_x++ )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                [o_adjacent_tiles addObject:[m_gameboard objectAtIndex:index]];
            else
                stop = true;
        }
    }
    else
    {
        /* la translation est suivant y,  on ajoute les tuiles adjacentes sur la même colonne */
        
        
        bool stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y-1; 0 <= pos_y && !stop; pos_y-- )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                [o_adjacent_tiles insertObject:[m_gameboard objectAtIndex:index] atIndex:0];
            else
                stop = true;
        }
        
        [o_adjacent_tiles addObject:self];
        
        stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y+1; pos_y < nb_tile_per_side && !stop; pos_y++ )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                [o_adjacent_tiles addObject:[m_gameboard objectAtIndex:index]];
            else
                stop = true;
        }
    }
}

- (void) find_tiles_to_be_replaced:(NSMutableArray*) o_tiles_to_be_replaced for_translation:(CGPoint) i_translation
{
    int nb_tile_per_side = sqrt( (double) [m_gameboard count] );
    
    if ( i_translation.x != 0 )
    {
        /* la translation est horizontale, on cherche les tuiles de couleur differentes */
        
        CGPoint position_temp;
        int signe = (0 < i_translation.x) ? 1 : -1;
        
//        NSLog(@"Translation horizontale %f", i_translation.x);
        
        // première tuile de couleur differente dans le sens de la translation
        bool stop = false;
        for ( int delta_x = 0; delta_x < nb_tile_per_side && !stop; delta_x++ )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + m_tile_position_on_gameboard.x + signe * delta_x;
            if (0 <= index && index < [m_gameboard count])
            {
                if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                {
                    [o_tiles_to_be_replaced addObject:[m_gameboard objectAtIndex:index]];
                    position_temp = [[m_gameboard objectAtIndex:index] get_tile_position_on_gameboard];
                    stop = true;
                }
            }
            else
            {
                stop = true;
            }
        }
        
        // autres tuiles de couleur differente dans le sens de la translation
        stop = false;
        for ( int delta_x = 1; delta_x < nb_tile_per_side && !stop; delta_x++ )
        {
            int index = position_temp.y * nb_tile_per_side + position_temp.x + signe * delta_x;
            
            if ( 0 <= (position_temp.x + signe * delta_x) && (position_temp.x + signe * delta_x) < nb_tile_per_side )
                if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                {
                    [o_tiles_to_be_replaced addObject:[m_gameboard objectAtIndex:index]];
                }
                else
                {
                    stop = true;
                }
            else
                stop = true;
        }
    } // fin translation horizontale
    else if ( i_translation.y != 0 )
    {
        /* la translation est verticale, on cherche les tuiles de couleur differentes */
        
        CGPoint position_temp;
        int signe = (0 < i_translation.y) ? 1 : -1;
        
        // première tuile de couleur differente dans le sens de la translation
        bool stop = false;
        for ( int delta_y = 0; delta_y < nb_tile_per_side && !stop; delta_y++ )
        {
            int index = (m_tile_position_on_gameboard.y + signe * delta_y) * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if (0 <= index && index < [m_gameboard count])
            {
                if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                {
                    [o_tiles_to_be_replaced addObject:[m_gameboard objectAtIndex:index]];
                    position_temp = [[m_gameboard objectAtIndex:index] get_tile_position_on_gameboard];
                    stop = true;
                }
            }
            else
            {
                stop = true;
            }
        }
        
        // autres tuiles de couleur differente dans le sens de la translation
        stop = false;
        for ( int delta_y = 1; delta_y < nb_tile_per_side && !stop; delta_y++ )
        {
            int index = (position_temp.y + signe * delta_y) * nb_tile_per_side + position_temp.x;
            if (0 <= index && index < [m_gameboard count])
                if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                    [o_tiles_to_be_replaced addObject:[m_gameboard objectAtIndex:index]];
                else
                    stop = true;
                else
                    stop = true;
        }
    } // fin translation verticale
}

- (void) translate_tiles:(CGPoint) i_translation_int
{
    if ( i_translation_int.x != 0 )
    {
        /* la translation est horizontale */
        
        // majoration de la translation
        int signe = (0 < i_translation_int.x) ? 1 : -1;
        i_translation_int.x = signe * MIN( fabs(i_translation_int.x), [m_tiles_replaced count] );
    
        // remplacement des tuiles deplacées
        for ( int num_tile = 0; num_tile < [m_moving_tiles count] && num_tile < [m_tiles_replaced count] ; num_tile++ )
        {
            if ( num_tile < fabs(i_translation_int.x) )
            {
                int num_tile_new = (0 < i_translation_int.x) ? num_tile : (int) ([m_moving_tiles count] - 1 - num_tile);
                [[m_moving_tiles objectAtIndex:num_tile_new] setBackgroundColor:m_tile_ante_color_at_translation];
            }
        }
        
        // écrasement des tuiles statiques
        for ( int num_tile = 0; num_tile < [m_tiles_replaced count]; num_tile++ )
        {
            if ( num_tile < ( fabs(i_translation_int.x) - [m_moving_tiles count] ) )
            {
                [[m_tiles_replaced objectAtIndex:num_tile] setBackgroundColor:m_tile_ante_color_at_translation];
            }
            else if ( num_tile < fabs(i_translation_int.x) )
            {
                [[m_tiles_replaced objectAtIndex:num_tile] setBackgroundColor:m_tile_color_at_translation];
            }
        }
    }
    else
    {
        /* la translation est verticale */
        
        // majoration de la translation
        int signe = (0 < i_translation_int.y) ? 1 : -1;
        i_translation_int.y = signe * MIN( fabs(i_translation_int.y), [m_tiles_replaced count] );
        
        for ( int num_tile = 0; num_tile < [m_moving_tiles count] && num_tile < [m_tiles_replaced count]; num_tile++ )
        {
            if ( num_tile < fabs(i_translation_int.y) )
            {
                int num_tile_new = (0 < i_translation_int.y) ? num_tile : (int) ([m_moving_tiles count] - 1 - num_tile);
                [[m_moving_tiles objectAtIndex:num_tile_new] setBackgroundColor:m_tile_ante_color_at_translation];
            }
        }
        
        for ( int num_tile = 0; num_tile < [m_tiles_replaced count]; num_tile++ )
        {
            if ( num_tile < ( fabs(i_translation_int.y) - [m_moving_tiles count] ) )
            {
                [[m_tiles_replaced objectAtIndex:num_tile] setBackgroundColor:m_tile_ante_color_at_translation];
            }
            else if ( num_tile < fabs(i_translation_int.y) )
            {
                [[m_tiles_replaced objectAtIndex:num_tile] setBackgroundColor:m_tile_color_at_translation];
            }
        }
    }
}

- (void) find_front_tile:(C_TILE**) o_front_tile and_last_tile:(C_TILE**) o_last_tile for_translation:(CGPoint) i_translation
{
    int nb_tile_per_side = sqrt( (double) [m_gameboard count] );
    
    if ( i_translation.x < 0 )
    {
        /* la translation est vers la gauche, on cherche la derniere tuile à droite de la meme couleurs */
        
        bool stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x; pos_x < nb_tile_per_side && !stop; pos_x++ )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                *o_last_tile = [m_gameboard objectAtIndex:index];
            else
                stop = true;
        }
        
        /* et on cherche la première tuile à gauche de couleur differente */
        
        stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x; 0 <= pos_x && !stop; pos_x-- )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
            {
                *o_front_tile = [m_gameboard objectAtIndex:index];
                stop = true;
            }
        }
    }
    
    if ( 0 < i_translation.x )
    {
        /* la translation est vers la droite, on cherche la derniere tuile à gauche de la meme couleurs */
        
        bool stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x; 0 <= pos_x && !stop; pos_x-- )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                *o_last_tile = [m_gameboard objectAtIndex:index];
            else
                stop = true;
        }
        
        /* et on cherche la première tuile à droite de couleur differente */
        stop = false;
        for ( int pos_x = m_tile_position_on_gameboard.x; pos_x < nb_tile_per_side && !stop; pos_x++ )
        {
            int index = m_tile_position_on_gameboard.y * nb_tile_per_side + pos_x;
            if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
            {
                *o_front_tile = [m_gameboard objectAtIndex:index];
                stop = true;
            }
        }
    }
    
    if ( 0 < i_translation.y )
    {
        /* la translation est vers le bas, on cherche la derniere tuile en haut de la meme couleurs */
        
        bool stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y; 0 <= pos_y && !stop; pos_y-- )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                *o_last_tile = [m_gameboard objectAtIndex:index];
            else
                stop = true;
        }
        
        /* et on cherche la première tuile à en bas de couleur differente */
        
        stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y; pos_y < nb_tile_per_side && !stop; pos_y++ )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
            {
                *o_front_tile = [m_gameboard objectAtIndex:index];
                stop = true;
            }
        }
        
    }
    
    if ( i_translation.y < 0 )
    {
        /* la translation est vers le bas, on cherche la derniere tuile en haut de la meme couleurs */
        
        bool stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y; pos_y < nb_tile_per_side && !stop; pos_y++ )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( [[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
                *o_last_tile = [m_gameboard objectAtIndex:index];
            else
                stop = true;
        }
        
        /* et on cherche la première tuile à en haut de couleur differente */
        
        stop = false;
        for ( int pos_y = m_tile_position_on_gameboard.y; 0 <= pos_y && !stop; pos_y-- )
        {
            int index = pos_y * nb_tile_per_side + m_tile_position_on_gameboard.x;
            if ( ![[[m_gameboard objectAtIndex:index] backgroundColor] isEqual:[self backgroundColor]] )
            {
                *o_front_tile = [m_gameboard objectAtIndex:index];
                stop = true;
            }
        }
        
    }
}


- (void) translate:(CGPoint) translation
{
    m_lastLocation = self.center;
    
    self.center = CGPointMake(m_lastLocation.x + translation.x,
                              m_lastLocation.y + translation.y);
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [self.superview bringSubviewToFront:self];
    
    // Remember original location
    m_lastLocation = self.center;
}



/* **************************************** */
/* *                METHODS               * */
/* **************************************** */


+(void) divide_rect_in_four_rects:(CGRect) i_base : (CGRect*) o_top_left : (CGRect*) o_top_right : (CGRect*) o_bottom_left : (CGRect*) o_bottom_right
{
    CGFloat tile_height = CGRectGetHeight ( i_base ) / 2.;
    CGFloat tile_width  = CGRectGetWidth  ( i_base ) / 2.;
    
    CGRect upper_line;
    CGRect lower_line;
    CGRectDivide(i_base, &upper_line, &lower_line, tile_height, 1);
    
    
    CGRectDivide( upper_line, o_top_left,    o_top_right,    tile_width, 0 );
    CGRectDivide( lower_line, o_bottom_left, o_bottom_right, tile_width, 0 );
}


+ (void) swapColor: (C_TILE*) i_tile_1 with: (C_TILE*) i_tile_2
{
    UIColor * temp = i_tile_1.backgroundColor;
    [i_tile_1 setBackgroundColor:i_tile_2.backgroundColor];
    [i_tile_2 setBackgroundColor:temp];
}

- (CGPoint) transform_in_translation_int: (CGPoint)i_translation
{
    CGPoint o_translation_int;
    
    // on ne récupère que la translation sur un axe
    if ( fabs(i_translation.x) < fabs(i_translation.y) )
        i_translation.x = 0;
    else
        i_translation.y = 0;
    
    if ( i_translation.x != 0 )
    {
        double current_pos  = fabs (i_translation.x) / CGRectGetWidth([self frame]);
        double previous_pos = floor( current_pos );
        double next_pos     = ceil ( current_pos );
        
        int signe = (0 < i_translation.x) ? 1 : -1;

        if ( (next_pos - current_pos) < 0.5 )
        {
            o_translation_int.x = signe * next_pos;
        }
        else
        {
            o_translation_int.x = signe * previous_pos;
        }
        
        o_translation_int.y = 0;
            
    }
    else
    {
        double current_pos  = fabs (i_translation.y) / CGRectGetWidth([self frame]);
        double previous_pos = floor( current_pos );
        double next_pos     = ceil ( current_pos );
        
        int signe = (0 < i_translation.y) ? 1 : -1;
        
        if ( (next_pos - current_pos) < 0.5 )
        {
            o_translation_int.y = signe * next_pos;
        }
        else
        {
            o_translation_int.y = signe * previous_pos;
        }
        
        o_translation_int.x = 0;
        
    }
    
    return o_translation_int;
}

@end
