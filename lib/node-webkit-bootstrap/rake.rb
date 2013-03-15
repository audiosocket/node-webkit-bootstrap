require "rake"

# Entry point for Rakefile

DSL = Rake::DSL

module NodeWebkitBootstrap
  class Rake
    class << self
      include DSL

      attr_accessor :app
      attr_accessor :app_path
      attr_accessor :run_package
      attr_accessor :build_package
      attr_accessor :test_package
      attr_accessor :test_path
    end

    @here = File.expand_path "..", __FILE__

    @app = "node-webkit-bootstrap"

    @run_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: true,
        width:   660,
        height:  500
      }
    }

    @build_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: false,
        width:   660,
        height:  500
      }
    }

    @test_package = {
      name: @app,
      main: "index.html",
      window: {
        toolbar: false,
        show:    false,
        width:   660,
        height:  500
      }
    }

    @app_path  = "#{@here}/bootstrap"
    @test_path = "#{@here}/test"

    def self.register &block
      yield self if block_given?

      Dir["#{@here}/tasks/*.rake"].each do |f|
        import f
      end
    end

    def self.build_runtime app, path, mode
      basedir = "tmp/node-webkit-bootstrap/#{app}-#{mode}"

      FileUtils.rm_rf   basedir
      FileUtils.mkdir_p File.dirname(basedir)
      FileUtils.cp_r    path, basedir

      case mode
        when :build
          package = NodeWebkitBootstrap::Rake.build_package
        when :run
          package = NodeWebkitBootstrap::Rake.run_package
        when :test
          package = NodeWebkitBootstrap::Rake.test_package
       end

      File.open "#{basedir}/package.json", "w" do |file|
        file.write JSON.pretty_generate(package)
      end
      if package[:dependencies]
        sh "which npm && cd tmp/node-webkit-bootstrap/#{app}-build && npm install --production"
      end

      sh "touch tmp/node-webkit-bootstrap/#{app}-run"
  end
  end
end
