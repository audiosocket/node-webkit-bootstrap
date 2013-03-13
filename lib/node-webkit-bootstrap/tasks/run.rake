namespace NodeWebkitBootstrap::Rake.app do
  app     = NodeWebkitBootstrap::Rake.app
  package = NodeWebkitBootstrap::Rake.run_package 
  path    = NodeWebkitBootstrap::Rake.path

  desc "Run #{app} (platform either \"linux/{x64,ia32}\" or \"osx/ia32\", default: \"osx/ia32\")."
  task :run, [:platform] => [ "tmp/node-webkit",
                              "tmp/node-webkit-bootstrap/#{app}-run"] do |t, args|
    platform = args[:platform] || "osx/ia32"
    
    if platform == "osx/ia32"
      path = "tmp/node-webkit/#{platform}/Contents/MacOS/node-webkit"
    else
      path = "tmp/node-webkit/#{platform}/nw"
    end

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
  end
end
