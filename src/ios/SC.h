#import <Cordova/CDVPlugin.h>
	
@interface SC : CDVPlugin

- (void)pluginInitialize;

- (void)watchForBreak:(CDVInvokedUrlCommand*)command;

- (void)testForBreak;

- (void)debuggerCheck:(CDVInvokedUrlCommand*)command;

- (void)jailbreakCheck:(CDVInvokedUrlCommand*)command;

@end