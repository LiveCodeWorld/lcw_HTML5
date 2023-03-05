script "Global | HTML | TagCloud | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | HTML | TagCloud | Menu
type: controller
version: 0.1

local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]   
   pass menu_Target
end menu_Target

getprop menu_IsSimple
   return true
end menu_IsSimple

function html_ConstructListArray
   local iListArray
   html_AddToListArray iListArray, "one", 1 
   html_AddToListArray iListArray, "two", 2
   html_AddToListArray iListArray, "three", 3 
   html_AddToListArray iListArray, "four", 4 
   --
   return iListArray
end html_ConstructListArray


--> Global | HTML | TagCloud | Menu
-
on menu_DisplayHtml displayView
   put the displayed_Text of displayView into someHTML
   --
   put html_ConstructListArray() into iListArray
   put html_ConstructListXml (someHTML, "tagcloud", iListArray) into someHTML 
   --
   display_Html someHTML, "Test List", "mouse", "toplevel"
   -- put someHTML
end menu_DisplayHtml

on menu_UploadHtml
   breeakpoint
   put the displayed_Text of displayView into someHTML
   --
   put html_ConstructListArray() into iListArray
   put html_ConstructListXml (someHTML, "tagcloud", iListArray) into someHTML 
   --
end menu_UploadHtml

on _
end _

on menu_Test displayView
   put the displayed_Text of displayView into someHTML
   --
   put html_ListNodes (someHTML)
end menu_Test

on menu_TestList
   put html_ConstructListArray() into iListArray
   put html_ConstructListLines (iListArray, pIndentString)
end menu_TestList

on menu_GetDiv displayView
   put the displayed_Text of displayView into someHTML
   --
   revXMLDeleteAllTrees
   put html_ConstructListArray() into iListArray
   --
   put html_ConstructListXml (someHTML, "tagcloud", iListArray)
end menu_GetDiv
