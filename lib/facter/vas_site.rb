# vas_site

Facter.add('vas_site') do
  setcode do
    if File.exists?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep "^Servers type" | cut -f10 -d" " | cut -f1 -d":" 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
