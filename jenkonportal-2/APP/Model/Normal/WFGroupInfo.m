//
//  RCDGroupInfo.m
//  RCloudMessage
//


#import "WFGroupInfo.h"

@implementation WFGroupInfo
#define KEY_RCDGROUP_INFO_NUMBER @"number"

- (instancetype)initWithCoder:(NSCoder *)decoder {
  if (self = [super initWithCoder:decoder]) {
    if (decoder == nil) {
      return self;
    }
    //
    self.number = [decoder decodeObjectForKey:KEY_RCDGROUP_INFO_NUMBER];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeObject:self.number forKey:KEY_RCDGROUP_INFO_NUMBER];
}
@end
