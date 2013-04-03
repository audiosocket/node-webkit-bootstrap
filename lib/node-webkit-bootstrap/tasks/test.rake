namespace NodeWebkitBootstrap::Rake.app do
  app       = NodeWebkitBootstrap::Rake.app
  test_path = NodeWebkitBootstrap::Rake.test_path

  desc "Run #{app} tests."
  task :test => [ "tmp/node-webkit",
                  "tmp/node-webkit-bootstrap/#{app}-test"] do
    NodeWebkitBootstrap::Rake.run_app app, :test
  end

  file "tmp/node-webkit-bootstrap/#{app}-test" => FileList["Rakefile", "#{test_path}/**/*"] do
    NodeWebkitBootstrap::Rake.build_runtime app, test_path, :test
  end
end
