import Config

# Example configuration for Versionise
# This project uses its own precommit alias
config :versionise,
  test_command: "mix precommit"

# For most projects using the default test command:
# config :versionise,
#   test_command: "mix test"

# Other examples:
# config :versionise,
#   test_command: "mix test --cover"
#
# config :versionise,
#   test_command: "mix ci"
