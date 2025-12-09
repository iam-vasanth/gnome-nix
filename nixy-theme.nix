{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "plymouth-nixy-theme";
  version = "1.0";
  
  src = /home/zoro/gnome-nix/nixy.tar.gz;
  
  dontConfigure = true;
  dontBuild = true;
  
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes/
    tar -xvf $src -C $out/share/plymouth/themes/
    substituteInPlace $out/share/plymouth/themes/nixy/*.plymouth --replace '@ROOT@' "$out/share/plymouth/themes/nixy/"
    runHook postInstall
  '';
}