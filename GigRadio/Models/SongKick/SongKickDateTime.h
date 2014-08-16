//
//  SongKickDateTime.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>

@interface SongKickDateTime : RLMObject
@property (nonatomic, strong) NSDate * datetime;
@property (nonatomic, strong) NSDate * date;
//@property (nonatomic, strong) NSDateComponents * time;
+(NSDictionary*)dictionaryConvertedFromJSON:(NSDictionary*)dict;
@end
RLM_ARRAY_TYPE(SongKickDateTime)
