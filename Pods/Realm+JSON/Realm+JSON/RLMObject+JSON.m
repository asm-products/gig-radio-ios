//
//  RLMObject+JSON.m
//  RealmJSONDemo
//
//  Created by Matthew Cheok on 27/7/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "RLMObject+JSON.h"
#import <objc/runtime.h>

static id MCValueFromInvocation(id object, SEL selector) {
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
	invocation.target = object;
	invocation.selector = selector;
	[invocation invoke];

	__unsafe_unretained id result = nil;
	[invocation getReturnValue:&result];

	return result;
}

static NSString *MCTypeStringFromPropertyKey(Class class, NSString *key) {
	const objc_property_t property = class_getProperty(class, [key UTF8String]);
    if (!property) {
        [NSException raise:NSInternalInconsistencyException format:@"Class %@ does not have property %@", class, key];
    }
	const char *type = property_getAttributes(property);
	return [NSString stringWithUTF8String:type];
}

@interface NSString (MCJSON)

- (NSString *)snakeToCamelCase;
- (NSString *)camelToSnakeCase;

@end

@implementation RLMObject (JSON)

+ (NSArray *)createInRealm:(RLMRealm *)realm withJSONArray:(NSArray *)array {
    NSMutableArray *result = [NSMutableArray array];
    
	[realm beginWriteTransaction];
	for (NSDictionary *dictionary in array) {
		id object = [self mc_createOrUpdateInRealm:realm withJSONDictionary:dictionary];
        [result addObject:object];
	}
	[realm commitWriteTransaction];
    
    return [result copy];
}

+ (instancetype)createInRealm:(RLMRealm *)realm withJSONDictionary:(NSDictionary *)dictionary {
	[realm beginWriteTransaction];
	id object = [self mc_createOrUpdateInRealm:realm withJSONDictionary:dictionary];
	[realm commitWriteTransaction];

	return object;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary {
	self = [super init];
	if (self) {
		[self mc_setValuesFromJSONDictionary:dictionary inRealm:nil];
	}
	return self;
}

- (NSDictionary *)JSONDictionary {
	return [self mc_createJSONDictionary];
}

#pragma mark - Private

+ (instancetype)mc_createFromJSONDictionary:(NSDictionary *)dictionary {
	id object = [[self alloc] init];
	[object mc_setValuesFromJSONDictionary:dictionary inRealm:nil];
	return object;
}

+ (instancetype)mc_createOrUpdateInRealm:(RLMRealm *)realm withJSONDictionary:(NSDictionary *)dictionary {
	if (!dictionary || [dictionary isEqual:[NSNull null]]) {
		return nil;
	}

	NSString *primaryKey = nil;
	NSString *primaryPredicate = nil;
	NSString *primaryKeyPath = nil;
//	if (!primaryKey) {
	SEL selector = NSSelectorFromString(@"primaryKey");
	if ([self respondsToSelector:selector]) {
		primaryKey = MCValueFromInvocation(self, selector);
	}

	if (primaryKey) {
		NSDictionary *inboundMapping = [self mc_inboundMapping];
		primaryKeyPath = [[inboundMapping allKeysForObject:primaryKey] firstObject];
		primaryPredicate = [NSString stringWithFormat:@"%@ = %%@", primaryKey];
	}
//	}

	id object = nil;
	if (primaryKey) {
		id primaryKeyValue = [dictionary valueForKeyPath:primaryKeyPath];
		RLMArray *array = [self objectsInRealm:realm where:primaryPredicate, primaryKeyValue];

		if (array.count > 0) {
			object = [array firstObject];
			[object mc_setValuesFromJSONDictionary:dictionary inRealm:realm];
//			NSLog(@"updated object with \"%@\" value %@", primaryKey, primaryKeyValue);
		}
	}

	if (!object) {
		object = [[self alloc] init];
		[object mc_setValuesFromJSONDictionary:dictionary inRealm:realm];
		[realm addObject:object];
//		NSLog(@"created object with \"%@\" value %@", primaryKey, [dictionary valueForKeyPath:primarykeyPath]);
	}

	return object;
}

- (void)mc_setValuesFromJSONDictionary:(NSDictionary *)dictionary inRealm:(RLMRealm *)realm {
	NSDictionary *mapping = [[self class] mc_inboundMapping];

	for (NSString *dictionaryKeyPath in mapping) {
		NSString *objectKeyPath = mapping[dictionaryKeyPath];

		id value = [dictionary valueForKeyPath:dictionaryKeyPath];

		if (value) {
			Class modelClass = [[self class] mc_normalizedClass];
			Class propertyClass = [modelClass mc_classForPropertyKey:objectKeyPath];
			SEL selector = NSSelectorFromString([objectKeyPath stringByAppendingString:@"JSONTransformer"]);

			if ([propertyClass isSubclassOfClass:[RLMObject class]]) {
				if (!value || [value isEqual:[NSNull null]]) {
					continue;
				}

				if (realm) {
					value = [propertyClass mc_createOrUpdateInRealm:realm withJSONDictionary:value];
				}
				else {
					value = [propertyClass mc_createFromJSONDictionary:value];
				}
			}
			else if ([propertyClass isSubclassOfClass:[RLMArray class]]) {
				RLMArray *array = [self valueForKeyPath:objectKeyPath];
				[array removeAllObjects];

				Class itemClass = NSClassFromString(array.objectClassName);
				for (NSDictionary *itemDictionary in(NSArray *) value) {
					if (realm) {
						id item = [itemClass mc_createOrUpdateInRealm:realm withJSONDictionary:itemDictionary];
						[array addObject:item];
					}
					else {
						id item = [itemClass mc_createFromJSONDictionary:value];
						[array addObject:item];
					}
				}
				continue;
			}
			else {
				NSValueTransformer *transformer = nil;
				if ([modelClass respondsToSelector:selector]) {
					transformer = MCValueFromInvocation(modelClass, selector);
				}
				else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
					transformer = [NSValueTransformer valueTransformerForName:MCJSONDateTimeTransformerName];
				}

				if (transformer) {
                    if ([value isEqual:[NSNull null]]) {
                        value = nil;
                    }
					value = [transformer transformedValue:value];
                    if (!value) {
                        value = [NSNull null];
                    }
				}

				if ([value isEqual:[NSNull null]]) {
                    if ([propertyClass isSubclassOfClass:[NSDate class]]) {
						value = [NSDate distantPast];
					}
					else if ([propertyClass isSubclassOfClass:[NSString class]]) {
						value = @"";
					}
					else {
						value = @0;
					}
				}
			}

			[self setValue:value forKeyPath:objectKeyPath];
		}
	}
}

