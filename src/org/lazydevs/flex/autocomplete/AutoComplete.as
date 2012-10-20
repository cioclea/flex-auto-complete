/**
 * Created with IntelliJ IDEA.
 * User: Sascha
 * Date: 20.10.12
 * Time: 00:11
 * To change this template use File | Settings | File Templates.
 */
package org.lazydevs.flex.autocomplete {
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.core.IFactory;
import mx.core.LayoutDirection;

import spark.collections.Sort;
import spark.components.List;
import spark.components.PopUpAnchor;
import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.NavigationUnit;
import spark.events.TextOperationEvent;

[Event(name="autoCompleteSelect", type="org.lazydevs.flex.autocomplete.AutoCompleteEvent")]
public class AutoComplete extends SkinnableComponent {

    [SkinPart(required)]
    public var popup:PopUpAnchor;

    [SkinPart(required)]
    public var list:List;

    [SkinPart(required)]
    public var input:TextInput;

    private var _dataProvider:IList;
    private var _collection:ListCollectionView = new ListCollectionView();
    private var _itemRenderer:IFactory;
    private var _filterFunction:Function;
    private var _sort:Sort;

    public function get dataProvider():IList {
        return _dataProvider;
    }

    public function set dataProvider(value:IList):void {
        _dataProvider = value;
        _collection.list = _dataProvider;
    }

    public function get itemRenderer():IFactory {
        return _itemRenderer;
    }

    public function set itemRenderer(value:IFactory):void {
        _itemRenderer = value;
        if (list) list.itemRenderer = _itemRenderer;
    }

    public function get filterFunction():Function {
        return _filterFunction;
    }

    public function set filterFunction(value:Function):void {
        _filterFunction = value;
        _collection.filterFunction = _filterFunction;
    }

    public function get sort():Sort {
        return _sort;
    }

    public function set sort(value:Sort):void {
        _sort = value;
        _collection.sort = _sort;
    }

    public function get text():String {
        return input ? input.text : "";
    }

    public function set text(value:String):void {
        if (!input)
            return;

        input.text = value;
    }

    public function AutoComplete() {
        filterFunction = defaultFilterFunction;
    }

    override protected function partAdded(partName:String, instance:Object):void {

        super.partAdded(partName, instance);

        if (instance == list) {

            if (_itemRenderer)
                list.itemRenderer = _itemRenderer;

            list.focusEnabled = false;
            list.allowMultipleSelection = false;
            list.dataProvider = _collection;
            list.addEventListener(MouseEvent.CLICK, onList_Click);
        }

        if (instance == input) {

            input.addEventListener(TextOperationEvent.CHANGE, onTextInput_Change);
            input.addEventListener(KeyboardEvent.KEY_DOWN, onTextInput_KeyDown);
            input.addEventListener(FocusEvent.FOCUS_OUT, onTextInput_FocusOut);
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void {

        if (instance == list) {

            list.removeEventListener(MouseEvent.CLICK, onList_Click);
        }

        if (instance == input) {

            input.removeEventListener(TextOperationEvent.CHANGE, onTextInput_Change);
            input.removeEventListener(KeyboardEvent.KEY_DOWN, onTextInput_KeyDown);
            input.removeEventListener(FocusEvent.FOCUS_OUT, onTextInput_FocusOut);
        }

        super.partRemoved(partName, instance);
    }

    private function onList_Click(e:Event):void {
        selectItem();
    }

    private function onTextInput_FocusOut(e:Event):void {
        closePopup();
    }

    private function onTextInput_Change(e:Event):void {
        filterItems();
    }

    private function onTextInput_KeyDown(e:KeyboardEvent):void {

        if (popup.displayPopUp) {
            switch (e.keyCode) {
                case Keyboard.UP:
                case Keyboard.DOWN:
                case Keyboard.END:
                case Keyboard.HOME:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN:
                    input.selectRange(text.length, text.length);
                    selectListItem(e);
                    break;
                case Keyboard.TAB:
                case Keyboard.ENTER:
                    selectItem();
                    break;
                case Keyboard.ESCAPE:
                    input.text = "";
                    closePopup();
                    break;
            }
        }
    }

    private function filterItems():void {

        _collection.refresh();

        if (input.text.length == 0 || _collection.length == 0) {
            closePopup();
            return;
        }

        openPopup();

        list.invalidateProperties();
        list.validateNow();
        list.selectedIndex = 0;
        list.dataGroup.horizontalScrollPosition = 0;
        list.dataGroup.verticalScrollPosition = 0;
    }

    private function selectItem():void {

        if (_collection.length == 0 || !list.selectedItem)
            return;

        var event:AutoCompleteEvent = new AutoCompleteEvent(AutoCompleteEvent.AUTO_COMPLETE_SELECT);

        event.item = list.selectedItem;

        input.text = "";

        closePopup();

        dispatchEvent(event);
    }

    private function selectListItem(e:KeyboardEvent):void {

        var navigationUnit:uint = mapKeyCodeForLayoutDirection(e);

        if (!NavigationUnit.isNavigationUnit(e.keyCode))
            return;

        var proposedNewIndex:int = list.layout.getNavigationDestinationIndex(list.caretIndex, navigationUnit, false);

        if (proposedNewIndex == -1)
            return;

        list.selectedIndex = proposedNewIndex;
        list.ensureIndexIsVisible(proposedNewIndex);
    }

    private function openPopup():void {

        popup.displayPopUp = true;
    }

    private function closePopup():void {
        popup.displayPopUp = false;
    }

    private function defaultFilterFunction(item:*):Boolean {

        return input.text == null || input.text.length == 0 || item.toString().toLowerCase().indexOf(input.text.toLowerCase()) >= 0;
    }

    private function mapKeyCodeForLayoutDirection(event:KeyboardEvent, mapUpDown:Boolean = false):uint {

        var keyCode:uint = event.keyCode;

        // If rtl layout, left still means left and right still means right so
        // swap the keys to get the correct action.
        switch (keyCode) {
            case Keyboard.DOWN:
            {
                // typically, if ltr, the same as RIGHT
                if (mapUpDown && layoutDirection == LayoutDirection.RTL)
                    keyCode = Keyboard.LEFT;
                break;
            }
            case Keyboard.RIGHT:
            {
                if (layoutDirection == LayoutDirection.RTL)
                    keyCode = Keyboard.LEFT;
                break;
            }
            case Keyboard.UP:
            {
                // typically, if ltr, the same as LEFT
                if (mapUpDown && layoutDirection == LayoutDirection.RTL)
                    keyCode = Keyboard.RIGHT;
                break;
            }
            case Keyboard.LEFT:
            {
                if (layoutDirection == LayoutDirection.RTL)
                    keyCode = Keyboard.RIGHT;
                break;
            }
        }

        return keyCode;
    }
}
}
