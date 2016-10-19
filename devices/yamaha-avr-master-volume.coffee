module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  commands = require '../yamaha-avr-commands'
  cmd = commands.cmd

  # Device class representing an the power state of the Yamaha AVR
  class YamahaAvrMasterVolume extends env.devices.DimmerActuator

    # Create a new YamahaAvrPresenceSensor device
    # @param [Object] config    device configuration
    # @param [YamahaAvrPlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @base = commons.base @, @config.class
      @id = @config.id
      @name = @config.name
      @interval = @base.normalize @config.interval, 10
      @volumeLimit = @base.normalize @config.volumeLimit, @config.volumeDbMin, @config.volumeDbMax
      @debug = @plugin.debug || false
      @statusUpdateHandler = @_createStatusUpdateHandler()
      @plugin.on 'statusUpdate', @statusUpdateHandler
      @attributes = _.cloneDeep(@attributes)
      @attributes.volume = {
        description: "Volume"
        type: "number"
        acronym: 'VOL'
        unit: 'dB'
      }
      @_dimlevel = 0
      @_state = false
      @_volume = @_levelToVolume @_dimlevel
      super()
      process.nextTick () =>
        @plugin.startStatusUpdates @interval * 1000

    destroy: () ->
      @plugin.removeListener 'statusUpdate', @statusUpdateHandler
      super()

    _createStatusUpdateHandler: () ->
      (status) =>
        @base.debug "Status Update", status
        if status.Volume?
          @_setVolume status.Volume
          @_setDimlevel @_volumeToLevel status.Volume
          @base.debug "Dimlevel #{@_dimlevel}"

    _setVolume: (volume) ->
      @base.setAttribute 'volume', volume

    _levelToVolume: (level) ->
      Math.round(((level * (Math.abs(@config.volumeDbMin) + @config.volumeDbMax) / 100) - Math.abs @config.volumeDbMin) * 2) / 2

    _volumeToLevel: (volumeDb) ->
      num = @base.normalize volumeDb, @config.volumeDbMin, @config.volumeDbMax
      Math.round (num + Math.abs @config.volumeDbMin) * 100 / (Math.abs(@config.volumeDbMin) + @config.volumeDbMax)

    changeDimlevelTo: (newLevel) ->
      if @_levelToVolume(newLevel) > @volumeLimit
        newLevel = @_volumeToLevel @volumeLimit
      volumeDB = @_levelToVolume newLevel

      new Promise (resolve, reject) =>
        @plugin.sendRequest(cmd.command cmd.put, cmd.mainZone cmd.volume cmd.level cmd.val volumeDB * 1e1).then (data) =>
          @_setDimlevel newLevel
          @_setVolume volumeDB
          @plugin.emit "statusUpdate",
            Volume: volumeDB
          resolve()
        .catch (errorResult) =>
          @base.rejectWithErrorString reject, if errorResult instanceof Error then errorResult else errorResult.error

    getVolume: () ->
      new Promise.resolve @_volume