#!/bin/bash

# plomlompom's Arch Linux post-installation setup
# ===============================================
#
# Preliminary note
# ----------------
#
# This shell script may be executed directly by root, or be used as a
# text guide to configure Arch Linux step-by-step post-installation. It
# originates from a series of wiki pages to record my post-install
# configuration with explanatory remarks, a complete listing of shell
# commands and config file texts -- the major difference is that
# non-code text is put into comment lines, file contents are outsourced
# to external files and all command lines are executed directly as root
# (commands to be executed by non-root are called by root via sudo).
#              -- plomlompom / Christian Heller <c.heller@plomlompom.de>
#
# Some constants for this script:

FILES=/root/postinstall/files
ME=plom
MEHOME=/home/$ME

# General first steps
# ===================
#
# Package management initialization
# ---------------------------------
# 
# Just booted my newly installed Arch Linux for the first time. I login
# as root. I establish an internet connection, upgrade the system via
# pacman and optimize its mirror list via "reflector".

dhcpcd eth0
cp $FILES/pacman.conf /etc/
pacman --noconfirm -Syyu
pacman --noconfirm -S reflector 
reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist 
pacman --noconfirm -Rsn reflector 

# Notice that I used the --noconfirm option on pacman. This is only for
# purposes of execution via a script. If you follow this script as a
# step-by-step guide, leave out the --noconfirm option in this and
# future steps.
#
# Locale
# ------
#
# The default locale is "C", which suffices for many purposes,
# especially if I want my system language to be English (which makes the
# googling of error messages etc. much more successful). Unfortunately,
# this "C" default is not UTF-8, which will create some confusion in
# matters of character sets / mappings further down the line. Thus it
# makes sense to choose /some/ UTF-8 locale for default;

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen 
locale-gen 
echo 'LOCALE="en_US.UTF-8"' >> /etc/rc.conf

# I chose an "en_" locale for the googling reason described above; the
# "US" part only matters for some special cases that I don't care much
# about right now, it's just as good or bad as any "en_" alternative.
#
# Man pages and pager
# -------------------
#
# Install man pages database, linux man pages and "less" pager.

pacman --noconfirm -S less man-db man-pages

# "less" is prone to useless logging, cluttering user directories with
# .lesshst history files. To disable these, I must export an environment
# variable (seriously, there is no better way to do this?):

echo 'export LESSHISTFILE=-' >> /etc/profile 

# Non-root user and its home directory
# ------------------------------------
#
# Create normal user; make sure the home directory starts clutter-free.

useradd -m $ME
rm $MEHOME/.*

# I want as many program files to be put into the directories defined by
# the FreeDesktop standards. Some programs (like i3's dmenu) put their
# files / directories directly into ~/ if they don't find these
# pre-existing, unnecessarily cluttering it. Therefore, I make sure the
# the directories I want them in exist from the beginning:

mkdir $MEHOME/.{cache,config}

# I also create a directory for user scripts that I'll add to $PATH in
# the shell configuration files:

mkdir $MEHOME/.bin

# Shell configuration / initialization
# ------------------------------------
#
# I initialize several variables and aliases for root and user shells,
# including a blue prompt for user shells and a warning red one for root
# shells. Bash differentiates between login and non-login shells and
# expects a .bash_profile for the one and a .bashrc for the other; my
# bash_profile merely references the .bashrc.

cp $FILES/bashrc_root /root/.bashrc
cp $FILES/bash_profile /root/.bash_profile
cp $FILES/bashrc $MEHOME/.bashrc
cp $FILES/bash_profile $MEHOME/.bash_profile

# Text editor
# -----------
#
# "ed" may be the standard editor, but (at least before I master "vi") I
# prefer "nano" for ease of use:

pacman --noconfirm -S nano
cp $FILES/nanorc ~/.nanorc
cp $FILES/nanorc $MEHOME/.nanorc

# In that nanorc config file, I specify that I want to use a directory
# for backups of all files I edit. This directory must be created by
# hand, for otherwise nano will simply write backup files right into the
# the directory where it is executed or (?) where the edited file lies.

