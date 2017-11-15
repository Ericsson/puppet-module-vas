# vas_version

Facter.add('vas_version') do
  setcode do
    if File.exists?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool -v | grep "vastool" | cut -f 4 -d " "'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
