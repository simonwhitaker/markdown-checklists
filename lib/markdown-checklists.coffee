MarkdownChecklistsView = require './markdown-checklists-view'
{CompositeDisposable} = require 'atom'

module.exports = MarkdownChecklists =
  markdownChecklistsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @markdownChecklistsView = new MarkdownChecklistsView(state.markdownChecklistsViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @markdownChecklistsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-checklists:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @markdownChecklistsView.destroy()

  serialize: ->
    markdownChecklistsViewState: @markdownChecklistsView.serialize()

  toggle: ->
    console.log 'MarkdownChecklists was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      editor = atom.workspace.getActiveTextEditor()
      lines = editor.getText().split(/\r?\n/)

      checked = 0
      total = 0
      for line in lines
        matches = line.match(/^\s*- \[(.)\]/)
        if matches
          total++
          if matches[1] == 'x'
            checked++

      @markdownChecklistsView.setCounts(checked, total)
      @modalPanel.show()
