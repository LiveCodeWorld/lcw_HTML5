script "lib_HtmlCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_HtmlCreate
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Html | Create
-
function html_ConstructDiv divContent, pDivClass, pDivID, pOtherParams, pTabChars
   if pTabChars is empty then put "  " into pTabChars
   --
   put "<div" into oTag
   if pDivClass is not empty then
      put space & "class='[[pDivClass]]'" after oTag
   end if
   if pDivID is not empty then
      put space & "id='[[pDivID]]'" after oTag
   end if
   if pOtherParams is not empty then
      put space & pOtherParams after oTag
   end if
   put ">" after oTag
   --
   line_Indent divContent, pTabChars
   --
   put merge (oTag & CR & divContent & CR & "</div>") into divSection
   return divSection
end html_ConstructDiv


--> XML | Construct
-
function xml_Enclose someString, tagName, pIndent, pAttributeName, pAttributeValue
   -- same as "xml_Tag" but slower and prettier output
   put "<" & tagName into taggedText
   put 2 into attributNum
   get the paramcount
   put it/2 - 1 into attributeCount
   repeat attributeCount
      put 2 * attributNum into paramNum
      put param (paramNum) into attributeName
      put param (paramNum+1) into attributeValue
      if attributeValue is not empty then
         put space & attributeName & "=" & kwote (attributeValue) after taggedText
      end if
      add 1 to attributNum
   end repeat
   
   if someString is empty then
      put "/>" after taggedText
   else if pIndent is true then
      put ">" & CR & outline_IncreaseIndent(word 1 to -1 of someString) & CR & "</" & word 1 of tagName & ">" after taggedText
   else
      put ">" & word 1 to -1 of someString & "</" & word 1 of tagName & ">" after taggedText
   end if
   return taggedText
end xml_Enclose

function xml_ConstructOpeningTag tagName, attributeName, attributeValue
   put "<" & tagName into taggedText
   put (the paramcount - 1)/2  into attributeCount
   repeat with attributeNum = 1 to attributeCount
      put param(2*attributeNum) into attributeName
      put param(2*attributeNum + 1) into attributeValue
      put space & attributeName & "=" & kwote(attributeValue) after taggedText
      add 1 to attributNum
   end repeat
   put ">" after taggedText
   return taggedText
end xml_ConstructOpeningTag

function xml_ConstructSimpleTag tagName, attributeName, attributeValue
   -- was "construct_SimpleTag" before "encloseInTag"
   put "<" & tagName into taggedText
   put (the paramcount - 1)/2  into attributeCount
   repeat with attributeNum = 1 to attributeCount
      put param (2*attributeNum) into attributeName
      put param (2*attributeNum + 1) into attributeValue
      put space & attributeName & "=" & kwote(attributeValue) after taggedText
      add 1 to attributNum
   end repeat
   put "/>" after taggedText
   return taggedText
end xml_ConstructSimpleTag


--> Html | List
-
function html_ConstructList someLines, pIsOrdered
   switch pIsOrdered
      case "ordered"
         put "<ol>" into someHtml
         break
      default
         put "<ul>" into someHtml
   end switch
   repeat for each line someLine in someLines
      put CR & tab & "<li>" & html_ConstructRefLink (someLine, someLine) & "</li>" after someHtml
      -- put CR & tab & "<li>" & someLine after someHtml
   end repeat
   switch pIsOrdered
      case "ordered"
         put CR & "</ol>" after someHtml
         break
      default
         put CR & "</ul>" after someHtml
   end switch
   return someHtml
end html_ConstructList


--> Html | Style
-
function html_MakeBold someText
   html_AddTag someText, "b"
   return someText
end html_MakeBold

function html_MakeColoured someText, someColour
   if someColour is empty then return someText
   colour_HexNormalise someColour
   return "<font color=" & kwote(someColour) & ">" & someText & "</font>"
end html_MakeColoured

function html_ConstructColouredText someText, someColour
   -- creates or changes coloured html
   if someColour is empty then return someText
   colour_HexNormalise someColour
   
   -- put "<font color=" & quote & "(.+)" & quote & ">"  into someReg
   put "<font color=" & quote & "([^\>]+)" & quote & ">"  into someReg
   if matchchunk(someText, someReg, startNum, endNum) is true then
      put someColour into char startNum to endNum of someText
      return someText
   else
      return "<font color=" & kwote(someColour) & ">" & someText & "</font>"
   end if