- (NSDictionary *)mc_createJSONDictionary {
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSDictionary *mapping = [[self class] mc_outboundMapping];

	for (NSString *objectKeyPath in mapping) {
		NSString *dictionaryKeyPath = mapping[objectKeyPath];

		id value = [self valueForKeyPath:objectKeyPath];
		if (value) {
			Class modelClass = [[self class] mc_normalizedClass];
			Class propertyClass = [modelClass mc_classForPropertyKey:objectKeyPath];
			SEL selector = NSSelectorFromString([objectKeyPath stringByAppendingString:@"JSONTransformer"]);

			if ([propertyClass isSubclassOfClass:[RLMObject class]]) {
				value = [value mc_createJSONDictionary];
			}
			else if ([propertyClass isSubclassOfClass:[RLMArray class]]) {
				NSMutableArray *array = [NSMutableArray array];
				for (id item in(RLMArray *) value) {
					[array addObject:[item mc_createJSONDictionary]];
				}
				value = [array copy];
			}
			else {
				NSValueTransformer *transformer = nil;
				if ([modelClass respondsToSelector:selector]) {
					transformer = MCValueFromInvocation(modelClass, selector);
				}
				else if ([propertyClass isSubclassOfClass:[NSDate class]]) {
					transformer = [NSValueTransformer valueTransformerForName:MCJSONDateTimeTransformerName];
				}

				if (transformer) {
					value = [transformer reverseTransformedValue:value];
				}
			}

			NSArray *keyPathComponents = [dictionaryKeyPath componentsSeparatedByString:@"."];
			id currentDictionary = result;
			for (NSString *component in keyPathComponents) {
				if ([currentDictionary valueForKey:component] == nil) {
					[currentDictionary setValue:[NSMutableDictionary dictionary] forKey:component];
				}
				currentDictionary = [currentDictionary valueForKey:component];
			}

			[result setValue:value forKeyPath:dictionaryKeyPath];
		}
	}

	return [result copy];
}

#pragma mark - Properties

+ (NSDictionary *)mc_defaultInboundMapping {
	unsigned count = 0;
	objc_property_t *properties = class_copyPropertyList(self, &count);

	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for (unsigned i = 0; i < count; i++) {
		objc_property_t property = properties[i];
		NSString *name = [NSString stringWithUTF8String:property_getName(property)];
		result[[name camelToSnakeCase]] = name;
	}

	return [result copy];
}

