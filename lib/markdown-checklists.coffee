MarkdownChecklistsView = require './markdown-checklists-view'
{CompositeDisposable, Point, Range} = require 'atom'

module.exports = MarkdownChecklists =
  markdownChecklistsView: null
  statsTile: null
  subscriptions: null

  activate: (state) ->
    @markdownChecklistsView = new MarkdownChecklistsView(state.markdownChecklistsViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    mypackage = this
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-checklists:toggle-stats': => @refresh_stats()
    @subscriptions.add atom.commands.add 'atom-workspace', 'markdown-checklists:toggle-item': => @toggle_item()
    @subscriptions.add atom.workspace.onDidStopChangingActivePaneItem ->
      mypackage.refresh_stats()
    
    @refresh_stats()

  consumeStatusBar: (statusBar) ->
    @statsTile = statusBar.addRightTile(item: @markdownChecklistsView.getElement(), priority: 500)

  deactivate: ->
    @statsTile?.destroy()
    @statsTile = null

    @subscriptions.dispose()
    @markdownChecklistsView.destroy()

  serialize: ->
    markdownChecklistsViewState: @markdownChecklistsView.serialize()

  toggle_item: ->
    console.log 'MarkdownChecklists toggled item'
    if editor = atom.workspace.getActiveTextEditor()
      for position in editor.getCursorBufferPositions()
        text = editor.lineTextForBufferRow(position.row)
        replacement = text.replace /^(\s*- \[)(.)(\])/, (match, pre, val, post) ->
          newval = 'x'
          if val == 'x'
            newval = ' '
          return [pre, newval, post].join('')
        if text != replacement
          range = new Range(new Point(position.row, 0), new Point(position.row, text.length))
          editor.setTextInBufferRange(range, replacement)
          @refresh_stats()

  refresh_stats: ->
    if editor = atom.workspace.getActiveTextEditor()
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
