PDFDocument = require './lib/document'
doc = new PDFDocument

# Register a font name for use later
doc.registerFont('Palatino', 'demo/fonts/PalatinoBold.ttf')

doc.font("Times-Roman")
  .text("abcd")

doc.write("output.pdf")