//
//  AppDelegate.m
//  IPAInstaller
//
//  Created by iMokhles on 28/03/16.
//  Copyright © 2016 iMokhles. All rights reserved.
//

#import "AppDelegate.h"
#import "PFAboutWindowController.h"

@interface AppDelegate ()
@property (nonatomic, strong) PFAboutWindowController *aboutWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)aboutApp:(id)sender {
    
    self.aboutWindowController = [[PFAboutWindowController alloc] init];
    [self.aboutWindowController setAppURL:[[NSURL alloc] initWithString:@"https://imokhles.net"]];
    [self.aboutWindowController setAppCredits:nil];
    [self.aboutWindowController setWindowShouldHaveShadow:YES];
    [self.aboutWindowController showWindow:nil];
}

@end
