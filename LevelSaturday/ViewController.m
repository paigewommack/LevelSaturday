//
//  ViewController.m
//  LevelSaturday
//
//  Created by Gregoire Paris on 11/07/15.
//  Copyright (c) 2015 Gregoire Paris. All rights reserved.
//

#include <stdlib.h>

#import "ViewController.h"




@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    m_color_button = [UIColor colorWithRed:53./255. green:73./255. blue:94./255. alpha:1]; // WET ASPHALT


    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    
    // SETTUP MASTER BUTTON
    CGRect slice_for_master_button;
    CGRect extra;
    
    CGFloat button_height = ( CGRectGetHeight( applicationFrame ) - CGRectGetWidth( applicationFrame ) ) / 2.;
    CGRectDivide(applicationFrame, &slice_for_master_button, &extra, button_height, 1);
    m_master_button = [[UIView alloc] initWithFrame:slice_for_master_button];
    m_master_button.backgroundColor = m_color_button;
//    self.view = master_button;
    [self.view addSubview:m_master_button];
    
    UITapGestureRecognizer *gesture_master_button = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(request_init:)];
    
    [m_master_button addGestureRecognizer:gesture_master_button];

    
    // SETTUP GAMEBOARD 1/2
    CGFloat gameboard_height = CGRectGetWidth( applicationFrame );
    CGRect slice_for_lower_button;
    CGRectDivide( extra, &m_slice_for_gameboard, &slice_for_lower_button, gameboard_height, 1);
    
    // LOWER BUTTON
    m_lower_button = [[UIView alloc] initWithFrame:slice_for_lower_button];
    m_lower_button.backgroundColor = m_color_button;
    [self.view addSubview:m_lower_button];
    
    
    // SETTUP GAMEBOARD 2/2
    m_gameboard = [C_GAMEBOARD alloc];
    [m_gameboard init_gameboard_tiles:self.view inRect:m_slice_for_gameboard];
    

    
    // FINISH SETUP
    [m_gameboard add_gameboard_tiles_to_superview];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) request_init:(UITapGestureRecognizer *)gestureRecognizer
{
    [m_gameboard    delete_gameboard_tiles_from_superview];
    [m_gameboard    init_gameboard_tiles:self.view inRect:m_slice_for_gameboard];
    [m_gameboard    add_gameboard_tiles_to_superview];
}










@end
