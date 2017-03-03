# pimatic-yamaha-avr

[![Npm Version](https://badge.fury.io/js/pimatic-yamaha-avr.svg)](http://badge.fury.io/js/pimatic-yamaha-avr)
[![Build Status](https://travis-ci.org/mwittig/pimatic-yamaha-avr.svg?branch=master)](https://travis-ci.org/mwittig/pimatic-yamaha-avr)
[![Dependency Status](https://david-dm.org/mwittig/pimatic-yamaha-avr.svg)](https://david-dm.org/mwittig/pimatic-yamaha-avr)

Pimatic plugin to monitor &amp; control a Yamaha AV Receiver over a network connection.

## Status of Implementation

The following features are provided:
* support for power switching, volume mute, volume control, input selection, and status display (main zone, only)
* auto-discovery of devices for pimatic 0.9
* action to select input source, devices for power switching, volume mute, volume control are "switch" or "dimmer" 
  devices types and support the respective action operations 

Additional features can be added easily and I am happy to do this on demand.

## Contributions

Contributions to the project are  welcome. You can simply fork the project and create a pull request with 
your contribution to start with. If you like this plugin, please consider &#x2605; starring 
[the project on github](https://github.com/mwittig/pimatic-yamaha-avr).

## Credits 

Many thanks to @ccvh and @seelenbrokat for their support in testing stuff at the early stages of development!

## Plugin Configuration

    {
          "plugin": "yamaha-avr",
          "host": "avr.fritz.box",
    }

The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| host              | -        | String  | Hostname or IP address of the AVR |
| port              | 80       | Number  | AVR control port. Only required for testing purposes |
| debug             | false    | Boolean | Debug mode. Writes debug messages to the pimatic log, if set to true |


## Device Configuration

The following devices can be used. As of pimatic 0.9 you can use the auto-discovery of the frontend to add devices
easily.

For each device the time interval used to obtain status updates from the AVR can be 
specified. The default is 30 seconds, the minimum value accepted is 10 seconds. It should be noted that updates are 
acquired by an centralized update handler. Thus the device with the smallest values set defines the time interval 
for the update handler. If no devices exist, e.g. devices have been removed at runtime, the update handler is stopped.

### YamahaAvrPresenceSensor

The Presence Sensor presents the power status of the receiver and provides information about
the master volume and selected input source.

    {
          "id": "avr-1",
          "name": "AVR Status",
          "class": "YamahaAvrPresenceSensor"
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interval          | 30       | Number  | The time interval in seconds (minimum 10) at which the power state of the AVR will be read |

### YamahaAvrPowerSwitch

The Power Switch can be used to switch the AVR on or off (standby) mode. Depending on your
AVR configuration you may not be able to switch it on. See the AVR manual for details.

    {
          "id": "avr-2",
          "name": "AVR Power",
          "class": "YamahaAvrPowerSwitch"
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interval          | 30       | Number  | The time interval in seconds (minimum 10) at which the power state of the AVR will be read |


### YamahaAvrMuteSwitch

The Mute Switch can be used to mute or un-mute the master volume.

    {
          "id": "avr-3",
          "name": "AVR Mute",
          "class": "YamahaAvrMuteSwitch"
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interval          | 30       | Number  | The time interval in seconds (minimum 10) at which the power state of the AVR will be read |


### YamahaAvrMasterVolume

The Master Volume can be used to change the absolute master volume. This device can only
be used with AVRs which support absolute volume control on a scale from 0-98. As some
AVRs already stop at a lower maximum volume the `maxAbsoluteVolume` property is provided
(see properties table below).

    {
          "id": "avr-4",
          "name": "AVR Master Volume",
          "class": "YamahaAvrMasterVolume"
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interval          | 30       | Number  | The time interval in seconds (minimum 10) at which the power state of the AVR will be read |
| volumeDecibel     | 16.5     | Number  | The maximum volume which can be set using the volume control |
| volumeDbMin       | -80.5    | Number  | The minimal volume in dB of the receiver (check the AVR manual to get the right setting) |
| volumeDbMax       | 16.5     | Number  | The maximum volume in dB of the receiver (check the AVR manual to get the right setting) |

### YamahaAvrInputSelector

The YamahaAvrInputSelector can be used to select the input source. Allowed values for input selection 
depend on the AVR model.

    {
          "id": "avr-5",
          "name": "AVR Inout Selector",
          "class": "YamahaAvrInputSelector"
          "buttons": [
               {
                 "id": "TUNER"
               }
               {
                 "id": "AUDIO1"
               }
          ]
    }

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| interval          | 20       | Number  | The time interval in seconds (minimum 10) at which the power state of the AVR will be read |
| buttons           | see example | Array   | The buttons to display for selection. See device configuration schema for details |

The following action is provided to switch the input source as part of rules

* `avr input <device> to "<id>"`, for example: `avr input yamaha-avr to "tv"`

## History

See [Release History](https://github.com/mwittig/pimatic-yamaha-avr/blob/master/HISTORY.md).

## License 

Copyright (c) 2015-2017, Marcus Wittig and contributors. All rights reserved.

[AGPL-3.0](https://github.com/mwittig/pimatic-yamaha-avr/blob/master/LICENSE)