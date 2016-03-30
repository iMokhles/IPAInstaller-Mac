//
//  ViewController.m
//  IPAInstaller
//
//  Created by iMokhles on 28/03/16.
//  Copyright © 2016 iMokhles. All rights reserved.
//

#import "ViewController.h"
#import "LibraryChecker.h"
#import "MobileDeviceAccess.h"
#import "IPAInstallerHelper.h"
#import "SSZipArchive.h"
#import "GCDTask.h"


/*
 
 Special thanks to ArtemVasnev for his library check method " https://github.com/ArtemVasnev/AppInstaller/blob/master/AppInstaller/LibraryChecker.m "
 
 */

@interface ViewController () <MobileDeviceAccessListener, SSZipArchiveDelegate>

@end

static NSImage *redImage = nil;
static NSImage *greenImage = nil;
double processedFiles=0;

@implementation ViewController
@synthesize deviceConnectedLogoView;
- (void)viewDidLoad {
    [super viewDidLoad];
    greenImage = [IPAInstallerHelper roundCornersImage:[NSImage imageNamed:@"greenImage"] CornerRadius:10];
    redImage = [IPAInstallerHelper roundCornersImage:[NSImage imageNamed:@"redImage"] CornerRadius:10];
    [deviceConnectedLogoView setImage:redImage];
    // Do any additional setup after loading the view.
    [[MobileDeviceAccess singleton] setListener:self];
    [self checkLibraries];
}

- (void)checkLibraries {
    BOOL librariesInstalled = [LibraryChecker isLibraryInstalled];
    self.installLibraries.hidden = librariesInstalled;
}

- (void)draggedFileAtPath:(NSURL *)path {
    [self uploadIPA:path];
}

- (void)uploadIPA:(NSURL *)url {
    _ipaTextField.stringValue = url.path;
    _uniButton.title = @"Extract";
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
    
    
    
}

- (IBAction)installLibrariesTapped:(id)sender {
    BOOL success = [LibraryChecker installLibraries];
    self.installLibraries.hidden = success;
}

- (IBAction)uniButtonTapped:(NSButton *)sender {
    if ([sender.title isEqualToString:@"Extract"]) {
        [_progressBarLabel setStringValue:@"Extracting"];
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[IPAInstallerHelper payloadExtractedPath] error:nil];
        if (files.count > 0) {
            if ([IPAInstallerHelper deleteFileAtPath:[IPAInstallerHelper payloadExtractedPath]]) {
                NSLog(@"Cleaning old extraction");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [SSZipArchive unzipFileAtPath:self.ipaTextField.stringValue toDestination:[IPAInstallerHelper ipaExtractedPath] delegate:self];
                });
                
            }
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [SSZipArchive unzipFileAtPath:self.ipaTextField.stringValue toDestination:[IPAInstallerHelper ipaExtractedPath] delegate:self];
            });
        }
    } else if ([sender.title isEqualToString:@"Install"]) {
        [self instalApp];
    }
}

- (void)updateProgress:(CGFloat)progress {
    [_progressBar setDoubleValue:progress];
}

- (void)updateProgressLabel:(NSString *)file {
    [[_logTextView textStorage] beginEditing];
    [[[_logTextView textStorage] mutableString] appendString:file];
    [[[_logTextView textStorage] mutableString] appendString:@"\n"];
    [[_logTextView textStorage] endEditing];
    
    NSRange range;
    range = NSMakeRange ([[_logTextView string] length], 0);
    
    [_logTextView scrollRangeToVisible: range];
}

- (void)instalApp {
    
    BOOL isPathExiste = [[NSFileManager defaultManager] fileExistsAtPath:[IPAInstallerHelper payloadExtractedPath]];
    
    if (isPathExiste) {
        
        for (NSString *appFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[IPAInstallerHelper payloadExtractedPath] error:nil]) {
            
            if ([appFile.lowercaseString containsString:@"app"]) {
                GCDTask* pingTask = [[GCDTask alloc] init];
                NSLog(@"%@", [[IPAInstallerHelper payloadExtractedPath] stringByAppendingPathComponent:appFile]);
                [pingTask setArguments:@[@"-i", [[IPAInstallerHelper payloadExtractedPath] stringByAppendingPathComponent:appFile]]];
                [pingTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"ideviceinstaller" ofType:nil]];
                
                [pingTask launchWithOutputBlock:^(NSData *stdOutData) {
                    NSString* output = [[NSString alloc] initWithData:stdOutData encoding:NSUTF8StringEncoding];
                    NSLog(@"OUT: %@", output);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([output containsString:@"5"]) {
                            [self updateProgress:5.0f];
                        }
                        if ([output containsString:@"15"]) {
                            [self updateProgress:15.0f];
                        }
                        if ([output containsString:@"20"]) {
                            [self updateProgress:20.0f];
                        }
                        if ([output containsString:@"30"]) {
                            [self updateProgress:30.0f];
                        }
                        if ([output containsString:@"40"]) {
                            [self updateProgress:40.0f];
                        }
                        if ([output containsString:@"50"]) {
                            [self updateProgress:50.0f];
                        }
                        if ([output containsString:@"60"]) {
                            [self updateProgress:60.0f];
                        }
                        if ([output containsString:@"70"]) {
                            [self updateProgress:70.0f];
                        }
                        if ([output containsString:@"80"]) {
                            [self updateProgress:80.0f];
                        }
                        if ([output containsString:@"90"]) {
                            [self updateProgress:90.0f];
                        }
                        if ([output containsString:@"Complete"]) {
                            [self updateProgress:100.0f];
                            [self resetAllContents];
                        }
                        [self updateProgressLabel:output];
                    });
                } andErrorBlock:^(NSData *stdErrData) {
                    NSString* output = [[NSString alloc] initWithData:stdErrData encoding:NSUTF8StringEncoding];
                    NSLog(@"ERR: %@", output);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateProgressLabel:output];
                    });
                } onLaunch:^{
                    NSLog(@"Task has started running.");
                } onExit:^{
                    NSLog(@"Task has now quit.");
                }];
            }
        }
        
    }
    
}

- (void)resetAllContents {
    if ([IPAInstallerHelper deleteFileAtPath:[IPAInstallerHelper payloadExtractedPath]]) {
        _ipaTextField.stringValue = @"";
        _uniButton.title = @"Browse";
        _progressBarLabel.stringValue = @"unzip";
    }
}
#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProgressLabel:unzippedFilePath];
    });
}

- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progress = ((100.0 / total) * loaded);
        if (progress < 100) {
            [self updateProgress:progress];
        } else if (progress == 100) {
            [self updateProgress:100];
            [self updateProgressLabel:@"unzipped DONE"];
            [_progressBarLabel setStringValue:@"Extracted"];
            [_uniButton setTitle:@"Install"];
            [self updateProgressLabel:@""];
            [self updateProgressLabel:@"Click Install now"];
        }
        
    });
}
#pragma mark - MobileDeviceAccessListener

/// This method will be called whenever a device is connected
- (void)deviceConnected:(AMDevice *)device {
    [deviceConnectedLogoView setImage:greenImage];
    self.deviceName.stringValue = [NSString stringWithFormat:@"Device Connected: %@", device.deviceName];
}
/// This method will be called whenever a device is disconnected
- (void)deviceDisconnected:(AMDevice *)device {
    [deviceConnectedLogoView setImage:redImage];
    self.deviceName.stringValue = @"Connect Device";
}
@end
