Jekyll::Hooks.register :site, :after_init do |site|
  unless File.exist?(site.collections_path + "/node_modules")
    system("yarn")
  end
  if Jekyll.env == "test"
    site.config["collections"]["fixtures"]["output"] = true
  end
end