end html_ConstructColouredText

function html_ConstructNameLink someText, someLink, pSomeColour
   if someLink is empty then return someText
   -- replace quote with "'" in someLink
   replace quote with "&quot;" in someLink
   put "<a name=" & kwote(someLink) & ">" & someText & "</a>" into someLink
   if pSomeColour is not empty then return html_ConstructColouredText (someLink, pSomeColour)
   return someLink
end html_ConstructNameLink


--> HTML | Video
-
function html_ConstructVideoTag videoURL, pMediaType, pVideoWidth, pShowControls, pPosterImageFile, pFallbackHtml
   -- this is a single source video tag
   if pFallbackHtml is empty then put "This is fallback content to display for user agents that do not support the video tag." into pFallbackHtml
   
   put "<video" into someHTML
   put space & "src=" & quote & videoURL & quote after someHTML
   switch word 1 of pMediaType
      case "webm"
         put space & "type='video/webm'" after someHTML
         break
      case "mp4"
         put  space & "type='video/mp4'" after someHTML
   end switch
   
   if pVideoWidth is not empty then put space & "width=" & quote & pVideoWidth & quote after someHTML
   if pShowControls is not false then put space & "controls" after someHTML
   if pPosterImageFile is not empty then put space & "poster=" & quote & pPosterImageFile & quote after someHTML
   put ">" after someHTML
   
   put pFallbackHtml after someHTML
   put "</video>" after someHTML
   
   return someHTML
end html_ConstructVideoTag

function html_ConstructOpenVideoTag pVideoWidth, pShowControls, pPosterImageFile
   -- this constructs an opening video tag
   put "<video" into someHTML
   if pPosterImageFile is not empty then put space & "poster=" & quote & pPosterImageFile & quote after someHTML
   if pVideoWidth is not empty then put space & "width=" & quote & pVideoWidth & quote after someHTML
   if pShowControls is not false then put space & "controls" after someHTML
   put ">" after someHTML
   return someHTML
end html_ConstructOpenVideoTag

function html_ConstructVideoSourceTag videoURL, pMediaType
   -- multiple source video tag
   -- should enhance to extract pMediaType from file extension
   put "<source src=" & quote & videoURL & quote into someHTML
   switch pMediaType
      case "webm"
         put space & "type='video/webm" after someHTML
         break
      case "mp4"
         put  space & "type='video/mp4" after someHTML
   end switch
   -- maybe add codecs?
   put ">" after someHTML
   return someHTML
end html_ConstructVideoSourceTag

function html_ConstructRefLink someText, someLink, pTarget
   if someLink is empty then return someText
   replace quote with "&quot;" in someLink
   put "<a href=" & quote & someLink & quote  into someLink
   if pTarget is not empty then
      -- "_blank" -- for opening in a new window
      put space & "target=" &quote& pTarget &quote after someLink
   end if
   put ">" & someText & "</a>" after someLink
   return someLink
end html_ConstructRefLink


--> Html | Sections
-
function html_AddHeaders someBody, htmlTitle, headerSection
   -- was "htmlHeaders"
   put "<HTML>" into someHtml
   if headerSection is empty then
      put CR & tab & "<HEAD><TITLE>" & htmlTitle & "</TITLE></HEAD>" after someHtml
   else
      put CR & tab & "<HEAD>" after someHtml
      put CR & tab & tab & "<TITLE>" & htmlTitle & "</TITLE>" after someHtml
      put CR & outline_IncreaseIndent(headerSection, 2) after someHtml
      put CR & tab & "</HEAD>" after someHtml
   end if
   put CR & tab & "<BODY>" after someHtml
   put CR & outline_IncreaseIndent(someBody, 2) after someHtml
   put CR & tab & "</BODY>" after someHtml
   put CR & "</HTML>" after someHtml
   return someHtml
end html_AddHeaders

command html_AddTag @someText, tagName
   put format ("<%s>%s</%s>", tagName, someText, tagName) into someText
end html_AddTag
