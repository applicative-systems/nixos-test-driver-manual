# Graphical VMs and OCR

Let's test something with [optical character recognition](https://en.wikipedia.org/wiki/Optical_character_recognition) (OCR) in a graphical VM.

In this scenario, we define a machine `server` that serves the standard [Apache HTTP server](https://httpd.apache.org/) _"It works!"_ page.
On the second machine, `client`, we run [Mozilla Firefox](https://www.firefox.com) to display this page and test if the text is really visible on the graphical desktop.

```nix title="browser.nix"
--8<-- "examples/browser.nix"
```

1.  **Enabling OCR**

    This setting adds `tesseract` and `imagemagick` to the test driver closure.
    It is not enabled by default to reduce the closure for non-graphical tests, which are the majority.

2.  **Configuring the desktop**

    This profile is commonly used among graphical tests in nixpkgs and configures a small desktop environment with auto login.

    Importing this file is not mandatory - we can always configure this ourselves.

3.  **Resolution settings**

    We reduce the display resolution to result in fewer pixels, which in turn reduces the resource usage of the Tesseract OCR analysis.
