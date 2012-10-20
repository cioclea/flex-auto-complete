/**
 * Created with IntelliJ IDEA.
 * User: Sascha
 * Date: 20.10.12
 * Time: 10:03
 * To change this template use File | Settings | File Templates.
 */
package org.lazydevs.flex.autocomplete {
import flash.events.Event;

public class AutoCompleteEvent extends Event{

    public static const AUTO_COMPLETE_SELECT:String = "autoCompleteSelect";

    public var item:*;

    public function AutoCompleteEvent(type:String) {
        super(type);
    }
}

}
