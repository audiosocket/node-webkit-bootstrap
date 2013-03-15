require "rbconfig"

namespace NodeWebkitBootstrap::Rake.app do
  app       = NodeWebkitBootstrap::Rake.app
  app_path  = NodeWebkitBootstrap::Rake.app_path
  test_path = NodeWebkitBootstrap::Rake.test_path

  desc "Run #{app}."
  task :run => [ "tmp/node-webkit",
                 "tmp/node-webkit-bootstrap/#{app}-run"] do
    run_app app, :run
  end

  desc "Run #{app} tests."
  task :test => [ "tmp/node-webkit",
                 "tmp/node-webkit-bootstrap/#{app}-test"] do
    run_app app, :test
  end

  file "tmp/node-webkit-bootstrap/#{app}-run" => FileList["#{app_path}/**/*"] do
    NodeWebkitBootstrap::Rake.build_runtime app, app_path, :run
  end

  file "tmp/node-webkit-bootstrap/#{app}-test" => FileList["#{test_path}/**/*"] do
    NodeWebkitBootstrap::Rake.build_runtime app, test_path, :test
  end

  def run_app app, mode
    case RbConfig::CONFIG["target_os"]
      when /darwin/i
        path = "tmp/node-webkit/osx/ia32/Contents/MacOS/node-webkit"
      when /mswin|mingw/i
        path = "tmp/node-webkit/win/ia32/nw.exe"
      when /linux/i
        case RbConfig::CONFIG["target_cpu"]
          when "x86_64"
            path = "tmp/node-webkit/linux/x64/nw"
          when "x86"
            path = "tmp/node-webkit/linux/ia32/nw"
        end
    end

    raise "Unsupported platform!" unless path

    sh "#{path} tmp/node-webkit-bootstrap/#{app}-#{mode}"
  end
end
