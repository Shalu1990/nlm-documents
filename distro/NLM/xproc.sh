#!/bin/sh

cp="calabash-1.0.2-94/calabash.jar:saxon/saxon9he.jar"
java -cp $cp -Dcom.xmlcalabash.phonehome=false com.xmlcalabash.drivers.Main $*