mkdir ~/.nano_backups 
mkdir $MEHOME/.nano_backups

# X11 and the i3 window manager
# =============================
#
# X11 window system
# -----------------
#
# I want fancy non-ASCII graphics, so I need X11. The following
# packages are needed for my system (other systems' users may drop
# "xf86-video-intel" and possibly replace it with something else):

pacman --noconfirm -S xorg-server xorg-xinit xf86-video-intel

# X configuration can be daunting, but I want to keep my config as
# as simple as possible, therefore I replace the X11 config directory
# tree (!) with one very short config file:

rm -rf /etc/X11/xorg.conf.d
cp $FILES/xorg.conf /etc/X11/

# Multi-monitor setup
# -------------------
#
# I installed Arch Linux on a small EeePC, but at home I have one large
# HD television screen to serve as a second high-resolution monitor. A
# simple tool to make dual-monitor use of it is "xrandr":

pacman --noconfirm -S xorg-xrandr

# xrandr makes multi-monitor configuration quite easy (considering it
# is a non-graphical command line tool), but for reasons of laziness I
# still want to encapsulate my most common use of it (which includes a
# relatively configuration-heavy special case) in scripts in $PATH:

cp $FILES/xrand $MEHOME/.bin/xrand
cp $FILES/xrandoff $MEHOME/.bin/xrandoff

# i3 window manager
# -----------------
# 
# I choose i3 as my window manager, combined with i3status as its
# status bar, dmenu as its program launcher and xterm as the default
# terminal:

pacman --noconfirm -S i3-wm dmenu i3status xterm
cp $FILES/xinitrc $MEHOME/.xinitrc
mkdir $MEHOME/.config/{i3,i3status}
cp $FILES/i3 $MEHOME/.config/i3/config
cp $FILES/i3status $MEHOME/.config/i3status/config

# Fonts
# -----
#
# The unscalable bitmap console fonts installed by default may be okay
# for console work, but they suck for many X11 applications that demand
# a certain typographical flexibility (like web browsers). The TrueType
# DejaVu font family package provides help:

pacman --noconfirm -S ttf-dejavu

# Dead keys
# ---------
#
# I have written two "scripts" (actually, they each only contain one
# command line; the only reason I don't define them as aliases is dmenu,
# which ignores aliases) to activate/de-active dead keys on my keyboard
# during an X session (the .xinitrc default is "nodeadkeys"):

cp $FILES/deadkeys $MEHOME/.bin/
cp $FILES/deadkeysno $MEHOME/.bin/

# Internet applications
# =====================
#
# Browser, IRC
# ------------
#
# "uzbl" and "irssi" take care of my chatting and browsing needs:

