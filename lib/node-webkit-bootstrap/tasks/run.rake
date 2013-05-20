NodeWebkitBootstrap::Rake.add_tasks do
  app        = NodeWebkitBootstrap::Rake.app
  build_deps = NodeWebkitBootstrap::Rake.build_deps
  app_path   = NodeWebkitBootstrap::Rake.app_path

  desc "Run #{app}."
  task :run => [ "tmp/node-webkit",
                 "tmp/node-webkit-bootstrap/#{app}-run"] do
    NodeWebkitBootstrap::Rake.run_app app, :run
  end

  file "tmp/node-webkit-bootstrap/#{app}-run" => FileList["Rakefile", "#{app_path}/**/*"].concat(build_deps) do
    NodeWebkitBootstrap::Rake.build_runtime app, app_path, :run
  end
end
