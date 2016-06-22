fs = require 'fs'
path = require 'path'

keywordSelectorPrefixPattern = /([a-zA-Z]+)\s*$/

module.exports =
  selector: '.source.r'
  disableForSelector: '.source.r .comment'
  filterSuggestions: true

  getSuggestions: (request) ->
    completions = null
    {prefix} = request
    scopes = request.scopeDescriptor.getScopesArray()

    if @isCompletingKeywordSelector(request)
      keywordCompletions = @getKeywordCompletions(request)
      if keywordCompletions?.length
        completions ?= []
        completions = completions.concat(keywordCompletions)

    completions

  onDidInsertSuggestion: ({editor, suggestion}) ->
    setTimeout(@triggerAutocomplete.bind(this, editor), 1) if suggestion.type is 'property'

  triggerAutocomplete: (editor) ->
    atom.commands.dispatch(atom.views.getView(editor), 'autocomplete-plus:activate', {activatedManually: false})

  loadKeywords: ->
    @keywords = {}
    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      {@keywords} = JSON.parse(content) unless error?
      return

  isCompletingKeywordSelector: ({editor, scopeDescriptor, bufferPosition}) ->
    scopes = scopeDescriptor.getScopesArray()
    keywordSelectorPrefix = @getKeywordSelectorPrefix(editor, bufferPosition)
    return false unless keywordSelectorPrefix?.length

    true

  getKeywordCompletions: ({bufferPosition, editor, prefix}) ->
    completions = []
    for keyword, options of @keywords when firstCharsEqual(keyword, prefix)
      completions.push(@buildKeywordCompletion(keyword, options))
    completions

  getKeywordSelectorPrefix: (editor, bufferPosition) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    keywordSelectorPrefixPattern.exec(line)?[1]

  buildKeywordCompletion: (keyword, {snippet, displayText, descriptionMoreURL, description, leftLabel}) ->
    completion =
      description: description
      descriptionMoreURL: descriptionMoreURL

    if displayText?.length
      completion.displayText = displayText

    if leftLabel?.length
      completion.leftLabel = leftLabel

    if snippet?.length
      completion.snippet = snippet
    else
      completion.text = "#{keyword}"

    completion

firstCharsEqual = (str1, str2) ->
  str1[0] is str2[0]
