//
//  ViewController.h
//  IPAInstaller
//
//  Created by iMokhles on 28/03/16.
//  Copyright © 2016 iMokhles. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragView.h"

@interface ViewController : NSViewController <DragViewDelegate>
@property (strong) IBOutlet NSImageView *deviceConnectedLogoView;
@property (strong) IBOutlet DragView *dragView;
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property (strong) IBOutlet NSTextField *progressBarLabel;
@property (strong) IBOutlet NSTextField *deviceName;
@property (strong) IBOutlet NSTextField *ipaTextField;
@property (strong) IBOutlet NSButton *uniButton;
@property (strong) IBOutlet NSTextView *logTextView;
@property (strong) IBOutlet NSButton *installLibraries;
- (IBAction)installLibrariesTapped:(id)sender;
- (IBAction)uniButtonTapped:(id)sender;


@end

