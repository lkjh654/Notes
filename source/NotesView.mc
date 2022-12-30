import Toybox.Graphics;
import Toybox.WatchUi;

class NotesView extends WatchUi.View {

    private var _qKey = ['q','Q', '1'];
    private var _pKey = ['p','P', '0'];
    private var _line1 = [['w','W', '2'], ['e','E', '3'], ['r','R', '4'], ['t','T', '5'], ['y','Y', '6'], ['u','U', '7'], ['i','I', '8'], ['o','O', '9']];
    private var _line2 = [['a','A', '-'], ['s','S', '/'], ['d','D', ':'], ['f','F', ';'], ['g','G', '('], ['h','H', ')'], ['j','J', '&'], ['k','K', '@'], ['l','L', '"']];
    private var _line3 = [['z','Z', '.'], ['x','X', ','], ['c','C', '?'], ['v','V', '!'], ['b','B', '+'], ['n','N', '*'], ['m','M', '=']];

    private var _text as Array<Char>;
    private var _textArea as ScrollableText;
    private var _multiModeKeys = new Array<TextButton>[0];
    private var _keyboardMode = 0;

    function initialize(text as String?) {
        setTextInternal(text);
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _multiModeKeys = new Array<TextButton>[0];
        var width = dc.getWidth();
        var height = dc.getHeight();

        var sizeLineTop = 4;
        var sizeLine0 = 2;
        var sizeLine1 = _line1.size();
        var sizeLine2 = _line2.size();
        var sizeLine3 = _line3.size();
        
        var layout = new Array<TextButton>[1 + sizeLineTop + sizeLine0 + sizeLine1 + sizeLine2 + sizeLine3];

        var r = width / 2;
        var xPrim = (2 * r) / 3;
        var yPrim = Math.sqrt(r * r - xPrim * xPrim);
        var y = r - yPrim;

        var keyboardHeight = height * 2 / 3;

        var textAreaWidth = 2 * xPrim;
        var textAreaHeight = height - keyboardHeight - y;
        var textAreaStartX = r - xPrim;
        var textAreaEndX = textAreaStartX + textAreaWidth;
        var textAreaStartY = y;

        _textArea = new ScrollableText({
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_XTINY,
            :locX =>textAreaStartX,
            :locY=>textAreaStartY,
            :width=>textAreaWidth,
            :height=>textAreaHeight
        });

        layout[0] = _textArea;

        var xSpaceForKey = (width / sizeLine1);
        var ySpaceForKey = (keyboardHeight / 3);

        // lineTop
        var keyWidth = textAreaWidth / sizeLineTop;
        var keyHeight = textAreaStartY;
        var shiftWidth = (1.1 * keyWidth).toNumber();
        var specialWidth = (0.7 * keyWidth).toNumber();
        var spaceWidth = (1.0 * keyWidth).toNumber();
        var backspaceWidth = textAreaWidth - shiftWidth - specialWidth - spaceWidth;
        var lineTopMargin = textAreaStartX;
        var lineTopLocY = 0;
        
        var layoutIndexOffset = 1;

        var shiftKey = buildKeyWithBias(KeyType.Shift, ['A', 'a', 'A'], lineTopMargin, lineTopLocY, shiftWidth, keyHeight, 0.75, 0.6);
        _multiModeKeys.add(shiftKey);
        layout[layoutIndexOffset] = shiftKey;
        var specialKey = buildKey(KeyType.Special, ['#', '#', 'a'], lineTopMargin + shiftWidth, lineTopLocY, specialWidth, keyHeight);
        _multiModeKeys.add(specialKey);
        layout[layoutIndexOffset + 1] = specialKey;
        layout[layoutIndexOffset + 2] = buildKey(KeyType.Regular, [' '], lineTopMargin + shiftWidth + specialWidth, lineTopLocY, spaceWidth, keyHeight);
        layout[layoutIndexOffset + 3] = buildKeyWithBias(KeyType.Backspace, ['<'], lineTopMargin + shiftWidth + specialWidth + spaceWidth, lineTopLocY, backspaceWidth, keyHeight, 0.4, 0.6);
        layoutIndexOffset += sizeLineTop;
        
        // line0
        keyWidth = textAreaStartX;
        keyHeight = textAreaHeight;
        var line0locY = textAreaStartY;

        var qKey = buildKeyWithBias(KeyType.Regular, _qKey, 0, line0locY, keyWidth, keyHeight, 0.6, 0.6);
        _multiModeKeys.add(qKey);
        layout[layoutIndexOffset] = qKey;
        layoutIndexOffset += 1;

        var pKey = buildKeyWithBias(KeyType.Regular, _pKey, textAreaEndX, line0locY, keyWidth, keyHeight, 0.4, 0.6);
        _multiModeKeys.add(pKey);
        layout[layoutIndexOffset] = pKey;
        layoutIndexOffset += 1;
        
        // line1
        var line1locY = height - keyboardHeight;
        keyHeight = ySpaceForKey;
        keyWidth = xSpaceForKey.toNumber();
        var line1Margin = (width - sizeLine1 * keyWidth) / 2;
        for(var i = 0; i < sizeLine1; i += 1) {
            var keys = _line1[i];
            var key = buildKey(KeyType.Regular, keys, line1Margin + keyWidth * i, line1locY, keyWidth, keyHeight);
            _multiModeKeys.add(key);
            layout[layoutIndexOffset + i] = key;
        }
        layoutIndexOffset += sizeLine1;

        // line2
        keyWidth = (xSpaceForKey * 0.8).toNumber();
        var boundaryKeyWidth = keyWidth * 1.5;
        var line2Margin = (width - (sizeLine2 - 2) * keyWidth - 2 * boundaryKeyWidth) / 2;
        var line2locY = line1locY + keyHeight;
        
        var keyLocX = line2Margin;

        for(var i = 0; i < sizeLine2; i += 1) {
            var currentKeyWidth = currentKeyWidth(keyWidth, boundaryKeyWidth, sizeLine2, i);
            var keys = _line2[i];
            var key = buildKey(KeyType.Regular, keys, keyLocX, line2locY, currentKeyWidth, keyHeight);
            _multiModeKeys.add(key);
            layout[layoutIndexOffset + i] = key;
            keyLocX += currentKeyWidth;
        }
        layoutIndexOffset += sizeLine2;

        // line3
        keyWidth = (xSpaceForKey * 0.8).toNumber();
        boundaryKeyWidth = keyWidth * 1.5;
        var line3Margin = (width - (sizeLine3 - 2) * keyWidth - 2 * boundaryKeyWidth) / 2;
        var line3locY = line2locY + keyHeight;
        keyLocX = line3Margin;
        
        for(var i = 0; i < sizeLine3; i += 1) {
            var currentKeyWidth = currentKeyWidth(keyWidth, boundaryKeyWidth, sizeLine3, i);
            var keys = _line3[i];
            var key;
            if (i == 0) {
                key = buildKeyWithBias(KeyType.Regular, keys, keyLocX, line3locY, currentKeyWidth, keyHeight, 0.6, 0.25);
            } else if (i == sizeLine3 - 1) {
                key = buildKeyWithBias(KeyType.Regular, keys, keyLocX, line3locY, currentKeyWidth, keyHeight, 0.4, 0.25);
            } else {
                key = buildKey(KeyType.Regular, keys, keyLocX, line3locY, currentKeyWidth, keyHeight);
            }
            
            _multiModeKeys.add(key);
            layout[layoutIndexOffset + i] = key;
            keyLocX += currentKeyWidth;
        }
        layoutIndexOffset += sizeLine3;
        
        updateText();
        setLayout(layout);
    }

