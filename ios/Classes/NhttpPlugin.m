#import "NhttpPlugin.h"
#if __has_include(<nhttp/nhttp-Swift.h>)
#import <nhttp/nhttp-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "nhttp-Swift.h"
#endif

@implementation NhttpPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNhttpPlugin registerWithRegistrar:registrar];
}
@end
