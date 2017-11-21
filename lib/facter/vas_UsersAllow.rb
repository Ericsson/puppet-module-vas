#vas_UsersAllow 

Facter.add('vas_UsersAllow') do
  setcode do
    if File.exists?('/etc/opt/quest/vas/users.allow ')
      cmd = 'cat /etc/opt/quest/vas/users.allow 2>/dev/null | tr -d "\r" | sed '/^$/d' | egrep -v "^#" | sort | tr -s "\n" " "'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
