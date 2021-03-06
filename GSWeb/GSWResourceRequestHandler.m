/** GSWResourceRequestHandler.m - <title>GSWeb: Class GSWResourceRequestHandler</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
   $Revision$
   $Date$
   $Id$

   This file is part of the GNUstep Web Library.
   
   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

#include "GSWeb.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

//====================================================================
@implementation GSWResourceRequestHandler

-(GSWResponse*)_404ResponseForPath:(NSString*)aPath
{
  GSWResponse * aResponse = [GSWApp createResponseInContext:nil];
  
  [aResponse setStatus:404];
  [aResponse setHeader:@"0"
                forKey:GSWHTTPHeader_ContentLength];
  return aResponse;
}


-(NSString*) _filepathForUripath:(NSString*) uri
{
  // testpic.jpg
  NSString * filePath  = nil;
  NSString * framework = nil;
  NSRange range = [uri rangeOfString:@"/"];
  
  if (range.location == NSNotFound) {
    // app wrapper resource
    framework = nil;
  } else {
    framework = [uri substringToIndex:range.location];
    range = [uri rangeOfString:@"/"
                       options:NSBackwardsSearch];
    if ((range.location != NSNotFound)) {
      uri = [uri substringFromIndex:range.location+1];
    }
  }

  
  range = [uri rangeOfString:@".."
                     options:NSBackwardsSearch];
  
  if ((range.location != NSNotFound)) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Resource paths containing '..' are not accepted."];  
  }

  range = [uri rangeOfString:@"~'"
                     options:NSBackwardsSearch];
  
  if ((range.location != NSNotFound)) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Resource paths containing '~' are not accepted."];  
  }
  
  range = [uri rangeOfString:@".wo"
                     options:NSBackwardsSearch];
  
  if ((range.location != NSNotFound)) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Resource paths containing '.wo' are not accepted."];  
  }

  range = [uri rangeOfString:@".wod"
                     options:NSBackwardsSearch];
  
  if ((range.location != NSNotFound)) {
    [NSException raise:NSInvalidArgumentException 
                format:@"Resource paths containing '.wod' are not accepted."];  
  }
  
  
  filePath = [[GSWApp resourceManager] pathForResourceNamed:uri
                                                inFramework:framework
                                                   language:nil];  
  return filePath;
}

-(GSWResponse*)handleRequest:(GSWRequest*)aRequest
{
  GSWResponse         * response=nil;
  NSString            * wodataValue=nil;
//  NSDictionary        * elements=nil;
  GSWDynamicURLString * uri = nil;
  NSString            * urlRequestHandlerPath = nil;
  NSString            * filePath = nil;
  
  uri = [aRequest uri];
  urlRequestHandlerPath = [uri urlRequestHandlerPath];
  
  //  elements=[aRequest uriOrFormOrCookiesElements];
  //  gswdata=[elements objectForKey:GSWKey_Data[GSWebNamingConv]];
  
  wodataValue = [aRequest stringFormValueForKey:@"wodata"];
  if (wodataValue)
  {
    response = [self _responseForDataCachedWithKey:wodataValue];
  } else {    
    filePath = [self _filepathForUripath:urlRequestHandlerPath];
    
    response = [self _responseForDataAtPath:filePath request:aRequest];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DidHandleRequestNotification
                                                      object:response
                                                    userInfo:nil];
  
  [response _finalizeInContext:nil];
  return response;
}

//--------------------------------------------------------------------
-(GSWResponse*)_responseForJavaClassAtPath:(NSString*)aPath
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataAtPath:(NSString*)aPath 
                              request:(GSWRequest*)aRequest
{
  NSString      * contentType;
  NSData        * fileData;
  GSWResponse   * aResponse;
  NSDictionary  * attributes;
  NSDate        * modDate;
  NSString      * eTagString;
  NSString      * dateString;
  NSString      * hashString;
  NSString      * ifNoneMatchValue;
  
  attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:aPath 
                                                                error:NULL];
  modDate = [attributes fileModificationDate];

  if (!modDate) {
    return [self _404ResponseForPath:aPath];
  }
  
  dateString = [modDate descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S GMT"
                                             timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
                                               locale:nil];

NSLog(@"dateString is %@", dateString);

  aResponse = [GSWApp createResponseInContext:nil];
  
  [aResponse setHeader:dateString
                forKey:@"Last-Modified"];

  hashString = [NSString stringWithFormat:@"%@-%@", dateString, [attributes objectForKey:NSFileSize]];
  
  eTagString = [NSString stringWithFormat:@"%lx", (unsigned long) [hashString hash]];
  
  [aResponse setHeader:eTagString
                forKey:@"ETag"];
  
  ifNoneMatchValue = [aRequest headerForKey:@"if-none-match"];

  if ([ifNoneMatchValue isEqualToString:eTagString]) {
    // return 304 Not Modified
    [aResponse setStatus:304];  
    
  } else {
    
    fileData = [NSData dataWithContentsOfFile:aPath];
    [aResponse setContent:fileData];
    [aResponse setStatus:200];
  }
  
  contentType = [[GSWApp resourceManager] contentTypeForResourcePath:aPath];
  
  if (contentType)
  {
    [aResponse setHeader:contentType
                  forKey:GSWHTTPHeader_ContentType];
  }
  
  
  return aResponse;
}

//--------------------------------------------------------------------
-(GSWResponse*)_responseForDataCachedWithKey:(NSString*)aKey
{
  //OK
  GSWResponse* response=nil;
  GSWResourceManager* resourceManager=nil;
  GSWURLValuedElementData* data=nil;

  response=[GSWApp createResponseInContext:nil];
  resourceManager=[[GSWApplication application] resourceManager];
  data=[resourceManager _cachedDataForKey:aKey];

  if (data)
    [data appendToResponse:response
          inContext:nil];
  else
    {
//      LOGSeriousError(@"No data for key '%@'",
//                      aKey);
      //TODO
    };
  return response;
};

//--------------------------------------------------------------------
-(GSWResponse*)_generateResponseForData:(NSData*)aData
                               mimeType:(NSString*)mimeType
{
  [self notImplemented: _cmd];	//TODOFN
  return nil;
};


//--------------------------------------------------------------------
+(id)handler
{
  return [[GSWResourceRequestHandler new] autorelease];
};

@end

