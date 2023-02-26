using Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class ScrollableText extends WatchUi.Drawable {
    
    private var _text as String;
    private var _font as Graphics.FontType;
    private var _scrollYOffset = 0;

    public function initialize(settings as { 
            :text as Lang.String or Lang.Symbol,
            :color as Graphics.ColorType,
            :backgroundColor as Graphics.ColorType,
            :font as Graphics.FontType,
            :justification as Graphics.TextJustification or Lang.Number,
            :identifier as Lang.Object,
            :locX as Lang.Numeric,
            :locY as Lang.Numeric,
            :width as Lang.Numeric,
            :height as Lang.Numeric,
            :visible as Lang.Boolean 
        }) {
        _text = settings.get(:text);
        _font = settings.get(:font);
        Drawable.initialize(settings);
    }

    public function setText(text as String) {
        _text = text;
        resetScroll();
        WatchUi.requestUpdate();
    }

    public function scrollUp() {
        _scrollYOffset--;
        WatchUi.requestUpdate();
    }

    public function scrollDown() {
        _scrollYOffset++;
        if(_scrollYOffset > 0){
            _scrollYOffset = 0;
        }
        WatchUi.requestUpdate();
    }

    function resetScroll() {
        _scrollYOffset = 0;
        WatchUi.requestUpdate();
    }

    function draw(dc as Dc) as Void {
        Drawable.draw(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var lines = buildLines(_text, dc);
        var lineSize = lines.size();
        var fontHeight = dc.getFontHeight(_font);
        var maxLines = (height / fontHeight).toNumber();
        
        var maxOffset = lineSize - maxLines;
        if (maxOffset < 0) {
            maxOffset = 0;
        }

        if (-_scrollYOffset > maxOffset) {
            _scrollYOffset = -maxOffset;
        }

        var startLine = lineSize - maxLines + _scrollYOffset;
        if (startLine < 0) {
            startLine = 0;
        }
        var endLine = startLine + maxLines;
        if (endLine > lineSize) {
            endLine = lineSize;
        }

        var counter = 0;
        for (var i = startLine; i < endLine; i++) {
            var line = lines[i];
            var lineText = _text.substring(line[0], line[1]);
            var x = locX;
            var y = locY + counter * fontHeight;
            dc.drawText(
                x,
                y,
                _font,
                lineText,
                Graphics.TEXT_JUSTIFY_LEFT
            );
            if(i == lineSize - 1) {
                var lineWidth = dc.getTextWidthInPixels(lineText, _font);
                var cursorX = locX + lineWidth;
                dc.drawLine(cursorX, y, cursorX, y + fontHeight);
            }
            counter++;
        }
    }

    function buildLines(text as String, dc as Dc) as Array<Array> {
        var input = text.toCharArray();
        var output = new Array<Array>[0];

        var lineWidth = width;

        var remainingWidth = lineWidth;
        
        var currentLineIndexStart = 0;
        var currentLineIndexEnd = 0;

        var previousBreakableChar = false;
        var currentWordIndexStart = 0;
        var currentWordIndexEnd = 0;

        var spaceWidth = dc.getTextWidthInPixels(" ", _font);
        
        var inputSize = input.size();
        var lastCharIndex = inputSize - 1;
        for (var i=0; i < inputSize; i++) {
            var char = input[i];
            var isSpace = char == ' ';
            var lastChar = (i == lastCharIndex);
            if((!isSpace) && (!lastChar)) {
                previousBreakableChar = false;
                currentWordIndexEnd++;
            } else {
                previousBreakableChar = true;
                
                if(lastChar && !isSpace) {
                    currentWordIndexEnd++;
                }
                var currentWord = text.substring(currentWordIndexStart, currentWordIndexEnd);
                var currentWordWidth = dc.getTextWidthInPixels(currentWord, _font);

                if(currentWordWidth <= remainingWidth) {
                    currentLineIndexEnd = currentWordIndexEnd;
                    remainingWidth = remainingWidth - currentWordWidth;
                } else if(currentWordWidth <= lineWidth) {
                    // add current line
                    output.add([currentLineIndexStart, currentLineIndexEnd]);
                    // start a new line
                    currentLineIndexStart = currentWordIndexStart + 1;
                    currentLineIndexEnd = currentWordIndexEnd;
                    remainingWidth = lineWidth - currentWordWidth;
                } else {
                    var index = currentWordIndexStart;
                    var fittingSubstringIndices = findFittingSubstringIndices(text, index, currentWordIndexEnd, remainingWidth, dc);
                    if (fittingSubstringIndices != null) {
                        index = fittingSubstringIndices[1];
                        output.add([currentLineIndexStart, index]);
                    } else {
                        output.add([currentLineIndexStart, currentLineIndexEnd]);
                    }
                    
                    currentLineIndexStart = index;
                    currentLineIndexEnd = currentLineIndexStart;
                    remainingWidth = lineWidth;
                    
                    while(index != currentWordIndexEnd) {
                        fittingSubstringIndices = findFittingSubstringIndices(text, index, currentWordIndexEnd, remainingWidth, dc);
                        
                        index = fittingSubstringIndices[1];

                        if(index == currentWordIndexEnd) {
                            remainingWidth = remainingWidth - fittingSubstringIndices[2];
                            currentLineIndexEnd = currentWordIndexEnd;
                        } else {
                            output.add([currentLineIndexStart, index]);
                            remainingWidth = lineWidth;

                            currentLineIndexStart = index;
                            currentLineIndexEnd = currentLineIndexStart;
                        }
                }
            }

            if(lastChar && isSpace) {
                if(spaceWidth <= remainingWidth) {
                    currentLineIndexEnd = i + 1;
                } else {
                    output.add([currentLineIndexStart, currentLineIndexEnd]);

                    currentLineIndexStart = currentWordIndexEnd;
                    currentLineIndexEnd = currentWordIndexEnd + 1;
                }
            }
            
            if (lastChar && currentLineIndexStart != currentLineIndexEnd){
                output.add([currentLineIndexStart, currentLineIndexEnd]);
            }

            currentWordIndexStart = i;
            currentWordIndexEnd = currentWordIndexStart + 1;
            }
        }
        return output;
    }

    function findFittingSubstringIndices(text as String, startIndex as Number, endIndex as Number, width as Number, dc as Dc) as Array<Number>? {
        var lastFittingIndex = -1;
        var lastFittingRemaingWidth = -1;
        
        for (var i=startIndex+1; i <= endIndex; i++) {
            var currentWordWidth = dc.getTextWidthInPixels(text.substring(startIndex, i), _font);
            if (currentWordWidth <= width) {
                lastFittingIndex = i;
                lastFittingRemaingWidth = width - currentWordWidth;
            } else {
                break;
            }
        }
        if (lastFittingIndex == -1) {
            return null;
        } else {
            return [startIndex, lastFittingIndex, lastFittingRemaingWidth];
        }
    }
}