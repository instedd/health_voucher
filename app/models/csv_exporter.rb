require 'csv'

class CsvExporter
  def headers(*headers)
    @headers = headers.flatten
  end

  def generate(options = {}, &block)
    options = options.merge headers: @headers, write_headers: true if @headers.present?
    QuotingCSV.generate(options, &block)
  end

  # Overrides Ruby's CSV to force quoting string fields that look like numbers.
  # This is for better compatibility with Excel CSV import.
  class QuotingCSV < CSV
    DEFAULT_OPTIONS = { write_headers: true }
    NUMBER_REGEXP = /\A-?\d+(\.\d*)?\z/

    def self.generate(options = {})
      super DEFAULT_OPTIONS.merge(options)
    end

    def initialize(*args)
      super *args

      do_quote = lambda do |field|
        field = String(field)
        encoded_quote = @quote_char.encode(field.encoding)
        encoded_quote + field.gsub(encoded_quote, encoded_quote * 2) + encoded_quote
      end
      quotable_chars = encode_str("\r\n", @col_sep, @quote_char)
      @quote = if @force_quotes
                 do_quote
               else
                 lambda do |field|
                   if field.nil?  # represent +nil+ fields as empty unquoted fields
                     ""
                   else
                     was_string = field.instance_of?(String)
                     field = String(field)
                     # represent empty fields as empty quoted fields
                     # add quotes if field was a string but looks like a number
                     if field.empty? or field.count(quotable_chars).nonzero?
                       do_quote.call(field)
                     elsif field =~ NUMBER_REGEXP and was_string
                       # prefix with = to force Excel to stop converting the field to a number
                       '=' + do_quote.call(field)
                     else
                       field
                     end
                   end
                 end
               end
    end
  end
end

