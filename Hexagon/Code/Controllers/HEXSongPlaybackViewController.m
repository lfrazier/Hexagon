//
//  HEXSongPlaybackViewController.m
//  Hexagon
//
//  Created by Lauren on 2/4/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXSongPlaybackViewController.h"
#import "HEXSpotifyManager.h"

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
    [[HEXSpotifyManager sharedInstance] playTrack:self.track];
}

- (IBAction)playingSwitchTapped:(id)sender {
    if (((UISwitch *)sender).isOn) {
        [[HEXSpotifyManager sharedInstance] resumeCurrentTrack];
    } else {
        [[HEXSpotifyManager sharedInstance] pauseCurrentTrack];
    }
}

- (IBAction)positionSliderMoved:(id)sender {
    NSTimeInterval newPosition = ((UISlider *)sender).value * self.track.duration;
    [[HEXSpotifyManager sharedInstance] seekCurrentTrackToPosition:newPosition];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
