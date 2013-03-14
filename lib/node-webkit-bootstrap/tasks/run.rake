require "rbconfig"

namespace NodeWebkitBootstrap::Rake.app do
  app     = NodeWebkitBootstrap::Rake.app
  package = NodeWebkitBootstrap::Rake.run_package 
  path    = NodeWebkitBootstrap::Rake.path

  desc "Run #{app}."
  task :run => [ "tmp/node-webkit",
                 "tmp/node-webkit-bootstrap/#{app}-run"] do
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

    sh "#{path} tmp/node-webkit-bootstrap/#{app}-run"
  end

  file "tmp/node-webkit-bootstrap/#{app}-run" => FileList["#{path}/**/*"] do
    basedir = "tmp/node-webkit-bootstrap/#{app}-run"

    FileUtils.rm_rf   basedir
    FileUtils.mkdir_p basedir
    FileUtils.cp_r    FileList["#{path}/**/*"], basedir
    File.open "#{basedir}/package.json", "w" do |file|
      file.write JSON.pretty_generate(package)
    end
    if package[:dependencies]
      sh "which npm && cd tmp/node-webkit-bootstrap/#{app}-build && npm install --production"
    end

    sh "touch tmp/node-webkit-bootstrap/#{app}-run"
  end
end
