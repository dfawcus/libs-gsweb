/** GSWResourceManager.m - <title>GSWeb: Class GSWResourceManager</title>
   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$
   
   <abstract></abstract>

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

static char rcsId[] = "$Id$";

#include "GSWeb.h"


//====================================================================
@implementation GSWResourceManager

GSWBundle* globalAppGSWBundle=nil;
GSWProjectBundle* globalAppProjectBundle=nil;
NSDictionary* globalMime=nil;
NSString* globalMimePListPathName=nil;
NSDictionary* localGS2ISOLanguages=nil;
NSDictionary* localISO2GSLanguages=nil;
NSString* globalLanguagesPListPathName=nil;
NSString* localNotFoundMarker=@"NOTFOUND";
//--------------------------------------------------------------------
+(void)initialize
{
  if (self==[GSWResourceManager class])
    {
      NSBundle* mainBundle=nil;
      GSWDeployedBundle* deployedBundle=nil;
      GSWLogC("Start GSWResourceManager +initialize");
      if ((self=[[super superclass] initialize]))
        {
          NSString* bundlePath=nil;
          mainBundle=[GSWApplication mainBundle];
          //NSDebugMLLog(@"resmanager",@"mainBundle:%p",mainBundle);
          //NSDebugMLLog(@"resmanager",@"mainBundle:%@",mainBundle);
          bundlePath=[mainBundle  bundlePath];
          //NSDebugMLLog(@"resmanager",@"bundlePath:%@",bundlePath);
          printf("bundlePath:%s",[bundlePath lossyCString]);
          deployedBundle=[GSWDeployedBundle bundleWithPath:bundlePath];
          //NSDebugMLLog(@"resmanager",@"deployedBundle:%@",deployedBundle);
	  
          globalAppProjectBundle=[[deployedBundle projectBundle] retain];
          //NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          NSAssert(globalAppProjectBundle,@"no globalAppProjectBundle");
          //		  LOGDumpObject(globalAppProjectBundle,2);
          //call  deployedBundle bundlePath
          //call  globalAppProjectBundle bundlePath
          //call isDebuggingEnabled
        };
      GSWLogC("Stop GSWResourceManager +init");
    };
};

//--------------------------------------------------------------------
+(void)dealloc
{
  GSWLogC("Dealloc GSWResourceManager Class");
  DESTROY(globalAppGSWBundle);
  DESTROY(globalAppProjectBundle);
  DESTROY(globalMime);
  DESTROY(globalMimePListPathName);
  DESTROY(localGS2ISOLanguages);
  DESTROY(localISO2GSLanguages);
  DESTROY(globalLanguagesPListPathName);
  GSWLogC("End Dealloc GSWResourceManager Class");
};

//--------------------------------------------------------------------
-(id)init
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      //TODO
      NSBundle* mainBundle=[NSBundle mainBundle];
      NSArray* allFrameworks=[NSBundle allFrameworks];
      int i=0;
      NSString* bundlePath=nil;
      NSBundle* bundle=nil;
      NSDictionary* infoDictionary=nil;
      for(i=0;i<[allFrameworks count];i++)
        {
          bundle=[allFrameworks objectAtIndex:i];
          bundlePath=[bundle bundlePath];
          NSDebugMLLog(@"resmanager",@"bundlePath=%@",bundlePath);
          //So what ?
        };
      
      _selfLock=[NSRecursiveLock new];
      
      [self _validateAPI];
      _frameworkProjectBundlesCache=[NSMutableDictionary new];
      _appURLs=[NSMutableDictionary new];
      _frameworkURLs=[NSMutableDictionary new];
      _appPaths=[NSMutableDictionary new];
      _frameworkPaths=[GSWMultiKeyDictionary new];
      _urlValuedElementsData=[NSMutableDictionary new];
      _stringsTablesByFrameworkByLanguageByName=[NSMutableDictionary new];
      _stringsTableArraysByFrameworkByLanguageByName=[NSMutableDictionary new];
      [self  _initFrameworkProjectBundles];
      //	  _frameworkPathsToFrameworksNames=[NSMutableDictionary new];

      allFrameworks=[NSBundle allFrameworks];
      for(i=0;i<[allFrameworks count];i++)
        {
          bundle=[allFrameworks objectAtIndex:i];
          infoDictionary=[bundle infoDictionary];
          //So what ?
          /*
            NSDebugMLLog(@"resmanager",@"****bundlePath=%@",bundlePath);
            NSDebugMLLog(@"resmanager",@"****[bundle bundleName]=%@",[bundle bundleName]);
            bundlePath=[bundle bundlePath];
            if ([bundle bundleName])
            [_frameworkPathsToFrameworksNames setObject:[bundle bundleName]
            forKey:bundlePath];					  
          */
        };
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWResourceManager");
  GSWLogC("Dealloc GSWResourceManager: _frameworkProjectBundlesCache");
  DESTROY(_frameworkProjectBundlesCache);
  GSWLogC("Dealloc GSWResourceManager: _appURLs");
  DESTROY(_appURLs);
  DESTROY(_frameworkURLs);
  DESTROY(_appPaths);
  DESTROY(_frameworkPaths);
  DESTROY(_urlValuedElementsData);
  DESTROY(_stringsTablesByFrameworkByLanguageByName);
  DESTROY(_stringsTableArraysByFrameworkByLanguageByName);
  DESTROY(_frameworkClassPaths);
//  DESTROY(_frameworkPathsToFrameworksNames);
  GSWLogC("Dealloc GSWResourceManager: _selfLock");
  DESTROY(_selfLock);
  GSWLogC("Dealloc GSWResourceManager Super");
  [super dealloc];
  GSWLogC("End Dealloc GSWResourceManager");
};

