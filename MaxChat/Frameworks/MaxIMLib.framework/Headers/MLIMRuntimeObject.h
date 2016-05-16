//
//  MLIMRuntimeObject.h
//  MaxIMLib
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Base class to support dynamic property storage.
 */
@interface MLIMRuntimeObject : NSObject

/**
 *  Initializes a newly allocated runtime object with a dictionary.
 *
 *  @param dictionary A dictionary containing the keys and values with which 
 *  to initialize the new runtime object.
 *
 *  @return An initialized runtime object containing the entries found in dictionary.
 */
- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary NS_DESIGNATED_INITIALIZER;

/**
 *  Returns a dictionary which represents a `MLIMRuntimeObject`. The dictionary contains
 *  all key-values except the properties which have ivars.
 *
 *  @return A dictionary represents the receiver.
 */
- (NSDictionary<NSString *, id> *)dictionaryRepresentation;

/**
 *  Adds to the receiving runtime object the entries from the dictionary.
 *
 *  If runtime object and the dictionary contain the same key, the runtime
 *  object’s previous value object for that key is sent a release message,
 *  and the new value object takes its place.
 *
 *  @param dictionary The dictionary from which to add entries
 */
- (void)addEntriesFromDictionary:(NSDictionary<NSString *, id> *)dictionary;

/**
 *  Return the property by default. Subclass can overide the method to return a
 *  different `keyPath` for a `property`.
 *
 *  @param property The name of dynamic property.
 *
 *  @return A key path of the form relationship.property, for example `department.name`
 */
- (NSString *)keyPathForProperty:(NSString *)property;

/**
 *  Returns the object associated with a given property name. The method will get
 *  keyPath for the property and then call `objectForKey:`.
 *
 *  @param propertyName The name of a property
 *
 *  @return The value object associated with the given property.
 */
- (nullable id)valueForPropertyName:(NSString *)propertyName;

/**
 *  Sets the value associated with a given property.
 *
 *  @discussion Setting `nil` for `key` results in unsetting the key on the object.
 *              If you need to represent a `nil` value, use `NSNull`.
 *
 *  @param value        The new value object for the property. A strong reference
 *  to the value object is maintained by `MLIMRuntimeObject`.
 *  @param propertyName The property name, MUST NOT be `nil`.
 */
- (void)setValue:(nullable id)value forPropertyName:(NSString *)propertyName;

/**
 *  Returns the object associated with a given key.
 *
 *  @param key The key that the object is associated with.
 *  @return The value associated with the given key, or nil if no value is associated with key.
 */
- (nullable id)objectForKey:(NSString *)key;

/**
 *  Sets the object associated with a given key.
 *
 *  @discussion Setting `nil` for `key` results in unsetting the key on the object.
 *              If you need to represent a `nil` value, use `NSNull`.
 *
 *  @param object  The object for `key`. A strong reference to the object is 
 *  maintained by `MLIMRuntimeObject`.
 *  @param key     The key. Raises an `NSInvalidArgumentException` if `key` is `nil`.
 */
- (void)setObject:(nullable id)object forKey:(NSString *)key;

/**
 *  In LLVM 4.0 (XCode 4.5) or higher allows myObject[key].
 *
 *  @param key The key.
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/**
 *  In LLVM 4.0 (XCode 4.5) or higher allows myObject[key] = value
 *
 *  @discussion Setting `nil` for `key` results in unsetting the key on the object.
 *  If you need to represent a `nil` value, use `NSNull`.
 *
 *  @param object   The object. A strong reference to the object is maintained by 
 *  `MLIMRuntimeObject`.
 *  @param key      The key. Raises an `NSInvalidArgumentException` if `key` is `nil`.
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
