import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class NotesMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _callback;

    function initialize(callback) {
        Menu2InputDelegate.initialize();
        _callback = callback;
    }

    function onSelect(item) as Void {
        var id = item.getId();
        if(id == :clear) {
            _callback.onClear();
        }
        else {
            _callback.onNoteSlotSelected(id);
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}