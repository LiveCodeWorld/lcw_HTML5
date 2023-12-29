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
function wiki_MergeFragment tName, wikiDomain, pageSlug, pageTitle
   put scaffold_Get (tName) into htmlTemplate
   put merge (htmlTemplate) into htmlFragment
   return htmlFragment
end wiki_MergeFragment

function wiki_RenderHtml htmlTemplate, wikiDomain, pPageSlug, pOwnedBy
   if pPageSlug is empty then put "welcome-visitors" into pPageSlug
   --
   put pageArray_Get (wikiDomain, pPageSlug) into pageArray
   put pageArray ["story"] into storyArray
   put pageArray ["title"] into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   wikiClient_SetEndScript htmlTemplate, pageTitle, pOwnedBy
   --
   put wiki_MergeFragment ("wiki-handle-parent", wikiDomain, pageSlug, pageTitle) & CR after pageDivContents
   put wiki_MergeFragment ("wiki-twins", wikiDomain, pageSlug, pageTitle) & CR after pageDivContents
   put wiki_MergeFragment ("wiki-header", wikiDomain, pageSlug, pageTitle) & CR after pageDivContents
   --
   put wiki_ConstructStoryDiv (storyArray) & CR after pageDivContents
   --
   put wiki_MergeFragment ("wiki-backlinks", wikiDomain, pageSlug, pageTitle) & CR after pageDivContents
   put wiki_ConstructFooter (wikiDomain, pageSlug) after pageDivContents
   
   put wiki_ConstructPageDiv (pageDivContents, pPageSlug) into pageDiv
   --
   wiki_SetTagOffsets htmlTemplate, "pages", startCharNum, endCharNum
   put the result into innerHTML
   if innerHTML is not empty then
      put pageDiv into char startCharNum to endCharNum of htmlTemplate
   end if
   return htmlTemplate
end wiki_RenderHtml

command wikiClient_SetEndScript @htmlTemplate, pageTitle, pOwnedBy, pIsAuthenticated, pIsClaimed, pIsOwner, pSeedNeighbors, pUser
   if pOwnedBy is empty then put "David Bovill" into pOwnedBy
   --
   replace "{{title}}" with pageTitle in htmlTemplate
   --
   wiki_SetTagOffsets htmlTemplate, "owned", startCharNum, endCharNum
   put the result into innerHTML
   if htmlTemplate is not empty then
      curly_ReplaceText innerHTML, "ownedBy", pOwnedBy
      put innerHTML into char startCharNum to endCharNum of htmlTemplate
   end if
   --
   put pIsAuthenticated is true into pIsAuthenticated
   curly_ReplaceText htmlTemplate, "authenticated", pIsAuthenticated
   --
   put pIsClaimed is true into pIsClaimed
   curly_ReplaceText htmlTemplate, "owned", pIsClaimed
   --
   put pIsOwner is true into pIsOwner
   curly_ReplaceText htmlTemplate, "isOwner", pIsOwner
   --
   curly_ReplaceText htmlTemplate, "seedNeighbors", pSeedNeighbors
   --
   curly_ReplaceText htmlTemplate, "user", pUser
end wikiClient_SetEndScript

function wiki_ConstructFooter wikiDomain, pageSlug
   put scaffold_Get ("wiki-footer") into footerFragment
   return footerFragment
end wiki_ConstructFooter

command wiki_SetTagOffsets sHTML, tagName, @startCharNum, @endCharNum
   put merge ("{{#[[tagName]]}}") into startTag
   put merge ("{{/[[tagName]]}}") into endTag
   --
   put offset (startTag, sHTML) into startCharNum
   if startCharNum = 0 then
      put 0 into endCharNum
      return empty
   else
      get offset (endTag, sHTML, startCharNum)
      if it = 0 then
         put 0 into endCharNum
         return empty
      end if
      put it + startCharNum - 1 into endInnerCharNum
      put endInnerCharNum + the number of chars of endTag into endCharNum
      --
      put startCharNum + the number of chars of startTag into startInnerCharNum
      put char startInnerCharNum to endInnerCharNum of sHTML into innerHtml
      return innerHtml
   end if
end wiki_SetTagOffsets

function wiki_ConstructTextDiv sText, pID
   /*
   -- the <a class="internal" href="/astral-ship.html" data-page-name="astral-ship" title="view">Astral Ship</a>.
   */
   pageArray_AssignID pID
   put xml_Enclose (sText, "p") into sPara
   put html_ConstructDiv (sPara, "item paragraph", pID) into textDiv
   return textDiv
end wiki_ConstructTextDiv

function wiki_ConstructFactoryDiv pID, pHelpText
   pageArray_AssignID pID
   if pHelpText is empty then
      put "Double-Click to Edit<br>Drop Text or Image to Insert<br>Or Choose a Plugin" into pHelpText
   end if
   
   put scaffold_Get ("wiki-factory") into htmlTemplate
   put merge (htmlTemplate) into factoryDiv
   return factoryDiv
end wiki_ConstructFactoryDiv

function wiki_ConstructStoryDiv storyArray
   repeat with itemNum = 1 to item 2 of the extents of storyArray
      put storyArray [itemNum] into itemArray
      --
      put itemArray ["id"] into pID
      put itemArray ["text"] into sText
      --
      put itemArray ["type"] into itemType
      switch itemType
         case "paragraph"
            put wiki_ConstructTextDiv (sText) into newDiv
            break
         case "markdown"
            put wiki_ConstructTextDiv (sText) into newDiv
            break
         case "factory"
            put wiki_ConstructFactoryDiv (pID) into newDiv
            break
         default
            -- breakpoint
      end switch
      --
      put newDiv & CR after storyDiv
   end repeat
   delete char -1 of storyDiv
   return storyDiv
end wiki_ConstructStoryDiv


--> Html | Create
-
function wiki_ConstructPageDiv storyDiv, pPageSlug, pTabChars
   if pTabChars is empty then put "  " into pTabChars
   --
   put html_ConstructDiv (storyDiv, "paper") into paperDiv
   line_Indent paperDiv, pTabChars
   put html_ConstructDiv (paperDiv, "page", pPageSlug, "tabindex='-1'") into pageDiv
   return pageDiv
end wiki_ConstructPageDiv

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
      put param(2*attributeNum) into attributeName
      put param(2*attributeNum + 1) into attributeValue
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

command html_DeconstructLink someLine, @someText, @someLink
   -- <a href="/Users/david/Movies/crossingTheBridge.mp4">Crossing The Bridge</a>
   -- (?Usi)
   put "<a (href)|(name)=" & quote & "([^>]*)" & quote & ">([^<]*)</a>" into someReg
   if matchtext(someLine, someReg, dummy1, dummy2, someLink, someText) is false then
      put someLine into someText
      put empty into someLink
   end if
end html_DeconstructLink

command html_DeconstructNameLink someLine, @someText, @someLink
   -- <a name="/Users/david/Movies/crossingTheBridge.mp4">Crossing The Bridge</a>
   
   put "<a name=" & quote & "([^>]*)" & quote & ">([^<]*)</a>" into someReg
   if matchtext(someLine, someReg, someLink, someText) is false then
      put someLine into someText
      put empty into someLink
   end if
end html_DeconstructNameLink

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
