class StripRenderer < Redcarpet::Render::Base
  def block_code(code, language)
    " "
  end

  def block_quote(quote)
    quote
  end

  def block_html(raw_html)
    raw_html
  end

  def header(text, header_level)
    "#{text} "
  end

  def hrule
    " "
  end

  def list(contents, list_type)
    " #{contents}"
  end

  def list_item(text, list_type)
    "* #{text}"
  end

  def paragraph(text)
    text
  end

  # Span-level calls

  def linebreak
    " "
  end

  # Postprocessing: strip the newlines

  def postprocess(document)
    document.gsub("\n", ' ').strip.downcase
  end
end
