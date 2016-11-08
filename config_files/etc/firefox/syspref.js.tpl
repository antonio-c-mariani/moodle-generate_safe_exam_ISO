// Set default homepage - users can change
lockPref("browser.startup.homepage", "%exam_server_url%");

// The URL that Firefox goes to when the user starts up the browser after the initial installation, or with a new profile
lockPref("startup.homepage_welcome_url", "");

// The URL that Firefox goes to when the user starts up the browser after upgrading.
lockPref("startup.homepage_override_url", "");

// Don't show WhatsNew on first run after every update
lockPref("browser.startup.homepage_override.mstone","ignore");

// Ask where to save every file
lockPref("browser.download.useDownloadDir", false);

// Disable updater
lockPref("app.update.enabled", false);

// Disable password save
lockPref("signon.rememberSignons", false);

// Autoconfig file (see /usr/lib/firefox/ directory)
lockPref("general.config.filename", "firefox.cfg");

// Turn off the obfuscation of config file
lockPref("general.config.obscure_value", 0);
