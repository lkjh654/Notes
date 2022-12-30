import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Timer;

class NotesApp extends Application.AppBase {

    private const AUTO_SAVE_TICK_MILLIS = 5000;
    private var _view as NotesView;
    
    private var _autoSaveTimer as Timer.Timer;

    private var _notesRepository as NotesRepository;

    function initialize() {
        AppBase.initialize();
        _autoSaveTimer = new Timer.Timer();
        _notesRepository = new NotesRepository();
    }

    function onStart(state as Dictionary?) as Void {
        _autoSaveTimer.start(method(:save), AUTO_SAVE_TICK_MILLIS, true);
    }

    function onStop(state as Dictionary?) as Void {
        _autoSaveTimer.stop();
        save();
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        _view = new NotesView(_notesRepository.getCurrentNote());
        return [_view , new NotesDelegate(_view, self, _notesRepository) ] as Array<Views or InputDelegates>;
    }

    (:glance)
    function getGlanceView() {
        return [ new NotesGlanceView(_notesRepository.getCurrentNote()) ];
    }

    function save() as Void {
        if(_view != null){
            _notesRepository.saveCurrentNote(_view.getText());
        }
    }

    function onClear() as Void {
        _view.onClear();
        save();
    }

    function onMenu() as Void {
        save();
    }

    function onNoteSlotSelected(index as Number) as Void {
        _notesRepository.setCurrentNoteIndex(index);
        _view.setText(_notesRepository.getCurrentNote());
    }

}

function getApp() as NotesApp {
    return Application.getApp() as NotesApp;
}