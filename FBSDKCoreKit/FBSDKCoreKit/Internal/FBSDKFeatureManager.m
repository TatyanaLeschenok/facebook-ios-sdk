// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "FBSDKFeatureManager.h"
#import "ServerConfiguration/FBSDKGateKeeperManager.h"

@implementation FBSDKFeatureManager

+ (BOOL)isEnabled:(FBSDKFeature)feature
{
  if (FBSDKFeatureCore == feature) {
    return YES;
  }

  FBSDKFeature parentFeature = [self getParentFeature:feature];
  if (parentFeature == feature) {
    return [self checkGK:feature];
  } else {
    return [FBSDKFeatureManager isEnabled:parentFeature] && [self checkGK:feature];
  }
}

+ (FBSDKFeature)getParentFeature:(FBSDKFeature)feature
{
  if ((feature & 0xFF) > 0) {
    return feature & 0xFFFF00;
  } else if ((feature & 0xFF00) > 0) {
    return feature & 0xFF0000;
  } else return 0;
}

+ (BOOL)checkGK:(FBSDKFeature)feature
{
  NSString *key = [NSString stringWithFormat:@"fb_sdk_feature_%@", [self featureName:feature]];
  BOOL defaultValue = [self defaultStatus:feature];

  return [FBSDKGateKeeperManager boolForKey:key
                               defaultValue:defaultValue];
}

+ (NSString *)featureName:(FBSDKFeature)feature
{
  NSString *featureName;
  switch (feature) {
    case FBSDKFeatureCore: featureName = @"core_kit"; break;
    case FBSDKFeatureAppEvents: featureName = @"app_events"; break;
    case FBSDKFeatureCodelessEvents: featureName = @"codeless_events"; break;
    case FBSDKFeatureRestrictiveDataFiltering: featureName = @"restrictive_data_filtering"; break;

    case FBSDKFeatureLogin: featureName = @"login_kit"; break;

    case FBDSDKFeatureShare: featureName = @"share_kit"; break;

    case FBSDKFeaturePlaces: featureName = @"places_kit"; break;
  }

  return featureName;
}

+ (BOOL)defaultStatus:(FBSDKFeature)feature
{
  return YES;
}

@end
