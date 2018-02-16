module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  commands = require '../yamaha-avr-commands'
  cmd = commands.cmd

  # Device class representing the input selector of the Yamaha AVR
  class YamahaAvrInputSelector extends env.devices.ButtonsDevice

    # Create a new YamahaAvrInputSelector device
    # @param [Object] config    device configuration
    # @param [YamahaAvrPlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @base = commons.base @, @config.class
      @id = @config.id
      @name = @config.name
      @interval = @base.normalize @config.interval, 10
      @debug = @plugin.debug || false
      for b in @config.buttons
        b.text = b.id unless b.text?
      @statusUpdateHandler = @_createStatusUpdateHandler()
      @plugin.on 'statusUpdate', @statusUpdateHandler
      super(@config)
      process.nextTick () =>
        @plugin.startStatusUpdates @interval * 1000

    destroy: () ->
      @plugin.removeListener 'statusUpdate', @statusUpdateHandler
      super()

    _createStatusUpdateHandler: () ->
      return (status) =>
        @base.debug "Status Update", status
        if status.Input?.Select?
          @_lastPressedButton = status.Input.Select
          @emit 'button', status.Input.Select

    buttonPressed: (buttonId) ->
      return new Promise (resolve, reject) =>
        matched = @config.buttons.some (element, iterator) =>
          element.id is buttonId

        if matched
          @plugin.sendRequest(cmd.command cmd.put, cmd.mainZone cmd.input cmd.inputSelect buttonId).then (data) =>
            @_lastPressedButton = buttonId
            @emit 'button', buttonId
            @plugin.emit "statusUpdate",
              Input:
                Select: buttonId
            resolve()
          .catch (errorResult) =>
            @base.rejectWithErrorString reject, if errorResult instanceof Error then errorResult else errorResult.error
        else
          @base.rejectWithErrorString new Error("No button with the id #{buttonId} found")