let
  pengu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlBQazBrTIU2dmXth9OG/4qI7yOZUzxXaHQGyaX4qEt";
in
{
  "claude.age".publicKeys = [ pengu ];
}
