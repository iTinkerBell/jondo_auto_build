STEP 1 – Update Enabled
prerequisite: README from 'torupdates', 'tor-browser-build' repositories should be exactly followed before trying the following steps.

This step can be divided into 4 parts.
1) tor-browser
tor-browser can be cloned from https://git.torproject.org/tor-browser.git 
This repository cannot be used directly.
The following steps must be exactly carried out.

(1) Clone source repository to local directory

cd /home/jenkins/workspace/JondoBrowser
git clone https://git.torproject.org/tor-browser.git
mv tor-browser firefox-local
cd firefox-local

(2) Modify tor-browser source code 
(pwd: /home/jenkins/workspace/JondoBrowser/firefox-local)

./browser/app/profile/firefox.js
Find “app.update.url” and replace the whole line with the following.

pref("app.update.url", "http://148.251.13.82/%CHANNEL%/%BUILD_TARGET%/%VERSION%/%LOCALE%");

./toolkit/mozapps/update/updater/archivereader.cpp
Find function “ArchiveReader::VerifySignature()” and replace it with the following code.

ArchiveReader::VerifySignature()
{
  if (!mArchive) {
    return ARCHIVE_NOT_OPEN;
  }
  return OK;
}

(3) Commit to tor-browser local repository

git add browser/app/profile/firefox.js toolkit/mozapps/update/updater/archivereader.cpp
git commit -m "archivereader.cpp updated"

(4) Copy hash value for this commit

git log

Current output is:
commit 13b28f9a3582f6c7b044a3fcb71bcaf2040decfb
Author: Oliver Meyer <oliver.meyer@jondos.de>
Date:   Sat Apr 29 19:59:55 2017 +0200

    archivereader.cpp updated
...

Find the last commit with the "archivereader.cpp updated" message, e.g. 13b28f9a3582f6c7b044a3fcb71bcaf2040decfb

(5) Put a tag for this commit
Current tor-browser-build project (7.0a3) uses 'tor-browser-52.1.0esr-7.0-2-build1' commit to build tor browser.
We need to put this tag to our commit to successfully build tor browser.
We use hash value obtained in (4).

git tag -a tor-browser-52.1.0esr-7.0-2-build1 13b28f9a3582f6c7b044a3fcb71bcaf2040decfb -f

(6) Sign this commit with gpg
- Check for existing key

gpg --list-keys

If there exists a key, output looks like this, and we can skip to the last step in (6)
Here we need public fingerprint, e.g. EE411C86

/root/.gnupg/pubring.gpg
------------------------
pub   2048R/EE411C86 2017-04-28
uid                  Oliver Meyer ("My secret key") <oliver.meyer@jondos.de>
sub   2048R/C1131EAC 2017-04-28

- Generate a key

gpg --gen-key

- Configure tor-browser local repository to use this key
We use public fingerprint previously obtained.

git config --local user.signingkey EE411C86

- Sign the last commit with this key and check its status

git tag -s tor-browser-52.1.0esr-7.0-2-build1 -m "JonDoFox developer" -f
git tag -v tor-browser-52.1.0esr-7.0-2-build1

Is successful, the output should contain "Good signature"




2) tor-browser-build
tor-browser-build can be cloned from https://git.torproject.org/builders/tor-browser-build.git
This repository cannot be used directly.
The following steps must be exactly carried out.

(1) Clone repository

cd /home/jenkins/workspace/JondoBrowser
git clone https://git.torproject.org/builders/tor-browser-build.git
cd tor-browser-build

(2) Copy keyring to project
(pwd: /home/jenkins/workspace/JondoBrowser/tor-browser-build)

cp /root/.gnupg/pubring.gpg ./keyring/tinkerbel.gpg

(3) Modify project configuration (firefox)
(pwd: /home/jenkins/workspace/JondoBrowser/tor-browser-build)

Open ./projects/firefox/config and edit the following lines.

git_url: /home/jenkins/workspace/JondoBrowser/firefox-local/.git
gpg_keyring: tinkerbel.gpg




3) torupdates
torupdates can be cloned from https://github.com/lancerajee/torupdates.git
A few lines should be changed.

(1) Clone repository

cd /var/www
git clone https://github.com/lancerajee/torupdates.git
cd torupdates

(2) Edit config.yml
(pwd: /var/www/torupdates)

releases_dir:  /var/www/torupdates/htdocs/torbrowser
download:
    ...
    bundles_url: http://148.251.13.82/torbrowser
    mars_url: http://148.251.13.82/torbrowser
build_targets:
    linux32: Linux_x86-gcc3
    linux64: Linux_x86_64-gcc3
    win32:
        - WINNT_x86-gcc3
        - WINNT_x86-gcc3-x86
        - WINNT_x86-gcc3-x64
    osx32: Darwin_x86-gcc3
    osx64: Darwin_x86_64-gcc3
channels:
    alpha: 7.0a3
    #release: 6.5n
    #nightly: 6.5n
versions:
    7.0a3:
        platformVersion: 52.1.0
        ...
        incremental_from:
          - 6.5n

4) Configure apache2 server to enable rewrite module

cd /etc/apache2/mods/available
a2enmod rewrite


Finally, we can build and deploy tor-browser with update link to 148.251.13.82

cd /home/jenkins/workspace/JondoBrowser/tor-browser-build
make alpha
cp -r alpha/unsigned/7.0a3/ /var/www/torupdates/htdocs/torbrowser
cd /var/www/torupdates
./update_reponses
service apache2 restart

Now, we can visit 148.251.13.82 and donwload 6.5n for testing.
After installing 6.5n, click 'About Tor Browser'.
It should start downloading update package.
After restarting browser, a new version 7.0a3 is installed.