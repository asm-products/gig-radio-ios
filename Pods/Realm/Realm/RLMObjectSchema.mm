////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMObjectSchema_Private.hpp"
#import "RLMObject_Private.h"
#import "RLMProperty_Private.h"
#import "RLMSchema_Private.h"
#import "RLMSwiftSupport.h"
#import "RLMUtil.hpp"

#import <tightdb/table.hpp>

// private properties
@interface RLMObjectSchema ()
@property (nonatomic, readwrite) NSDictionary *propertiesByName;
@property (nonatomic, readwrite, assign) NSString *className;
@end

@implementation RLMObjectSchema

- (instancetype)initWithClassName:(NSString *)objectClassName objectClass:(Class)objectClass properties:(NSArray *)properties {
    self = [super init];
    self.className = objectClassName;
    self.properties = properties;
    self.objectClass = objectClass;
    return self;
}

// return properties by name
-(RLMProperty *)objectForKeyedSubscript:(id <NSCopying>)key {
    return _propertiesByName[key];
}

// create property map when setting property array
-(void)setProperties:(NSArray *)properties {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:_properties.count];
    for (RLMProperty *prop in properties) {
        map[prop.name] = prop;
    }
    _propertiesByName = map;
    _properties = properties;
}

- (void)setPrimaryKeyProperty:(RLMProperty *)primaryKeyProperty {
    _primaryKeyProperty.isPrimary = NO;
    primaryKeyProperty.isPrimary = YES;
    _primaryKeyProperty = primaryKeyProperty;
}

+ (instancetype)schemaForObjectClass:(Class)objectClass {
    return [self schemaForObjectClass:objectClass createAccessors:NO];
}

+ (instancetype)schemaForObjectClass:(Class)objectClass createAccessors:(BOOL)create {
    RLMObjectSchema *schema = [RLMObjectSchema new];
    schema.className = [objectClass className];
    schema.objectClass = objectClass;

    // create array of RLMProperties
    schema.properties = [self propertiesForClass:objectClass];

    if (NSString *primaryKey = [objectClass primaryKey]) {
        for (RLMProperty *prop in schema.properties) {
            if ([primaryKey isEqualToString:prop.name]) {
                // FIXME - re-enable when we have core suppport
                //attr = attr | RLMPropertyAttributeIndexed;
                schema.primaryKeyProperty = prop;
                break;
            }
        }

        if (!schema.primaryKeyProperty) {
            NSString *message = [NSString stringWithFormat:@"Primary key property '%@' does not exist on object '%@'",
                                 primaryKey, schema.className];
            @throw [NSException exceptionWithName:@"RLMException" reason:message userInfo:nil];
        }
        if (schema.primaryKeyProperty.type != RLMPropertyTypeInt && schema.primaryKeyProperty.type != RLMPropertyTypeString) {
            @throw [NSException exceptionWithName:@"RLMException"
                                           reason:@"Only 'string' and 'int' properties can be designated the primary key"
                                         userInfo:nil];
        }
    }

    if (create) {
        schema.standaloneClass = RLMStandaloneAccessorClassForObjectClass(objectClass, schema);

        RLMReplaceSharedSchemaMethod(objectClass, schema);
        RLMReplaceClassNameMethod(objectClass, schema.className);
    }

    return schema;
}

+ (NSArray *)propertiesForClass:(Class)objectClass {
    NSArray *ignoredProperties = [objectClass ignoredProperties];

    // For Swift classes we need an instance of the object when parsing properties
    id swiftObjectInstance = nil;
    BOOL isSwiftClass = [RLMSwiftSupport isSwiftClassName:NSStringFromClass(objectClass)];
    if (isSwiftClass) {
        swiftObjectInstance = [[objectClass alloc] init];
    }

    unsigned int count;
    objc_property_t *props = class_copyPropertyList(objectClass, &count);
    NSMutableArray *propArray = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        NSString *propertyName = @(property_getName(props[i]));
        if ([ignoredProperties containsObject:propertyName]) {
            continue;
        }

        RLMPropertyAttributes atts = [objectClass attributesForProperty:propertyName];
        if (isSwiftClass) {
            [propArray addObject:[[RLMProperty alloc] initSwiftPropertyWithName:propertyName
                                                                     attributes:atts
                                                                       property:props[i]
                                                                       instance:swiftObjectInstance]];
        }
        else {
            [propArray addObject:[[RLMProperty alloc] initWithName:propertyName attributes:atts property:props[i]]];
        }
    }
    free(props);

    return propArray;
}


// generate a schema from a table - specify the custom class name for the dynamic
// class and the name to be used in the schema - used for migrations and dynamic interface
+(instancetype)schemaFromTableForClassName:(NSString *)className realm:(RLMRealm *)realm {
    tightdb::TableRef table = RLMTableForObjectClass(realm, className);
    if (!table) {
        return nil;
    }
    
    // create array of RLMProperties
    size_t count = table->get_column_count();
    NSMutableArray *propArray = [NSMutableArray arrayWithCapacity:count];
    for (size_t col = 0; col < count; col++) {
        // create new property
        NSString *name = RLMStringDataToNSString(table->get_column_name(col).data());
        RLMProperty *prop = [[RLMProperty alloc] initWithName:name
                                                         type:RLMPropertyType(table->get_column_type(col))
                                              objectClassName:nil
                                                   attributes:(RLMPropertyAttributes)0];
        prop.column = col;
        if (prop.type == RLMPropertyTypeObject || prop.type == RLMPropertyTypeArray) {
            // set link type for objects and arrays
            tightdb::TableRef linkTable = table->get_link_target(col);
            prop.objectClassName = RLMClassForTableName(@(linkTable->get_name().data()));
        }

        [propArray addObject:prop];
    }

    // create schema object and set properties
    RLMObjectSchema *schema = [RLMObjectSchema new];
    schema.properties = propArray;
    schema.className = className;

    // get primary key from realm metadata
    NSString *primaryKey = RLMRealmPrimaryKeyForObjectClass(realm, className);
    if (primaryKey) {
        schema.primaryKeyProperty = schema[primaryKey];
        if (!schema.primaryKeyProperty) {
            NSString *reason = [NSString stringWithFormat:@"No property matching primary key '%@'", primaryKey];
            @throw [NSException exceptionWithName:@"RLMException" reason:reason userInfo:nil];
        }
    }

    // for dynamic schema use vanilla RLMObject accessor classes
    schema.objectClass = RLMObject.class;
    schema.standaloneClass = RLMObject.class;

    return schema;
}

- (id)copyWithZone:(NSZone *)zone {
    RLMObjectSchema *schema = [[RLMObjectSchema allocWithZone:zone] init];
    schema.properties = self.properties;
    schema.objectClass = self.objectClass;
    schema.className = self.className;
    schema.primaryKeyProperty = schema[_primaryKeyProperty.name];
    return schema;
}

@end
