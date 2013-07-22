#TODO check if the options are correct
#TODO bottom padding is heigher than the padding specified in the options
#TODO use underscore for private functions
#TODO generalize the font of data and header and provide the possibility to pass them throw the options

#TODO -> consider left & right margin of the page

LineWrapper = require '../line_wrapper'

module.exports =
  initTables: ->
    console.log 'init tables'

  table: (data, options) ->
    @tableOptions = options
    @rowY = @page.margins.top + @tableOptions.margins.top
    @printHeaderRow()
    @printRow rowIndex, row for row, rowIndex in data

  # print a row
  printRow: (rowIndex, row) ->
    @rowHeight = @getRowHeight(row)

    if @rowY + @rowHeight > @page.height - @page.margins.bottom
      @addPage()
      @rowY = @page.margins.top + @tableOptions.margins.top
      @printHeaderRow()
      @rowHeight = @getRowHeight(row)

    # print the data in each column
    for col, colIndex in @tableOptions.columns
      @printCol rowIndex, row, colIndex, col

    # print the borer of the row
    @moveTo(@tableOptions.margins.left, @rowY)
      .lineTo(@tableOptions.margins.left + @getWidth(), @rowY)
      .lineTo(@tableOptions.margins.left + @getWidth(), @rowY + @rowHeight)
      .lineTo(@tableOptions.margins.left, @rowY + @rowHeight)
      .stroke()

    for col, colIndex in @tableOptions.columns
      # print the line that divide each column
      @moveTo(@getXOfColumn(colIndex), @rowY)
        .lineTo(@getXOfColumn(colIndex), @rowY + @rowHeight)
        .stroke()

    @rowY += @rowHeight

  # print a column
  printCol: (rowIndex, row, colIndex, col) ->
    @font('Times-Roman')
    .text(
      row[col.id] or '',
      @getXOfColumn(colIndex) + @tableOptions.padding.left,
      @rowY + @tableOptions.padding.top,
      width: @getColWidth(colIndex)
    )

  # print a row
  printHeaderRow: ->
    @rowHeight = 30

    # print the data in each column
    for col, colIndex in @tableOptions.columns
      @printHeaderCol colIndex

    # print the borer of the row
    @moveTo(@tableOptions.margins.left, @rowY)
      .lineTo(@tableOptions.margins.left + @getWidth(), @rowY)
      .lineTo(@tableOptions.margins.left + @getWidth(), @rowY + @rowHeight)
      .lineTo(@tableOptions.margins.left, @rowY + @rowHeight)
      .stroke()

    for col, colIndex in @tableOptions.columns
      # print the line that divide each column
      @moveTo(@getXOfColumn(colIndex), @rowY)
        .lineTo(@getXOfColumn(colIndex), @rowY + @rowHeight)
        .stroke()

    @rowY += @rowHeight

  # print an header column
  printHeaderCol: (colIndex) ->
    @font('Times-Bold')
    .text(
      @tableOptions.columns[colIndex].name or '',
      @getXOfColumn(colIndex) + @tableOptions.padding.left,
      @rowY + @tableOptions.padding.top,
      width: @getColWidth(colIndex)
    )

  getColWidth : (colIndex) ->
    @getXOfColumn(colIndex+1) - @getXOfColumn(colIndex) - @tableOptions.padding.left

  getRowHeight: (row) ->
    maxHeight = 0;

    for col, colIndex in @tableOptions.columns
      height = 0
      line = () -> height += @currentLineHeight(true)
      wrapper = new LineWrapper(this)
      wrapper.on 'line', line.bind(this)
      wrapper.wrap([row[col.id] or ''], { width: @getColWidth(colIndex) })
      if height > maxHeight
        maxHeight = height

    return maxHeight + @tableOptions.padding.bottom + 8 # TODO use font height instead of 8

  # get the x position of a column
  getXOfColumn: (colIndex) ->
    perc = 0
    for col, i in @tableOptions.columns when i < colIndex
      perc += col.width

    return @tableOptions.margins.left + (@getWidth() * perc / 100)

  # return the width of the table
  getWidth: ->
    @page.width - (@tableOptions.margins.left + @tableOptions.margins.right)
