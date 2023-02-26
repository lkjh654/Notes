import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

(:glance)
class NotesGlanceView extends WatchUi.GlanceView {

    private var _text as String;
    private var _textArea as TextArea?;

    function initialize(text as String) {
        if(text == null || text.equals("")) {
            _text = WatchUi.loadResource(Rez.Strings.empty_string_placeholder);
        } else {
            _text = text;
        }
        GlanceView.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _textArea = new WatchUi.TextArea({
            :color=>Graphics.COLOR_WHITE,
            :font=>[Graphics.FONT_XTINY],
            :locX =>0,
            :locY=>0,
            :width=> dc.getWidth(),
            :height=> dc.getHeight()
        });
        _textArea.setText(_text);
        
        setLayout([_textArea]);
    }
}
