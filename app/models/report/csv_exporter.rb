class Report::CsvExporter < CsvExporter
  def initialize(report)
    @report = report
  end

  def export
    titles = @report.column_titles
    titles[0] = "# #{titles[0]}"
    headers titles
    generate do |csv|
      @report.data.each do |row|
        csv << @report.column_keys.map {|key| row[key]}.flatten
      end
    end
  end
end

