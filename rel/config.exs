# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"J]gllLo9!*{HGqjQ3s=M0t9GxO%2YT>]S1&*,EIVGUuni?dNZG0RRVzIEm%e>*tU")
end

environment :prod do
  set(pre_start_hooks: "bin/hooks/")
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"0*xsbIl3AS91,?[R9RMhLPs47@P3q?@cC%f0]RH})s`A4v]aU(^=b@^1sLm4RlN6")
end

# environment :default do
#   # set(pre_start_hooks: "bin/hooks/")
#   set(dev_mode: false)
#   set(include_erts: true)
#   set(include_src: false)
#
#   set(
#     overlays: [
#       {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
#     ]
#   )
# end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :api do
  set(version: current_version(:api))

  set(
    applications: [
      :runtime_tools,
      api: :permanent,
      digital_signature: :permanent,
      core: :permanent
    ]
  )

  set(
    config_providers: [
      {Toml.Provider, [path: "/home/ds/config.toml"]}
    ]
  )
end

release :core do
  set(version: current_version(:core))

  set(
    applications: [
      :runtime_tools
    ]
  )
end

release :digital_signature do
  set(version: current_version(:digital_signature))

  set(
    applications: [
      :runtime_tools,
      core: :permanent
    ]
  )
end

release :ocsp_service do
  set(version: current_version(:ocsp_service))

  set(
    applications: [
      :runtime_tools,
      ocsp_service: :permanent,
      digital_signature: :permanent,
      core: :permanent
    ]
  )

  set(
    config_providers: [
      {Toml.Provider, [path: "/home/ds/config.toml"]}
    ]
  )
end

release :synchronizer_crl do
  set(version: current_version(:synchronizer_crl))

  set(
    applications: [
      :runtime_tools,
      synchronizer_crl: :permanent,
      core: :permanent
    ]
  )
end
