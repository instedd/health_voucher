class Report
  class << self
    def group_by(*options)
      @by_options = options.map(&:to_sym)
      @by_options.each do |opt|
        define_method("by_#{opt}?") { self.by == opt }
      end
    end

    def by_options
      @by_options ||= []
    end
  end

  attr_accessor :since_time, :until_time
  attr_reader :data, :totals, :params, :sort, :direction

  def initialize(params = Hash.new)
    @params = params

    self.by = params[:by]
    @since_time = Date.parse_human_param(params[:since]).beginning_of_day rescue nil
    @until_time = Date.parse_human_param(params[:until]).end_of_day rescue nil

    @sort = params[:sort]
    @direction = params[:direction] || 'asc'
  end

  def empty?
    @data.empty?
  end

  def build
    @data = []
    @totals = {}
  end

  def by
    @by ||= self.class.by_options.first
  end

  def title
    "Report"
  end

  def column_titles
    column_keys.map {|key| key.to_s.humanize}
  end

  def column_keys
    []
  end

  def sort_keys
    []
  end

  def humanized_date_range
    [since_time.present? ? 'since ' + since_time.to_date.to_human_param : nil,
     until_time.present? ? 'until ' + until_time.to_date.to_human_param : nil].compact.join(' ')
  end

  protected

  def by=(value)
    @by = if !value.nil? && self.class.by_options.map(&:to_s).include?(value.to_s)
      value.to_sym
    else
      self.class.by_options.first
    end
  end

  def add_date_criteria(base, field)
    base = base.where("#{field} >= ?", since_time) unless since_time.nil?
    base = base.where("#{field} <= ?", until_time) unless until_time.nil?
    base
  end

  def totalize(data, keys)
    data.reduce({}) do |memo, row|
      keys.each do |key|
        if row[key].is_a?(Array)
          if memo[key].nil?
            memo[key] = row[key].clone
          else
            memo[key] = memo[key].zip(row[key]).map { |x,y| x + y }
          end
        else
          memo[key] = (memo[key] || 0) + row[key]
        end
      end
      memo
    end
  end

  def sort_data!
    return unless sort_keys.map(&:to_s).include?(sort)
    @data = @data.sort_by do |row|
      row[sort.to_sym]
    end
    @data = @data.reverse if direction == 'desc'
    @data
  end

end

