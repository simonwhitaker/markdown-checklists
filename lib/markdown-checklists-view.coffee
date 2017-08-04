module.exports =
class MarkdownChecklistsView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('markdown-checklists')

    # Create message element
    @message = document.createElement('div')
    @message.classList.add('message')
    @element.appendChild(@message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setCounts: (checked, total) ->
    percent = Math.round(checked * 100 / total)
    displayText = "#{checked}/#{total} (#{percent}%)"
    @message.textContent = displayText