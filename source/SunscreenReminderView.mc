import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Attention;

var CYCLE_DURATION_MS = 90 * 60 * 1000;
var HALF_A_MINUTE_IN_MS = 0.5 * 60 * 1000;
var CYCLE_COUNT = 1;


class SunscreenReminderView extends WatchUi.SimpleDataField {
    var didAlert = false;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Apply sunscreen";
    }

    // Potential improvement. Implement using the Timer object instead of this custom logic. Makes code cleaner
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Timer/Timer.html
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var total_cycle_time = CYCLE_DURATION_MS * CYCLE_COUNT;
        var time_left_in_cycle = total_cycle_time - info.elapsedTime;
        
        if (time_left_in_cycle <= HALF_A_MINUTE_IN_MS) {
            if (didAlert == false) {
                alert();
                didAlert = true;
            }

            if (time_left_in_cycle <= 0) {
                CYCLE_COUNT++;
                didAlert = false;
            }
            return "Apply now";
        } else {
            return formatTime((total_cycle_time - info.elapsedTime));
        }

    }

    function alert() {
        if (Attention has :ToneProfile) {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }

        if (Attention has :vibrate) {
            var vibeData =
            [
                new Attention.VibeProfile(25, 2000),
                new Attention.VibeProfile(50, 2000),
                new Attention.VibeProfile(100, 2000)
            ];
            Attention.vibrate(vibeData);
        }
    }

    function formatTime(milliseconds as Number) as String {
        // Get seconds
        var seconds = milliseconds / 1000;

        // Calculate minutes (integer division) and remaining seconds (modulo)
        var minutes = Math.floor(seconds / 60);
        seconds = seconds % 60;

        // Create an empty string to build the formatted time
        var formattedTime = "";

        // Add leading zero for minutes if necessary
        if (minutes < 10) {
            formattedTime += "0";
        }
        formattedTime += minutes.toString();

        // Add colon separator
        formattedTime += ":";

        // Add leading zero for seconds if necessary
        if (seconds < 10) {
            formattedTime += "0";
        }
        formattedTime += seconds.toString();

        return formattedTime;
    }
}