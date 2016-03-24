#import "SC.h"
#import <Cordova/CDVPlugin.h>
#import "SecurityCheck.h"

@implementation SC

// callback from checks
typedef void (^cbBlock) ();

/**
 * during pluginInitialize register watchForBreak
 */
- (void)pluginInitialize {
    NSLog(@"pluginInitialize SC");
    [self watchForBreak:nil];
}
/**
 * Register DidBecomeActive and WillEnterForegroud event notifications
 * calls testForBreak
 */
- (void)watchForBreak:(CDVInvokedUrlCommand*)command {
    __weak id weakSelf = self;
    if (weakSelf) {
         NSLog(@"SecurityCheck registering handlers for notification...");
        // onAppActive
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(testForBreak) 
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
        // onAppForeground
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(testForBreak) 
                                                     name:UIApplicationWillEnterForegroundNotification 
                                                   object:nil];
        [self testForBreak];
    }
};

/**
 * testing for debugger and jailbreak
 */
- (void)testForBreak {
    
    cbBlock exitOnBreak = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            NSLog(@"SECURITY VIOLATION detected! Exiting...");
            exit(1);
        };
    };
    NSLog(@"SecurityCheck testing for jailbreak");

    //-----------------------------------
    // jailbreak detection
    //-----------------------------------
    checkFork(exitOnBreak);
    checkFiles(exitOnBreak);
    checkLinks(exitOnBreak);
    NSLog(@"SecurityCheck testing for debugger");
    //-----------------------------------
    // debugger detection
    //-----------------------------------
    dbgCheck(exitOnBreak);
    NSLog(@"SecurityCheck testing done");

    
};

/**
 * check for debugger
 */ 
 - (void)debuggerCheck:(CDVInvokedUrlCommand*)command {
    cbBlock dbChkCallback = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    };

    dbgCheck(dbChkCallback);    
};

/**
 * check for jailbreak
 */
- (void)jailbreakCheck:(CDVInvokedUrlCommand*)command {
   cbBlock jbChkCallback = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    };
   
    //-----------------------------------
    // jailbreak detection
    //-----------------------------------
    checkFork(jbChkCallback);
    checkFiles(jbChkCallback);
    checkLinks(jbChkCallback);
};
@end