+ (NSDictionary *)mc_defaultOutboundMapping {
	unsigned count = 0;
	objc_property_t *properties = class_copyPropertyList(self, &count);

	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for (unsigned i = 0; i < count; i++) {
		objc_property_t property = properties[i];
		NSString *name = [NSString stringWithUTF8String:property_getName(property)];
		result[name] = [name camelToSnakeCase];
	}

	return [result copy];
}

#pragma mark - Convenience Methods

+ (Class)mc_normalizedClass {
	NSString *className = NSStringFromClass(self);
	className = [className stringByReplacingOccurrencesOfString:@"RLMAccessor_" withString:@""];
	className = [className stringByReplacingOccurrencesOfString:@"RLMStandalone_" withString:@""];
	return NSClassFromString(className);
}

+ (NSDictionary *)mc_inboundMapping {
	Class objectClass = [self mc_normalizedClass];
	static NSMutableDictionary *mappingForClassName = nil;
	if (!mappingForClassName) {
		mappingForClassName = [NSMutableDictionary dictionary];
	}

	NSDictionary *mapping = mappingForClassName[[objectClass description]];
	if (!mapping) {
		SEL selector = NSSelectorFromString(@"JSONInboundMappingDictionary");
		if ([objectClass respondsToSelector:selector]) {
			mapping = MCValueFromInvocation(objectClass, selector);
		}
		else {
			mapping = [objectClass mc_defaultInboundMapping];
		}
		mappingForClassName[[objectClass description]] = mapping;
	}
	return mapping;
}

+ (NSDictionary *)mc_outboundMapping {
	Class objectClass = [self mc_normalizedClass];
	static NSMutableDictionary *mappingForClassName = nil;
	if (!mappingForClassName) {
		mappingForClassName = [NSMutableDictionary dictionary];
	}

	NSDictionary *mapping = mappingForClassName[[objectClass description]];
	if (!mapping) {
		SEL selector = NSSelectorFromString(@"JSONOutboundMappingDictionary");
		if ([objectClass respondsToSelector:selector]) {
			mapping = MCValueFromInvocation(objectClass, selector);
		}
		else {
			mapping = [objectClass mc_defaultOutboundMapping];
		}
		mappingForClassName[[objectClass description]] = mapping;
	}
	return mapping;
}

+ (Class)mc_classForPropertyKey:(NSString *)key {
	NSString *attributes = MCTypeStringFromPropertyKey(self, key);
	if ([attributes hasPrefix:@"T@"]) {
        static NSCharacterSet *set = nil;
        if (!set) {
            set = [NSCharacterSet characterSetWithCharactersInString:@"\"<"];
        }
        
		NSString *string;
		NSScanner *scanner = [NSScanner scannerWithString:attributes];
        scanner.charactersToBeSkipped = set;
        [scanner scanUpToCharactersFromSet:set intoString:NULL];
        [scanner scanUpToCharactersFromSet:set intoString:&string];
		return NSClassFromString(string);
	}
	return nil;
}

@end

@implementation NSString (MCJSON)

- (NSString *)snakeToCamelCase {
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSCharacterSet *underscoreSet = [NSCharacterSet characterSetWithCharactersInString:@"_"];
	scanner.charactersToBeSkipped = underscoreSet;

	NSMutableString *result = [NSMutableString string];
	NSString *buffer = nil;

	while (![scanner isAtEnd]) {
		BOOL atStartPosition = scanner.scanLocation == 0;
		[scanner scanUpToCharactersFromSet:underscoreSet intoString:&buffer];
		[result appendString:atStartPosition ? buffer:[buffer capitalizedString]];
	}

	return result;
}

- (NSString *)camelToSnakeCase {
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
	scanner.charactersToBeSkipped = uppercaseSet;

	NSMutableString *result = [NSMutableString string];
	NSString *buffer = nil;

	while (![scanner isAtEnd]) {
		[scanner scanUpToCharactersFromSet:uppercaseSet intoString:&buffer];
		[result appendString:[buffer lowercaseString]];

		if (![scanner isAtEnd]) {
			[result appendString:@"_"];
			[result appendString:[[self substringWithRange:NSMakeRange(scanner.scanLocation, 1)] lowercaseString]];
		}
	}

	return result;
}

@end
