#!/usr/bin/bash

while read -r line
do
        mkdir $line
        gau -subs $line >> $line/$line &
        assetfinder $line | grep -E '*' | waybackurls >> $line/$line &
        waybackurls $line >> $line/$line &
        assetfinder $line | grep -E '*' | httpx -silent >> $line/asset.$line & #1 nuclei
        wait

        cat $line/$line | sort | uniq | httpx -silent >> $line/httpx.$line #2 corsfinder
        rm $line/$line

        grep '=' $line/httpx.$line | qsreplace 'xsst"><>' >> $line/xss.$line #3 xssfinder

        cd $line
        python3 /root/hunting/xssfinder.py $line/xss.$line
        python3 /root/hunting/corsfinder.py $line/httpx.$line
        #nuclei -l asset.$line -t /root/hunting/recon/nuclei-templates >> nuclei
        cd ..
done < $1
