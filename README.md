README for Microblu for ChipKIT
===============================

This is an initial release of Microblu for ChipKIT WF32.  There are certainly bugs.

It has been confirmed to work with digitalWrites.  I can toggle LEDs on the board over the Internet!

Things to check on/do:
 * Remove many of the debug print statements.
 * Test Firmata!  I am pretty sure not all the digital pins work due to "gaps" in the count?
 * Add Firmata support for Wifire and then test on Wifire!
 * Test the other Firmata support pieces, like Servo, digitalRead, analogRead, analogWrite.
 * Clean up connect()
 * Talk with the Octoblu folks to see if there is a better base sketch than the Ethernet one.  For
     instance, we have a bunch of RAM!

IDE Setup!
==========
Install the following libraries into your sketchbook library folder.

 * Requires the Octoblu fork of the MQTT PubSubClient https://github.com/jacobrosenthal/pubsubclient
 * Requires DEIPcK and DEWFcK which should be included in your MPIDE or UECIDE.
 * Requires CKClient: https://github.com/wayneandlayne/ckclient
 * Requires Firmata (with WF32 support): https://github.com/wayneandlayne/firmata
 * Requires Microblu MQTT: https://github.com/octoblu/microblu_mqtt


Wifi Setup!
===========

You'll need to specify the SSID of your Wifi (and password if you have one.)
You can do that by changing the line:

    const char * szSsid = "YOUR_SSID";

You choose authentication by uncommenting ONLY ONE of the following lines:

    //#define USE_WPA2_PASSPHRASE
    //#define USE_WPA2_KEY
    //#define USE_WEP40
    //#define USE_WEP104
    //#define USE_WF_CONFIG_H

You probably want WPA2_PASSPHRASE, but maybe you have an access point setup with the other ways.  There are
examples below.

Then, you need to set the password if you have one.  There are examples in the beginning.

Octoblu setup!
==============

You need to get a 'firmware' type UUID and token for Octoblu.

You can get this by opening a terminal, and running:
```
    curl -X POST -d "type=firmwareController&payloadOnly=true&name=Arduino" https://meshblu.octoblu.com/devices
```
It should return something like this:
```
    {"geo":{"range":[2227419722,1427320735],"country":"US","region":"","city":"","ll":[38,-97],"metro":0},
    "ipAddress":"73.37.123.12","name":"Arduino","online":false,"payloadOnly":"true",
    "timestamp":"2015-05-24T02:00:57.433Z","type":"firmwareController",
    "uuid":"YOUR-UUID-HERE","token":"YOURTOKENHERE"}%
```
Fill in the two lines below to match the output of the curl command, and uncomment them by removing the two
leading //

    //char UUID[]  = "YOUR-UUID-HERE";
    //char TOKEN[] = "YOURTOKENHERE";

Getting started
===============

When you start, use the Serial Terminal to watch things.  It should print some pin callbacks, and after 30 seconds
or so, it should connect to your wifi and start connecting to Octoblu.

Right now, the error handling isn't very good, and pull requests to both documentation and the code would be
greatly appreciated!

Go to the Octoblu designer, and make a new workflow with an operator node of Trigger, and a configured node of Ardiuno.

Connect the output of the trigger to the input of the Arduino.  Then, add an operator node of Delay, and another configured
node of Arduino.  Connect the output of the trigger to the delay too, and the output of the delay to the Arduino.

Then, set the arduino directly connected to the trigger to digitalWrite pin 13 to 1, and the second Arduino
to digitalWrite pin 13 to 0.  Set the delay to whatever you want.  Go to the top right, and press start.
It's the green rectangle with the play triangle.

When you click the box that looks like a big input to the trigger, the trigger, first Arduino, and delay block should
grow for a second.  Then, after a delay, the delay block and second arduino will also grow.

There should be some activity in the Serial Terminal, and then the red light by BTN3 will light up indicating
activity, and LD6 near VR1 should blink for about however long the delay was!

Awesome!

(When doing this in the future, make sure the device is connected, stop and start the workflow, and everything should
work great.  It looks like whatever initializes the pins isn't being triggered when the sketch starts,
but instead waits for some "workflow started" callback.  This can probably be fixed.)
