import Toybox.Lang;
import Toybox.WatchUi;

class NotesDelegate extends WatchUi.BehaviorDelegate {

    private var _controlsCallback;
    private var _menuCallback;
    private var _notesRepository as NotesRepository;

    function initialize(controlsCallback, menuCallback, notesRepository as NotesRepository) {
        BehaviorDelegate.initialize();
        _controlsCallback = controlsCallback;
        _menuCallback = menuCallback;
        _notesRepository = notesRepository;
    }

    function onMenu() as Boolean {
        _menuCallback.onMenu();
        var menu = new WatchUi.Menu2({});
        var delegate;

        var clearLabel = WatchUi.loadResource(Rez.Strings.menu_clear);

        menu.addItem(
            new WatchUi.MenuItem(
                clearLabel,
                null,
                :clear,
                null
            )
        );

        var slotLabelTemplate = WatchUi.loadResource(Rez.Strings.menu_slot_template);
        var emptySummaryLabel = WatchUi.loadResource(Rez.Strings.empty_string_placeholder);
        var notesSummaries = _notesRepository.getNoteSummaries();
        var selectedNoted = _notesRepository.getCurrentNoteIndex();

        for(var i = 0; i < notesSummaries.size(); i += 1) {
            var title;
            var subtitle;

            if (i == selectedNoted) {
                title = "[" + slotLabelTemplate + " " + i + "]";
            }
            else {
                title = slotLabelTemplate + " " + i;
            }

            var summary = notesSummaries[i];
            if (summary == null || summary.equals("")) {
                subtitle = emptySummaryLabel;
            }
            else {
                subtitle = summary;
            }

            menu.addItem(
                new WatchUi.MenuItem(
                    title,
                    subtitle,
                    i,
                    null
                )
            );
        }

        delegate = new NotesMenuDelegate(_menuCallback);

        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onSelectable(event as WatchUi.SelectableEvent) as Boolean {
        var instance = event.getInstance();
        if (instance instanceof TextButton && instance.getState() == :stateSelected) {
            _controlsCallback.onKeyboardKeyPressed(instance.keyType, instance.getCurrentKey());
        }
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if(key == WatchUi.KEY_DOWN) {
            _controlsCallback.onScrollDown();
            return true;
        } else if(key == WatchUi.KEY_UP) {
            _controlsCallback.onScrollUp();
            return true;
        }
        return false;
    }
}