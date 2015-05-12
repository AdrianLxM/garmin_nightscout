using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Timer as Timer;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

var serverUrl = "";
var units = "mmol";

class CgmData {
	var age;
	var bgValue;
	var bgDelta;
}

class cgmgarminwatchView extends Ui.View {

hidden var bgData;
	hidden var timer1;

	function requestCgmValues( ) {
		Sys.print( "Loading data from: " + serverUrl + "\n" );
		Comm.makeJsonRequest( serverUrl, {"units"=>units}, {}, method(:onReceiveCgmValues) );
		return true;
	}

	function onRequestCgmValuess( ) {
		requestCgmValues( );
		return true;
	}

	function onReceiveCgmValues( responseCode, data ) {
		if( 200 == responseCode ) {
			var currentCgmData = new CgmData( );
			currentCgmData.bgValue = data["sgv"];
			currentCgmData.age = data["timedelta"];
			currentCgmData.bgDelta = data["bgdelta"];
			bgData = currentCgmData;
			Sys.println(bgData.age + "\n");
			Sys.println(bgData.bgValue + "\n");
			Sys.println(bgData.bgDelta + "\n");
			Ui.requestUpdate( );
		} else if( 404 == responseCode ) {
			Sys.println( "Server reported 404 - Not found\n" );
			timer1.stop( );
		} else {
			Sys.println( "Failed to load\nError: " + responseCode.toString() + "\n" );
		}
	}

    //! Load your resources here
    function onLayout(dc) {
    	bgData = null;
		requestCgmValues( );
    	timer1 = new Timer.Timer( );
    	timer1.start( method(:onRequestCgmValuess), 60000, true );
        setLayout(Rez.Layouts.MainLayout(dc));
    	Sys.println( "Loading Data\n" );
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
		var bgValue = null;
		var age = null;
		dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK );
		dc.clear();
		dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
		if( null == bgData ) {
			dc.drawText( 85, 30, Gfx.FONT_SMALL, "No Data", Gfx.TEXT_JUSTIFY_LEFT );
		} else {
			dc.drawText( 45, 30, Gfx.FONT_SMALL, "BG: " + bgData.bgValue + " mmol/L", Gfx.TEXT_JUSTIFY_LEFT );
			dc.drawText( 45, 60, Gfx.FONT_SMALL, "Change: " + bgData.bgDelta + " mmol/L", Gfx.TEXT_JUSTIFY_LEFT );
			dc.drawText( 45, 90, Gfx.FONT_SMALL, "Age: " + bgData.age + " min", Gfx.TEXT_JUSTIFY_LEFT );
		}
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }


}