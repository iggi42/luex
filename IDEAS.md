# Erlang
- more documentation & examples, and -spec
- property testing for Lua functions to ensure they can handle all lua values feed into them and only
- different encoding of Lua values:
  - functions should return value and new vm state
  - tables should be maps, and arrays should be lists (not sure)
  - non-binary strings should user-data not strings. (not sure)

# Elixir:
- macro to define Luerl extensions
- load these functions via require in Lua
- mix repl

- [experimental] Lua concurrency via the callbacks


