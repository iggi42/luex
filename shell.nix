let pkgs = import <nixpkgs> {};
in 
pkgs.mkShellNoCC {
  packages = with pkgs; [
    erlang_25
    elixir_1_18
  ];
}
