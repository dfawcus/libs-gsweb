/** GSWHTMLTemplateParser.m - <title>GSWeb: Class GSWHTMLTemplateParser</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
   $Revision$
   $Date$
   $Id$
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include "GSWHTMLRawParser.h"

//====================================================================
@implementation GSWHTMLTemplateParser

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
    {
      NSDebugMLog(@"_currentElement=%@",_currentElement);
    }
  return self;
}

//--------------------------------------------------------------------
-(GSWElement*)parseHTML
{
  GSWElement* template=nil;

  LOGObjectFnStart();

  if ([_string length])
    {
      GSWHTMLRawParser* htmlRawParser = [GSWHTMLRawParser parserWithDelegate:self
                                                          htmlString:_string];

      NS_DURING
        {
          [htmlRawParser parseHTML];
        }
      NS_HANDLER
        {
          [[[localException class] 
             exceptionWithName:[localException name]
             reason:[NSString stringWithFormat:@"In template named %@: %@",
                             _templateName,[localException reason]]
             userInfo:[localException userInfo]]raise];
        }
      NS_ENDHANDLER;

      if ([_currentElement parentElement])
        {
          NSDebugMLog(@"_currentElement=%@",_currentElement);
          [NSException raise:NSInvalidArgumentException 
                       format:@"In template named %@: Missing dynamic tag end after reaching end of template. Tag name is '%@'. templateInfo: %@",
                       _templateName,[_currentElement name],[_currentElement templateInfo]];
        }
      else
        template=[_currentElement template];
    };

  LOGObjectFnStop();

  return template;
};

//--------------------------------------------------------------------
-(GSWElement*)parse
{
  GSWElement* template=nil;

  LOGObjectFnStart();

  [self parseDeclarations];
  _currentElement = [GSWTemporaryElement temporaryElement];
  template=[self parseHTML];

  // If we've found error raise exception
  NSDebugMLog(@"_errorMessages=%@",_errorMessages);
  if ([[self errorMessages]count]>0)
    {
      NSDebugMLog(@"declarationsFilePath=%@",_declarationsFilePath);
      NSDebugMLog(@"errorMessages=%@",[self errorMessages]);
      ExceptionRaise(@"GSWHTMLTemplateParser",@"%@\nDefinitionFiles: %@",
                     [self errorMessagesAsText],
                     _processedDeclarationsFilePaths);
    };

  LOGObjectFnStop();

  return template;
}

//--------------------------------------------------------------------
//TEMP should be removed later
-(GSWElement*)template
{
  return [self parse];
};

//--------------------------------------------------------------------
/** Called by parser when it has parsed raw text
Creates a GSWHTMLBareString element with the text
**/
-(void)parser:(GSWBaseParser*)parser
 didParseText:(NSString*)text
{
  GSWHTMLBareString* element=nil;

  LOGObjectFnStart();

  NSDebugMLog(@"text=%@",text);

  element = [GSWHTMLBareString elementWithString:text];

  [_currentElement addChildElement:element];

  LOGObjectFnStop();
}


//--------------------------------------------------------------------
/** Called by parser when it has opened  a dynamic tag 
Creates a GSWTemporaryElement element, waiting for tag end
**/
-(void)				parser:(GSWBaseParser*)parser
       didParseOpeningDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
                        withProperties:(NSDictionary*)tagProperties
                          templateInfo:(NSString*)templateInfo
{
  LOGObjectFnStart();

  NSDebugMLog(@"Opening element: tagProperties=%@",tagProperties);
  NSDebugMLog(@"Opening element: templateInfo=%@",templateInfo);
  NSDebugMLog(@"Opening element: parent=%@",_currentElement);

  _currentElement = [GSWTemporaryElement temporaryElementOfType:tagType
                                         withProperties:tagProperties
                                         templateInfo:templateInfo
                                         parent:_currentElement];

  NSDebugMLog(@"New (Child) _currentElement=%@",_currentElement);

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
/** Called by parser when it has closed  a dynamic tag 
Creates a dynamic element from current temporary element element
**/
-(void)				parser:(GSWBaseParser*)parser
       didParseClosingDynamicTagOfType:(GSWHTMLRawParserTagType)tagType
                      withTemplateInfo:(NSString*)templateInfo
{
  GSWTemporaryElement* parent=nil;

  LOGObjectFnStart();
  
  NSDebugMLog(@"Closing element=%@",_currentElement);

  parent=[_currentElement parentElement];
  NSDebugMLog(@"Parent element=%@",_currentElement);

  if(!parent)
    {
      [NSException raise:NSInvalidArgumentException 
                   format:@"Unmatched dynamic tag end. %@.",
                   templateInfo];
    } 
  else
    {
      NS_DURING
        {
          GSWElement* element = nil;
          element = [_currentElement dynamicElementWithDeclarations:_declarations
                                     languages:_languages];
          NSDebugMLog(@"element=%@",element);
          
          NSAssert2(element,@"No element for %@ with declarations %@",_currentElement,_declarations);
          
          [parent addChildElement:element];
        }
      NS_HANDLER
        {
          NSDebugMLog(@"Exception: %@",localException);
          if ([localException isKindOfClass:[GSWDeclarationFormatException class]]
              && [(GSWDeclarationFormatException*)localException canDelay])
            {
              [self addErrorMessageFormat:@"In template named %@: %@",
                    _templateName,[localException description]];
            }
          else
            {
              [[[localException class] 
                 exceptionWithName:[localException name]
                 reason:[NSString stringWithFormat:@"In template named %@: %@",
                                  _templateName,[localException reason]]
                 userInfo:[localException userInfo]]raise];
            };
        }
      NS_ENDHANDLER;

      _currentElement = parent;

      NSDebugMLog(@"New (Parent) _currentElement=%@",_currentElement);
    }
  LOGObjectFnStop();
}

//--------------------------------------------------------------------
/** Called by parser when it has parsed a comment
Creates a GSWHTMLComment with the comment text
**/
-(void)		parser:(GSWBaseParser*)parser
       didParseComment:(NSString*)text
{
  GSWHTMLComment* element=nil;

  LOGObjectFnStart();

  NSDebugMLog(@"didParseComment child Of element: %@",_currentElement);
  NSDebugMLog(@"string=%@",text);

  element = [GSWHTMLComment elementWithString:text];
  NSDebugMLog(@"element=%@",element);

  [_currentElement addChildElement:element];
  NSDebugMLog(@"_currentElement=%@",_currentElement);

  LOGObjectFnStop();
}

@end

