namespace NodeWebkitBootstrap::Rake.app do
  desc "Download latest node-webkit code (default version: #{NodeWebkitBootstrap::Rake.nw_version})."
  task :download, [:version] do |t, args|
    version = args[:version] || NodeWebkitBootstrap::Rake.nw_version
    NodeWebkitBootstrap::Rake.download_nw version
  end
end
