#import "../src/HardwareUtils.h"
#import <UIKit/UIKit.h>

@interface HWClass : NSObject
{
@private
HardwareUtils *hwobj;
}

-(id)initWithHwObject:(HardwareUtils *)obj;

@end

@implementation HWClass

-(id)initWithHwObject:(HardwareUtils *)obj
{
    self = [super init];
    if (self)
    {
        hwobj = obj;
    }
    return self;
}

-(void)reachabilityChanged:(NSNotification*)note
{
    hwobj->emitNetworkStatusChanged();
}

@end

static HWClass *hwclass;
static Reachability *reach;

HardwareUtils::HardwareUtils(QObject *parent):
    QObject(parent)
{
    hwclass = [[HWClass alloc] initWithHwObject: this];

    // Allocate a reachability object
    reach = [Reachability reachabilityForInternetConnection];

    // Here we set up a NSNotification observer.
    [[NSNotificationCenter defaultCenter] addObserver:hwclass
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [reach startNotifier];
}

HardwareUtils::~HardwareUtils()
{
    [[NSNotificationCenter defaultCenter] removeObserver:hwclass];
    [reach release];
    [hwclass release];
}

void HardwareUtils::showAlertMessage(QString title, QString message, QString buttontext)
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
            initWithTitle:[NSString stringWithUTF8String: title.toUtf8().data()]
            message:[NSString stringWithUTF8String: message.toUtf8().data()]
            delegate:nil
            cancelButtonTitle:[NSString stringWithUTF8String: buttontext.toUtf8().data()]
            otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

int HardwareUtils::getNetworkStatus()
{
    return (int)[reach currentReachabilityStatus];
}