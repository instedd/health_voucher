class CodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[0-9]+\z/
      record.errors[attribute] << "contains invalid characters"
    end

    unless value.length == @options[:length]
      record.errors[attribute] << "is of invalid length"
    end

    unless Card::Code.check(value)
      record.errors[attribute] << "is invalid"
    end
  end

  def check_validity!
    unless @options[:length] > 0
      raise ArgumentError, "length must be greater than zero"
    end
  end
end

