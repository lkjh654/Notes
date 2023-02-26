import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class TextButton extends WatchUi.Button {

    var keys as Array<Char>;
    var keyType as Number;
    private var _mode = 0;
    private var _horizontalTextBias = 0.5;
    private var _verticalTextBias = 0.5;

    public function initialize(settings as {
                :keyType as Number,
                :keys as Array<Char>,
                :behaviour as Symbol,
                :background as Graphics.ColorType or Drawable,
                :locX as Number,
                :locY as Number,
                :width as Number,
                :height as Number,
                :horizontalTextBias as Float?,
                :verticalTextBias as Float?,
                :stateDefault as Graphics.ColorType or Drawable,
                :stateHighlighted as Graphics.ColorType or Drawable,
                :stateSelected as Graphics.ColorType or Drawable,
                :stateDisabled as Graphics.ColorType or Drawable,
            }) {
        keys = settings.get(:keys);
        keyType = settings.get(:keyType);
        if (settings.get(:horizontalTextBias) != null){
            _horizontalTextBias = settings.get(:horizontalTextBias);
        }
        if (settings.get(:verticalTextBias) != null){
            _verticalTextBias = settings.get(:verticalTextBias);
        }
        Button.initialize(settings);
    }

    // Update the view
    function draw(dc as Dc) as Void {
        Button.draw(dc);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            locX + width * _horizontalTextBias,
            locY + height * _verticalTextBias,
            Graphics.FONT_SMALL,
            getCurrentKey().toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    public function getCurrentKey() as Char {
        return keys[_mode];
    }

    public function setMode(mode as Number) as Void {
        if(mode >= 0 && mode < keys.size()) {
            _mode = mode;
        }
    }
}