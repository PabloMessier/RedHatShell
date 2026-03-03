What to do to emulate the WSL-RHEL experience:

Here’s a step-by-step architecture mapping and setup plan:

⸻

🧱 1. Use Podman Machine to Run Linux:
podman machine init --now

This spins up a VM (using QEMU) that runs Linux. Inside this VM, containers will run.

You can access the VM via SSH:
podman machine ssh

Now you’re in a Linux environment, like WSL.

 2. Run a RHEL container
If you have Red Hat subscription access, run:

podman login registry.redhat.io
podman pull registry.redhat.io/ubi9/ubi
podman run -it --rm registry.redhat.io/ubi9/ubi

Alternatively, use CentOS Stream 9 or Fedora if you don’t have RH access:
podman run -it --rm quay.io/centos/centos:stream9

3. Check hostnamectl inside the container
Once inside, run:

dnf install -y systemd
hostnamectl

You’ll likely see:
Chassis: container
Virtualization: podman

	•	If you see Virtualization: podman, that confirms it’s inside a Podman container.
	•	If you don’t see hostnamectl working correctly, you may need to enable systemd-based container setups (see below).

⸻

🧪 4. (Optional) Enable systemd in the container
Podman supports systemd in containers via OCI hooks.

Use a container that supports systemd:
podman run -it --rm --privileged --systemd=always registry.redhat.io/ubi9/ubi

Or use a systemd-enabled container image like:
podman run -it --rm --privileged --systemd=always quay.io/centos/centos:stream9

If you’re aiming to match the RHEL-on-WSL feel on macOS, then:
	1.	Use podman machine to simulate the WSL VM.
	2.	Use podman run to simulate container rootfs.
	3.	Enable systemd in containers if needed to match hostnamectl output.

Bonus: Running a container with systemd

To simulate the WSL-style environment more closely (i.e., with hostnamectl reporting Chassis: container), run:
podman run --rm -it --privileged --systemd=always registry.redhat.io/ubi9/ubi

Or for CentoOS:
podman run --rm -it --privileged --systemd=always quay.io/centos/centos:stream9

You’ll need --privileged and --systemd=always to bootstrap systemd correctly inside a container.

⸻

📌 Next Steps (Recommended)
	1.	✅ Confirm the hostnamectl output inside the container.
	2.	🧪 Test if Virtualization: podman and Chassis: container appear.
	3.	🚀 Optionally build a custom container with systemd and extra tools pre-installed.
	4.	📁 Use Podman volumes to simulate persistent environments like WSL home folders.

If you get this error:

hostnamectl fails with:
System has not been booted with systemd as init system (PID 1). Can't operate.

That’s because your container does not have systemd as PID 1, which is required for commands like hostnamectl, loginctl, timedatectl, etc., to function properly.

Solution: Run a Podman container with systemd as PID 1

You need to start the container with options that allow systemd to become the init system:

Corrected Command:
podman run --rm -it --privileged --systemd=always quay.io/centos/centos:stream9

Or for UBI:
podman run --rm -it --privileged --systemd=always registry.redhat.io/ubi9/ubi

Explanation of Flags:
	•	--privileged: Gives the container almost all the capabilities of the host (required for systemd to control namespaces properly).
	•	--systemd=always: Tells Podman to run systemd as PID 1 inside the container.
	•	--rm: Auto-remove the container when it exits.
	•	-it: Interactive terminal.

Persistent Systemd Container

If you want a container that acts like a persistent shell environment (like RHEL on WSL), consider:

podman run -dit \
  --name redhat-shell \
  --privileged \
  --systemd=always \
  -v redhat-home:/home \
  registry.redhat.io/ubi9/ubi

Then later:
podman exec -it redhat-shell /bin/bash

Or start it again with:
podman start -ai redhat-shell


Switch to Non-Root User Automatically (Optional)

If you want to enter as a non-root user:

Edit ~/bin/redhat-shell:
# Replace this:
podman exec -it "$CONTAINER" bash

# With this:
podman exec -it --user user "$CONTAINER" bash

Enable Container Autostart on Reboot (Optional)
podman generate systemd --name redhat-shell --files --restart-policy=always

This creates a .service unit you can install if needed.


Create a Desktop Shortcut or Alias

You can create an alias in your .zshrc:
alias redhat='redhat-shell'