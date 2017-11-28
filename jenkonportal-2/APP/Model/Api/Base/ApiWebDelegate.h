//
//  ApiWebDelegate.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ApiRespModel.h"

static NSString * const POST = @"POST";
static NSString * const GET = @"GET";

@protocol ApiWebDelegate <NSObject>

- (void)method:(NSString *)method url:(NSString *)url charsParams:(NSDictionary *)params constructingBodyStream:(void (^)(id <AFMultipartFormData> stream))coustructing onSuccess:(void (^)(id responseObject))success onFailure:(void (^)(NSError *error))failure;

@end
