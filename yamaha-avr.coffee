# Yamaha AVR plugin
module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  rest = require('restler-promise')(Promise)
  commands = require './yamaha-avr-commands'
  cmd = commands.cmd
  query = commands.query
  deviceConfigTemplates = [
    {
      "name": "Yamaha AVR Status",
      "class": "YamahaAvrPresenceSensor",
    }
    {
      "name": "Yamaha AVR Power",
      "class": "YamahaAvrPowerSwitch"
    }
    {
      "name": "Yamaha AVR Mute",
      "class": "YamahaAvrMuteSwitch"
    }
    {
      "name": "Yamaha AVR Master Volume",
      "class": "YamahaAvrMasterVolume",
    }
    {
      "name": "Yamaha AVR Input Selector",
      "class": "YamahaAvrInputSelector",
    }
  ]


  # ###YamahaAvrPlugin class
  class YamahaAvrPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      @host = @config.host
      @port = @config.port || 80
      @debug = @config.debug || false
      @base = commons.base @, 'Plugin'

      # register devices
      deviceConfigDef = require("./device-config-schema")
      for device in deviceConfigTemplates
        do (device) =>
          className = device.class
          # convert camel-case classname to kebap-case filename
          filename = className.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
          classType = require('./devices/' + filename)(env)
          @base.debug "Registering device class #{className}"
          @framework.deviceManager.registerDeviceClass(className, {
            configDef: deviceConfigDef[className],
            createCallback: (config, lastState) =>
              return new classType(config, @, lastState)
          })

      # auto-discovery
      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-yamaha-avr', 'Searching for AVR controls'
        for device in deviceConfigTemplates
          do (device) =>
            matched = @framework.deviceManager.devicesConfig.some (element, iterator) =>
              element.class is device.class

            if not matched
              @framework.deviceManager.discoveredDevice 'pimatic-yamaha-avr', device.name, device
      )

    _requestStatusUpdates: () ->
        @base.cancelUpdate()
        @base.debug "Requesting status update"
        @sendRequest(cmd.command cmd.get, cmd.mainZone cmd.basicStatus cmd.getParam).then (data) =>
          status =
            Power: query.powerState query.powerControl query.basicStatus query.mainZone query.command data
            Mute: query.mute query.volume query.basicStatus query.mainZone query.command data
            Volume: (query.val query.level query.volume query.basicStatus query.mainZone query.command data) / 10
            Input:
              Select: query.inputSelect query.input query.basicStatus query.mainZone query.command data
          @emit 'statusUpdate', status
        .catch (errorResult) =>
          @base.error "Error:", if errorResult instanceof Error then errorResult else errorResult.error
        .finally () =>
          unless @listenerCount 'statusUpdate' is 0
            @base.scheduleUpdate(@_requestStatusUpdates, @updateInterval)
          else
            @base debug "No more listeners for status updates. Stopping update cycle"

    startStatusUpdates: (interval) ->
      if not @updateInterval? or @updateInterval > @updateInterval
        @updateInterval = interval
      @_requestStatusUpdates()

    sendRequest: (command) ->
      return new Promise (resolve, reject) =>
        @base.debug "Request: #{command}"
        rest.post("http://#{@host}:#{@port}/YamahaRemoteControl/ctrl", {
          data: command,
          parser: rest.restler.parsers.xml
        })
        .then (result) =>
          @base.debug "Response: #{JSON.stringify(result.data)}"
          if query.resultCode(result.data) is 0
            resolve result.data
          else
            throw new Error "Command #{command} failed with return code #{query.resultCode result.data}"
        .catch (errorResult) =>
          reject if errorResult instanceof Error then errorResult else errorResult.error

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new YamahaAvrPlugin