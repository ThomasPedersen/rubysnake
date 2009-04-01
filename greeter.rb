# So far, keep adding stuff!

class Greeter
  def self.greet
    puts "Hey"
  end
end

Greeter.greet
%w(fish chips potato).collect{|s| s.reverse.capitalize}.each{|o| puts o}
sleep 6