/** GSWApplication.h - <title>GSWeb: Class GSWApplication</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

// $Id$

#ifndef _GSWApplication_h__
	#define _GSWApplication_h__

GSWEB_EXPORT void
GSWApplicationSetDebugSetOption(NSString* opt);

GSWEB_EXPORT int
WOApplicationMain(NSString* applicationClassName,
		  int argc, const char *argv[]);

GSWEB_EXPORT int
GSWApplicationMain(NSString* applicationClassName,
		   int argc, const char *argv[]);

GSWEB_EXPORT NSString* globalApplicationClassName;
GSWEB_EXPORT int GSWebNamingConv;//GSWNAMES_INDEX or WONAMES_INDEX

#define GSWebNamingConvInversed		\
	(GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX)

#define GSWebNamingConvForRound(r)	\
	((r)==0 ? GSWebNamingConv : 	\
	  (GSWebNamingConv==GSWNAMES_INDEX ? WONAMES_INDEX : GSWNAMES_INDEX))

GSWEB_EXPORT BOOL WOStrictFlag;

@class GSWSessionStore;
@class GSWStatisticsStore;
@class GSWResourceManager;
@class GSWRequestHandler;
@class GSWLifebeatThread;
@class GSWSession;
@class GSWAdaptor;
@class GSWComponent;
@class GSWElement;
@class GSWResponse;
@class GSWAssociation;
@class GSWComponentDefinition;
@class GSWDictionary;
@class GSWActionRequestHandler;
@class GSWAction;

//====================================================================
@interface GSWApplication : NSObject <NSLocking>
{
  NSArray* _adaptors;
  GSWSessionStore* _sessionStore;
  GSWDictionary* _componentDefinitionCache;
  NSTimeInterval _timeOut;
  NSDate* _startDate;
  NSDate* _lastAccessDate;
  NSTimer* _timer;
//  GSWContext* context;        // being deprecated
  GSWStatisticsStore* _statisticsStore;
  GSWResourceManager* _resourceManager;
  NSDistantObject* _remoteMonitor;
  NSConnection* _remoteMonitorConnection;
  NSString* _instanceNumber;
  NSMutableDictionary* _requestHandlers;
  GSWRequestHandler* _defaultRequestHandler;
  NSString*          _hostAddress;
@public //TODO-NOW REMOVE
  NSRecursiveLock* _selfLock;
#ifndef NDEBUG
  int _selfLockn;
  NSThread *_selfLock_thread_id;
#endif
  NSRecursiveLock* _globalLock;
  NSAutoreleasePool* _globalAutoreleasePool;
  unsigned _pageCacheSize;
  unsigned _permanentPageCacheSize;
  int _activeSessionsCount;
  int _minimumActiveSessionsCount;
  BOOL _pageRecreationEnabled;
  BOOL _pageRefreshOnBacktrackEnabled;
  BOOL _terminating;
  BOOL _dynamicLoadingEnabled;
  BOOL _printsHTMLParserDiagnostics;
  BOOL _refusingNewSessions;
  BOOL _shouldDieWhenRefusing;
  BOOL _refusingNewClients;
  BOOL _refuseThisRequest;
  BOOL _isMultiThreaded;
  BOOL _isMTProtected;
  BOOL _timedRunLoop;
  BOOL _isTracingEnabled;
  BOOL _isTracingAssignmentsEnabled;
  BOOL _isTracingObjectiveCMessagesEnabled;
  BOOL _isTracingScriptedMessagesEnabled;
  BOOL _isTracingStatementsEnabled;
  BOOL _allowsConcurrentRequestHandling;
  NSRunLoop* _currentRunLoop;
  NSDate* _runLoopDate;
  NSTimer* _initialTimer;
  NSLock* _activeSessionsCountLock;

  GSWLifebeatThread* _lifebeatThread;
  id _recorder;
}

- (NSString*) hostAddress;
-(void) _setHostAddress:(NSString *) hostAdr;


-(BOOL) shouldRestoreSessionOnCleanEntry:(GSWRequest*) aRequest;
-(BOOL)allowsConcurrentRequestHandling;
-(BOOL)adaptorsDispatchRequestsConcurrently;
-(BOOL)isConcurrentRequestHandlingEnabled;
-(NSRecursiveLock *) requestHandlingLock;
-(BOOL)isRequestHandlingLocked;
-(void)lock;
-(void)unlock;


-(NSString*)baseURL;

-(NSString*)number;
-(NSString*)path;
-(BOOL)isTaskDaemon;
-(NSString*)name;
-(NSString*)description;
-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

-(void)registerRequestHandlers;

-(NSString*)defaultRequestHandlerClassName;

-(Class)defaultRequestHandlerClass;

- (NSString*) sessionIdKey;

- (NSString*) instanceIdKey;

-(void)becomesMultiThreaded;

-(NSString*)_webserverConnectURL;

-(NSString*)_directConnectURL;

-(NSString*)_applicationExtension;

-(void)_resetCacheForGeneration;

-(void)_resetCache;

-(GSWComponentDefinition*) _componentDefinitionWithName:(NSString*)aName
                                              languages:(NSArray*)languages;

-(GSWComponentDefinition*)lockedComponentDefinitionWithName:(NSString*)aName
                                                  languages:(NSArray*)languages;

-(GSWComponentDefinition*)lockedLoadComponentDefinitionWithName:(NSString*)aName
                                                       language:(NSString*)language;
-(NSArray*)lockedComponentBearingFrameworks;

-(NSArray*)lockedInitComponentBearingFrameworksFromBundleArray:(NSArray*)bundles;

-(Class)contextClass;

-(GSWContext*)createContextForRequest:(GSWRequest*)aRequest;

//-(Class)responseClass;

-(GSWResponse*)createResponseInContext:(GSWContext*)aContext;

-(Class)requestClass;

-(GSWResourceManager*)createResourceManager;

-(GSWStatisticsStore*)createStatisticsStore;

-(GSWSessionStore*)createSessionStore;

-(void)_discountTerminatedSession;

-(void)_finishInitializingSession:(GSWSession*)aSession;

-(GSWSession*)_initializeSessionInContext:(GSWContext*)aContext;

-(int)_activeSessionsCount;

-(void)_setContext:(GSWContext*)aContext;
// Internal Use only
-(GSWContext*)_context;

-(BOOL)_isDynamicLoadingEnabled;

-(void)_disableDynamicLoading;

-(BOOL)_isPageRecreationEnabled;

-(void)_touchPrincipalClasses;

-(NSString*)_newLocationForRequest:(GSWRequest*)aRequest;

-(void)_connectionDidDie:(id)unknown;

-(BOOL)_shouldKill;

-(void)_setShouldKill:(BOOL)flag;

-(void)_synchronizeInstanceSettingsWithMonitor:(id)aMonitor;

-(BOOL)_setupForMonitoring;

-(id)_remoteMonitor;

-(NSString*)_monitorHost;

-(NSString*)_monitorApplicationName;

-(void)_terminateFromMonitor;

-(NSArray*)adaptors;

-(GSWAdaptor*)adaptorWithName:(NSString*)aName
                    arguments:(NSDictionary*)someArguments;

-(BOOL)isCachingEnabled;

-(void)setCachingEnabled:(BOOL)flag;

-(GSWSessionStore*)sessionStore;

-(void)setSessionStore:(GSWSessionStore*)sessionStore;

-(GSWSession*)createSessionForRequest:(GSWRequest*)aRequest;

-(GSWSession*)_createSessionForRequest:(GSWRequest*)aRequest;

-(Class)_sessionClass;

-(Class)sessionClass;//NDFN

-(GSWSession*)restoreSessionWithID:(NSString*)aSessionID
                         inContext:(GSWContext*)aContext;

//-(GSWSession*)_restoreSessionWithID:(NSString*)aSessionID
//                          inContext:(GSWContext*)aContext;

-(void)saveSessionForContext:(GSWContext*)aContext;

-(unsigned int)pageCacheSize;

-(void)setPageCacheSize:(unsigned int)aSize;

-(unsigned)permanentPageCacheSize;

-(void)setPermanentPageCacheSize:(unsigned)aSize;

-(BOOL)isPageRefreshOnBacktrackEnabled;

-(void)setPageRefreshOnBacktrackEnabled:(BOOL)flag;

-(GSWComponent*)pageWithName:(NSString*)aName
                  forRequest:(GSWRequest*)aRequest;

-(GSWComponent*)pageWithName:(NSString*)aName
                   inContext:(GSWContext*)aContext;

-(NSString*)defaultPageName;//NDFN

-(GSWElement*)dynamicElementWithName:(NSString *)aName
                        associations:(NSDictionary*)someAssociations
                            template:(GSWElement*)templateElement
                           languages:(NSArray*)languages;

-(GSWElement*)lockedDynamicElementWithName:(NSString*)aName
                              associations:(NSDictionary*)someAssociations
                                  template:(GSWElement*)templateElement
                                 languages:(NSArray*)languages;
-(NSRunLoop*)runLoop;

-(void)threadWillExit;//NDFN

-(void)run;

-(BOOL)runOnce;

-(void)setTimeOut:(NSTimeInterval)aTimeInterval;

-(NSTimeInterval)timeOut;

-(void)terminate;

-(BOOL)isTerminating;

-(void)_scheduleApplicationTimerForTimeInterval:(NSTimeInterval)aTimeInterval;

-(NSDate*)lastAccessDate;//NDFN

-(NSDate*)startDate;//NDFN

-(void)lockedAddTimer:(NSTimer*)aTimer;//NDFN

-(void)addTimer:(NSTimer*)aTimer;//NDFN

-(void)_setNextCollectionCount:(int)_count;

-(void)_sessionDidTimeOutNotification:(NSNotification*)notification_;

-(void)_openInitialURL;

-(void)_openURL:(NSString*)_url;

-(GSWResponse*)dispatchRequest:(GSWRequest*)aRequest;

-(void)awake;

-(id <GSWActionResults>)invokeActionForRequest:(GSWRequest*)aRequest
                                     inContext:(GSWContext*)aContext;

-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext;

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext;

-(void)_setRecordingHeadersToResponse:(GSWResponse*)aResponse
                           forRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext;
-(void)sleep;

-(GSWResponse*)handleException:(NSException*)exception
                     inContext:(GSWContext*)aContext;

-(GSWResponse*)handlePageRestorationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)_handlePageRestorationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)handleSessionCreationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)_handleSessionCreationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)handleSessionRestorationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)_handleSessionRestorationErrorInContext:(GSWContext*)aContext;

-(GSWResponse*)handleActionRequestErrorWithRequest:(GSWRequest*)aRequest
                                         exception:(NSException*)exception
                                            reason:(NSString*)reason
                                    requestHanlder:(GSWActionRequestHandler*)requestHandler
                                   actionClassName:(NSString*)actionClassName
                                        actionName:(NSString*)actionName
                                       actionClass:(Class)actionClass
                                      actionObject:(GSWAction*)actionObject;

+(void)_setApplication:(GSWApplication*)application;
+(GSWApplication*)application;

-(BOOL)printsHTMLParserDiagnostics;
-(void)setPrintsHTMLParserDiagnostics:(BOOL)flag;

-(Class)scriptedClassWithPath:(NSString*)path;
-(Class)scriptedClassWithPath:(NSString*)path
                     encoding:(NSStringEncoding)encoding;
-(Class)_classWithScriptedClassName:(NSString*)aName
                          languages:(NSArray*)languages;
-(void)_setClassFromNameResolutionEnabled:(BOOL)flag;

-(Class)libraryClassWithPath:(NSString*)path;//NDFN

-(void)debugWithString:(NSString*)string;

-(void)debugWithFormat:(NSString*)format
             arguments:(va_list)someArgumentsu;

-(void)debugWithFormat:(NSString*)formatString,...;

+(void)debugWithFormat:(NSString*)formatString,...;

-(void)logString:(NSString*)string;

+(void)logString:(NSString*)string;

-(void)logWithFormat:(NSString*)aFormat,...;

+(void)logWithFormat:(NSString*)aFormat,...;

-(void)logWithFormat:(NSString*)formatString
           arguments:(va_list)arguments;

-(void)logErrorString:(NSString*)string;

+(void)logErrorString:(NSString*)string;

-(void)logErrorWithFormat:(NSString*)aFormat,...;

+(void)logErrorWithFormat:(NSString*)aFormat,...;

-(void)logErrorWithFormat:(NSString*)formatString
                arguments:(va_list)arguments;

-(void)trace:(BOOL)flag;
-(void)traceAssignments:(BOOL)flag;
-(void)traceObjectiveCMessages:(BOOL)flag;
-(void)traceScriptedMessages:(BOOL)flag;
-(void)traceStatements:(BOOL)flag;
+(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)anAssociationDescription
                                 value:(id)aValue;
+(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
               associationDescription:(NSString*)anAssociationDescription
                                value:(id)aValue;

-(void)logTakeValueForDeclarationNamed:(NSString*)aDeclarationName
                                  type:(NSString*)aDeclarationType
                          bindingNamed:(NSString*)aBindingName
                associationDescription:(NSString*)anAssociationDescription
                                 value:(id)aValue;

-(void)logSetValueForDeclarationNamed:(NSString*)aDeclarationName
                                 type:(NSString*)aDeclarationType
                         bindingNamed:(NSString*)aBindingName
			   associationDescription:(NSString*)anAssociationDescription
                                value:(id)aValue;
+(void)logSynchronizeComponentToParentForValue:(id)value_
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent;
+(void)logSynchronizeParentToComponentForValue:(id)aValue
                                   association:(GSWAssociation*)anAssociation
                                   inComponent:(NSObject*)aComponent;

-(void)_setTracingAspect:(id)unknwon
                 enabled:(BOOL)enabled;
-(void)debugAdaptorThreadExited;

//NDFN
//Same as GSWDebugging but it print messages on stdout AND call GSWDebugging methods
-(void)statusDebugWithString:(NSString*)aString;
-(void)statusDebugWithFormat:(NSString*)aFormat
                   arguments:(va_list)arguments;

-(void)statusDebugWithFormat:(NSString*)aFormat,...;
+(void)statusDebugWithFormat:(NSString*)aFormat,...;

-(void)statusLogString:(NSString*)string;
+(void)statusLogString:(NSString*)string;

-(void)statusLogWithFormat:(NSString*)aFormat,...;
+(void)statusLogWithFormat:(NSString*)aFormat,...;

-(void)statusLogWithFormat:(NSString*)aFormat
                 arguments:(va_list)arguments;

-(void)statusLogErrorString:(NSString*)string;
+(void)statusLogErrorString:(NSString*)string;

-(void)statusLogErrorWithFormat:(NSString*)aFormat,...;
+(void)statusLogErrorWithFormat:(NSString*)aFormat,...;

-(void)statusLogErrorWithFormat:(NSString*)aFormat
                      arguments:(va_list)arguments;

-(void)setStatisticsStore:(GSWStatisticsStore*)statisticsStore;
-(NSDictionary*)statistics;//bycopy
-(GSWStatisticsStore*)statisticsStore;

-(BOOL)monitoringEnabled;
-(int)activeSessionsCount;
-(int)minimumActiveSessionsCount;
-(void)setMinimumActiveSessionsCount:(int)aCount;
-(BOOL)isRefusingNewSessions;
-(void)refuseNewSessions:(BOOL)flag;
-(NSTimeInterval)_refuseNewSessionsTimeInterval;
-(void)logToMonitorWithFormat:(NSString*)aFormat;
-(void)terminateAfterTimeInterval:(NSTimeInterval)aTimeInterval;

-(void)setResourceManager:(GSWResourceManager*)resourceManager;
-(GSWResourceManager*)resourceManager;

-(GSWRequestHandler*)defaultRequestHandler;

-(void)setDefaultRequestHandler:(GSWRequestHandler*)handler;

-(void)registerRequestHandler:(GSWRequestHandler*)handler
                       forKey:(NSString*)aKey;

-(void)removeRequestHandlerForKey:(NSString*)requestHandlerKey;

-(NSArray*)registeredRequestHandlerKeys;

-(GSWRequestHandler*)requestHandlerForKey:(NSString*)aKey;

-(GSWRequestHandler*)handlerForRequest:(GSWRequest*)aRequest;


//-(void)setResponseClassName:(NSString*)className;
//-(NSString*)responseClassName;
//-(void)setRequestClassName:(NSString*)className;
//-(NSString*)requestClassName;

//NDFN
-(id)propListWithResourceNamed:(NSString*)aName
                        ofType:(NSString*)aType
                   inFramework:(NSString*)aFrameworkName
                     languages:(NSArray*)languages;
+(BOOL)createUnknownComponentClasses:(NSArray*)classes
                      superClassName:(NSString*)aSuperClassName;
+(void)addDynCreateClassName:(NSString*)aClassName
              superClassName:(NSString*)aSuperClassName;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages;
//NDFN
-(NSString*)pathForResourceNamed:(NSString*)aName
                          ofType:(NSString*)aType 
                     inFramework:(NSString*)aFrameworkName
                       languages:(NSArray*)languages;

//NDFN
-(NSString*)urlForResourceNamed:(NSString*)aName
                    inFramework:(NSString*)aFrameworkName
                      languages:(NSArray*)languages
                        request:(GSWRequest*)aRequest;
//NDFN
-(NSString*)stringForKey:(NSString*)key_
            inTableNamed:(NSString*)aTableName
        withDefaultValue:(NSString*)defaultValue
             inFramework:(NSString*)aFrameworkName
               languages:(NSArray*)languages;
//NDFN
//-(NSDictionary*)stringsTableNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages;
//NDFN
//-(NSArray*)stringsTableArrayNamed:(NSString*)aTableName
//                      inFramework:(NSString*)aFrameworkName
//                        languages:(NSArray*)languages;
//NDFN
-(NSArray*)filterLanguages:(NSArray*)languages;
@end

GSWEB_EXPORT GSWApplication* GSWApp;

/* User Defaults. This is an interface in WO 4.x -- dw*/
@interface GSWApplication (UserDefaults)

