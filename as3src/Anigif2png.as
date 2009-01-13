package {
    import flash.display.Sprite;
    import uffy.Uffy;

    [SWF(frameRate=60, background=0x000000)]
    public class Anigif2png extends Sprite {
        public function Anigif2png() {
            Uffy.register('Anigif2png', Anigif2pngImpl);
        }
    }
}

import flash.display.BitmapData;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Encoder;
import mx.utils.SHA256;
import org.gif.decoder.GIFDecoder;
import org.gif.frames.GIFFrame;
import uffy.javascript;

class Anigif2pngImpl {
    public var imageURL:String;
    public function Anigif2pngImpl() {
    }

    javascript function load(url:String, callback:Function, finishCallback:Function = null, isUniq:Boolean = true):void {
        var loader:URLLoader = new URLLoader;
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, function(e:Event):void {
            var d:ByteArray = e.target.data;
            var gifDecoder:GIFDecoder = new GIFDecoder;
            gifDecoder.read(d);
            var hl:uint = gifDecoder.getFrameCount();
            var n:uint = Math.ceil(Math.sqrt(hl));

            var imgEncoder:PNGEncoder = new PNGEncoder;
            var sha1s:Object = {};
            var images:Array = [];
            var png:ByteArray;
            for (var i:uint = 0; i < hl; i++) {
                var f:GIFFrame = gifDecoder.getFrame(i);
                var bdd:BitmapData = f.bitmapData;
                png = imgEncoder.encode(bdd);
                var sha:String = SHA256.computeDigest(png);
                if (isUniq && !sha1s[sha]) {
                    sha1s[sha] = true;
                } else {
                    images.push(png);
                }
            }

            var encoder:Base64Encoder = new Base64Encoder();
            for each(png in images) {
                encoder.encodeBytes(png);
                var url:String = 'data:' + imgEncoder.contentType + ';base64,' + encoder.flush();
                callback(url);
            }
            if (finishCallback) finishCallback();
        });
        loader.load(new URLRequest(url));
    }
}
