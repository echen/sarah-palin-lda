require 'iconv'
require 'time'

EMAILS_DIRECTORY = "emails/"

class String
  IC = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  
  def fix_encoding  
    IC.iconv(self + ' ')[0..-2]
  end
  
  def clean
    self.fix_encoding
  end
end

weights = {}
IO.foreach("document-topic-distributions.txt") do |line|
  next if line.strip.empty?
  line = line.strip.split(",")
  doc_id = line[0].to_i
  topic_weights = line[1..-1].map(&:to_f)
  weights[doc_id] = topic_weights
end

count = 0
Dir.glob(EMAILS_DIRECTORY + "*.txt") do |filename|
  base = File.basename(filename).gsub(".txt", "").to_i
  text = File.read(filename).clean
  if text =~ /sent\s*:(.+?)$/i    
    begin
      date = text.match(/sent\s*:(.+?)$/i).captures.first
      date = Time.parse(date)
      puts [base, date.year, date.month, date.day, date.hour, date.wday].join("\t") + "\t" + weights[base].join("\t")
    rescue
      count += 1
    end
  else
    count += 1
  end
end
puts count