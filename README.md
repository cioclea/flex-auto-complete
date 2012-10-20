An auto complete input for Flex 4 (Spark), based on the component found here: http://flashcommander.org/blog/flex-4-autocomplete. I cleaned up the code, removed some options that I didn't need and added others. The main difference is that you can now provide an item renderer for the auto complete suggestions.

Some features:
* Possibility to provide custom filter function (*AutoComplete.filterFunction*), can access (*AutoComplete.text*) to get the entered text
* Possibility to provide custom sort object (*AutoComplete.sort*)
* Possibility to provide custom item renderer for the suggestions in the drop-down (*AutoComplete.itemRenderer*)
* Possibility to provide a label field / function (*AutoComplete.labelField, AutoComplete.labelFunction*). Used for the display of suggestions if no item renderer is specified, and to complete the text based on the selected suggestion
* Option to clear the text when an item is selected (*AutoComplete.clearTextAfterSelection*)

Differences to the original component:
* Only opens the drop down when the user starts typing, no option to open on focus
* Escape clears the text and closes drop-down
* Avoids the workaround of using a customized list for dispatching keyboard events to the drop-down
* Default filter function always uses contains on item label, no option to use starts-with