Jekyll::Hooks.register :site, :after_init do |site|
  if Jekyll.env == "test"
    site.config["collections"]["fixtures"]["output"] = true
  end
end
