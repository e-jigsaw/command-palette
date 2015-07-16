require 'atom-livescript'
CommandPaletteView = require './lib/command-palette-view.ls'

module.exports =
  activate: ->
    view = new CommandPaletteView
    @disposable = atom.commands.add 'atom-workspace', 'command-palette:toggle', -> view.toggle()

  deactivate: -> @disposable.dispose()
