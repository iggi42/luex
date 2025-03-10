defmodule LuexCliTest do
  use ExUnit.Case

  alias Luex.Cli

  describe "parse_arg/1" do
    test "simple script call" do
      assert {%Cli.Options{}, 1} == Cli.parse_arg(["hello_world.lua"])
    end

    test "two executes and a script call with args" do
      lua_args = [
        "-e",
        "print([[first]])",
        "-e",
        "print([[secound]])",
        "script.lua"
      ]

      script_args = [
        "script_arg1",
        "script_arg2"
      ]

      options = %Cli.Options{execute: ["print([[first]])", "print([[secound]])"]}

      assert {options, script_args} == Cli.parse_arg(lua_args ++ script_args)
    end

    test "detected interactive mode after script" do
      # -i implies also -v
      assert {%Cli.Options{interactive: true, show_version: true}, []} ==
               Cli.parse_arg(["-i", "some.lua"])
    end

    test "detected ignore-env" do
      assert {%Cli.Options{ignore_env: true}, []} == Cli.parse_arg(["-E"])
    end

    test "detected 3 libraries to require before a script" do
      input = ["-l", "lua-cjson", "-l", "lua-resty-http", "some.lua", "script_arg1"]
      options = %Cli.Options{library: ["lua-cjson", "lua-resty-http"]}
      assert {options, ["script_arg1"]} == Cli.parse_arg(input)
    end

    test "detected execute from stdin" do
      # TODO, what the fuck.
      # I guess this only happens if there is a script? ignoring the switch?
    end
  end
end
