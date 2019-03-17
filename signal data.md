# signal data

https://physionet.org/physiobank/database/mimic3wdb/

## WFDB software (waveform database)

https://physionet.org/physiotools/wfdb.shtml

in particular, focus on the python toolkit 

https://physionet.org/physiobank/database/mimic3wdb/31/3141595/

### headers

first lines of the **master header** file, `3141595.hea.txt`

427 segments and gaps, 242353557 sample intervals (22 days at 125 samples per second)

```
3141595/427 7 125 242353557 10:02:51.840      
3141595_layout 0
3141595_0001 2888500     # segment 1, 2888500 sample intervals (6h15min+)
3141595_0002 534125
3141595_0003 250
3141595_0004 7250
...
3141595_0416 131125
3141595_0417 1913875
# Location: nicu
```



**layout** header file `3141595_layout.hea.txt` 

5 ECG, 1 repiration, 1 PPG signal (not all available simutanuously) 

```
3141595_layout 7 125 0 10:02:51.840
~ 0 646/mV 13 0 -3584 0 0 I
~ 0 1022/mV 13 0 -3584 0 0 II
~ 0 512(-258)/mV 11 0 -512 0 0 III
~ 0 510(-256)/mV 10 0 -1536 0 0 AVR
~ 0 510(-256)/mV 10 0 -1536 0 0 V
~ 0 515(-258)/pm 10 0 0 0 0 RESP
~ 0 1023(-512)/NU 10 0 0 0 0 PLETH
```



### individuals 

`3141595_0001.hea.txt` gives an overview of what's inside 0001 record: PPG, repiration, ECG2, AVR

```
3141595_0001 4 125 2888500 10:02:51.840
3141595_0001.dat 16 1023(0)/NU 10 512 470 -12412 0 PLETH
3141595_0001.dat 16 515(254)/pm 10 512 0 19668 0 RESP
3141595_0001.dat 16 510(256)/mV 10 512 565 13968 0 II
3141595_0001.dat 16 510(256)/mV 10 512 0 0 0 AVR
```



Signal is in `3141595_0001.dat`. 





### matching numerics: 3141595n 

`3141595n.hea.txt` shows that there's 1938730 intervals (22 days, 1 sample per second), contains heart rate, pulse, NBP (non invasive blood pressure - raw, systolic, diastolic, mean), respiration, sp02

```
3141595n 8 1 1938730 10:02:52
3141595n.dat 16 1/bpm 16 0 142 29726 0 HR
3141595n.dat 16 1/bpm 16 0 145 -25932 0 PULSE
3141595n.dat 16 1/mmHg 16 0 -32768 8715 0 NBP
3141595n.dat 16 1/mmHg 16 0 -32768 -14954 0 NBP Sys
3141595n.dat 16 1/mmHg 16 0 -32768 -26331 0 NBP Dias
3141595n.dat 16 1/mmHg 16 0 -32768 -11099 0 NBP Mean
3141595n.dat 16 1/pm 16 0 49 6171 0 RESP
3141595n.dat 16 1/% 16 0 95 29829 0 SpO2
# Location: nicu
```







## matched subset

https://physionet.org/physiobank/database/mimic3wdb/matched/#downloading-the-matched-subset

2.4TB



### download only this one patient p010013

https://physionet.org/physiobank/database/mimic3wdb/matched/p01/p010013/

in Data directory, 

```shell
mkdir -p MIMICwavep01
rsync -CaLvz physionet.org::mimic3wdb-matched/p01/p010013 MIMICwavep01
```

this will download only patient 10013. Note that not all patients have the corresponding waveforms. 



## Demo 

https://github.com/MIT-LCP/wfdb-python/blob/master/demo.ipynb

