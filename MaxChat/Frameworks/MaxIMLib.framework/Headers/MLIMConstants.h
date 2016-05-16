//
//  MLIMConstants.h
//  MaxLeapIM
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const MLIMErrorDomain;

typedef NS_ENUM(NSInteger, MLIMErrorCode) {
    kMLIMErrorUnknown = 1,
    kMLIMErrorInvalidParameter = 5001,
    kMLIMErrorServerDBError = 5002,
    kMLIMErrorNoPermission = 5003,
    kMLIMErrorNotFound = 5004,
    kMLIMErrorParameterConflict = 5005,
    kMLIMErrorS3UploadFailed = 5006,
    kMLIMErrorImageProcessingError = 5007,
    kMLIMErrorHitTheLimit = 5008
};

typedef void (^MLIMBooleanResultBlock)(BOOL succeeded, NSError *__nullable error);
typedef void (^MLIMIdResultBlock)(id __nullable object, NSError *__nullable error);
typedef void (^MLIMProgressBlock)(int percentDone);
typedef void (^MLIMStringResultBlock)(NSString *__nullable string, NSError *__nullable error);


NS_ASSUME_NONNULL_END

