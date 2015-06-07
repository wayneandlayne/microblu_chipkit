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
 
Or, just download this zip file (which contains all of the above) and drop it's contents into your sketchbook library folder. (For example, C:\Users\Brian\Documents\mpide\libraries under Windows) https://github.com/wayneandlayne/microblu_chipkit/raw/master/microblu_chipkit_libraries.zip

Sketch Setup!
=============
Copy the microblu_chipkit folder from this repo into your sketchbook folder, and then open up the microblu_chipkit.pde file in MPIDE.

Select the WF32 board from the Tools->Board->chipKIT->ChipKIT WF32 menu.


Wifi Setup!
===========

In the microblue_chipkit.pde sketch, you'll need to specify the SSID of your Wifi (and password if you have one.)
You do that by changing YOUR_SSID to the SSID of your WiFi access point in the line:

    const char * szSsid = "YOUR_SSID";

You choose authentication by uncommenting ONLY ONE of the following lines:

    //#define USE_WPA2_PASSPHRASE
    //#define USE_WPA2_KEY
    //#define USE_WEP40
    //#define USE_WEP104
    //#define USE_WF_CONFIG_H

You probably want WPA2_PASSPHRASE, but maybe you have an access point setup with the other ways.  There are
examples below.

Then, you need to set the password if you have one.  There are examples in the beginning of the sketch.

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
In the sketch, fill in the two lines below to match the output of the curl command, and uncomment them by removing the two
leading //

    //char UUID[]  = "YOUR-UUID-HERE";
    //char TOKEN[] = "YOURTOKENHERE";

Getting started
===============

When you start, use the Serial Terminal to watch things.  It should print some pin callbacks (like "setPinModeCallback: 0,1", etc.), and after 30 seconds or so, it should connect to your wifi and start connecting to Octoblu.

When this connection is established, you will see something like this on the Serial Terminal:
```
WiFi connected
connecting...
MQIsdpÂ'mb_afb7cb2e-d64b-475d-afda-10cd4320d1a0$afb7cb2e-d64b-475d-afda-10cd4320d1a0(2027173c340154e9d9d89218b7e7e7989a1ff617
20,2,0,0,
connected
)8:$afb7cb2e-d64b-475d-afda-10cd4320d1a0
```

Right now, the error handling isn't very good, and pull requests to both documentation and the code would be
greatly appreciated!

Setting up the Octoblu flow
===========================

Go to the Octoblu designer, and make a new workflow with an operator node of Trigger, and a configured node of Arduino. To create the Arduino node and get it to show up in your 'configured' node list, you will need to select it from the 'available' node list, then click 'setup' to configure that Arduino. When you do so, you will want to choose the 'Claim an existing device' option, and then put in the name of this Arduino node instance (like "WF32"), and your UUID and Token that you put into the sketch. These must match (Octoblu Arduino node and sketch) in order for the connection to be made. Once your Arduino (WF32) has been setup, it will appear in the 'configured' pallet and you can click on it to create a new node in the flow. 

Connect the output of the trigger to the input of the Arduino.  Then, add an operator node of Delay, and another configured
node of Arduino.  Connect the output of the trigger to the delay too, and the output of the delay to the Arduino.

Then, set the Arduino directly connected to the trigger to digitalWrite pin 13 to 1, and the second Arduino
to digitalWrite pin 13 to 0.  Set the delay to whatever you want (like 5 seconds).  Go to the top right, and press start.
It's the green rectangle with the play triangle.

![Proper Octoblu Flow setup example](https://github.com/wayneandlayne/microblu_chipkit/Flow.png)

When you click the box that looks like a big input to the trigger, the trigger, first Arduino, and delay block should
grow for a second.  Then, after the delay, the delay block and second Arduino will also grow.

There should be some activity in the Serial Terminal when you first click, and then after the delay as well, and then the red led by BTN3 will light up indicating
serial activity, and green LED LD6 near VR1 should blink for about however long the delay was!

Awesome!

(When doing this in the future, make sure the device is connected, stop and start the workflow, and everything should
work great.  It looks like whatever initializes the pins isn't being triggered when the sketch starts,
but instead waits for some "workflow started" callback.  This can probably be fixed.)
