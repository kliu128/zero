{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Pylint for vscode to stop complaining
    (python3.withPackages(pkgs: [ pkgs.pylint ])) pipenv octave
  ];
}