+(NSArray*)loadFrameworks;
+(void)setLoadFrameworks:(NSArray*)frameworks;
+(BOOL)isDebuggingEnabled;
+(void)setDebuggingEnabled:(BOOL)flag;
+(BOOL)autoOpenInBrowser;
+(void)setAutoOpenInBrowser:(BOOL)flag;
+(BOOL)isDirectConnectEnabled;
+(void)setDirectConnectEnabled:(BOOL)flag;
+(NSString*)cgiAdaptorURL;
+(void)setCGIAdaptorURL:(NSString*)url;
+(BOOL)isCachingEnabled;
+(void)setCachingEnabled:(BOOL)flag;
+(NSString*)applicationBaseURL;
+(void)setApplicationBaseURL:(NSString*)baseURL;
+(NSString*)frameworksBaseURL;
+(void)setFrameworksBaseURL:(NSString*)baseURL;
+(NSString*)recordingPath;
+(void)setRecordingPath:(NSString*)path;
+(NSArray*)projectSearchPath;
+(void)setProjectSearchPath:(NSArray*)pathArray;
+(BOOL)isMonitorEnabled;
+(void)setMonitorEnabled:(BOOL)flag;
+(NSString*)monitorHost;
+(void)setMonitorHost:(NSString*)hostName;
+(NSString*)SMTPHost;
+(void)setSMTPHost:(NSString*)hostName;
+(NSString*)adaptor;
+(void)setAdaptor:(NSString*)adaptorName;
+(NSNumber*)port;
+(void)setPort:(NSNumber*)port;
+(id)listenQueueSize;
+(void)setListenQueueSize:(id)aSize;
+(id)workerThreadCount;
+(void)setWorkerThreadCount:(id)workerThreadCount;
+(NSArray*)additionalAdaptors;
+(void)setAdditionalAdaptors:(NSArray*)adaptorList;
+(BOOL)includeCommentsInResponses;
+(void)setIncludeCommentsInResponses:(BOOL)flag;
+(NSString*)componentRequestHandlerKey;
+(void)setComponentRequestHandlerKey:(NSString*)aKey;
+(NSString*)directActionRequestHandlerKey;
+(void)setDirectActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)ajaxRequestHandlerKey;
+(void)setAjaxRequestHandlerKey:(NSString*)aKey;
+(NSString*)resourceRequestHandlerKey;
+(void)setResourceRequestHandlerKey:(NSString*)aKey;
+(NSString*)statisticsStoreClassName;
+(void)setStatisticsStoreClassName:(NSString*)name;
+(void)setSessionTimeOut:(NSNumber*)aTimeOut;
+(NSNumber*)sessionTimeOut;