//--------------------------------------------------------------------
-(NSString*)description
{
  NSString* dscr=nil;
  [self lock];
  NS_DURING
    {
      dscr=[NSString stringWithFormat:@"<%s %p - _frameworkProjectBundlesCache:%p _appURLs:%@ _frameworkURLs:%@ _appPaths:%@ _frameworkPaths:%@ _urlValuedElementsData:%@ _frameworkClassPaths:%@>",
                     object_get_class_name(self),
                     (void*)self,
                     (void*)_frameworkProjectBundlesCache,
                     _appURLs,
                     _frameworkURLs,
                     _appPaths,
                     _frameworkPaths,
                     _urlValuedElementsData,
                     _frameworkClassPaths];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  return dscr;
};

//--------------------------------------------------------------------
-(void)_initFrameworkProjectBundles
{
  //OK
  NSArray* allFrameworks=nil;
  int i=0;
  NSBundle* bundle=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
  allFrameworks=[NSBundle allFrameworks];
  NSDebugMLLog(@"resmanager",@"allBundles=%@",[NSBundle allBundles]);
  NSDebugMLLog(@"resmanager",@"allFrameworks=%@",allFrameworks);
  for(i=0;i<[allFrameworks count];i++)
    {
      bundle=[allFrameworks objectAtIndex:i];
      NSDebugMLLog(@"resmanager",@"bundle=%@",bundle);
      frameworkName=[bundle bundleName];
      NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
      [self lockedCachedBundleForFrameworkNamed:frameworkName];
    };
  LOGObjectFnStop();
};
/*
//--------------------------------------------------------------------
-(NSString*)frameworkNameForPath:(NSString*)aPath
{
  NSString* _name=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"aPath=%@",aPath);
  [self lock];
  NS_DURING
	{
	  NSDebugMLLog(@"resmanager",@"_frameworkPathsToFrameworksNames=%@",_frameworkPathsToFrameworksNames);
	  _name=[_frameworkPathsToFrameworksNames objectForKey:aPath];	  
	  NSDebugMLLog(@"resmanager",@"_name=%@",_name);
	  if (!_name)
		{
		  NSArray* allFrameworks=[NSBundle allFrameworks];
		  NSString* bundlePath=nil;
		  NSBundle* bundle=nil;
		  int i=0;
		  for(i=0;i<[allFrameworks count];i++)
			{
			  bundle=[allFrameworks objectAtIndex:i];
			  bundlePath=[bundle bundlePath];
			  if (![_frameworkPathsToFrameworksNames objectForKey:bundlePath])
				{
				  NSDebugMLLog(@"resmanager",@"****bundlePath=%@",bundlePath);
				  NSDebugMLLog(@"resmanager",@"****[bundle bundleName]=%@",[bundle bundleName]);
				  if ([bundle bundleName])
					[_frameworkPathsToFrameworksNames setObject:[bundle bundleName]
													 forKey:bundlePath];				  
				  else
					{
					  NSDebugMLLog(@"resmanager",@"no name for bundle %@",bundle);
					};
				};
			};
		  NSDebugMLLog(@"resmanager",@"_frameworkPathsToFrameworksNames=%@",_frameworkPathsToFrameworksNames);
		  _name=[_frameworkPathsToFrameworksNames objectForKey:aPath];	  
		  NSDebugMLLog(@"resmanager",@"_name=%@",_name);
		};
	}
  NS_HANDLER
	{
	  NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
	  //TODO
	  [self unlock];
	  [localException raise];
	}
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return _name;
  
};
*/
//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ languages=%@",resourceName,aFrameworkName,languages);
  [self lock];
  NS_DURING
    {
      path=[self lockedPathForResourceNamed:resourceName
                 inFramework:aFrameworkName
                 languages:languages];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)name
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)request
{
  //OK
  NSString* url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"name=%@ aFrameworkName=%@ languages=%@ request=%@",
               name,aFrameworkName,languages,request);
