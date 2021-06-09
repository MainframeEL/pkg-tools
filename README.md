A quick helper for getting a Mainframe Enterprise Linux package maintainer build development
configuration setup.

## Installation
From this source directory, run the following commands:


```
    make
    sudo make install
```

This installation will automatically install `nginx` and will configure a
local repository to be run and usable at: /usr/share/nginx/html/repo

note: The permissions on this repository are wide open, so please tune if
you are on a shared system.


## Getting and building a Sun/OS Linux package
Once these tools are installed, you will be able to do the following:

```
    melget sed
    melbuild sed
```

This will create a directory structure at `~/mel/` and you will be able
to find the RPM sources as well as the build directory, logs, and
artificats there.

## Debugging and patching packages
When build errors happen, and you need to create a patch for a package,
you can use the following example to get you going:

```
    # Creates a working directory, will take optional branch
    melprep sed
    cd ~/mel/_work/sed/*

    # A build error exists when running in nspawn container on the builder
    # for this test, so let's "exit 0" near the top...
    vim testsuite/inplace-selinux.sh

    # Create a patch configuration from the working directory and name the
    # patch file. This will create the patch, integrate it into the SPEC
    # file, and "reget" the sed package. If you need to edit or view the
    # Proto3 config and patch, it can be found here: ~/mel/patch/sed/r8/
    sunpatch inplace-selinux-notest.patch

    # Now you can test your build
    melbuild sed

```
