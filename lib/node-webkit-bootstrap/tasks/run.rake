namespace NodeWebkitBootstrap::Rake.app do
  app = NodeWebkitBootstrap::Rake.app

  desc "Run #{app}."
  task :run, [:platform] => [ "tmp/node-webkit",
                              "tmp/node-webkit-bootstrap/#{app}"] do |t, args|
    platform = args[:platform] || "osx/ia32"
    sh "tmp/node-webkit/#{platform}/Contents/MacOS/node-webkit tmp/node-webkit-bootstrap/#{app}"
  end
end
