# Gabriele
Simple audio signal visualizer

Gabriele is built in pure Processing(using Java language of version 7). 

# Features

Gabriele has the following features:
* viewing spectrum of sound played back in real time; 
  there are three supported types of spectrum:
    * linear standard spectrum,
    * linear average spectrum,
    * logarthimic average spectrum,
    * standard linear spectrum modulated using sine function.
* changing type of a window used to sample the audio signal,
* drawing x and y axis so you can easily read the amplitued in dB and frequency in Hz.

# Planned features

I want to add some features like osciloscope to generate harmonical singals like sine, triangular etc. with drawing plot of this signal while viewing its sepctrum. Another feature I want to add is recording modulated signal to the WAV file. Last in the queue is some sort of prefferences panel and writing settings, but I will do it for sure, using JSON of course.

# Technical notes

Gabriele is released for: 
- [x] Windows,
- [x] GNU/Linux.



Gabriele is 64-bit __only__. Built and compiled using Processing 3 with Java 1.8u161.

Tests:
- Windows 10 x64 Pro on Java 1.8u161
- Ubuntu 17.10 x64 - in plans
- Linux Mint 18.3

**Note**: There is a thing with Linux OS. You need to "play" with you alsa mixer to see that there is actually a signal on the sound card. The thing is that if you set a source it not realyl needs to be a sink of master so pay attention to it. In my case it worked properly for Headphones source and Analog Audio Output source with Master and Capture L R set to max. 
If Master is muted or the source is not connected to OS's master and Capture is active, it will appear as a noise visible in the app.

# Download
The newest copy of natalie commpressed to .zip file with included Java 1.8u161 is accessible on my server under the [url](http://fms.lukas-bownik.net/File/Download/1). If for some reason you can't download it, please write me an issue in this repo. 
