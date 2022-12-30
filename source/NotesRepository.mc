import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class NotesRepository {
    
    private const SLOT_0_KEY = "TEXT";
    private const SLOT_N_KEY_TEMPLATE = "TEXT_";
    private const CURRENT_NOTE_INDEX = "INDEX";

    private const MAX_SLOTS = 5;

    private const MAX_SUMMARY_LENGTH = 40;

    public function getCurrentNote() {
        return getNoteForKey(getKeyForIndex(getCurrentNoteIndex()));
    }

    public function saveCurrentNote(note as String) {
        return Application.Storage.setValue(getKeyForIndex(getCurrentNoteIndex()), note);
    }

    public function getNoteSummaries() as Array<String> {
        var summaries = new Array<String>[MAX_SLOTS];
        for(var i = 0; i < summaries.size(); i += 1) {
            var summary = getNoteForKey(getKeyForIndex(i));
            if (summary != null && summary.length() > MAX_SUMMARY_LENGTH) {
                summary = summary.substring(0, MAX_SUMMARY_LENGTH);
            }
            summaries[i] = summary;
        }
        return summaries;
    }

    public function getCurrentNoteIndex() as Number {
        var index = Application.Storage.getValue(CURRENT_NOTE_INDEX);
        if (index == null) {
            return 0;
        }
        else {
            return index;
        }
    }

    public function setCurrentNoteIndex(index as Number) {
        Application.Storage.setValue(CURRENT_NOTE_INDEX, index);
    }

    private function getNoteForKey(key as String) {
        return Application.Storage.getValue(key);
    }

    private function getKeyForIndex(index as Number) as String {
        if (index == 0) {
            return SLOT_0_KEY;
        }
        else {
            return SLOT_N_KEY_TEMPLATE + index;
        }
    }
}