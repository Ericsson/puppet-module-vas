# qas_domain

Facter.add("qas_domain") do
  setcode do
    test_installed = "test -f /opt/quest/bin/vastool; echo $?"
    if Facter::Util::Resolution.exec(test_installed) == '0'
      cmd = '/opt/quest/bin/vastool info domain 2>/dev/null'
      response = Facter::Util::Resolution.exec(cmd)
      response
    end
  end
end
