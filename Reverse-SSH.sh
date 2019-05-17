Our school network won't let you ssh over port 22. We need to work around that.

I tested this on cyber122, I assume it works on Eduroam.
command: ssh-keygen
command: cat ~/.ssh/id_rsa.pub
Copy the key output from start to finish. 
It will look like "ssh-rsa AAAAB3NzaC1yc2EAAAADAQA3h51P1jBJTLIGEyPSC665TJLzcoG4Xnwi34T pi@raspberrypi", but longer.

Access GCP Platform in your Pi browser.
Under COMPUTER ENGINE find metadata and enter the ssh keys tabs.
-paste your public key and save.
Via the web interface, ssh into your GCP instance. (Instance CLI)
Change the SSH server to accept SSH connects over port 443.
command: sudo nano /etc/ssh/sshd_config
-Add "Port 443" above #Port 22. Save file and exit nano.
command: sudo service ssh restart
Keep this Instance CLI window open

Inside GCP web interface, shutdown your instance. 
Edit the GCP instance to have a static address, and accept https connections(auto adds to firewall).

In Raspberry Pi.
Test the simple ssh connection. 
command: ssh -i ~/.ssh/id_rsa -p 443 pi@(external ip address of your instance on GCP)
Did it work?

Test a simple reverse ssh connection
command: ssh -i ~/.ssh/id_rsa -p 443 -R 2210:localhost:22 pi@(external ip address of your instance on GCP)
Inside the Instance CLI
command: ssh -p 2210 pi@localhost
It should ask for your password to the pi. Check to make sure it made the reverse connection.
-exit the reverse ssh connection.

You've made a simple reverse ssh connection

Now, setup your pi to automatically make the connection upon restart and then to check the connection periodically.

Create a script
In this case, I'm store it in /bin/
command: sudo touch /bin/my_autossh
command: sudo chmod +x /bin/my_autossh
command: sudo nano /bin/my_autossh
#!/bin/bash
SSH_COMMAND="ssh -i ~/.ssh/id_rsa -fNT -R 2210:localhost:22 -p 443 pi@(external ip address of your instance on GCP)"

if [[ -z $(ps -aux | grep "$SSH_COMMAND" | sed '$ d') ]]
then exec $SSH_COMMAND
fi
- save and exit

Crontab schedules tasks.
command: crontab -e
Accept the text editor you are comfortable with.
Add this to the bottom of the file:
@reboot sleep 60 && /bin/my_autossh
*/1 * * * * /bin/my_autossh
