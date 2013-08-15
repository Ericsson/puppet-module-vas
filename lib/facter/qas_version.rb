# qas_version

Facter.add('qas_version') do
  setcode do
    test_installed = 'test -f /opt/quest/bin/vastool; echo $?'
    if Facter::Util::Resolution.exec(test_installed) == '0'
      cmd = '/opt/quest/bin/vastool -v | grep "^vastool"'
      response = Facter::Util::Resolution.exec(cmd)
      response.split(" ")[3]
    end
  end
end

Facter.add('qasmajversion') do
  setcode do
    test_installed = 'test -f /opt/quest/bin/vastool; echo $?'
    if Facter::Util::Resolution.exec(test_installed) == '0'
      cmd = '/opt/quest/bin/vastool -v | grep "^vastool"'
      response = Facter::Util::Resolution.exec(cmd)
      response.split(" ")[3].chars.first
    end
  end
end
