# Maggie
Simple audio signal visualizer

Maggie is built in pure Processing(using Java language of version 7). 

# Features

Maggie has the following features:
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

Maggie is released for: 
- [x] Windows,
- [ ] GNU/Linux. - I'm gonna start testing version for this OS in no time. 
Maggie is 64-bit __only__. Built and compiled using Processing 3 with Java 1.8u161.

Tests:
- Windows 10 x64 Pro on Java 1.8u161
- Ubuntu 17.10 x64 - in plans.

# Download
The newest copy of natalie commpressed to .zip file with included Java 1.8u161 is accessible on my server under the [url](http://fms.lukas-bownik.net/File/Download/1). If for some reason you can't download it, please write me an issue in this repo. 
