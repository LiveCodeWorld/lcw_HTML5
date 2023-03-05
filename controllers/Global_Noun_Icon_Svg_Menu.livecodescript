script "Global | Noun | Icon | Svg | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Noun | Icon | Svg | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   if exists (displayView) then
      put the displayed_Object of displayView into svgStack
      if exists (svgStack) is false then return displayView
      put the long id of control 1 of cd 1 of svgStack into svgView
      return svgView
   else
      return tObject
   end if
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Noun | Icon | Svg | Menu
-
on menu_DisplaySvgButton svgView
   put the svg_XML of svgView into svgXML
   --
   -- put the stack_Name of svgView into stackName
   -- put the label of stack stackName into sLable
   put the icon_Data of svgView into iconData
   put iconData ["term"] into sLable
   --
   display_SvgButton svgXML, sLable
   put the result into svgButton
   set the icon_Data of svgButton to iconData
   return svgButton
end menu_DisplaySvgButton

on submenu_Assets
   return "Global | Svg | Assets | Menu"
end submenu_Assets

private command _
end _

on menu_DisplayIconData svgView
   put the icon_Data of svgView into iconData
   display_Data iconData, "icon_Data"
end menu_DisplayIconData

on menu_DisplaySvgUrl svgView
   put the svg_URL of svgView into svgURL
   put svgURL
end menu_DisplaySvgUrl

private command __
end __

on menu_DisplaySvgXml svgView
   put the svg_XML of svgView into svgXML
   --
   display_Text svgXML
end menu_DisplaySvgXml

on menu_DisplaySvgPathText svgView
   put the svg_XML of svgView into svgXML
   --
   put svg_GetPathText (svgXML)
end menu_DisplaySvgPathText

on menu_DisplayNodeOutline svgView
   put the svg_XML of svgView into svgXML
   put svg_GetNodeOutline (svgXML)
end menu_DisplayNodeOutline

private on __
end __

on subMenu_Frame
   return "Global | Frame | Menu"
end subMenu_Frame