pacman --noconfirm -S uzbl-browser irssi
mkdir $MEHOME/.config/uzbl
cp $FILES/uzbl/* $MEHOME/.config/uzbl/

# E-mail: receive and send
# ------------------------
#
# First I get me a mail retrieval agent: "getmail".

pacman --noconfirm -S getmail
mkdir $MEHOME/.config/getmail
cp $FILES/getmailrc $MEHOME/.config/getmail/

# Mail is to be stored in a Maildir ~/mail directory that needs to be
# set up properly before getmail can use it:

mkdir -p $MEHOME/.mail/inbox/{tmp,new,cur}  

# Apart from the inbox, different types of messages are to go directly
# into appropriate mail boxes (for mailing lists etc.), a filtering to
# be performed by "procmail":

pacman --noconfirm -S procmail
mkdir $MEHOME/.config/procmail
cp $FILES/procmailrc $MEHOME/.config/procmail/

# I need to set up these alternative mailboxes' directories, too. What
# directories exactly is determined from the filters named in the
# procmailrc, from which directory names are translated to existing
# directories via some shell magic:

mboxes=`cat $FILES/procmailrc | grep -E '^[0-9A-Za-z-]+/$' | tr -s "/\n" "," | rev | cut -c 2- | rev`
echo "mkdir -p $MEHOME/.mail/{$mboxes}/{tmp,new,cur}" > /tmp/mboxes
bash /tmp/mboxes
rm /tmp/mboxes

# Now on to a message transfer agent, "msmtp". Notice the chmod 600 for
# the msmtprc: msmtp refuses to start if it has more permissions set.

pacman --noconfirm -S msmtp 
mkdir $MEHOME/.config/msmtp 
cp $FILES/msmtprc $MEHOME/.config/msmtp/
chmod 600 $MEHOME/.config/msmtp/msmtprc

# getmail + msmtp provide a most minimalist e-mail system. To receive
# mail into the mail directory set up above, just type "getmail". To
# send mail, just pipe an e-mail message text (optionally with header
# lines) into msmtp followed by the recipient adress, like this: 
#
# $ echo 'Hi there!' | msmtp bob@example.com 
# 
# This suffices to mail the echoed string to bob@example.com. I could
# also cat entire text files to msmtprc the same way; for the header,
# msmtp takes its "From:" from the msmtprc, and the "To:" from its only
# mandatory argument.
# 
# E-mail: mutt
# ------------
#
# This suffices for minimal mail needs, but for an e-mail power user, a
# proper mail user agent comes in handy. I choose mutt for that:

pacman --noconfirm -S mutt 
mkdir $MEHOME/.config/mutt
cp $FILES/muttrc $MEHOME/.config/mutt/muttrc

# My mutt configuration uses msmtp as its sendmail agent. Unfortunately,
# my paranoia against storing passwords on the hard disk complicates
# both programs' interplay: msmtp wants its SMTP password from
# somewhere, and that "somewhere" may be an interactive password prompt
# when msmtp is called directly from the command line; mutt, however,
# fails to provide such a prompt to msmtp. One alternative is to store
# the password in the config file; if you're not as paranoid as me, by
# all means do this and avoid my ugly workaround described below.
#
# <RANT>
# I am somewhat disappointed by this lack of interoperability between
# mutt and msmtp (the first letter of which, according to legend,
# betrays its orientation towards mutt). The developers of mutt
# seemingly have decided that bloating their mail user agent into a mail
# transfer agent is the solution (mutt has grown its own SMTP
# capabilities) and marked this interoperability issue "wontfix":
#
# http://dev.mutt.org/trac/ticket/2864
#
# To be fair, blame might also be directed against msmtp for failing to
# provide a simple "--password=" option or some such to accomodate
# password input from calling programs.
# </RANT>
#
# My workaround forces a password prompt on mutt from the outside once
# msmtp is called and delivers the result to the latter.
# 
# It involves msmtp's "--passwordeval=" option to receive the password
# from the output of a named command. Here I define a shell script that
# does two things: First it suspends the calling mutt process; then it
# waits for a file that contains the password to appear in /tmp/, reads
# it, deletes it and returns the password to msmtp. As msmtp learns of
# the password, its parent mutt will already be revived and returned to
# the foreground, due to the encapsulation of the mutt process into
# another shell script (through which alone mutt ought to be started)
# that waits for mutt's suspension, reacts to it by printing a password
# prompt, writes the received password into the aforementioned file in
# /tmp/ and then foregrounds mutt again. (This is implemented in a loop
# that ends once mutt is closed properly and not just suspended.)
#
# Anyway, here's to my two scripts just described:

cp $FILES/mutt_msmtp_break $MEHOME/.config/mutt/
chmod u+x $MEHOME/.config/mutt/mutt_msmtp_break
cp $FILES/mutt_msmtp_loop $MEHOME/.bin/

# Power management
# ----------------
#
# I use the "powertop" tool to oversee my power consumption:

pacman --noconfirm -S powertop

# Sound
# -----
#
# Set speaker volume to maximum and enable user to play sound by adding
# him to "audio" group.

pacman --noconfirm -S alsa-utils
gpasswd -a $ME audio
amixer set 'Speaker' 100% unmute
amixer set 'Master' 100% unmute
alsactl store

# Finishing touches
# -----------------
# Change ownership of files created in user home directory to user.

chown -R $ME:$ME $MEHOME

# Make all files in ~/.bin/ executable.

chmod u+x $MEHOME/.bin/*

# Update man pages database.

mandb -q

# Re-start for clean re-configuration of environment.

reboot
