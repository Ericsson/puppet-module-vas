# vas_domain

Facter.add('vas_domain') do
  setcode do
    if File.exists?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info domain 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
