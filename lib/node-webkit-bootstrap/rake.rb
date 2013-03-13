# Entry point for Rakefile

here = File.expand_path "..", __FILE__
Dir["#{here}/tasks/*.rake"].sort.each { |f| import f }
