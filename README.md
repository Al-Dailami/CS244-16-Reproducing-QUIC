# CS244-16-Reproducing-QUIC
Once you've cloned this directory, make sure that hardware virtualization is enabled on your computer. You can configure this setting in BIOS. Then configure the VM to have at least two cores in VirtualBox settings.

You can choose not to do this, but the QUIC client will have somewhat lower throughput because it is CPU-bound.

Now, go to the experiment_scripts directory and run ./run_test.sh. After you've done that, check the graphs folder to see all the relevant results.