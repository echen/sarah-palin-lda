class String
  require 'iconv'

  IC = Iconv.new('UTF-8//IGNORE', 'UTF-8')

  STOPWORDS = "able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your".split(",")

  def fix_encoding  
    IC.iconv(self + ' ')[0..-2]
  end

  def clean    
    ret = self.fix_encoding
    ret = ret.gsub(/From\s*:.+?Subject\s*:/m, "")
    ret = ret.gsub('"', " ").gsub("'", " ").gsub(",", "")
    ret = ret.remove_stopwords
    ret = ret.collapse_whitespace
    ret
  end

  def remove_stopwords
    ret = self
    STOPWORDS.each do |stopword|
      ret = ret.gsub(/^#{stopword}\s/i, " ")
      ret = ret.gsub(/\s#{stopword}$/i, " ")  
      ret = ret.gsub(/\s#{stopword}\s/i, " ")
    end
    ret
  end

  def collapse_whitespace
    self.gsub(/\s+/, " ")
  end

  def remove_nonalphanumeric
    self.gsub(/[^a-zA-Z0-9]/, "")
  end

  def extract_first_email
    x = self.fix_encoding
    first_email_regex = /(From\s*:.*?)From\s*:/m
    if x =~ first_email_regex
      return x.match(first_email_regex).captures.first
    else
      return x
    end
  end
end

EMAILS_DIRECTORY = "emails/"

File.open("emails.csv", "w") do |f|
  Dir.glob(EMAILS_DIRECTORY + "*.txt") do |filename|
    email_id = File.basename(filename).gsub(".txt", "")
    text = File.read(filename).clean
    f.puts [email_id, text].join(",")
  end
end