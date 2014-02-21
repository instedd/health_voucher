module ReportsHelper
  def percent_of(value_or_hash, total_or_hash, key=nil)
    if key.nil?
      value = value_or_hash
      total = total_or_hash
    else
      value = value_or_hash[key]
      total = total_or_hash[key]
    end
    if total == 0
      "-"
    else
      result = 100.0 * value.to_f / total.to_f
      number_to_percentage(result, precision: 2)
    end
  end
end
