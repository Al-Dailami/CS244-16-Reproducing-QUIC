# CS244-16-Reproducing-QUIC
Once you've cloned this directory, make sure that hardware virtualization is enabled on your computer. You can configure this setting in BIOS. Then configure the VM to have at least two cores in VirtualBox settings.

You can choose not to do this, but the QUIC client will have somewhat lower throughput because it is CPU-bound.

Now, go to the experiment_scripts directory and run ./run_test.sh. You'll be prompted for the root password, which is "password". After you've done that, check the graphs folder to see all the relevant results.

If you'd like to run the full experiment, rather than just the graphs in the blog, then go into the run_test script and uncomment the longer DELAY and BANDWIDTH lists. Note that this takes around 12 hours to run.