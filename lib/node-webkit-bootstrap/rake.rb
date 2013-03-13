require "rake"

# Entry point for Rakefile

DSL = Rake::DSL

module NodeWebkitBootstrap
  class Rake
    class << self
      include DSL

      attr_accessor :app
      attr_accessor :package
      attr_accessor :path
    end

    @here = File.expand_path "..", __FILE__

    @app = "node-webkit-bootstrap"

    @package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: true,
        width:   660,
        height:  500
      }
    }

    @path = "#{@here}/bootstrap"

    def self.register &block
      yield self if block_given?

      Dir["#{@here}/tasks/*.rake"].each do |f|
        import f
      end
    end
  end
end
