{ stdenv, lib }:

stdenv.mkDerivation {
  name = "plymouth-nixy-theme";
  
  src = ./.;
  
  installPhase = ''
    mkdir -p $out/share/plymouth/themes/nixy
    cp -r * $out/share/plymouth/themes/nixy/
  '';
}