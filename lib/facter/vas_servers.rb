# vas_servers

Facter.add('vas_servers') do
  setcode do
    if File.exists?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep -v "^Servers type" | tr [:upper:] [:lower:] | tr -s "\n" " " 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
