//
//  Prefix header
//
//  The contents of this file are implicitly included at the beginning of every source file.
//



#define kTextColor                  UIColorFromRGB(0x404040)
#define kNavigationBGColor          UIColorFromRGB(0x27AE60)
#define kMainBGColor                UIColorFromRGB(0xFF7700)
#define kDefaultTextColor           UIColorFromRGB(0x444444)
#define kDefaultGrayColor           UIColorFromRGB(0x8F8F8F)
#define kSeparatorLineColor         [UIColor groupTableViewBackgroundColor]

#define kRecentChatsUpdatedNotification         @"kRecentChatsUpdatedNotification"
#define kMaxLeapDidLoginNofitification          @"kMaxLeapDidLoginNofitification"
#define kMaxLeapDidLogoutNofitification         @"kMaxLeapDidLogoutNofitification"


#define ImageNamed(x)               [UIImage imageNamed:x]
#define SAFE_STRING(string)         string ?: @""
#define SAFE_Array(array)           array ?: @[]

#define IMCurrentClient             [MaxChatIMClient sharedInstance].client
#define IMCurrentUser               [MaxChatIMClient sharedInstance].client.currentUser
#define IMCurrentUserID             [MaxChatIMClient sharedInstance].client.currentUser.uid

#define MaxLeapSignedUser           (([MLUser currentUser] && ![MLAnonymousUtils isLinkedWithUser:[MLUser currentUser]]) ? [MLUser currentUser] : nil)
#define MaxLeapSignedUserId         MaxLeapSignedUser.username

#define MaxSocialUserWithId(uid)    [MaxSocialUser userWithId: uid]
#define MaxSocialCurrentUser        (([MLUser currentUser] && ![MLAnonymousUtils isLinkedWithUser:[MLUser currentUser]]) ? [MaxSocialUser userWithId: [MLUser currentUser].username] : nil)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBWithAlpha( rgbValue, a ) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define ScreenRect [[UIScreen mainScreen] bounds]


#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

#define BLOCK_SAFE_ASY_RUN_MainQueue(block, ...) block ? dispatch_async(dispatch_get_main_queue(), ^{\
BLOCK_SAFE_RUN(block,__VA_ARGS__); \
}): nil

#define BLOCK_SAFE_ASY_RUN_GlobalQueue(block, ...) block ? dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){\
BLOCK_SAFE_RUN(block,__VA_ARGS__); \
}): nil

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define JSON_STRING_WITH_OBJ(obj) (obj?[[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:nil] encoding:NSUTF8StringEncoding]:nil)
#define JSON_OBJECT_WITH_STRING(string) (string?[NSJSONSerialization JSONObjectWithData: [string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil]:nil)