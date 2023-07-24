{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.requests
    python3Packages.selenium
    python3Packages.beautifulsoup4
  ];

  #shellHook = ''
  #  export PYTHONPATH=$PYTHONPATH:${python3Packages.requests}/${python3Packages.requests.sitePackages}:${python3Packages.selenium}/${python3Packages.selenium.sitePackages}:${python3Packages.beautifulsoup4}/${python3Packages.beautifulsoup4.sitePackages}
  #'';
}
