//
//  HEXSongPlaybackViewController.m
//  Hexagon
//
//  Created by Lauren on 2/4/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXSongPlaybackViewController.h"
#import "HEXSpotifyManager.h"
#import "HEXPlaybackManager.h"

@interface HEXSongPlaybackViewController ()

@end

@implementation HEXSongPlaybackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[[HEXPlaybackManager sharedInstance] playTrack:self.track callback:nil];
}

- (IBAction)playingSwitchTapped:(id)sender {
    [HEXPlaybackManager sharedInstance].isPlaying = ((UISwitch *)sender).isOn;
}

- (IBAction)positionSliderMoved:(id)sender {
    NSTimeInterval newPosition = ((UISlider *)sender).value * [HEXPlaybackManager sharedInstance].currentTrack.duration;
    [[HEXPlaybackManager sharedInstance] seekToTrackPosition:newPosition];
}

- (IBAction)prevTapped:(id)sender {
    [[HEXPlaybackManager sharedInstance] playPreviousTrackWithCallback:nil];
}

- (IBAction)nextTapped:(id)sender {
    [[HEXPlaybackManager sharedInstance] playNextTrackWithCallback:nil];
}

- (IBAction)volumeSliderMoved:(id)sender {
    [HEXPlaybackManager sharedInstance].volume = ((UISlider *)sender).value;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
