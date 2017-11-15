# vas_server_type

Facter.add('vas_server_type') do
  setcode do
    if File.exists?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep "^Servers type" | cut -f4 -d" " | cut -f1 -d","' 
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