+(BOOL)isStatusDebuggingEnabled;//NDFN
+(void)setStatusDebuggingEnabled:(BOOL)flag;//NDFN
+(BOOL)isStatusLoggingEnabled;//NDFN
+(void)setStatusLoggingEnabled:(BOOL)flag;//NDFN
+(NSString*)outputPath;
+(void)setOutputPath:(NSString*)path;
+(BOOL)isLifebeatEnabled;
+(void)setLifebeatEnabled:(BOOL)flag;
+(NSString*)lifebeatDestinationHost;
+(void)setLifebeatDestinationHost:(NSString*)host;
+(int)lifebeatDestinationPort;
+(void)setLifebeatDestinationPort:(int)port;
+(NSTimeInterval)lifebeatInterval;
+(void)setLifebeatInterval:(NSTimeInterval)interval;
+(int)intPort;
+(void)setIntPort:(int)port;
+(NSString*)host;
+(void)setHost:(NSString*)host;
+(id)workerThreadCountMin;
+(void)setWorkerThreadCountMin:(id)workerThreadCount;
+(id)workerThreadCountMax;
+(void)setWorkerThreadCountMax:(id)workerThreadCount;
+(NSString*)streamActionRequestHandlerKey;
+(void)setStreamActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)pingActionRequestHandlerKey;
+(void)setPingActionRequestHandlerKey:(NSString*)aKey;
+(NSString*)staticResourceRequestHandlerKey;
+(void)setStaticResourceRequestHandlerKey:(NSString*)aKey;
+(NSString*)resourceManagerClassName;
+(void)setResourceManagerClassName:(NSString*)name;
+(NSString*)sessionStoreClassName;
+(void)setSessionStoreClassName:(NSString*)name;
+(NSString*)recordingClassName;
+(void)setRecordingClassName:(NSString*)name;
+(Class)recordingClass;
+(void)setSessionTimeOutValue:(NSTimeInterval)aTimeOutValue;
+(NSTimeInterval)sessionTimeOutValue;
+(NSString*)debugSetConfigFilePath;//NDFN
+(void)setDebugSetConfigFilePath:(NSString*)debugSetConfigFilePath;//NDFN
+(void)setDefaultUndoStackLimit:(NSUInteger)limit;
+(NSUInteger)defaultUndoStackLimit;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(NSString*)defaultTemplateParser;//NDFN
+(void)setDefaultTemplateParser:(NSString*)defaultTemplateParser;//NDFN
+(BOOL)defaultDisplayExceptionPages;//NDFN
+(void)setDefaultDisplayExceptionPages:(BOOL)flag;//NDFN
+(void)_setAllowsCacheControlHeader:(BOOL)flag;
+(BOOL)_allowsCacheControlHeader;

+(NSDictionary*)_webServerConfigDictionary;
+(Class)_applicationClass;
+(Class)_compiledApplicationClass;
+(GSWRequestHandler*)_componentRequestHandler;

+(id)defaultModelGroup;
+(id)_modelGroupFromBundles:(id)_bundles;

-(NSDictionary*)mainBundleInfoDictionary;
+(NSDictionary*)mainBundleInfoDictionary;
-(NSDictionary*)bundleInfo;
+(NSDictionary*)bundleInfo;
-(NSBundle*)mainBundle;
+(NSBundle*)mainBundle;

+(int)_garbageCollectionRepeatCount;
+(BOOL)_lockDefaultEditingContext;
+(void)_setLockDefaultEditingContext:(BOOL)flag;
+(id)_allowsConcurrentRequestHandling;
+(void)_setAllowsConcurrentRequestHandling:(id)unknown;


+(int)_requestLimit;
+(int)_requestWindow;
+(BOOL)_multipleThreads;
+(BOOL)_multipleInstances;
+(void)_readLicenseParameters;

@end /* User defaults */

#endif //_GSWApplication_h__