    private function currentKeyWidth(keyWidth, boundaryKeyWidth, lineSize, index) as Number {
        if (index == 0 || index == lineSize - 1) {
            return boundaryKeyWidth;
        }
        else {
            return keyWidth;
        }
    }
    
    private function buildKeyWithBias(keyType as Number, keys as Array<Char>, locX as Number, locY as Number, width as Number, height as Number, horizontalTextBias as Float, verticalTextBias as Float) as TextButton {
        var paddingX = 1;
        var paddingY = 1;
        var settings = {
            :keyType => keyType,
            :keys=>keys,
            :background=>Graphics.COLOR_BLACK,
            :locX=> locX + paddingX,
            :locY=> locY + paddingY,
            :width=>width - 2 * paddingX,
            :height=>height - 2 * paddingY,
            :horizontalTextBias=>horizontalTextBias,
            :verticalTextBias=>verticalTextBias,
            :stateDefault=> Graphics.COLOR_WHITE,
            :stateHighlighted=> Graphics.COLOR_BLUE,
            :stateSelected=> Graphics.COLOR_PURPLE,
            :stateDisabled=> Graphics.COLOR_WHITE,
            };
        return new TextButton(settings);
    }

    private function buildKey(keyType as Number, keys as Array<Char>, locX as Number, locY as Number, width as Number, height as Number) as TextButton {
        return buildKeyWithBias(keyType, keys, locX, locY, width, height, null, null);
    }

    function onKeyboardKeyPressed(keyType as Number, c as Char) as Void {
        if (keyType == KeyType.Regular) {
            _text.add(c);
            if(_keyboardMode == KeyboardUppercase) {
                _keyboardMode = KeyboardLowercase;
                updateKeyboardMode();
            }
        } else if (keyType == KeyType.Shift) {
            if(_keyboardMode == KeyboardLowercase) {
                _keyboardMode = KeyboardUppercase;
            } else if(_keyboardMode == KeyboardUppercase) {
                _keyboardMode = KeyboardLowercase;
            } else if(_keyboardMode == KeyboardSpecial) {
                _keyboardMode = KeyboardUppercase;
            }
            updateKeyboardMode();
        } else if (keyType == KeyType.Special) {
            if(_keyboardMode == KeyboardLowercase) {
                _keyboardMode = KeyboardSpecial;
            } else if(_keyboardMode == KeyboardUppercase) {
                _keyboardMode = KeyboardSpecial;
            } else if(_keyboardMode == KeyboardSpecial) {
                _keyboardMode = KeyboardLowercase;
            }
            updateKeyboardMode();
        } else if (keyType == KeyType.Backspace) {
            var size = _text.size();
            if(size > 0) {
                _text = _text.slice(0, size - 1);
            }
        }
        
        updateText();
    }

    function onClear() as Void {
        _text = new Array<Char>[0];
        updateText();
    }

    function setText(text as String) as Void {
        setTextInternal(text);
        updateText();
    }

    private function setTextInternal(text as String) as Void {
        if (text == null) {
            _text = new Array<Char>[0];
        } else {
            _text = text.toCharArray();
        }
    }

    function onScrollDown() {
        _textArea.scrollDown();
    }

    function onScrollUp() {
        _textArea.scrollUp();
    }

    private function updateText() {
        _textArea.setText(getText());
    }

    private function updateKeyboardMode() {
        for(var i = 0; i < _multiModeKeys.size(); i += 1) {
            _multiModeKeys[i].setMode(_keyboardMode);
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function getText() as String {
        return StringUtil.charArrayToString(_text);
    }

    enum {
        KeyboardLowercase,
        KeyboardUppercase,
        KeyboardSpecial
    }
}
