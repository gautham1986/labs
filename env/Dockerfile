# Linux DevOps/SRE practice box: Ubuntu 24.04 with systemd as PID 1.
#
# Built and run by docker-compose.yml at the repo root (`make up`).
# systemd inside Docker needs: --privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# The stock image is "minimized" (no man pages). Restore docs - reading man pages is part of the job.
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes /etc/dpkg/dpkg.cfg.d/docker-unminimize 2>/dev/null; \
    if [ -x /usr/local/sbin/unminimize ]; then yes | /usr/local/sbin/unminimize >/dev/null 2>&1 || true; fi

COPY packages.txt /tmp/packages.txt
RUN apt-get update \
 && grep -vE '^\s*(#|$)' /tmp/packages.txt | xargs apt-get install -y --no-install-recommends \
 && locale-gen en_US.UTF-8 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/packages.txt

# Trim systemd units that make no sense (or hang) inside a container.
RUN systemctl mask \
      systemd-udevd.service systemd-udevd-kernel.socket systemd-udevd-control.socket \
      systemd-modules-load.service sys-kernel-config.mount sys-kernel-debug.mount \
      sys-kernel-tracing.mount systemd-remount-fs.service getty.target \
      console-getty.service systemd-firstboot.service \
 && systemctl disable nginx.service prometheus-node-exporter.service \
 && systemctl enable ssh.service cron.service \
 && mkdir -p /run/sshd

# The learner: a normal user with passwordless sudo, just like most cloud VMs.
# Its UID matches yours on the host (make passes it in) so files in workspace/ stay editable.
ARG LAB_UID=1000
ARG LAB_GID=1000
RUN userdel -r ubuntu 2>/dev/null; groupdel ubuntu 2>/dev/null; \
    (getent group "$LAB_GID" >/dev/null || groupadd -g "$LAB_GID" learner) \
 && useradd -m -s /bin/bash -u "$LAB_UID" -g "$LAB_GID" -G sudo,adm,systemd-journal learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-learner \
 && chmod 0440 /etc/sudoers.d/90-learner \
 && echo 'learner:learner' | chpasswd

# Every container gets its own SSH host keys on first boot (instead of sharing the image's).
RUN rm -f /etc/ssh/ssh_host_* \
 && printf '%s\n' '[Unit]' 'Description=Generate SSH host keys on first boot' \
      'Before=ssh.service ssh.socket' 'ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key' \
      '[Service]' 'Type=oneshot' 'ExecStart=/usr/bin/ssh-keygen -A' \
      '[Install]' 'WantedBy=multi-user.target' 'RequiredBy=ssh.service' \
      > /etc/systemd/system/ssh-hostkeys.service \
 && systemctl enable ssh-hostkeys.service

# Make the `lab` command available everywhere and show a welcome banner.
COPY profile-lab.sh /etc/profile.d/zz-lab.sh
RUN ln -s /lab/lab /usr/local/bin/lab

# LVM inside a container has no udev: let LVM manage /dev nodes itself.
RUN mkdir -p /etc/lvm && printf 'activation {\n  udev_sync = 0\n  udev_rules = 0\n}\n' > /etc/lvm/lvmlocal.conf

WORKDIR /home/learner
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
