STEP 2 – Integrate Jondo addon to firefox


This step can be divided into 3 parts.
1) Modification to 'jondoaddon' project
(pwd : /home/jenkins/workspace/JondoBrowser)
We make modifications so that this can be automatically built and integrated into firefox.

(1) Clone repository to local directory and rename it
git clone https://github.com/jondos/jondobrowser
mv jondobrowser jondoaddon-local
cd jondoaddon-local

(2) Modification to 'jondoaddon-local' repository
mv jondoaddon src

(3) Copy 'makexpi.sh' from 'torbutton' repository to 'jondoaddon-local' repository
cp /home/jenkins/workspace/JondoBrowser/tor-browser-build/git_clones/torbutton/makexpi.sh ./

(4) Commit current change to local repository.
git add *
git commit -m "jondoaddon-local repository fix"

(5) Give a tag(with current version name) to this commit.
git tag -a 1.9.5.13a 4f226da6cfb521ee15c3deffdee5f47fa6dd4450 -f

(6) Sign this tag and verify.
git config --local user.signingkey EE411C86
git tag -s 1.9.5.13a -m "signed by jondos developer" -f
git tag -v 1.9.5.13a




2) Modification to 'tor-browser-build' project
(pwd : /home/jenkins/workspace/JondoBrowser/tor-browser-build)
Here we need to delete 'torbutton', 'tor-launcher' projects and add 'jondoaddon' project to the build environment.

(1) ./projects/tor-browser/build
(replace the following lines. Delete - lines and add + lines instead) 

-   mv [% c('input_files_by_name/tor-launcher') %] $TBDIR/$EXTSPATH/tor-launcher@torproject.org.xpi
-   mv [% c('input_files_by_name/torbutton') %] $TBDIR/$EXTSPATH/torbutton@torproject.org.xpi
+   mv [% c('input_files_by_name/jondoaddon') %] $TBDIR/$EXTSPATH/info@jondos.de.xpi


(2) ./projects/tor-browser/config
(replace the following lines. Delete - lines and add + lines instead) 

-  - project: tor-launcher
-    name: tor-launcher
-  - project: torbutton
-    name: torbutton
+  - project: jondoaddon
+    name: jondoaddon


(3) ./projects/tor-launcher/
(delete this folder)

(4) rename 'torbutton' to 'jondoaddon'
(mv torbutton jondoaddon)

(5) ./projects/jondoaddon/config
...
version: 1.9.5.13a
git_url: /home/jenkins/workspace/JondoBrowser/jondoaddon-local/.git
...
gpg_keyring: tinkerbel.gpg
...




3) Modification to 'firefox-local' repository.
(pwd : /home/jenkins/workspace/JondoBrowser/firefox-local)
Here we need to modify firefox to accept and enable unsigned 'jondoaddon'.
Also delete all 'tor-launcher' related code.

(1) ./browser/app/profile/000-tor-browser.js
(add jondoaddon to enabled anddons list)
-pref("extensions.enabledAddons", "https-everywhere%40eff.org:3.1.4,%7B73a6fe31-595d-460b-a920-fcc0f8843232%7D:2.6.6.1,torbutton%40torproject.org:1.5.2,ubufox%40ubuntu.com:2.6,tor-launcher%40torproject.org:0.1.1pre-alpha,%7B972ce4c6-7e08-4474-a285-3208198ce6fd%7D:17.0.5");
+pref("extensions.enabledAddons", "https-everywhere%40eff.org:3.1.4,%7B73a6fe31-595d-460b-a920-fcc0f8843232%7D:2.6.6.1,info%40jondos.de:1.9.5.13a,ubufox%40ubuntu.com:2.6,%7B972ce4c6-7e08-4474-a285-3208198ce6fd%7D:17.0.5");

(2) ./browser/components/nsBrowserGlue.js
           if ((addon.signedState <= AddonManager.SIGNEDSTATE_MISSING) &&
-              !(addon.id == "torbutton@torproject.org" ||
-                addon.id == "tor-launcher@torproject.org" ||
+              !(addon.id == "info@jondos.de" ||
                 addon.id == "https-everywhere-eff@eff.org")) {

(3) ./tbb-tests/browser_tor_TB4.js
-   ["extensions.enabledAddons", "https-everywhere%40eff.org:3.1.4,%7B73a6fe31-595d-460b-a920-fcc0f8843232%7D:2.6.6.1,torbutton%40torproject.org:1.5.2,ubufox%40ubuntu.com:2.6,tor-launcher%40torproject.org:0.1.1pre-alpha,%7B972ce4c6-7e08-4474-a285-3208198ce6fd%7D:17.0.5"],
+   ["extensions.enabledAddons", "https-everywhere%40eff.org:3.1.4,%7B73a6fe31-595d-460b-a920-fcc0f8843232%7D:2.6.6.1,info%40jondos.de:1.9.5.13a,ubufox%40ubuntu.com:2.6,%7B972ce4c6-7e08-4474-a285-3208198ce6fd%7D:17.0.5"],


(4) ./toolkit/mozapps/extensions/content/extensions.js
-  if (aAddon.id == "torbutton@torproject.org" ||
-      aAddon.id == "tor-launcher@torproject.org" ||
+  if (aAddon.id == "info@jondos.de" ||
       aAddon.id == "https-everywhere-eff@eff.org") {

(5) ./toolkit/mozapps/extensions/internal/XPIProvider.jsm
-  if (aAddon.id == "torbutton@torproject.org" ||
-      aAddon.id == "tor-launcher@torproject.org" ||
+  if (aAddon.id == "info@jondos.de" ||
       aAddon.id == "https-everywhere-eff@eff.org" ||
       aAddon.id == "meek-http-helper@bamsoftware.com") {
...
-            addon.id != "torbutton@torproject.org" &&
-            addon.id != "tor-launcher@torproject.org" &&
+            addon.id != "info@jondos.de" &&

(6) ./toolkit/xre/nsAppRunner.cpp
-  uriString.Append("extensions/torbutton@torproject.org.xpi");
+  uriString.Append("extensions/info@jondos.de.xpi");
...
-  uriString.Append("profile.default/extensions/torbutton@torproject.org.xpi");
+  uriString.Append("profile.default/extensions/info@jondos.de.xpi");



Done.
Now we need to do a clean build.
Remove these folders and make.
(pwd : /home/jenkins/workspace/JondoBrowser/tor-browser-build)
alpha, git_clones, logs, out