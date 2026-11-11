# Using a CA

> Has to have some understanding about the concept behind how a Certificate Authority (CA) works. Also, I hope that I won't forget this concept again.

- __Step 1:__ We create a CA.
	- `-t ed25519` specifies the key type.
	- `-f` specifies where to save the key and the name of the key.
	- `-C` is a comment
	```bash
	ssh-keygen -t ed25519 -f ~/lab-ca/lab_ca -C "lab CA"
	```
- __Step 2:__ Make the server trust the CA for user logins.
	- We need to copy the CA's public key to the server.
	- We can move this public key to `/etc/ssh/` dir.
	- Add `TrustedUserCAKeys /etc/ssh/lab_ca.pub` to a newline in `/etc/ssh/sshd_config`.
	- Or, I created a file called `/etc/ssh/sshd_config.d/10-ca.conf` and place `TrustedUserCAKeys /etc/ssh/lab_ca.pub` inside it.
	```bash
	scp ~/lab-ca/lab_ca.pub admin@192.168.1.10:/tmp/lab_ca.pub
	sudo mv /tmp/lab_ca.pub /etc/ssh/lab_ca.pub
	```
-  **Step 3:** Give the server a host certificate. (Optional)
	- The server should prove its identity with a certificate, so clients don’t get the fingerprint prompt.
	- The server gives its `host public key` to the CA (or we take it form the server in our case).
	- In most systems the `host public key` will be `/etc/ssh/ssh_host_ed25519_key.pub`.
	```bash
	scp admin@192.168.1.10:/etc/ssh/ssh_host_ed25519_key.pub ~/lab-ca
	```
- Then the CA signs the `host public key`. This creates a new `ssh_host_ed25519_key-cert.pub`.
	- `-s` specifies the CA's private key doing the signing.
	- `-I` is an identity label stored inside the key which is used for identifying. Also, sshd logs it. It helps if we need to identify a key if we need to revoke it
	- `-h` marks this as an host certificate (not a user certificate).
	- `-n` specifies the ssh-server's domain name or IP. So when ssh-server send its certificate to the host-client, the client can check is this the one I'm expecting!
	- `-V +52w` means its valid for 52 weeks.
	```bash
	ssh-keygen -s ~/lab-ca/lab_ca -I client-laptop -h -n server.lab.local,192.168.1.10 -V +52w ssh_host_ed25519_key.pub
	```
- After signing the CA returns `server_host_key-cert.pub` to the server and the server places it in the `/etc/ssh` dir.
	- Then we need to configure the `sshd` to start serving this key for fingerprinting by editing the `/etc/ssh/sshd_config` file.
	- Add `HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub` to a newline.
	- Or, I create a new file `/etc/ssh/sshd_config.d/30-hostcert.conf` and place `HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub` inside it.
	- Test sshd and then restart.
	```bash
	scp ~/lab-ca/server_host_key-cert.pub admin@192.168.1.10:/tmp/
	sudo mv /tmp/server_host_key-cert.pub /etc/ssh/ssh_host_ed25519_key-cert.pub
	```
- **Step 4:** Set up the client to trust the CA for the server.
	- Copy the CA's public key and add it to a line in the `~/.ssh/known_hosts` file.
	- `@cert-authority` tells the client to trust the host certificates signed by this key for these names.
	```bash
	@cert-authority *.lab.local ssh-ed25519 AAAA...paste the full contents of lab_ca.pub...
	```
- **Step 5:** CA signs the user's key.
	- Make a key if you don't have one.
	```bash
	ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
	```
	- Give the public-key to the CA and the CA sign this public key.
		- `-n alice,ubuntu` specifies the usernames this certificate can log in as.
		- This will create a `id_ed25519-cert.pub`.
		- The CA gives this to the user.
	```bash
	ssh-keygen -s ~/lab-ca/lab_ca -I alice-laptop -n alice,ubuntu -V +52w id_ed25519.pub
	```
	- Place this key in the `~/.ssh`, where ssh finds it automatically.
	- I create if not present, a `config` inside `~/.ssh` and it will contain the whats shown below.
	```config
	Host the-server
        HostName server.lab
        User daki
        SetEnv TERM=tmux-256color
        IdentityFile ~/lab/.ssh/k8s/control-plane
        CertificateFile ~/lab/.ssh/k8s/control-plane-cert.pub
	```
- **Step 6:** Hardening the server.
	- We will harden the server by creating a configuration policy for sshd.
	- The server will accept ssh connections based on that.
	- I will create `/etc/ssh/sshd_config.d/20-hardening.conf`.
	- Put the following content in that file.
	```config
	# Authentication
	PermitRootLogin no
	PasswordAuthentication no
	KbdInteractiveAuthentication no
	PermitEmptyPasswords no
	PubkeyAuthentication yes
	AuthenticationMethods publickey
	
	# Limit_who and how much
	AllowUsers daki
	MaxAuthTries 1
	LoginGraceTime 30
	MaxSessions 1
	
	# Drop dead sessions
	ClientAliveInterval 300
	ClientAliveCountMax 2
	```
	- Restart the service for applying the configurations.
	```bash
	sudo sshd -t
	sudo systemctl restart ssh
	```