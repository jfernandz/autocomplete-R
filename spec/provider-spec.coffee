
AutocompleteR = require '../lib/main'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AutocompleteR", ->
  [editor, provider] = []

  getCompletions = ->
    cursor = editor.getLastCursor()
    start = cursor.getBeginningOfCurrentWordBufferPosition()
    end = cursor.getBufferPosition()
    prefix = editor.getTextInRange([start, end])
    request =
      editor: editor
      bufferPosition: end
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
    provider.getKeywordCompletions(request)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('autocomplete-R')
    waitsForPromise -> atom.packages.activatePackage('language-r')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-R').mainModule.getProvider()

    waitsFor -> Object.keys(provider.keywords).length > 0
    waitsForPromise -> atom.workspace.open('test.r')
    runs -> editor = atom.workspace.getActiveTextEditor()

  it "returns completions on text input", ->
    editor.setText('')
    expect(getCompletions().length).toBe 0

  it "returns no completions in comment", ->
    editor.setText('#')

    editor.setCursorBufferPosition([0, 1])
    expect(getCompletions().length).toBe 0

  it "returns no completions in string", ->
    editor.setText('""')

    editor.setCursorBufferPosition([0, 1])
    expect(getCompletions().length).toBe 0
