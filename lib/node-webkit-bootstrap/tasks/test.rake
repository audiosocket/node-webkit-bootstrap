NodeWebkitBootstrap::Rake.add_tasks do
  next if ENV["NODE_WEBKIT_BOOTSTRAP_NO_TESTS"]

  app        = NodeWebkitBootstrap::Rake.app
  build_deps = NodeWebkitBootstrap::Rake.build_deps
  test_path  = NodeWebkitBootstrap::Rake.test_path

  desc "Run #{app} tests."
  task :test => [ "tmp/node-webkit",
                  "tmp/node-webkit-bootstrap/#{app}-test"] do
    NodeWebkitBootstrap::Rake.run_app app, :test
  end

  file "tmp/node-webkit-bootstrap/#{app}-test" => FileList["Rakefile", "#{test_path}/**/*"].concat(build_deps) do
    NodeWebkitBootstrap::Rake.build_runtime app, test_path, :test
  end
end
