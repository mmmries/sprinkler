use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set cookie: :"m?JWqybuwwS;pA![pY:w.=X7ZDdz?1GOuj;HZNJ(Snz%^/y}eKR!!edC:&janxE`"
end

environment :prod do
  set cookie: :"m?JWqybuwwS;pA![pY:w.=X7ZDdz?1GOuj;HZNJ(Snz%^/y}eKR!!edC:&janxE`"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :sprinkler do
  set version: current_version(:sprinkler)
  plugin Shoehorn
  plugin Nerves
end