//  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  [self lock];
  NS_DURING
    {
      url=[self lockedUrlForResourceNamed:name
                inFramework:aFrameworkName
                languages:languages
                request:request];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
//  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)stringForKey:(NSString*)key
            inTableNamed:(NSString*)tableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)framework
               languages:(NSArray*)languages
{
  NSString* string=nil;
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      string=[self lockedStringForKey:key
                   inTableNamed:tableName
                   inFramework:framework
                   languages:languages];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  if (!string)
    string=defaultValue;
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)stringsTableNamed:(NSString*)tableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages;
{
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName=%@ frameworkName=%@",tableName,aFrameworkName);
  [self lock];
  NS_DURING
    {
      stringsTable=[self lockedStringsTableNamed:tableName
                         inFramework:aFrameworkName
                         languages:languages];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)stringsTableArrayNamed:(NSString*)tableName
                      inFramework:(NSString*)aFrameworkName
                        languages:(NSArray*)languages
{
  NSArray* stringsTableArray=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"tableName=%@ frameworkName=%@",tableName,aFrameworkName);
  [self lock];
  NS_DURING
    {
      stringsTableArray=[self lockedStringsTableArrayNamed:tableName
                              inFramework:aFrameworkName
                              languages:languages];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"_selfLockn=%d",_selfLockn);
  TmpUnlock(_selfLock);
#ifndef NDEBUG
	_selfLockn--;
#endif
  NSDebugMLLog(@"resmanager",@"_selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)lock
{
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"_selfLockn=%d",_selfLockn);
  TmpLockBeforeDate(_selfLock,[NSDate dateWithTimeIntervalSinceNow:GSLOCK_DELAY_S]);
#ifndef NDEBUG
  _selfLockn++;
#endif
  NSDebugMLLog(@"resmanager",@"_selfLockn=%d",_selfLockn);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)lockedStringForKey:(NSString*)aKey
                  inTableNamed:(NSString*)aTableName
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages
{
  //OK
  NSString* string=nil;
  NSString* language=nil;
  int i=0;
  int _count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  _count=[languages count];
  NSDebugMLLog(@"resmanager",@"languages=%@",languages);
  NSDebugMLLog(@"resmanager",@"frameworks=%@",frameworks);
  for(i=0;!string && i<=_count;i++)
	{
	  if (i<_count)
		language=[languages objectAtIndex:i];
	  else
		language=nil;
	  for(iFramework=0;!string && iFramework<[frameworks count];iFramework++)
		{
		  frameworkName=[frameworks objectAtIndex:iFramework];
		  if ([frameworkName length]==0)
                    frameworkName=nil;
		  string=[self lockedCachedStringForKey:aKey
						inTableNamed:aTableName
						inFramework:frameworkName
						language:language];
		};
	};
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
//NDFN
-(NSDictionary*)lockedStringsTableNamed:(NSString*)aTableName
                            inFramework:(NSString*)aFrameworkName
                              languages:(NSArray*)languages
{
  //OK
  NSDictionary* stringsTable=nil;
  NSString* language=nil;
  int i=0;
  int _count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  _count=[languages count];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];
  for(i=0;!stringsTable && i<_count;i++)
	{
	  language=[languages objectAtIndex:i];
	  for(iFramework=0;!stringsTable && iFramework<[frameworks count];iFramework++)
		{
		  frameworkName=[frameworks objectAtIndex:iFramework];
		  if ([frameworkName length]==0)
			frameworkName=nil;
		  stringsTable=[self lockedCachedStringsTableWithName:aTableName
							  inFramework:frameworkName
							  language:language];
		};
	};
  NSDebugMLLog(@"resmanager",@"lockedStringsTableNamed:%@ inFramework:%@ languages:%@: %@",
               aTableName,
               aFrameworkName,
               languages,
               stringsTable);
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayNamed:(NSString*)aTableName
							inFramework:(NSString*)aFrameworkName
							  languages:(NSArray*)languages
{
  //OK
  NSArray* stringsTableArray=nil;
  NSString* language=nil;
  int i=0;
  int _count=0;
  int iFramework=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  _count=[languages count];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
	{
	  frameworks=[_frameworkProjectBundlesCache allKeys];
	  frameworks=[frameworks arrayByAddingObject:@""];
	}
  else
	  frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];
  for(i=0;!stringsTableArray && i<_count;i++)
	{
	  language=[languages objectAtIndex:i];
	  for(iFramework=0;!stringsTableArray && iFramework<[frameworks count];iFramework++)
		{
		  frameworkName=[frameworks objectAtIndex:iFramework];
		  if ([frameworkName length]==0)
			frameworkName=nil;
		  stringsTableArray=[self lockedCachedStringsTableArrayWithName:aTableName
								   inFramework:frameworkName
								   language:language];
		};
	};
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedStringForKey:(NSString*)aKey
                        inTableNamed:(NSString*)aTableName 
                         inFramework:(NSString*)aFrameworkName
                            language:(NSString*)aLanguage
{
  //OK
  NSString* string=nil;
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  stringsTable=[self lockedCachedStringsTableWithName:aTableName
					  inFramework:aFrameworkName
					  language:aLanguage];
  if (stringsTable)
	string=[stringsTable objectForKey:aKey];
  LOGObjectFnStop();
  return string;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedCachedStringsTableWithName:(NSString*)aTableName 
                                     inFramework:(NSString*)aFrameworkName
                                        language:(NSString*)aLanguage
{
  //OK
  NSDictionary* stringsTable=nil;
  LOGObjectFnStart();
  stringsTable=[[[_stringsTablesByFrameworkByLanguageByName objectForKey:aFrameworkName]
                   objectForKey:aLanguage]
                  objectForKey:aTableName];
  if (!stringsTable)
    stringsTable=[self  lockedStringsTableWithName:aTableName 
                         inFramework:aFrameworkName
                         language:aLanguage];
  else if (stringsTable==localNotFoundMarker)
    stringsTable=nil;

  NSDebugMLLog(@"resmanager",@"lockedCachedStringsTableNamed:%@ inFramework:%@ language:%@: %@",
               aTableName,
               aFrameworkName,
               aLanguage,
               stringsTable);
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedCachedStringsTableArrayWithName:(NSString*)aTableName 
                                     inFramework:(NSString*)aFrameworkName
                                        language:(NSString*)aLanguage
{
  //OK
  NSArray* stringsTableArray=nil;
  LOGObjectFnStart();
  stringsTableArray=[[[_stringsTableArraysByFrameworkByLanguageByName objectForKey:aFrameworkName]
                        objectForKey:aLanguage]
                       objectForKey:aTableName];
  if (!stringsTableArray)
    stringsTableArray=[self  lockedStringsTableArrayWithName:aTableName 
                              inFramework:aFrameworkName
                              language:aLanguage];
  else if (stringsTableArray==localNotFoundMarker)
    stringsTableArray=nil;
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSDictionary*)lockedStringsTableWithName:(NSString*)aTableName 
                               inFramework:(NSString*)aFrameworkName
                                  language:(NSString*)aLanguage
{
  //OK
  NSDictionary* stringsTable=nil;
  NSString* relativePath=nil;
  NSString* path=nil;
  GSWDeployedBundle* bundle=nil;
  NSString* resourceName=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"aTableName=%@ aFrameworkName=%@ aLanguage=%@",
               aTableName,aFrameworkName,aLanguage);
  resourceName=[aTableName stringByAppendingString:GSWStringTablePSuffix];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];

  for(i=0;!path && i<[frameworks count];i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        {
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",aFrameworkName);
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              // NSDebugMLLog(@"resmanager",@"found cached bundle=%@",bundle);
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   forLanguage:aLanguage];
              // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          // NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               forLanguage:aLanguage];
          // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
//  NSDebugMLLog(@"resmanager",@"path=%@",path);
  if (path)
    {
      //TODO use encoding ??
      stringsTable=[NSDictionary dictionaryWithContentsOfFile:path];
      if (!stringsTable)
        {
          NSString* tmpString=[NSString stringWithContentsOfFile:path];
          LOGSeriousError(@"Bad stringTable \n%@\n from file %@",
                          tmpString,
                          path);
        };
    };
  {
    NSMutableDictionary* frameworkDict=[_stringsTablesByFrameworkByLanguageByName objectForKey:aFrameworkName];
    NSMutableDictionary* languageDict=nil;
    if (!frameworkDict)
      {
        frameworkDict=[NSMutableDictionary dictionary];
        if (!aFrameworkName)
          aFrameworkName=@"";//Global
        [_stringsTablesByFrameworkByLanguageByName setObject:frameworkDict
                                                   forKey:aFrameworkName];
      };
    languageDict=[frameworkDict objectForKey:aLanguage];
    if (!languageDict)
      {
        languageDict=[NSMutableDictionary dictionary];
        if (!aLanguage)
          aLanguage=@"";
        [frameworkDict setObject:languageDict
                       forKey:aLanguage];
      };
    NSAssert(aTableName,@"No tableName");
    if (stringsTable)
      [languageDict setObject:stringsTable
                    forKey:aTableName];
    else
      [languageDict setObject:localNotFoundMarker
                    forKey:aTableName];
  }
  NSDebugMLLog(@"resmanager",@"lockedStringsTableWithName:%@ inFramework:%@ language:%@: %sFOUND",
               aTableName,
               aFrameworkName,
               aLanguage,
               (stringsTable ? "" : "NOT "));
  LOGObjectFnStop();
  return stringsTable;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)lockedStringsTableArrayWithName:(NSString*)aTableName 
                               inFramework:(NSString*)aFrameworkName
                                  language:(NSString*)aLanguage
{
  //OK
  NSArray* stringsTableArray=nil;
  NSString* relativePath=nil;
  NSString* path=nil;
  GSWDeployedBundle* bundle=nil;
  NSString* resourceName=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"aTableName=%@ aFrameworkName=%@ aLanguage=%@",aTableName,aFrameworkName,aLanguage);
  resourceName=[aTableName stringByAppendingString:GSWStringTableArrayPSuffix];
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];
  
  for(i=0;!path && i<[frameworks count];i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      
      if (frameworkName)
        {
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",aFrameworkName);
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              // NSDebugMLLog(@"resmanager",@"found cached bundle=%@",bundle);
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   forLanguage:aLanguage];
              // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          // NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               forLanguage:aLanguage];
          // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
  //  NSDebugMLLog(@"resmanager",@"path=%@",path);
  if (path)
    {
      //TODO use encoding ??
      stringsTableArray=[NSArray arrayWithContentsOfFile:path];
      if (!stringsTableArray)
        {
          NSString* tmpString=[NSString stringWithContentsOfFile:path];
          LOGSeriousError(@"Bad stringTableArray \n%@\n from file %@",
                          tmpString,
                          path);
        };
    };
  {
    NSMutableDictionary* frameworkDict=[_stringsTableArraysByFrameworkByLanguageByName objectForKey:aFrameworkName];
    NSMutableDictionary* languageDict=nil;
    if (!frameworkDict)
      {
        frameworkDict=[NSMutableDictionary dictionary];
        if (!aFrameworkName)
          aFrameworkName=@"";//Global
        [_stringsTableArraysByFrameworkByLanguageByName setObject:frameworkDict
                                                        forKey:aFrameworkName];
      };
    languageDict=[frameworkDict objectForKey:aLanguage];
    if (!languageDict)
      {
        languageDict=[NSMutableDictionary dictionary];
        if (!aLanguage)
          aLanguage=@"";
        [frameworkDict setObject:languageDict
                       forKey:aLanguage];
      };
    NSAssert(aTableName,@"No tableName");
    if (stringsTableArray)
      [languageDict setObject:stringsTableArray
                    forKey:aTableName];
    else
      [languageDict setObject:localNotFoundMarker
                    forKey:aTableName];
  }
  LOGObjectFnStop();
  return stringsTableArray;
};

//--------------------------------------------------------------------
-(NSString*)lockedUrlForResourceNamed:(NSString*)resourceName
                          inFramework:(NSString*)aFrameworkName
                            languages:(NSArray*)languages
                              request:(GSWRequest*)request
{
  //OK	TODOV
  NSString* url=nil;
  BOOL isUsingWebServer=NO;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ languages=%@ _request=%@",
               resourceName,aFrameworkName,languages,request);
//  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  isUsingWebServer=!request || [request _isUsingWebServer];
  NSDebugMLLog(@"resmanager",@"_isUsingWebServer=%s",(isUsingWebServer ? "YES" : "NO"));
  if (isUsingWebServer)
    {
      url=[self lockedCachedURLForResourceNamed:resourceName
                inFramework:aFrameworkName
                languages:languages];
    }
  else
    {
      NSString* path=[self pathForResourceNamed:resourceName
                           inFramework:aFrameworkName
                           languages:languages];
      if (path)
        {
          GSWURLValuedElementData* cachedData=[self _cachedDataForKey:path];
          if (!cachedData)
            {
              NSString* type=[self contentTypeForResourcePath:url];
              [self setData:nil
                    forKey:path
                    mimeType:type
                    session:nil];
            };
        }
      else
        path=[NSString stringWithFormat:@"ERROR_NOT_FOUND_framework_*%@*_filename_%@",
                       aFrameworkName,
                       resourceName];
      url=[request _urlWithRequestHandlerKey:GSWResourceRequestHandlerKey[GSWebNamingConv]
                   path:nil
                   queryString:[NSString stringWithFormat:
                                           @"%@=%@",
                                         GSWKey_Data[GSWebNamingConv],
                                         path]];//TODO Escape
    };
  //  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
  //  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)lockedCachedURLForResourceNamed:(NSString*)resourceName
								inFramework:(NSString*)aFrameworkName
								  languages:(NSArray*)languages
{
  //OK
  NSString* url=nil;
  NSString* relativePath=nil;
  GSWDeployedBundle* bundle=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ languages=%@",resourceName,aFrameworkName,languages);
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];
  
  for(i=0;!url && i<[frameworks count];i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        {
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              //			  NSDebugMLLog(@"resmanager",@"found cached bundle=%@",bundle);
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   forLanguages:languages];
              //			  NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
              if (relativePath)
                {
                  //TODOV
                  NSString* applicationBaseURL=[GSWApplication applicationBaseURL];
                  NSString* wrapperName=[bundle wrapperName];
                  NSDebugMLLog(@"resmanager",@"applicationBaseURL=%@",applicationBaseURL);
                  NSDebugMLLog(@"resmanager",@"wrapperName=%@",wrapperName);
                  url=[applicationBaseURL stringByAppendingPathComponent:wrapperName];
                  NSDebugMLLog(@"resmanager",@"url=%@",url);
                  url=[url stringByAppendingPathComponent:relativePath];
                  NSDebugMLLog(@"resmanager",@"url=%@",url);
                };
            };
        }
      else
        {
          NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               forLanguages:languages];
          NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
          if (relativePath)
            {
              NSString* applicationBaseURL=[GSWApplication applicationBaseURL];
              NSString* wrapperName=[globalAppProjectBundle wrapperName];
              NSDebugMLLog(@"resmanager",@"applicationBaseURL=%@",applicationBaseURL);
              NSDebugMLLog(@"resmanager",@"wrapperName=%@",wrapperName);
              url=[applicationBaseURL stringByAppendingPathComponent:wrapperName];
              url=[url stringByAppendingPathComponent:relativePath];
            };
        };
    };
  if (!url)
    {
      LOGSeriousError(@"No URL for resource named: %@ in framework named: %@ for languages: %@",
                      resourceName,
                      aFrameworkName,
                      languages);
    };
  //  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
  //  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  //  NSDebugMLLog(@"resmanager",@"url=%@",url);
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)resourceName
                           inFramework:(NSString*)aFrameworkName
                             languages:(NSArray*)languages
{ 
  NSString* path=nil;
  NSString* relativePath=nil;
  GSWDeployedBundle* bundle=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ languages=%@",
               resourceName,aFrameworkName,languages);
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];
  NSDebugMLLog(@"resmanager",@"frameworks=%@",frameworks);

  for(i=0;!path && i<[frameworks count];i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      if (frameworkName)
        {
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          //NSDebugMLLog(@"resmanager",@"bundle=%@",bundle);
          if (bundle)
            {
              // NSDebugMLLog(@"resmanager",@"found cached bundle=%@",bundle);
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   forLanguages:languages];
              // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               forLanguages:languages];
          NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
  //  NSDebugMLLog(@"resmanager",@"path=%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)lockedCachedBundleForFrameworkNamed:(NSString*)resourceName
{
  //OK
  GSWDeployedBundle* bundle=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@",resourceName);
  NSAssert(resourceName,@"No name");
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  if ([resourceName isEqualToString:GSWFramework_app])
    {
      resourceName=[globalAppProjectBundle projectName];
      bundle=globalAppProjectBundle;
    }
  else
    bundle=[_frameworkProjectBundlesCache objectForKey:resourceName];
  //  NSDebugMLLog(@"resmanager",@"bundle %@ %s cached",resourceName,(bundle ? "" : "NOT"));
  if (!bundle)
    {
      NSMutableArray* allFrameworks=[[NSBundle allFrameworks] mutableCopy];
      int i=0;
      NSString* bundlePath=nil;
      NSBundle* tmpBundle=nil;
      NSDictionary* infoDict=nil;
      NSString* frameworkName=nil;
      GSWDeployedBundle* projectBundle=nil;

      [allFrameworks addObjectsFromArray:[NSBundle allBundles]];
      [allFrameworks autorelease];
      
      for(i=0;!bundle && i<[allFrameworks count];i++)
        {
          tmpBundle=[allFrameworks objectAtIndex:i];
          // NSDebugMLLog(@"resmanager",@"tmpBundle=%@",tmpBundle);
          bundlePath=[tmpBundle bundlePath];
          // NSDebugMLLog(@"resmanager",@"bundlePath=%@",bundlePath);
          frameworkName=[bundlePath lastPathComponent];
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
          frameworkName=[frameworkName stringByDeletingPathExtension];
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
          if ([frameworkName isEqualToString:resourceName])
            {
              bundle=[GSWDeployedBundle bundleWithPath:bundlePath];
              NSDebugMLLog(@"resmanager",@"bundle=%@",bundle);
              /*projectBundle=[GSWProjectBundle projectBundleForProjectNamed:resourceName
                isFramework:YES];
                NSDebugMLLog(@"resmanager",@"projectBundle=%@",projectBundle);
                if (projectBundle)
                {
                //TODO
                };
              */
              NSAssert(bundle,@"No bundle");
              NSAssert(resourceName,@"No name");
              [_frameworkProjectBundlesCache setObject:bundle
                                             forKey:resourceName];
              //NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
            };
        };
    };
  //  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  //  NSDebugMLLog(@"resmanager",@"bundle=%@",bundle);
  LOGObjectFnStop();
  return bundle;
};

@end

//====================================================================
@implementation GSWResourceManager (GSWURLValuedElementsDataCaching)

//--------------------------------------------------------------------
-(void)flushDataCache
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [_urlValuedElementsData removeAllObjects];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
	  //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setURLValuedElementData:(GSWURLValuedElementData*)aData
{
  LOGObjectFnStart();
  [self lock];
  NSDebugMLLog(@"resmanager",@"aData=%@",aData);
  NS_DURING
    {
      [self lockedCacheData:aData];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)setData:(NSData*)aData
        forKey:(NSString*)aKey
      mimeType:(NSString*)aType
       session:(GSWSession*)session_ //unused
{
  GSWURLValuedElementData* dataValue=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"aData=%@",aData);
  NSDebugMLLog(@"resmanager",@"aKey=%@",aKey);
  NSDebugMLLog(@"resmanager",@"aType=%@",aType);
  dataValue=[[[GSWURLValuedElementData alloc] initWithData:aData
                                              mimeType:aType
                                              key:aKey] autorelease];
  NSDebugMLLog(@"resmanager",@"dataValue=%@",dataValue);
  [self setURLValuedElementData:dataValue];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeDataForKey:(NSString*)aKey
                session:(GSWSession*)session //unused
{
  LOGObjectFnStart();
  [self lock];
  NS_DURING
    {
      [self lockedRemoveDataForKey:aKey];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerA)

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
                        language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ aLanguage=%@",resourceName,aFrameworkName,aLanguage);
//  NSDebugMLLog(@"resmanager",@"[_frameworkProjectBundlesCache count]=%d",[_frameworkProjectBundlesCache count]);
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  [self lock];
  NS_DURING
    {
      path=[self lockedPathForResourceNamed:resourceName
                 inFramework:aFrameworkName
                 language:aLanguage];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(NSString*)lockedPathForResourceNamed:(NSString*)resourceName
                           inFramework:(NSString*)aFrameworkName
                              language:(NSString*)aLanguage
{
  //OK
  NSString* path=nil;
  NSString* relativePath=nil;
  GSWDeployedBundle* bundle=nil;
  int i=0;
  NSArray* frameworks=nil;
  NSString* frameworkName=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@ aLanguage=%@",resourceName,aFrameworkName,aLanguage);
//  NSDebugMLLog(@"resmanager",@"_frameworkProjectBundlesCache=%@",_frameworkProjectBundlesCache);
  if (!WOStrictFlag && [aFrameworkName isEqualToString:GSWFramework_all])
    {
      frameworks=[_frameworkProjectBundlesCache allKeys];
      frameworks=[frameworks arrayByAddingObject:@""];
    }
  else
    frameworks=[NSArray arrayWithObject:aFrameworkName ? aFrameworkName : @""];

  for(i=0;!path && i<[frameworks count];i++)
    {
      frameworkName=[frameworks objectAtIndex:i];
      if ([frameworkName length]==0)
        frameworkName=nil;
      
      if (frameworkName)
        {
          // NSDebugMLLog(@"resmanager",@"frameworkName=%@",frameworkName);
          bundle=[self lockedCachedBundleForFrameworkNamed:frameworkName];
          if (bundle)
            {
              // NSDebugMLLog(@"resmanager",@"found cached bundle=%@",bundle);
              relativePath=[bundle relativePathForResourceNamed:resourceName
                                   forLanguage:aLanguage];
              // NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
              if (relativePath)
                {
                  path=[[bundle bundlePath] stringByAppendingPathComponent:relativePath];
                };
            };
        }
      else
        {
          NSDebugMLLog(@"resmanager",@"globalAppProjectBundle=%@",globalAppProjectBundle);
          relativePath=[globalAppProjectBundle relativePathForResourceNamed:resourceName
                                               forLanguage:aLanguage];
          NSDebugMLLog(@"resmanager",@"relativePath=%@",relativePath);
          if (relativePath)
            {
              NSString* applicationPath=[GSWApp path];
              path=[applicationPath stringByAppendingPathComponent:relativePath];
            };
        };
    };
  //  NSDebugMLLog(@"resmanager",@"path=%@",path);
  LOGObjectFnStop();
  return path;
};

//--------------------------------------------------------------------
-(GSWDeployedBundle*)_appProjectBundle
{
  return globalAppProjectBundle;
};

//--------------------------------------------------------------------
-(NSArray*)_allFrameworkProjectBundles
{
  //OK
  NSArray* array=nil;
  LOGObjectFnStart();
  array=[_frameworkProjectBundlesCache allValues];
  LOGObjectFnStop();
  return array;
};

//--------------------------------------------------------------------
-(void)lockedRemoveDataForKey:(NSString*)key
{
  LOGObjectFnStart();
  [_urlValuedElementsData removeObjectForKey:key];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(BOOL)_doesRequireJavaVirualMachine
{
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(id)_absolutePathForJavaClassPath:(NSString*)path
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(GSWURLValuedElementData*)_cachedDataForKey:(NSString*)key
{
  //OK
  GSWURLValuedElementData* data=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"key=%@",key);
  [self lock];
  NS_DURING
    {
      data=[_urlValuedElementsData objectForKey:key];
      NSDebugMLLog(@"resmanager",@"data=%@",data);
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
  return data;
};

//--------------------------------------------------------------------
-(void)lockedCacheData:(GSWURLValuedElementData*)aData
{
  //OK
  NSData* data=nil;
  BOOL isTemporary=NO;
  NSString* key=nil;
  NSString* type=nil;
  LOGObjectFnStart();
  data=[aData data];
  NSAssert(data,@"Data");
  isTemporary=[aData isTemporary];
  key=[aData key];
  NSAssert(key,@"No key");
  type=[aData type];
  [self lock];
  NS_DURING
    {
      if (!_urlValuedElementsData)
        _urlValuedElementsData=[NSMutableDictionary new];
      [_urlValuedElementsData setObject:aData
                              forKey:key];
    }
  NS_HANDLER
    {
      NSDebugMLLog(@"resmanager",@"EXCEPTION:%@ (%@) [%s %d]",
                   localException,[localException reason],__FILE__,__LINE__);
      //TODO
      [self unlock];
      [localException raise];
    }
  NS_ENDHANDLER;
  [self unlock];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSString*)contentTypeForResourcePath:(NSString*)path
{
  //OK
  NSString* type=nil;
  NSString* extension=nil;
  NSDictionary* tmpMimeTypes=nil;
  NSMutableDictionary* mimeTypes=[NSMutableDictionary dictionary];
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"path=%@",path);
  extension=[path pathExtension];
  NSDebugMLLog(@"resmanager",@"extension=%@",extension);
  if (extension)
    {
      extension=[extension lowercaseString];
      NSDebugMLLog(@"resmanager",@"extension=%@",extension);
      type=[globalMime objectForKey:extension];
      NSDebugMLLog(@"resmanager",@"type=%@",type);
    };
  if (!type)
    type=[NSString stringWithString:@"application/octet-stream"];
  NSDebugMLLog(@"resmanager",@"type=%@",type);
  LOGObjectFnStop();
  return type;
};

//--------------------------------------------------------------------
-(NSArray*)_frameworkClassPaths
{
  return _frameworkClassPaths;
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerOldFn)

//--------------------------------------------------------------------
-(NSString*)urlForResourceNamed:(NSString*)resourceName
                    inFramework:(NSString*)aFrameworkName
{
  NSString* url=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@",resourceName,aFrameworkName);
  url=[self urlForResourceNamed:resourceName
			 inFramework:aFrameworkName
			 languages:nil
			 request:nil];
  LOGObjectFnStop();
  return url;
};

//--------------------------------------------------------------------
-(NSString*)pathForResourceNamed:(NSString*)resourceName
                     inFramework:(NSString*)aFrameworkName
{
  NSString* path=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"resmanager",@"resourceName=%@ aFrameworkName=%@",resourceName,aFrameworkName);
  path=[self pathForResourceNamed:resourceName
             inFramework:aFrameworkName
             language:nil];
  LOGObjectFnStop();
  return path;
};

@end


//====================================================================
@implementation GSWResourceManager (GSWResourceManagerB)

//--------------------------------------------------------------------
-(void)_validateAPI
{
  //Verifier que self ne r�pond pas aux OldFN
  LOGObjectFnNotImplemented();	//TODOFN
};

@end

//====================================================================
@implementation GSWResourceManager (GSWResourceManagerClassA)

//--------------------------------------------------------------------
//NDFN
+(NSString*)GSLanguageFromISOLanguage:(NSString*)ISOLanguage
{
  return [localISO2GSLanguages objectForKey:[[ISOLanguage stringByTrimmingSpaces] lowercaseString]];
};

//--------------------------------------------------------------------
//NDFN
+(NSArray*)GSLanguagesFromISOLanguages:(NSArray*)ISOLanguages
{
  NSArray* GSLanguages=nil;
  if (ISOLanguages)
    {
      NSMutableArray* array=[NSMutableArray array];
      NSString* ISOLanguage=nil;
      NSString* GSLanguage=nil;
      int i=0;
      for(i=0;i<[ISOLanguages count];i++)
        {
          ISOLanguage=[ISOLanguages objectAtIndex:i];
          GSLanguage=[self GSLanguageFromISOLanguage:ISOLanguage];
          if (GSLanguage)
            [array addObject:GSLanguage];
          else
            {
              LOGError(@"Unknown language: %@\nKnown languages are : %@",ISOLanguage,localISO2GSLanguages);
            };
        };
      GSLanguages=[NSArray arrayWithArray:array];
    }
  return GSLanguages;
};

//--------------------------------------------------------------------
//NDFN
+(NSString*)ISOLanguageFromGSLanguage:(NSString*)GSLanguage
{
  return [localGS2ISOLanguages objectForKey:[[GSLanguage stringByTrimmingSpaces] lowercaseString]];
};

//--------------------------------------------------------------------
//NDFN
+(NSArray*)ISOLanguagesFromGSLanguages:(NSArray*)GSLanguages
{
  NSArray* ISOLanguages=nil;
  if (GSLanguages)
    {
      NSMutableArray* array=[NSMutableArray array];
      NSString* ISOLanguage=nil;
      NSString* GSLanguage=nil;
      int i=0;
      for(i=0;i<[GSLanguages count];i++)
        {
          GSLanguage=[GSLanguages objectAtIndex:i];
          ISOLanguage=[self ISOLanguageFromGSLanguage:GSLanguage];
          [array addObject:ISOLanguage];
        };
      ISOLanguages=[NSArray arrayWithArray:array];
    }
  return ISOLanguages;
};
//--------------------------------------------------------------------
+(GSWBundle*)_applicationGSWBundle
{
  LOGClassFnStart();
  if (!globalAppGSWBundle)
    {
      NSString* applicationBaseURL=nil;
      NSString* baseURL=nil;
      NSString* wrapperName=nil;
      applicationBaseURL=[GSWApplication applicationBaseURL]; //(retourne /GSWeb)
      NSDebugMLLog(@"resmanager",@"applicationBaseURL=%@",applicationBaseURL);
      wrapperName=[globalAppProjectBundle wrapperName];
      NSDebugMLLog(@"resmanager",@"wrapperName=%@",wrapperName);
      baseURL=[applicationBaseURL stringByAppendingFormat:@"/%@",wrapperName];
      NSDebugMLLog(@"resmanager",@"baseURL=%@",baseURL);
      NSDebugMLLog(@"resmanager",@"[globalAppProjectBundle bundlePath]=%@",[globalAppProjectBundle bundlePath]);
      globalAppGSWBundle=[[GSWBundle alloc]initWithPath:[globalAppProjectBundle bundlePath]
                                           baseURL:baseURL];
      NSDebugMLLog(@"resmanager",@"globalAppGSWBundle=%@",globalAppGSWBundle);
      //???
      {
        NSBundle* resourceManagerBundle=[NSBundle bundleForClass:
                                                    NSClassFromString(@"GSWResourceManager")];
        NSDebugMLLog(@"resmanager",@"resourceManagerBundle bundlePath=%@",[resourceManagerBundle bundlePath]);
        globalMimePListPathName=[resourceManagerBundle pathForResource:@"MIME"
                                                       ofType:@"plist"]; //TODO should return /usr/GNUstep/Libraries/GNUstepWeb/GSWeb.framework/Resources/MIME.plist
        NSDebugMLLog(@"resmanager",@"globalMimePListPathName=%@",globalMimePListPathName);
        if (!globalMimePListPathName)
          globalMimePListPathName = [[NSBundle bundleForClass: self]
                                      pathForResource:@"MIME"
                                      ofType:@"plist"];
            
        NSDebugMLLog(@"resmanager",@"globalMimePListPathName=%@",globalMimePListPathName);
#ifdef DEBUG
        if (!globalMimePListPathName)
          {
            NSDictionary* env=[[NSProcessInfo processInfo] environment];

            NSDebugMLLog(@"error",@"GNUSTEP_USER_ROOT=%@",[env objectForKey: @"GNUSTEP_USER_ROOT"]);
            NSDebugMLLog(@"error",@"GNUSTEP_LOCAL_ROOT=%@",[env objectForKey: @"GNUSTEP_LOCAL_ROOT"]);
            NSDebugMLLog(@"error",@"gnustepBundle resourcePath=%@",[[NSBundle gnustepBundle]resourcePath]);
          };
#endif
        NSAssert(globalMimePListPathName,@"No resource MIME.plist");
        {
          NSDictionary* tmpMimeTypes=nil;
          NSMutableDictionary* mimeTypes=[NSMutableDictionary dictionary];
          LOGObjectFnStart();
          tmpMimeTypes=[NSDictionary  dictionaryWithContentsOfFile:globalMimePListPathName];
          // NSDebugMLLog(@"resmanager",@"tmpMimeTypes=%@",tmpMimeTypes);
          if (tmpMimeTypes)
            {
              NSEnumerator* enumerator = [tmpMimeTypes keyEnumerator];
              id key;
              id value;
              while ((key = [enumerator nextObject]))
                {
                  value=[tmpMimeTypes objectForKey:key];
                  value=[value lowercaseString];
                  key=[key lowercaseString];
                  NSAssert(key,@"No key");
                  [mimeTypes setObject:value
                             forKey:key];
                };
              // NSDebugMLLog(@"resmanager",@"mimeTypes=%@",mimeTypes);
            };
          ASSIGN(globalMime,[NSDictionary dictionaryWithDictionary:mimeTypes]);
        };
        globalLanguagesPListPathName=[resourceManagerBundle pathForResource:@"languages"
                                                            ofType:@"plist"];
        NSDebugMLLog(@"resmanager",@"globalLanguagesPListPathName=%@",globalLanguagesPListPathName);
        if (!globalLanguagesPListPathName)
          globalLanguagesPListPathName=[[NSBundle bundleForClass: self]
                                         pathForResource:@"languages"
                                         ofType:@"plist"];
            
        NSDebugMLLog(@"resmanager",@"globalLanguagesPListPathName=%@",globalLanguagesPListPathName);
        NSAssert(globalLanguagesPListPathName,@"No resource languages.plist");
        {
          NSDictionary* tmpLanguages=nil;
          NSMutableDictionary* ISO2GS=[NSMutableDictionary dictionary];
          NSMutableDictionary* GS2ISO=[NSMutableDictionary dictionary];
          LOGObjectFnStart();
          tmpLanguages=[NSDictionary  dictionaryWithContentsOfFile:globalLanguagesPListPathName];
          NSDebugMLLog(@"resmanager",@"tmpLanguages=%@",tmpLanguages);
          if (tmpLanguages)
            {
              NSEnumerator* enumerator = [tmpLanguages keyEnumerator];
              id iso=nil;
              id gs=nil;
              while ((iso = [enumerator nextObject]))
                {
                  gs=[tmpLanguages objectForKey:iso];
                  NSAssert(gs,@"No gs");
                  [ISO2GS setObject:gs
                          forKey:[iso lowercaseString]];
                  if ([iso length]==2)//No xx-xx
                    {
                      [GS2ISO setObject:iso
                              forKey:[gs lowercaseString]];
                    };
                };
              NSDebugMLLog(@"resmanager",@"ISO2GS=%@",ISO2GS);
              NSDebugMLLog(@"resmanager",@"GS2ISO=%@",GS2ISO);
            };
          ASSIGN(localISO2GSLanguages,[NSDictionary dictionaryWithDictionary:ISO2GS]);
          ASSIGN(localGS2ISOLanguages,[NSDictionary dictionaryWithDictionary:GS2ISO]);
        };
      };
	  
      [globalAppGSWBundle clearCache];
    };
  LOGClassFnStop();
  return globalAppGSWBundle;
};

@end
