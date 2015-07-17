require! {
  \underscore-plus : _
  \atom-space-pen-views : {SelectListView, $, $$}
  fuzzaldrin
  \./completeQuery.ls
}

class CommandPaletteView extends SelectListView
  keyBindings: null

  initialize: ->
    super!
    @addClass \command-palette

  getFilterKey: -> \name

  getFilterQuery: ->
    @filterEditorView.getText! |> completeQuery

  cancelled: -> @hide!

  toggle: -> if @panel?.isVisible! then @cancel! else @show!

  show: ->
    @panel ?= atom.workspace.addModalPanel do
      item: @
    @panel.show!

    @storeFocusedElement!

    if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
      @eventElement = @previouslyFocusedElement[0]
    else
      @eventElement = atom.views.getView atom.workspace
    @keyBindings = atom.keymaps.findKeyBindings do
      target: @eventElement

    commands = atom.commands.findCommands do
      target: @eventElement
    commands = _.sortBy commands, \name
    @setItems commands

    @focusFilterEditor!

  hide: ->
    @panel?.hide!

  viewForItem: ({name, displayName, eventDescription}) ->
    keyBindings = @keyBindings
    matches = fuzzaldrin.match name, @getFilterQuery!

    $$ ->
      highlighter = (command, matches, offsetIndex) ~>
        lastIndex = 0
        matchedChars = [] # Build up a set of matched chars to be more semantic

        for matchIndex in matches
          matchIndex -= offsetIndex
          if matchIndex < 0
            continue
          unmatched = command.substring lastIndex, matchIndex
          if unmatched
            if matchedChars.length
              @span do
                matchedChars.join ''
                class: \character-match
            matchedChars = []
            @text unmatched
          matchedChars.push command[matchIndex]
          lastIndex = matchIndex + 1

        if matchedChars.length
          @span do
            matchedChars.join ''
            class: \character-match

        # Remaining characters are plain text
        @text command.substring lastIndex

      @li do
        class: \event
        \data-event-name : name
        ~>
          @div do
            class: \pull-right
            ~>
              for binding in keyBindings when binding.command is name
                @kbd do
                  _.humanizeKeystroke binding.keystrokes
                  class: \key-binding
          @p do
            class: \command-name
            -> highlighter name, matches, 0
          @span do
            class: \command-description
            displayName

  confirmed: ({name}) ->
    @cancel!
    @eventElement.dispatchEvent do
      new CustomEvent do
        name
        bubbles: true
        cancelable: true

module.exports = CommandPaletteView
